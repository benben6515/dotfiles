import { restoreText } from "./restore.js"
import { redactText } from "./engine.js"

function isPlainObject(value) {
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
 * @param {unknown} value
 * @param {{ prefix: string, lookup(ph: string): string | undefined }} session
 * @returns {unknown} 还原后的新对象（未变化时返回原引用）
 */
export function restoreDeep(value, session) {
  const seen = new WeakSet()

  const walk = (node) => {
    if (!node || typeof node !== "object") return node
    if (seen.has(node)) return node
    seen.add(node)

    if (Array.isArray(node)) {
      let changed = false
      const out = new Array(node.length)
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
    const out = {}
    for (const key of Object.keys(node)) {
      const v = node[key]
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
 * @param {unknown} value
 * @param {{ keywords: Array<{value:string,category:string}>, regex: Array<{pattern:string,flags:string,category:string}>, exclude: Set<string> }} patterns
 * @param {{ getOrCreatePlaceholder(original: string, category: string): string }} session
 */
export function redactDeep(value, patterns, session) {
  const seen = new WeakSet()

  const walk = (node) => {
    if (!node || typeof node !== "object") return
    if (seen.has(node)) return
    seen.add(node)

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
      const v = node[key]
      if (typeof v === "string") node[key] = redactText(v, patterns, session).text
      if (v && typeof v === "object") walk(v)
    }
  }

  walk(value)
}
