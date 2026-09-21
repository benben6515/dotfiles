// Jev model router — `/route <task>` classifies the task with TypeSafe's Jev
// (OpenCode Zen System One endpoint) and switches the session between
// GLM-5.3-Flash (fast/cheap) and GLM-5.3 (stronger) before submitting.
// Fails open to flash (the usual default) if Jev is unavailable.
//
// Note: per-message auto-routing is not possible — the prompt hook runs
// before model resolution and cannot change the model. Explicit /route
// command is the supported path.
import { readFileSync } from "node:fs"

const ZEN_URL = "https://opencode.ai/zen/v1/systemone"
const MODEL_JEV = "jev-1.13"
const KEY_FILE = `${process.env.HOME}/.local/share/loop/zen.key`
const LIGHT = { providerID: "opencode-go", id: "mimo-v2.5" }
const FAST = { providerID: "opencode", id: "glm-5.3-flash" }
const FULL = { providerID: "opencode", id: "glm-5.3" }
const TIMEOUT_MS = 10_000

function apiKey(): string {
  if (process.env.OPENCODE_API_KEY) return process.env.OPENCODE_API_KEY
  try {
    return readFileSync(KEY_FILE, "utf8").trim()
  } catch {
    return ""
  }
}

async function pickModel(promptText: string): Promise<{ providerID: string; id: string } | undefined> {
  const key = apiKey()
  if (!key) return undefined
  try {
    const res = await fetch(ZEN_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
        "User-Agent": "opencode-jev-route/1.0",
      },
      body: JSON.stringify({
        model: MODEL_JEV,
        state: promptText.slice(0, 4000),
        questions: {
          tier: {
            type: "choice",
            instructions: "Pick the smallest model tier that can handle this coding agent task well.",
            criteria: {
              light: "Trivia, arithmetic, quick facts, one-word or one-line answers, tiny text transformations, simple classification.",
              fast: "Coding lookups, explanations, small localized edits, formatting, simple one-file scripts.",
              full: "Multi-file refactors, architecture design, hard debugging, long multi-step plans, high-stakes changes.",
            },
          },
        },
      }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    })
    if (!res.ok) return undefined
    const data = (await res.json()) as { answers?: { tier?: { choice?: string } } }
    switch (data.answers?.tier?.choice) {
      case "light": return LIGHT
      case "full": return FULL
      case "fast": return FAST
      default: return undefined
    }
  } catch {
    return undefined
  }
}

export default {
  id: "jev-route",
  async setup(ctx) {
    // Pre-message auto-routing: classify every admitted user prompt with Jev
    // and switch the session model before model resolution happens (prompt
    // hooks complete before admission, resolution runs after admission).
    // Slash commands are skipped — they route themselves (/route).
    // Jev failure fails open: session keeps its current model.
    await ctx.session.hook("prompt", async (event) => {
      const text = event.prompt.text
      if (text.startsWith("/")) return
      try {
        const model = await pickModel(text)
        if (model) await ctx.session.switchModel({ sessionID: event.sessionID, model })
      } catch {
        // fail open: keep the session's current model
      }
    })

    await ctx.command.transform((editor) => {
      editor.add({
        name: "route",
        description: "Jev 分類任務複雜度，自動選 GLM-5.3-Flash 或 GLM-5.3 執行",
        execute: async ({ sessionID, prompt, delivery }) => {
          const model = (await pickModel(prompt.text)) ?? FAST
          await ctx.session.switchModel({ sessionID, model })
          await ctx.session.prompt({ ...prompt, sessionID, delivery })
        },
      })
    })
  },
}
