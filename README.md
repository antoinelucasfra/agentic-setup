# agentic-setup

OMP agent config: skills, agents, rules, hooks, plugins — multi-device sync via git.

## Contents

| Path | What |
|---|---|
| `omp-manifest.yml` | Marketplaces, plugins, OMP settings, extension configs |
| `.agents/AGENTS.md` | Global agent instructions |
| `.agents/settings.json` | Agent settings |
| `.agents/skills/` | 40 skills (30 original + 10 from `.github/skills/`) |
| `.agents/agents/` | 16 task agent definitions (moved from `.github/agents/`) |
| `.agents/rules/` | 8 coding rules (general + commit-workflow) |
| `.agents/hooks/` | Session auto-commit hook (moved from `.github/hooks/`) |

## Device Setup

**First device:**
```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup

# Copy everything to ~/.agents/
cp -r .agents/AGENTS.md .agents/settings.json ~/.agents/
cp -r .agents/skills/* ~/.agents/skills/
cp -r .agents/agents/ ~/.agents/agents/
cp -r .agents/rules/* ~/.agents/rules/
cp -r .agents/hooks/ ~/.agents/hooks/

# Apply manifest (plugins, settings, extensions)
yq eval '.settings' omp-manifest.yml > ~/.omp/agent/config.yml
yq eval '.marketplaces[].source' omp-manifest.yml | xargs -I{} omp plugin marketplace add "{}" 2>/dev/null
yq eval '.plugins[].id' omp-manifest.yml | xargs -I{} omp plugin install "{}" 2>/dev/null
```

**Device 2+:** same as above, skip OMP install.

## Daily Sync

After adding/changing a skill, agent, rule, or hook:

```bash
cd ~/project/agentic-setup

# Snapshot everything from ~/.agents/
rsync -a ~/.agents/skills/ .agents/skills/
rsync -a ~/.agents/agents/ .agents/agents/
rsync -a ~/.agents/rules/ .agents/rules/
rsync -a ~/.agents/hooks/ .agents/hooks/
cp ~/.agents/AGENTS.md .agents/
cp ~/.agents/settings.json .agents/

git add -A && git commit -m "chore: sync $(date +%Y%m%d)" && git push
```

On the other device:
```bash
cd ~/project/agentic-setup && git pull

# Restore everything to ~/.agents/
rsync -a .agents/skills/ ~/.agents/skills/
rsync -a .agents/agents/ ~/.agents/agents/
rsync -a .agents/rules/ ~/.agents/rules/
rsync -a .agents/hooks/ ~/.agents/hooks/
cp .agents/AGENTS.md ~/.agents/
cp .agents/settings.json ~/.agents/
```

### Auto-sync shell hook (optional)

```bash
# In ~/.zshrc or ~/.bashrc
omp-sync() {
  cd ~/project/agentic-setup
  rsync -a ~/.agents/ .agents/ --exclude=.agents/skills/node_modules
  git add -A && git commit -m "chore: sync $(date +%Y%m%d)" && git push
}
```

## Structure

```
~/.agents/                  # User-global OMP config (every session)
├── AGENTS.md               # Global agent instructions
├── settings.json           # Empty (OMP reads ~/.omp/agent/config.yml)
├── agents/                 # 16 task agent definitions
├── rules/                  # 8 coding rules
├── hooks/session-end/      # Auto-commit hook
└── skills/                 # 40 skills

~/project/.agents/rules/    # Project-specific rules only (9)
                            # (AGENTS.md, general rules removed)
```
