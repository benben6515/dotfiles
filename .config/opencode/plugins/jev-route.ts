// Jev model router — auto-routes each message to the smallest model that can
// handle it: opencode-go/mimo-v2.5 (light) → zai-coding-plan/glm-5.3-flash
// (fast) → zai-coding-plan/glm-5.3 (full), via a pre-prompt Jev call to the
// OpenCode Zen System One endpoint. /route forces classification explicitly.
// Fails open: Jev unavailable → session keeps its current model.
//
// Known ceiling: classification sees only the new prompt, not conversation
// history — a longer continuation like "把 refactor 做完" can misdirect.
// ponytail: upgrade path = append last assistant message snippet to state.
import { readFileSync } from 'node:fs';

const ZEN_URL = 'https://opencode.ai/zen/v1/systemone';
const MODEL_JEV = 'jev-1.13';
const KEY_FILE = `${process.env.HOME}/.local/share/loop/zen.key`;
const LIGHT = { providerID: 'opencode-go', id: 'mimo-v2.5' };
const FAST = { providerID: 'zai-coding-plan', id: 'glm-5.3-flash' };
const FULL = { providerID: 'zai-coding-plan', id: 'glm-5.3' };
// Chat path: admission blocks on this hook, so keep the budget tight.
const TIMEOUT_MS = 3_000;
// Continuations ("繼續", "ok", "thanks") stay on the current model —
// classifying them would drop an in-progress heavy task to a small model.
const MIN_ROUTE_CHARS = 8;
// Image attachments need vision: route to flash, never to mimo (no vision).
// Matches both the raw input shape ({uri}) and the resolved shape
// ({mime, source:{uri}}) that files can arrive in.
const IMAGE_RE = /\.(png|jpe?g|gif|webp|bmp|heic|svg)$/i;

function hasImage(files?: ReadonlyArray<Record<string, unknown>>): boolean {
  return !!files?.some((f) => {
    const uri =
      typeof f.uri === 'string'
        ? f.uri
        : (((f.source as Record<string, unknown> | undefined)?.uri as string | undefined) ?? '');
    if (IMAGE_RE.test(uri)) return true;
    return typeof f.mime === 'string' && (f.mime as string).startsWith('image/');
  });
}

type ModelRef = { providerID: string; id: string };

// Tier keywords accepted by /pin. Anything else containing "/" is parsed as
// "provider/model" verbatim.
function resolveTier(arg: string): ModelRef | undefined {
  const a = arg.toLowerCase();
  if (['mimo', 'light', 'v2.5'].some((k) => a.includes(k))) return LIGHT;
  if (['flash', 'fast', 'highspeed'].some((k) => a.includes(k))) return FAST;
  if (['full', '5.3', 'glm'].some((k) => a.includes(k))) return FULL;
  const slash = arg.indexOf('/');
  if (slash > 0) return { providerID: arg.slice(0, slash), id: arg.slice(slash + 1) };
  return undefined;
}

function apiKey(): string {
  if (process.env.OPENCODE_API_KEY) return process.env.OPENCODE_API_KEY;
  try {
    return readFileSync(KEY_FILE, 'utf8').trim();
  } catch {
    return '';
  }
}

async function pickModel(promptText: string): Promise<{ providerID: string; id: string } | undefined> {
  const key = apiKey();
  if (!key) return undefined;
  try {
    const res = await fetch(ZEN_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${key}`,
        'Content-Type': 'application/json',
        'User-Agent': 'opencode-jev-route/1.0',
      },
      body: JSON.stringify({
        model: MODEL_JEV,
        state: promptText.slice(0, 4000),
        questions: {
          tier: {
            type: 'choice',
            instructions: 'Pick the smallest model tier that can handle this coding agent task well.',
            criteria: {
              light:
                'Trivia, arithmetic, quick facts, one-word or one-line answers, tiny text transformations, simple classification.',
              fast: 'Coding lookups, explanations, small localized edits, formatting, simple one-file scripts.',
              full: 'Multi-file refactors, architecture design, hard debugging, long multi-step plans, high-stakes changes.',
            },
          },
        },
      }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
    if (!res.ok) return undefined;
    const data = (await res.json()) as { answers?: { tier?: { choice?: string } } };
    switch (data.answers?.tier?.choice) {
      case 'light':
        return LIGHT;
      case 'full':
        return FULL;
      case 'fast':
        return FAST;
      default:
        return undefined;
    }
  } catch {
    return undefined;
  }
}

export default {
  id: 'jev-route',
  async setup(ctx) {
    // Pre-message auto-routing: classify every admitted user prompt with Jev
    // and switch the session model before model resolution happens (prompt
    // hooks complete before admission, resolution runs after admission).
    // Slash commands are skipped — they route themselves (/route).
    // Jev failure fails open: session keeps its current model.
    await ctx.session.hook('prompt', async (event) => {
      const text = event.prompt.text;
      if (text.startsWith('/') || text.trim().length < MIN_ROUTE_CHARS) return;
      try {
        // Manually pinned session → leave the model alone.
        const pin = await ctx.storage.get(`pin/${event.sessionID}`);
        if (pin) return;
        // Image attachment → vision needed → flash, skip Jev (it only sees text).
        const model = hasImage(event.prompt.files) ? FAST : await pickModel(text);
        if (model) await ctx.session.switchModel({ sessionID: event.sessionID, model });
      } catch {
        // fail open: keep the session's current model
      }
    });

    await ctx.command.transform((editor) => {
      editor.add({
        name: 'route',
        description: 'Jev 分類任務複雜度，自動選 MiMo-V2.5 / GLM-5.3-Flash / GLM-5.3 執行',
        execute: async ({ sessionID, prompt, delivery }) => {
          const model = hasImage(prompt.files) ? FAST : ((await pickModel(prompt.text)) ?? FAST);
          await ctx.session.switchModel({ sessionID, model });
          await ctx.session.prompt({ ...prompt, sessionID, delivery });
        },
      });
      editor.add({
        name: 'pin',
        description: '釘住 model 停用自動路由；可帶層級 mimo|flash|full 或 provider/model',
        execute: async ({ sessionID, prompt }) => {
          const arg = prompt.text.trim();
          let model = arg ? resolveTier(arg) : undefined;
          if (arg && !model) {
            await ctx.session.synthetic({
              sessionID,
              text: `⛔ 不認得「${arg}」。可用：mimo | flash | full | provider/model`,
            });
            return;
          }
          if (model) await ctx.session.switchModel({ sessionID, model });
          await ctx.storage.set(`pin/${sessionID}`, { pinned: true });
          const ref = model ? `${model.providerID}/${model.id}` : '目前 model';
          await ctx.session.synthetic({ sessionID, text: `📌 已釘住 ${ref}，自動路由停用（/unpin 解除）` });
        },
      });
      editor.add({
        name: 'unpin',
        description: '解除釘住，恢復 Jev 自動路由',
        execute: async ({ sessionID }) => {
          await ctx.storage.remove(`pin/${sessionID}`);
          await ctx.session.synthetic({ sessionID, text: '🔓 已解除釘住，恢復 Jev 自動路由' });
        },
      });
    });
  },
};
