import type { PatternSet } from "./patterns.ts"

export interface Span {
  start: number
  end: number
}

interface FoundMatch {
  start: number
  end: number
  original: string
  category: string
}

export interface PlannedMatch extends FoundMatch {
  placeholder?: string
}

export interface RedactSession {
  getOrCreatePlaceholder(original: string, category: string): string
}

function subtractCovered(start: number, end: number, covered: Span[]): Span[] {
  if (start >= end) return []
  const out: Span[] = []
  let cur = start
  for (const c of covered) {
    if (c.end <= cur) continue
    if (c.start >= end) break
    if (c.start > cur) out.push({ start: cur, end: Math.min(c.start, end) })
    if (c.end >= end) {
      cur = end
      break
    }
    cur = Math.max(cur, c.end)
  }
  if (cur < end) out.push({ start: cur, end })
  return out
}

function insertCovered(covered: Span[], span: Span): Span[] {
  if (span.start >= span.end) return covered
  let i = 0
  for (; i < covered.length; i++) {
    if (covered[i].start > span.start) break
  }
  covered.splice(i, 0, span)
  if (covered.length <= 1) return covered

  const merged: Span[] = []
  for (const c of covered) {
    const last = merged.at(-1)
    if (!last) {
      merged.push(c)
      continue
    }
    if (c.start <= last.end) {
      if (c.end > last.end) last.end = c.end
      continue
    }
    merged.push(c)
  }
  return merged
}

/**
 * 对输入文本进行脱敏替换，返回替换后的文本与命中信息。
 * 设计与 VibeGuard 的 redact 引擎一致：处理重叠命中，确保不会把占位符切碎。
 */
export function redactText(input: unknown, patterns: PatternSet, session: RedactSession): { text: string; matches: PlannedMatch[] } {
  const text = String(input ?? "")
  if (!text) return { text, matches: [] }

  const found: FoundMatch[] = []

  for (const rule of patterns.keywords) {
    const needle = rule.value
    if (!needle) continue
    let idx = 0
    for (;;) {
      const pos = text.indexOf(needle, idx)
      if (pos === -1) break
      const start = pos
      const end = pos + needle.length
      const original = text.slice(start, end)
      idx = end
      if (patterns.exclude.has(original)) continue
      found.push({ start, end, original, category: rule.category })
    }
  }

  for (const rule of patterns.regex) {
    const baseFlags = String(rule.flags ?? "")
    const flags = baseFlags.includes("g") ? baseFlags : `${baseFlags}g`
    const re = new RegExp(rule.pattern, flags)
    for (const m of text.matchAll(re)) {
      if (!m[0]) continue
      const start = m.index ?? -1
      if (start < 0) continue
      const end = start + m[0].length
      const original = text.slice(start, end)
      if (patterns.exclude.has(original)) continue
      found.push({ start, end, original, category: rule.category })
    }
  }

  if (found.length === 0) return { text, matches: [] }

  // 右侧优先；同起点优先更长，便于把左侧大范围命中拆掉
  found.sort((a, b) => {
    if (a.start !== b.start) return b.start - a.start
    return b.end - a.end
  })

  const planned: PlannedMatch[] = []
  let covered: Span[] = []
  for (const m of found) {
    const segments = subtractCovered(m.start, m.end, covered)
    for (const seg of segments) {
      if (seg.start < 0 || seg.end > text.length || seg.start >= seg.end) continue
      planned.push({
        start: seg.start,
        end: seg.end,
        original: text.slice(seg.start, seg.end),
        category: m.category,
      })
      covered = insertCovered(covered, seg)
    }
  }

  planned.sort((a, b) => b.start - a.start)

  let out = text
  for (const m of planned) {
    const placeholder = session.getOrCreatePlaceholder(m.original, m.category)
    out = out.slice(0, m.start) + placeholder + out.slice(m.end)
    m.placeholder = placeholder
  }

  return { text: out, matches: planned }
}
