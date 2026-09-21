import { restoreText, type RestoreSession } from "./restore.ts"
import { redactText, type RedactSession } from "./engine.ts"
import type { PatternSet } from "./patterns.ts"

function isPlainObject(value: unknown): boolean {
  if (!value || typeof value !== "object") return false
  if (Array.isArray(value)) return false
  const proto = Object.getPrototypeOf(value)
  return proto === Object.prototype || proto === null
}

/**
 * 深度遍历工具参数对象，把所有字符串里的占位符还原为原值。
 * 纯函数：返回重建后的副本，绝不原地修改输入节点。
 * opencode V2 传入的工具 input 可能是 frozen 对象，原地赋值会抛
 * "Attempted to assign to readonly property"，所以必须重建。
 * - 只遍历 Array / PlainObject
 * - 使用 WeakSet 避免循环引用导致爆栈
 */
export function restoreDeep(value: unknown, session: RestoreSession): unknown {
  const seen = new WeakSet<object>()

  const walk = (node: unknown): unknown => {
    if (!node || typeof node !== "object") return node
    if (seen.has(node as object)) return node
    seen.add(node as object)

    if (Array.isArray(node)) {
      let changed = false
      const out: unknown[] = new Array(node.length)
      for (let i = 0; i < node.length; i++) {
        const v = node[i]
        if (typeof v === "string") {
          out[i] = restoreText(v, session)
          if (out[i] !== v) changed = true
        } else if (v && typeof v === "object") {
          out[i] = walk(v)
          if (out[i] !== v) changed = true
        } else {
          out[i] = v
        }
      }
      return changed ? out : node
    }

    if (!isPlainObject(node)) return node

    let changed = false
    const out: Record<string, unknown> = {}
    for (const key of Object.keys(node)) {
      const v = (node as Record<string, unknown>)[key]
      if (typeof v === "string") {
        out[key] = restoreText(v, session)
        if (out[key] !== v) changed = true
      } else if (v && typeof v === "object") {
        out[key] = walk(v)
        if (out[key] !== v) changed = true
      } else {
        out[key] = v
      }
    }
    return changed ? out : node
  }

  return walk(value)
}

/**
 * 深度遍历对象，把所有字符串中的敏感内容替换为占位符（原地修改）。
 * - 只遍历 Array / PlainObject
 * - 使用 WeakSet 避免循环引用导致爆栈
 */
export function redactDeep(value: unknown, patterns: PatternSet, session: RedactSession): void {
  const seen = new WeakSet<object>()

  const walk = (node: unknown): void => {
    if (!node || typeof node !== "object") return
    if (seen.has(node as object)) return
    seen.add(node as object)

    if (Array.isArray(node)) {
      for (let i = 0; i < node.length; i++) {
        const v = node[i]
        if (typeof v === "string") node[i] = redactText(v, patterns, session).text
        if (v && typeof v === "object") walk(v)
      }
      return
    }

    if (!isPlainObject(node)) return

    for (const key of Object.keys(node)) {
      const v = (node as Record<string, unknown>)[key]
      if (typeof v === "string") (node as Record<string, unknown>)[key] = redactText(v, patterns, session).text
      if (v && typeof v === "object") walk(v)
    }
  }

  walk(value)
}
