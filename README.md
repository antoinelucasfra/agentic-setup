# agentic-setup

OMP agent config — skills, agents, rules, hooks — kept as a single git repository
whose working tree **is** `~/.agents`. No symlink, no copy/rsync step: the one
physical directory `~/.agents` is the repo, so a second copy (and the drift that
comes with it) is structurally impossible.

## Contents

| Path | What |
|---|---|
| `AGENTS.md` | Global agent instructions (always loaded) |
| `skills/` | 81 skills |
| `agents/` | 4 task-agent definitions |
| `rules/` | 4 coding rules (commit-workflow + 3 general) |
| `hooks/` | Session-end auto-commit hook |
| `settings.json` | Empty placeholder (OMP reads `~/.omp/agent/config.yml`) |

## Device setup

```bash
# Clone the repo directly into the global config path
git clone https://github.com/antoinelucasfra/agentic-setup.git ~/.agents

# (Optional) Apply the OMP manifest — plugins, settings, extensions.
# This is device-local tooling config, separate from the agent config above.
yq eval '.settings' omp-manifest.yml > ~/.omp/agent/config.yml
yq eval '.marketplaces[].source' omp-manifest.yml | xargs -I{} omp plugin marketplace add "{}" 2>/dev/null
yq eval '.plugins[].id' omp-manifest.yml | xargs -I{} omp plugin install "{}" 2>/dev/null
```

That's it. A new clone at `~/.agents` is immediately the live agent config.

## Daily workflow

Because `~/.agents` *is* the repo, any change the agent makes shows up as an
uncommitted file there. Commit and push normally:

```bash
cd ~/.agents
git add -A && git commit -m "chore: update config $(date +%Y%m%d)" && git push
```

The session-end hook also auto-commits and pushes, and (on a feature branch)
opens/assigns a PR to the owner — so routine edits rarely need manual git.

```
~/.agents/                  # User-global OMP config AND the git repo
├── AGENTS.md               # Global agent instructions
├── settings.json           # Empty (OMP reads ~/.omp/agent/config.yml)
├── agents/                 # 4 task-agent definitions
├── rules/                  # 4 coding rules
├── hooks/session-end/      # Auto-commit + PR hook
└── skills/                 # 81 skills
```
