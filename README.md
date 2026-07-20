# agentic-setup

OMP agent config: skills, agents, rules, hooks, plugins — single source of truth in git,
synced across devices via a symlink.

## Contents

| Path | What |
|---|---|
| `.agents/skills/` | 31 skills |
| `.agents/agents/` | 4 task agent definitions |
| `.agents/rules/` | 4 coding rules (commit-workflow + 3 general) |
| `.agents/hooks/` | Session auto-commit hook |

## Device Setup

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git ~/project/agentic-setup

# Point the global config at the repo (one-time, per device)
ln -s ~/project/agentic-setup/.agents ~/.agents

# Apply the OMP manifest (plugins, settings, extensions) — separate from agent config
yq eval '.settings' omp-manifest.yml > ~/.omp/agent/config.yml
yq eval '.marketplaces[].source' omp-manifest.yml | xargs -I{} omp plugin marketplace add "{}" 2>/dev/null
yq eval '.plugins[].id' omp-manifest.yml | xargs -I{} omp plugin install "{}" 2>/dev/null
```

> The symlink replaces the old copy/rsync workflow. Never `rm -rf ~/.agents/` — that
> follows the link and deletes the repo. Use `rm ~/.agents` to remove just the link.

## Daily workflow

Because `~/.agents` *is* the repo, changes the agent makes show up as uncommitted files
here. Commit and push (the session-end hook also auto-commits and pushes):

```bash
cd ~/project/agentic-setup
git add -A && git commit -m "chore: update config $(date +%Y%m%d)" && git push
```

On another device, just pull — the symlink already points at the cloned repo:

```bash
cd ~/project/agentic-setup && git pull
```

```
~/.agents/                  # User-global OMP config (every session)
├── AGENTS.md               # Global agent instructions
├── settings.json           # Empty (OMP reads ~/.omp/agent/config.yml)
├── agents/                 # 4 task agent definitions
├── rules/                  # 4 coding rules
├── hooks/session-end/      # Auto-commit hook
└── skills/                 # 31 skills
```
