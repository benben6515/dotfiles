// vibeguard — OpenCode V2 plugin (ported from opencode-vibeguard 0.1.0, which
// used the V1 plugin API and no longer loads on OpenCode 2.x).
//
// Redacts configured sensitive strings into placeholders before any model
// request, and restores them locally:
//   - ctx.session.hook("context" | "compaction" | "generate" | "title"):
//     redact outgoing messages (provider never sees plaintext; persisted
//     history is untouched)
//   - ctx.session.hook("http.response"): restore placeholders in streamed /
//     buffered provider responses so the TUI shows real values
//   - ctx.tool.hook("execute.before"): restore placeholders in tool args so
//     local tools run with real values
//
// Reuses the upstream src/ modules unchanged (config, patterns, session,
// engine, deep, restore). No-op when no vibeguard.config.json is found or
// enabled=false, same as upstream.

import { loadConfig, type VibeGuardConfig } from "./src/config.ts"
import { buildPatternSet, type PatternSet } from "./src/patterns.ts"
import { PlaceholderSession } from "./src/session.ts"
import { redactText, type RedactSession } from "./src/engine.ts"
import { redactDeep, restoreDeep } from "./src/deep.ts"
import { restoreText, type RestoreSession } from "./src/restore.ts"

// Longest placeholder we generate: "__VG_" + category + "_" + 12 hex + "__".
// Keep generous headroom; shortens output latency by one chunk at worst.
const STREAM_HOLD_CHARS = 64

type AnyRecord = Record<string, any>

// Generic walker: redact text/reasoning parts and tool states wherever they
// appear in the message structure, without assuming a specific schema.
function redactNode(
  node: AnyRecord | any[] | null | undefined,
  patterns: PatternSet,
  session: RedactSession,
  stats: { changed: number },
): void {
  if (!node || typeof node !== "object") return
  if (Array.isArray(node)) {
    for (const item of node) redactNode(item, patterns, session, stats)
    return
  }

  const type = node.type
  if ((type === "text" || type === "reasoning") && typeof node.text === "string") {
    if (node.ignored === true) return
    const after = redactText(node.text, patterns, session).text
    if (after !== node.text) {
      node.text = after
      stats.changed++
    }
    return
  }
  if (type === "tool" && node.state && typeof node.state === "object") {
    const state = node.state
    if (state.input && typeof state.input === "object") redactDeep(state.input, patterns, session)
    for (const key of ["output", "error", "raw"]) {
      if (typeof state[key] === "string") {
        const after = redactText(state[key], patterns, session).text
        if (after !== state[key]) {
          state[key] = after
          stats.changed++
        }
      }
    }
    return
  }

  for (const value of Object.values(node)) {
    if (value && typeof value === "object") redactNode(value, patterns, session, stats)
  }
}

// Restore placeholders in a provider response body. SSE bodies are streamed
// through with a small holdback window so placeholders split across chunk
// boundaries still resolve; other bodies are buffered.
function restoreResponseBody(
  body: any,
  session: RestoreSession,
  isStream: boolean,
): any {
  if (!isStream) {
    return body.then == null ? body : body.then((text: unknown) => restoreText(String(text), session))
  }

  const decoder = new TextDecoder()
  const encoder = new TextEncoder()
  let carry = ""
  return body.pipeThrough(
    new TransformStream({
      transform(chunk: Uint8Array, controller: TransformStreamDefaultController<Uint8Array>) {
        carry += decoder.decode(chunk, { stream: true })
        if (carry.length <= STREAM_HOLD_CHARS) return
        const emit = carry.slice(0, -STREAM_HOLD_CHARS)
        carry = carry.slice(-STREAM_HOLD_CHARS)
        controller.enqueue(encoder.encode(restoreText(emit, session)))
      },
      flush(controller: TransformStreamDefaultController<Uint8Array>) {
        carry += decoder.decode()
        if (carry) controller.enqueue(encoder.encode(restoreText(carry, session)))
      },
    }),
  )
}

export default {
  id: "vibeguard",
  async setup(ctx: any) {
    const directory = ctx.location?.directory ?? process.cwd()
    const config: VibeGuardConfig = await loadConfig(directory)
    const debug = Boolean(process.env.OPENCODE_VIBEGUARD_DEBUG) || Boolean(config.debug)

    if (debug) {
      const from = config.loadedFrom ? config.loadedFrom : "not found (plugin is a no-op)"
      console.log(`[opencode-vibeguard] config: ${from} enabled=${config.enabled}`)
    }
    if (!config.enabled) return

    const patterns = buildPatternSet(config.patterns)
    const sessions = new Map<string, PlaceholderSession>()

    const getSession = (sessionID: unknown): PlaceholderSession => {
      const key = String(sessionID ?? "") || "__default__"
      const existing = sessions.get(key)
      if (existing) return existing
      const created = new PlaceholderSession({
        prefix: config.prefix,
        ttlMs: config.ttlMs,
        maxMappings: config.maxMappings,
      })
      sessions.set(key, created)
      return created
    }

    const redactMessages = (event: AnyRecord | null | undefined) => {
      if (!event || !Array.isArray(event.messages) || event.messages.length === 0) return
      const session = getSession(event.sessionID)
      session.cleanup()
      const stats = { changed: 0 }
      for (const message of event.messages) redactNode(message, patterns, session, stats)
      if (debug && stats.changed > 0) {
        console.log(`[opencode-vibeguard] redacted ${stats.changed} part(s) before ${event.kind ?? "context"} request`)
      }
    }

    // Redact every model-request kind: the agent loop, compaction summaries,
    // transient generate calls, and title generation all replay history.
    for (const kind of ["context", "compaction", "generate", "title"]) {
      await ctx.session.hook(kind, redactMessages)
    }

    // Restore placeholders coming back from the provider (live output).
    await ctx.session.hook("http.response", (event: AnyRecord | null | undefined) => {
      const response = event?.response
      if (!response || !response.body) return
      const session = getSession(event.sessionID)
      session.cleanup()
      const contentType = response.headers?.get?.("content-type") ?? ""
      const isStream = contentType.includes("text/event-stream")
      const body = isStream ? response.body : response.text()
      event.response = new Response(restoreResponseBody(body, session, isStream), {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers,
      })
      if (debug) console.log("[opencode-vibeguard] restored placeholders in provider response")
    })

    // Restore real values in tool args before local execution.
    // opencode V2 passes tool input as a frozen object; mutating it throws
    // "Attempted to assign to readonly property". restoreDeep is pure, so
    // replace event.input wholesale instead of writing into it.
    await ctx.tool.hook("execute.before", (event: AnyRecord | null | undefined) => {
      const session = getSession(event?.sessionID)
      session.cleanup()
      if (event?.input && typeof event.input === "object") {
        event.input = restoreDeep(event.input, session)
      }
    })
  },
}
