export interface KeywordRule {
  value: string
  category: string
}

export interface RegexRule {
  pattern: string
  flags: string
  category: string
}

export interface PatternSet {
  keywords: KeywordRule[]
  regex: RegexRule[]
  exclude: Set<string>
}

function sanitizeCategory(input: unknown): string {
  const raw = String(input ?? "").trim()
  if (!raw) return "TEXT"
  const upper = raw.toUpperCase()
  const safe = upper.replace(/[^A-Z0-9_]/g, "_").replace(/_+/g, "_")
  if (!safe) return "TEXT"
  return safe
}

/**
 * 将 Go 风格的 `(?i)` / `(?m)` 前缀做一个轻量兼容（仅处理“开头连续出现”的情况）。
 */
function peelInlineFlags(pattern: unknown, flags: unknown): { pattern: string; flags: string } {
  let p = String(pattern ?? "")
  let f = String(flags ?? "")

  for (;;) {
    if (p.startsWith("(?i)")) {
      p = p.slice(4)
      if (!f.includes("i")) f += "i"
      continue
    }
    if (p.startsWith("(?m)")) {
      p = p.slice(4)
      if (!f.includes("m")) f += "m"
      continue
    }
    break
  }

  return { pattern: p, flags: f }
}

/**
 * 内置规则：从 VibeGuard 的 builtin 规则移植（做了 JS 兼容调整）。
 * 目标是“低配置成本 + 尽量覆盖”，不追求 100% 精准。
 */
const BUILTIN = new Map<string, RegexRule>([
  [
    "email",
    {
      pattern: String.raw`[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}`,
      flags: "i",
      category: "EMAIL",
    },
  ],
  [
    "china_phone",
    {
      // 直接匹配手机号本体（用 lookaround 替代 Go 里的捕获组边界保留写法）
      pattern: String.raw`(?<!\d)1[3-9]\d{9}(?!\d)`,
      flags: "",
      category: "CHINA_PHONE",
    },
  ],
  [
    "china_id",
    {
      pattern: String.raw`(?<!\d)\d{17}[\dXx](?!\d)`,
      flags: "",
      category: "CHINA_ID",
    },
  ],
  [
    "uuid",
    {
      pattern: String.raw`[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}`,
      flags: "",
      category: "UUID",
    },
  ],
  [
    "ipv4",
    {
      // 不校验每段 0-255；目标是覆盖常见情况
      pattern: String.raw`(?:\d{1,3}\.){3}\d{1,3}`,
      flags: "",
      category: "IPV4",
    },
  ],
  [
    "mac",
    {
      pattern: String.raw`(?:[0-9a-f]{2}:){5}[0-9a-f]{2}`,
      flags: "i",
      category: "MAC",
    },
  ],
])

export function buildPatternSet(patterns: unknown): PatternSet {
  const raw = patterns && typeof patterns === "object" ? (patterns as Record<string, unknown>) : {}

  const keywords = Array.isArray(raw.keywords) ? raw.keywords : []
  const regex = Array.isArray(raw.regex) ? raw.regex : []
  const builtin = Array.isArray(raw.builtin) ? raw.builtin : []
  const exclude = Array.isArray(raw.exclude) ? raw.exclude : []

  const keywordRules = keywords
    .map((x): KeywordRule | null => {
      if (!x || typeof x !== "object") return null
      const item = x as Record<string, unknown>
      const value = String(item.value ?? "").trim()
      if (!value) return null
      const category = sanitizeCategory(item.category)
      return { value, category }
    })
    .filter((x): x is KeywordRule => x !== null)

  const regexRules: RegexRule[] = []

  for (const x of regex) {
    if (!x || typeof x !== "object") continue
    const item = x as Record<string, unknown>
    const pattern = String(item.pattern ?? "").trim()
    if (!pattern) continue
    const category = sanitizeCategory(item.category)
    const flags = typeof item.flags === "string" ? item.flags : ""
    const peeled = peelInlineFlags(pattern, flags)
    regexRules.push({ pattern: peeled.pattern, flags: peeled.flags, category })
  }

  for (const name of builtin) {
    const key = String(name ?? "").trim()
    if (!key) continue
    const rule = BUILTIN.get(key)
    if (!rule) continue
    regexRules.push({ pattern: rule.pattern, flags: rule.flags, category: rule.category })
  }

  const excludeSet = new Set(exclude.map((x) => String(x ?? "")))

  return {
    keywords: keywordRules,
    regex: regexRules,
    exclude: excludeSet,
  }
}
