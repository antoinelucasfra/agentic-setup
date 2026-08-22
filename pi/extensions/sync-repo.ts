/**
 * /sync-repo — push live pi config to the agentic-setup GitHub repo.
 * Thin wrapper around scripts/sync.sh in the config repo.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const run = promisify(execFile);

export default function (pi: ExtensionAPI) {
  pi.registerCommand("sync-repo", {
    description: "Sync pi config to agentic-setup repo (pull, rsync, commit, push)",
    handler: async (ctx) => {
      const script = `${process.env.PI_SYNC_REPO ?? `${process.env.HOME}/.agents`}/scripts/sync.sh`;
      ctx.ui.notify("Syncing pi config…", "info");
      try {
        const { stdout } = await run("bash", [script], { timeout: 120_000 });
        ctx.ui.notify(stdout.trim().split("\n").slice(-3).join("\n"), "info");
      } catch (e: any) {
        ctx.ui.notify(`sync failed:\n${e.stdout ?? ""}\n${e.stderr ?? e.message}`, "error");
      }
    },
  });
}
