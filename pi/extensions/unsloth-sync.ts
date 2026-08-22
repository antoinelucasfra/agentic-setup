import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

const CANDIDATE_PORTS = [8888, 8889, 8890, 8891, 8892, 8893, 8894, 8895];
const AUTH_PATH = path.join(os.homedir(), ".unsloth/studio/auth/agent_api_key.json");
const MODELS_JSON_PATH = path.join(os.homedir(), ".pi/agent/models.json");
const HF_CACHE = path.join(os.homedir(), ".cache/huggingface/hub");
const BIG_CONTEXT = 32768;

let discoveredBase: string | null = null; // e.g. http://127.0.0.1:8889
let discoveredV1: string | null = null;   // e.g. http://127.0.0.1:8889/v1

async function discoverStudio(): Promise<string | null> {
  if (discoveredBase) {
    try {
      const r = await fetch(`${discoveredBase}/api/health`, { signal: AbortSignal.timeout(1000) });
      if (r.ok) return discoveredBase;
    } catch {}
    discoveredBase = null;
    discoveredV1 = null;
  }
  for (const p of CANDIDATE_PORTS) {
    const base = `http://127.0.0.1:${p}`;
    try {
      const r = await fetch(`${base}/api/health`, { signal: AbortSignal.timeout(800) });
      if (!r.ok) continue;
      const j: any = await r.json().catch(() => ({}));
      // Prefer server_url from health if present
      const url = j?.server_url as string | undefined;
      if (url && url.startsWith("http://")) {
        discoveredBase = url.replace(/\/$/, "");
        discoveredV1 = `${discoveredBase}/v1`;
        return discoveredBase;
      }
      discoveredBase = base;
      discoveredV1 = `${base}/v1`;
      return base;
    } catch {}
  }
  return null;
}

function getApiKeyFor(base: string | null): string | undefined {
  try {
    const raw = fs.readFileSync(AUTH_PATH, "utf-8");
    const j = JSON.parse(raw);
    const servers = j?.servers as Record<string, any> | undefined;
    if (!servers) return undefined;
    if (base && servers[base]) {
      const e = servers[base];
      return e.minted?.[0] ?? e.saved?.[0];
    }
    // Fallback: first minted key from any server (handles 8888->8889 migration)
    for (const v of Object.values(servers)) {
      const k = (v as any).minted?.[0] ?? (v as any).saved?.[0];
      if (k) return k;
    }
    // Last resort: read from pi isolated models.json
    try {
      const pj = JSON.parse(fs.readFileSync(path.join(os.homedir(), ".unsloth/studio/auth/agents/pi/.pi/agent/models.json"), "utf-8"));
      return pj?.providers?.unsloth?.apiKey;
    } catch {}
  } catch {}
  return undefined;
}

type CachedModel = { repo_id: string };
type LiveModel = { id: string };

async function fetchCachedModels(base: string, apiKey: string): Promise<string[] | null> {
  try {
    const res = await fetch(`${base}/api/hub/cached-gguf`, {
      headers: { Authorization: `Bearer ${apiKey}` },
      signal: AbortSignal.timeout(3000),
    });
    if (!res.ok) return null;
    const j: any = await res.json();
    const arr = j?.cached as CachedModel[] | undefined;
    if (!Array.isArray(arr)) return null;
    // Filter partial/false and size>0 (9B empty dir returns not in list already)
    return arr.filter((c) => !c.repo_id.includes("partial") && c.repo_id.startsWith("unsloth/")).map((c) => c.repo_id);
  } catch {
    return null;
  }
}

async function fetchLiveModels(baseV1: string, apiKey: string): Promise<string[] | null> {
  try {
    const res = await fetch(`${baseV1}/models`, {
      headers: { Authorization: `Bearer ${apiKey}` },
      signal: AbortSignal.timeout(3000),
    });
    if (!res.ok) return null;
    const j: any = await res.json();
    const data = j?.data as LiveModel[] | undefined;
    if (Array.isArray(data)) return data.map((m) => m.id);
    if (Array.isArray(j)) return (j as LiveModel[]).map((m) => m.id);
    return null;
  } catch {
    return null;
  }
}

