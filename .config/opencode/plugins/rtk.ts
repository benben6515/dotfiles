import { execFileSync } from "node:child_process"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.
//
// Ported to the OpenCode V2 plugin API (default export with id + setup,
// ctx.tool.hook replaces the V1 "tool.execute.before" hook key).

export default {
  id: "rtk",
  async setup(ctx) {
    try {
      execFileSync("rtk", ["--version"], { stdio: "ignore" })
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", (event) => {
      const tool = String(event?.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const input = event?.input
      if (!input || typeof input !== "object") return

      const command = (input as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      try {
        const rewritten = execFileSync("rtk", ["rewrite", command], {
          encoding: "utf8",
        }).trim()
        if (rewritten && rewritten !== command) {
          // opencode V2 tool input may be frozen — replace the whole input
          // object instead of assigning into it.
          event.input = { ...input, command: rewritten }
        }
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    })
  },
}
