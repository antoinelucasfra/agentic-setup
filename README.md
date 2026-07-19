# agentic-setup

OMP agent config: skills, agents, rules, hooks, plugins — single source of truth in git,
synced across devices via a symlink.

## Contents

| Path | What |
|---|---|
| `omp-manifest.yml` | Marketplaces, plugins, OMP settings, extension configs |
| `.agents/AGENTS.md` | Global agent instructions |
| `.agents/settings.json` | Agent settings |
| `.agents/skills/` | 90 skills |
| `.agents/agents/` | 16 task agent definitions |
| `.agents/rules/` | 8 coding rules |
| `.agents/hooks/` | Session auto-commit + PR-assign hook |

## Single source of truth

`~/.agents` is a **symlink** to this repo's `.agents/` directory. There is exactly one
copy of the config — here. The agent harness reads `~/.agents/...` and transparently
resolves into this repository, so changes the harness makes (new skills, agents, hook
edits) land directly in the repo. No copy/rsync step, so the two can never drift.

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

## Structure

```
agentic-setup/              # git repo = single source of truth (clone anywhere)
├── omp-manifest.yml        # OMP device bootstrap (plugins/settings)
├── README.md
├── .gitignore
└── .agents/                # <- symlinked from ~/.agents
    ├── AGENTS.md           # Global agent instructions
    ├── settings.json       # Empty (OMP reads ~/.omp/agent/config.yml)
    ├── agents/             # 16 task agent definitions
    ├── rules/              # 8 coding rules
    ├── hooks/session-end/  # Auto-commit + PR-assign hook
    └── skills/             # 90 skills
```