function scanFsCache(): string[] {
  try {
    const ids: string[] = [];
    if (!fs.existsSync(HF_CACHE)) return ids;
    for (const entry of fs.readdirSync(HF_CACHE)) {
      if (!entry.startsWith("models--unsloth--")) continue;
      const repo = entry.replace("models--", "").replace(/--/g, "/");
      const snapDir = path.join(HF_CACHE, entry, "snapshots");
      if (!fs.existsSync(snapDir)) continue;
      const snaps = fs.readdirSync(snapDir);
      let hasGguf = false;
      for (const s of snaps) {
        const sp = path.join(snapDir, s);
        try {
          const files = fs.readdirSync(sp);
          if (files.some((f) => f.endsWith(".gguf"))) {
            // Check size > 100MB to exclude empty mmproj-only stubs (9B ghost is 0 snaps, so excluded)
            const total = files.filter((f) => f.endsWith(".gguf")).reduce((acc, f) => {
              try { return acc + fs.statSync(path.join(sp, f)).size; } catch { return acc; }
            }, 0);
            if (total > 50_000_000) hasGguf = true;
          }
          // Also check blobs for gguf content if snapshots is symlink-heavy
          if (!hasGguf) {
            // Walk one level deeper for blobs-linked ggufs
            for (const f of files) {
              const fp = path.join(sp, f);
              try {
                if (fs.statSync(fp).size > 50_000_000 && f.endsWith(".gguf")) hasGguf = true;
              } catch {}
            }
          }
        } catch {}
      }
      // Do NOT use blobs size alone - bge-small etc have blobs but no .gguf (no chat model)
      // Ghost entries (9B) have 0 snaps, so already excluded above
      if (hasGguf) ids.push(repo);
    }
    return ids;
  } catch {
    return [];
  }
}

function toDisplayName(id: string): string {
  const base = id.split("/").pop() || id;
  return base.replace("-MTP-GGUF", "").replace(/-/g, " ");
}

function buildPiModels(ids: string[]) {
  const short = ids.map((id) => ({
    id,
    name: `${toDisplayName(id)} 4k (Unsloth Desktop)`,
    reasoning: true as const,
    input: ["text", "image"] as ("text" | "image")[],
    contextWindow: 4096,
    maxTokens: 4096,
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
  }));
  const big = ids.map((id) => ({
    id,
    name: `${toDisplayName(id)} Big 32k (Unsloth Desktop)`,
    reasoning: true as const,
    input: ["text", "image"] as ("text" | "image")[],
    contextWindow: BIG_CONTEXT,
    maxTokens: 8192,
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
  }));
  return { short, big };
}

function syncModelsJson(ids: string[], baseV1: string, apiKey: string): boolean {
  try {
    const raw = fs.readFileSync(MODELS_JSON_PATH, "utf-8");
    const j: any = JSON.parse(raw);
    if (!j.providers) j.providers = {};
    let changed = false;

    const syncProvider = (key: string, models: any[]) => {
      const prev = j.providers[key];
      if (!prev) {
        j.providers[key] = { baseUrl: baseV1, api: "openai-completions", apiKey, models };
        changed = true;
        return;
      }
      const prevIds = new Set((prev.models ?? []).map((m: any) => m.id));
      const liveIds = new Set(models.map((m) => m.id));
      const sameSize = liveIds.size === prevIds.size && [...liveIds].every((id) => prevIds.has(id));
      const sameMeta = sameSize && models.every((m) => {
        const p = (prev.models ?? []).find((x: any) => x.id === m.id);
        return p && p.contextWindow === m.contextWindow && p.name === m.name;
      });
      const sameBase = prev.baseUrl === baseV1;
      if (!sameSize || !sameMeta || !sameBase) changed = true;
      if (changed) {
        prev.baseUrl = baseV1;
        prev.api = "openai-completions";
        prev.apiKey = apiKey;
        prev.models = models;
      }
    };

    const { short, big } = buildPiModels(ids);
    syncProvider("unsloth", short);
    syncProvider("unsloth-big", big);
    if (j.providers["unsloth-max"]) { delete j.providers["unsloth-max"]; changed = true; }
    if (ids.length === 0) {
      // Server down or no cached models -> don't wipe file to avoid thrashing, but ensure empty if we had stale 9B
      // Only prune if file had ids not in fs (handled above). If truly 0 cached, empty lists are correct.
      const hadModels = (j.providers["unsloth"]?.models?.length ?? 0) > 0 || (j.providers["unsloth-big"]?.models?.length ?? 0) > 0;
      if (hadModels && ids.length === 0) {
        // Check filesystem fallback before wiping
        const fsIds = scanFsCache();
        if (fsIds.length === 0) {
          j.providers["unsloth"].models = [];
          j.providers["unsloth-big"].models = [];
          changed = true;
        }
      }
    }
    if (changed) {
      fs.writeFileSync(MODELS_JSON_PATH, JSON.stringify(j, null, 2) + "\n");
      return true;
    }
    return false;
  } catch (e) {
    console.error("[unsloth-sync] models.json sync failed:", e);
    return false;
  }
}

