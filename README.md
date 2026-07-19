# agentic-setup

OMP agent config, personal skills, and multi-device sync.

## Contents

| Path | What |
|---|---|
| `omp-manifest.yml` | Marketplaces, plugins, OMP settings, extension configs |
| `.agents/skills/` | 30 personal skills (synced) |
| `.agents/AGENTS.md` | Global agent instructions |
| `.agents/rules/` | Custom code rules |

## Device Setup

**First device:**
```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup

# Install OMP (one-time)

# Copy agent config
cp -r .agents/AGENTS.md .agents/rules/ ~/.agents/
cp -r .agents/skills/* ~/.agents/skills/

# Apply manifest (plugins, settings, extensions)
yq eval '.settings' omp-manifest.yml > ~/.omp/agent/config.yml
yq eval '.marketplaces[].source' omp-manifest.yml | xargs -I{} omp plugin marketplace add "{}" 2>/dev/null
yq eval '.plugins[].id' omp-manifest.yml | xargs -I{} omp plugin install "{}" 2>/dev/null
```

**Device 2+:** same as above, skip OMP install.

## Daily Sync

After adding a skill to `~/.agents/skills/` or changing config:

```bash
cd ~/project/agentic-setup

# Snapshot skills + config
rsync -a ~/.agents/skills/ .agents/skills/
rsync -a ~/.agents/AGENTS.md .agents/
rsync -a ~/.agents/rules/ .agents/rules/

git add -A && git commit -m "chore: sync $(date +%Y%m%d)" && git push
```

On the other device:
```bash
cd ~/project/agentic-setup && git pull
rsync -a .agents/skills/ ~/.agents/skills/
cp .agents/AGENTS.md ~/.agents/
rsync -a .agents/rules/ ~/.agents/rules/
```

### Auto-sync shell hook (optional)

```bash
# In ~/.zshrc or ~/.bashrc
skill-sync() { rsync -a ~/.agents/skills/ ~/project/agentic-setup/.agents/skills/ && cd ~/project/agentic-setup && git add -A && git commit -m "chore: sync $(date +%Y%m%d)" && git push; }
```

## Skills

Your personal skills live in `~/.agents/skills/`. The repo holds a versioned copy. To add a new skill:

```bash
mkdir ~/.agents/skills/<name>
# write ~/.agents/skills/<name>/SKILL.md
cp -r ~/.agents/skills/<name> ~/project/agentic-setup/.agents/skills/
cd ~/project/agentic-setup && git add -A && git commit -m "feat: add <name> skill" && git push
```
