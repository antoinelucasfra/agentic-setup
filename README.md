# agentic-setup

Setup scripts and multi-device sync for the OMP coding agent harness.

## Quick Start (first device)

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup
./setup.sh
```

## New Device Setup (device 2+)

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup
./setup.sh --bootstrap
```

`--bootstrap` reads `omp-manifest.yml` — installs plugins, applies OMP settings, copies `.agents/`. Idempotent.

## Daily Sync

After installing a plugin or changing config, snapshot the manifest:

```bash
cd ~/project/agentic-setup
./setup.sh --bootstrap           # re-sync manifest → live state (plugins, config)
git add -A && git commit -m "chore: sync" && git push
```

On the other device:

```bash
cd ~/project/agentic-setup
git pull
./setup.sh --bootstrap
```

### Auto-sync shell hook (optional)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
omp() {
  command omp "$@"
  if [[ "$1" == "plugin" && ("$2" == "install" || "$2" == "uninstall") ]]; then
    (cd ~/project/agentic-setup && git add -A && git commit -m "chore: sync $(date +%Y%m%d)" && git push) 2>/dev/null || true
  fi
}
```

## Contents

| File | Purpose |
|---|---|
| `setup.sh` | Install + bootstrap (use `--bootstrap` for device 2+) |
| `omp-manifest.yml` | Declares marketplaces, plugins, OMP settings, extension configs |
| `.agents/AGENTS.md` | Global agent instructions |
| `.agents/rules/` | Code quality guidelines |

## What's Synced vs Recreated

**Synced via git (user-managed):**
- `omp-manifest.yml` — what to install and how to configure
- `setup.sh` — installer and bootstrap script
- `.agents/AGENTS.md` — global agent instructions
- `.agents/rules/` — custom rules

**Recreated per-device (from manifest + `--bootstrap`):**
- `~/.omp/agent/config.yml` — rewritten from manifest settings
- Plugins — installed via `omp plugin install`
- Extension configs — written from manifest

**Never synced (runtime):**
- `~/.omp/logs/`, `~/.omp/cache/`, `~/.omp/agent/*.db*`
- Plugin download caches — reinstalled on each device

## Commands

```bash
./setup.sh                 # Full install (first device)
./setup.sh --bootstrap     # Apply manifest (any device)
./setup.sh --dry-run       # Preview
./setup.sh --uninstall     # Remove
./setup.sh --help          # All options
```
