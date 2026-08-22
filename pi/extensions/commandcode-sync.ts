import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

const BASE_V1 = "https://api.commandcode.ai/provider/v1";
const AUTH_PATH = path.join(os.homedir(), ".pi/agent/auth.json");
const MODELS_JSON_PATH = path.join(os.homedir(), ".pi/agent/models.json");
const REFRESH_MS = 4 * 60 * 60 * 1000; // same cadence as built-in remote catalog refresh

function getApiKey(): string | undefined {
  try {
    const auth = JSON.parse(fs.readFileSync(AUTH_PATH, "utf-8"));
    if (auth?.commandcode?.key) return auth.commandcode.key;
  } catch {}
  try {
    const mj = JSON.parse(fs.readFileSync(MODELS_JSON_PATH, "utf-8"));
    return mj?.providers?.commandcode?.apiKey;
  } catch {}
  return undefined;
}

type ApiModel = { id: string; name?: string; context_length?: number };

async function fetchCatalog(apiKey: string): Promise<ApiModel[] | null> {
  try {
    const res = await fetch(`${BASE_V1}/models`, {
      headers: { Authorization: `Bearer ${apiKey}` },
      signal: AbortSignal.timeout(10_000),
    });
    if (!res.ok) return null;
    const j: any = await res.json();
    const data = j?.data;
    if (!Array.isArray(data)) return null;
    return data.filter((m: any) => typeof m?.id === "string");
  } catch {
    return null;
  }
}

/** Merge live catalog with curated metadata (cost/reasoning/etc.) already in models.json. */
function buildModels(live: ApiModel[], current: any[]): any[] {
  const byId = new Map(current.map((m) => [m.id, m]));
  return live.map((m) => {
    const prev = byId.get(m.id);
    return {
      ...(prev ?? {}),
      id: m.id,
      name: m.name ?? prev?.name ?? m.id,
      reasoning: prev?.reasoning ?? true,
      input: prev?.input ?? ["text", "image"],
      cost: prev?.cost,
      contextWindow: m.context_length ?? prev?.contextWindow ?? 128000,
      maxTokens: prev?.maxTokens,
    };
  });
}

function syncModelsJson(models: any[], apiKey: string | undefined): boolean {
  try {
    const j: any = JSON.parse(fs.readFileSync(MODELS_JSON_PATH, "utf-8"));
    const prev = j.providers?.commandcode;
    const prevIds = new Set((prev?.models ?? []).map((m: any) => m.id));
    const nextIds = new Set(models.map((m) => m.id));
    const unchanged =
      prevIds.size === nextIds.size && [...nextIds].every((id) => prevIds.has(id));
    if (unchanged && prev) return false;
    j.providers.commandcode = { ...(prev ?? {}), baseUrl: BASE_V1, api: "openai-completions", models };
    if (apiKey) j.providers.commandcode.apiKey = apiKey;
    fs.writeFileSync(MODELS_JSON_PATH, JSON.stringify(j, null, 2) + "\n");
    return true;
  } catch (e) {
    console.error("[commandcode-sync] models.json sync failed:", e);
    return false;
  }
}

export default function (pi: ExtensionAPI) {
  let lastIds = new Set<string>();

  const sync = async () => {
    const apiKey = getApiKey();
    if (!apiKey) return;
    const live = await fetchCatalog(apiKey);
    if (!live || live.length === 0) return; // API down -> keep last known catalog

    let current: any[] = [];
    try {
      current = JSON.parse(fs.readFileSync(MODELS_JSON_PATH, "utf-8"))?.providers?.commandcode?.models ?? [];
    } catch {}

    const models = buildModels(live, current);
    const changed = live.length !== lastIds.size || live.some((m) => !lastIds.has(m.id));

    // Immediate effect, no restart needed
    try { pi.registerProvider("commandcode", { baseUrl: BASE_V1, apiKey, api: "openai-completions", models }); }
    catch (e: any) { if (!String(e?.message ?? e).includes("stale")) throw e; }

    if (syncModelsJson(models, apiKey)) lastIds = new Set(live.map((m) => m.id));
    else if (changed) lastIds = new Set(live.map((m) => m.id));
  };

  pi.on("session_start", () => { sync().catch(() => {}); });
  const timer = setInterval(() => { sync().catch(() => {}); }, REFRESH_MS);
  timer.unref?.();

  pi.registerCommand("commandcode-sync", {
    description: "Force-sync commandcode model catalog from its API",
    handler: async (_args, ctx) => {
      await sync();
      ctx.ui.notify(`commandcode catalog synced (${lastIds.size} models cached)`, "info");
    },
  });
}
