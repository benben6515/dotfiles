// Jev high-stakes gate — before bash runs a risky command (git push,
// pulumi up/destroy/refresh, terraform apply/destroy), send the command
// plus a git summary to Jev and ask one noul question: is this
// high-stakes? Score >= THRESHOLD blocks the tool call with a reason.
//
// Fail open: Jev down / timeout / unparseable → allow (and log). The gate
// must never brick workflows because the classifier is unavailable.
//
// Bypass: touch ~/.local/share/loop/jev-gate.allow — valid 10 minutes,
// for deliberate prod deploys after the user confirms.
//
// Known ceiling: sees only the command + diff stat + last 5 commit
// subjects, not full diff content. ponytail: full diff (truncated) if
// misclassifications show up.
import { appendFileSync, readFileSync, statSync } from "node:fs"

const ZEN_URL = "https://opencode.ai/zen/v1/systemone"
const MODEL_JEV = "jev-1.13"
const KEY_FILE = `${process.env.HOME}/.local/share/loop/zen.key`
const LOG_FILE = `${process.env.HOME}/.local/share/loop/jev-route.log`
const ALLOW_FILE = `${process.env.HOME}/.local/share/loop/jev-gate.allow`

const TIMEOUT_MS = 4_000
const THRESHOLD = 0.6
const ALLOW_WINDOW_MS = 10 * 60_000

// Deliberately narrow: only commands that ship or destroy state. Extend
// here if a new class of risky command shows up.
const RISKY = /\bgit push\b|\bpulumi\s+(up|destroy|refresh)\b|\bterraform\s+(apply|destroy)\b/

function logLine(msg: string): void {
  try {
    appendFileSync(LOG_FILE, `${new Date().toISOString()} [gate] ${msg}\n`)
  } catch { }
}



function apiKey(): string {
  // Key source is ONLY the key file. OPENCODE_API_KEY is off-limits:
  // opencode injects its own unrelated key into that name.
  try {
    return readFileSync(KEY_FILE, "utf8").trim()
  } catch {
    return ""
  }
}

async function run(cwd: string, args: string[]): Promise<string> {
  const p = Bun.spawn(args, { cwd, stdout: "pipe", stderr: "ignore" })
  return await new Response(p.stdout).text()
}

async function changeSummary(cmd: string, cwd: string): Promise<string> {
  const parts = [`command: ${cmd}`]
  for (const args of [
    ["git", "--no-pager", "diff", "HEAD", "--stat"],
    ["git", "--no-pager", "log", "--oneline", "-5"],
  ]) {
    try {
      const out = (await run(cwd, args)).trim()
      if (out) parts.push(`\n$ ${args.join(" ")}\n${out}`)
    } catch { }
  }
  return parts.join("\n").slice(0, 3000)
}

async function highStakesScore(
  cmd: string,
  cwd: string,
  key: string,
): Promise<number | null> {
  try {
    const res = await fetch(ZEN_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
        "User-Agent": "opencode-jev-gate/1.0",
      },
      body: JSON.stringify({
        model: MODEL_JEV,
        state: await changeSummary(cmd, cwd),
        questions: {
          high_stakes: {
            type: "noul",
            instructions:
              "Is this a high-stakes, hard-to-reverse operation — production " +
              "deploy, destructive infrastructure change, shared-history " +
              "rewrite, forced push, or likely data loss? Answer close to 1 " +
              "only for genuinely dangerous situations; routine " +
              "feature-branch pushes are close to 0.",
          },
        },
      }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    })
    if (!res.ok) {
      logLine(`HTTP ${res.status} from ${ZEN_URL}: ${cmd}`)
      return null
    }
    const data = (await res.json()) as {
      answers?: { high_stakes?: { noul?: number } }
    }
    const score = data.answers?.high_stakes?.noul
    return typeof score === "number" ? score : null
  } catch (e) {
    logLine(`fail-open (${e instanceof Error ? e.message : String(e)}): ${cmd}`)
    return null
  }
}

export const JevGate = async ({ directory }: { directory: string }) => {
  return {
    "tool.execute.before": async (
      input: { tool: string },
      output: { args: { command?: string } },
    ) => {
      if (input.tool !== "bash") return
      const cmd = String(output.args.command ?? "")
      if (!RISKY.test(cmd)) return
      // Prefer the tool call's own working dir: the session may run in a
      // linked worktree, while `directory` is the project root the plugin
      // loaded with — the diff summary must come from where the command
      // will actually run.
      const cwd = String(output.args.workdir ?? directory)
      try {
        const st = statSync(ALLOW_FILE)
        if (Date.now() - st.mtimeMs < ALLOW_WINDOW_MS) {
          logLine(`allow (bypass window active): ${cmd}`)
          return
        }
      } catch { }
      const key = apiKey()
      if (!key) return
      const score = await highStakesScore(cmd, cwd, key)
      if (score === null) return
      if (score >= THRESHOLD) {
        logLine(`BLOCK (${score.toFixed(2)}): ${cmd}`)
        // No bypass instructions here on purpose: the agent could run them
        // itself (touch isn't a RISKY command) and self-approve. Bypass is
        // user-only, documented in ~/ai/loop/NOTE.md.
        throw new Error(
          `⛔ Jev gate 判定這是高風險操作（score ${score.toFixed(2)} >= ${THRESHOLD}），已阻擋: ${cmd}。` +
          `請停止執行，向使用者說明變更內容與風險；只有使用者親自確認後才能放行` +
          `（放行方式見 ~/ai/loop/NOTE.md 的 jev-gate 段，或由使用者在自己終端執行該指令）。`,
        )
      }
    },
  }
}
