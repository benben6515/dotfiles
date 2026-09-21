import { getPlaceholderRegex } from "./session.ts"

export interface RestoreSession {
  prefix: string
  lookup(ph: string): string | undefined
}

/**
 * 还原字符串中的占位符；若占位符不在映射表中，则保持原样。
 */
export function restoreText(input: unknown, session: RestoreSession): string {
  const text = String(input ?? "")
  if (!text) return text
  const re = getPlaceholderRegex(session.prefix)
  return text.replace(re, (ph) => session.lookup(ph) ?? ph)
}
