#!/usr/bin/env bash
# Sync live pi config -> agentic-setup repo. Pull, copy, commit, push.
# Conflicts: stop and report, never auto-resolve.
set -euo pipefail

REPO="${PI_SYNC_REPO:-$HOME/.agents/agentic-setup}"
# fallback for machines where clone lives elsewhere
[[ -d "$REPO/.git" ]] || REPO="$HOME/project/agentic-setup"
[[ -d "$REPO/.git" ]] || { echo "no config repo found (~/.agents/agentic-setup or ~/project/agentic-setup). Set PI_SYNC_REPO." >&2; exit 1; }

PI_HOME="$HOME/.pi/agent"
cd "$REPO"
git pull --rebase --autostash || { echo "pull failed — resolve conflict in $REPO manually" >&2; exit 1; }

# full config: settings, models, extensions (incl. custom .ts), skills, rules, AGENTS.md
# excluded by design: memory DB (per-device SQLite), sessions, node_modules, secrets (auth.json, trust.json)
rsync -a --delete "$PI_HOME/extensions/"    pi/extensions/
cp "$PI_HOME/settings.json"                 pi/settings.json
cp "$PI_HOME/models.json"                   pi/models.json
cp "$PI_HOME/AGENTS.md"                     pi/AGENTS.md 2>/dev/null || true
# skills live in $PI_HOME/skills or shared ~/.agents/skills depending on device
for src in "$PI_HOME/skills" "$HOME/.agents/skills"; do
  [[ -d "$src" ]] && { rsync -a --delete "$src/" pi/skills/; break; }
done
[[ -d "$PI_HOME/rules" ]] && rsync -a --delete "$PI_HOME/rules/" pi/rules/

if git diff --cached --quiet && git diff --quiet; then
  echo "already up to date"
  exit 0
fi

git add -A
git commit -m "pi sync from $(hostname) $(date -u +%FT%TZ)"
git push
echo "synced: $(git log -1 --format=%h) pushed from $(hostname)"