export default async function (pi: ExtensionAPI) {
  let lastIds = new Set<string>();
  let interval: NodeJS.Timeout | undefined;

  const sync = async () => {
    const base = await discoverStudio();
    if (!base) return; // Studio down -> keep last
    const baseV1 = `${base}/v1`;
    discoveredBase = base;
    discoveredV1 = baseV1;
    const key = getApiKeyFor(base);
    if (!key) return;

    // Primary: cached-gguf (available on device). Fallback: fs scan. Live is not used for list.
    let ids = await fetchCachedModels(base, key);
    if (ids === null) {
      // API failed -> fs fallback (handles 9B ghost correctly)
      ids = scanFsCache();
      // If still empty and server is up, try live as last resort
      if (ids.length === 0) {
        const live = await fetchLiveModels(baseV1, key);
        if (live && live.length) ids = live;
      }
    }
    // De-dupe
    ids = [...new Set(ids)];

    const changed = ids.length !== lastIds.size || ids.some((id) => !lastIds.has(id)) || lastIds.size !== ids.length;
    const { short, big } = buildPiModels(ids);

    try { pi.registerProvider("unsloth", { baseUrl: baseV1, apiKey: key, api: "openai-completions", models: short }); } catch (e: any) { if (!String(e?.message ?? e).includes("stale")) throw e; }
    try { pi.registerProvider("unsloth-big", { baseUrl: baseV1, apiKey: key, api: "openai-completions", models: big }); } catch (e: any) { if (!String(e?.message ?? e).includes("stale")) throw e; }
    try { pi.unregisterProvider("unsloth-max"); } catch (e: any) { if (!String(e?.message ?? e).includes("stale")) {} }

    const fileChanged = syncModelsJson(ids, baseV1, key);
    if (changed || fileChanged) lastIds = new Set(ids);
  };

  await sync();
  interval = setInterval(() => { sync().catch(()=>{}); }, 10_000);
  pi.on("session_start", () => { sync().catch(()=>{}); });
  pi.on("session_end", () => { if (interval) clearInterval(interval); });

  pi.registerCommand("unsloth-sync", {
    description: "Force sync Unsloth Studio cached models to Pi (always-on watcher runs every 10s)",
    handler: async (_args, ctx) => {
      await sync();
      const base = discoveredBase ?? "unknown";
      const ids = scanFsCache();
      const cached = await (async () => {
        const k = getApiKeyFor(base);
        if (!k || !base) return null;
        return fetchCachedModels(base, k);
      })();
      ctx.ui.notify(`Studio ${base} | cached API: ${cached?.join(", ") || "n/a"} | fs: ${ids.join(", ") || "none"} | Pi: ${[...lastIds].join(", ") || "none"}`, cached ? "info" : "warning");
    },
  });
}
