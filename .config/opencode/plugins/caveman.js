// caveman plugin shim — opencode auto-loads top-level files in this
// directory only (no recursion), so this re-exports the real plugin from
// the caveman/ subdir. Single source of truth stays in caveman/plugin.js.
export { default } from './caveman/plugin.js';
