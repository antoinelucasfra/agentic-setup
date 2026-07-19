# agentic-setup

Setup scripts, skills, and multi-device sync for the OMP coding agent harness.

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
./setup.sh                    # system prerequisites (OMP, Bun, etc.)
./omp-bootstrap.sh            # apply plugins, settings, skills from manifest
```

`omp-bootstrap.sh` is idempotent — safe to re-run anytime.

## Daily Sync

After installing a new plugin or changing config on any device:

```bash
cd ~/project/agentic-setup
./omp-sync.sh --commit --push
```

On the other device:

```bash
cd ~/project/agentic-setup
git pull
./omp-bootstrap.sh         # reapply any new plugins/config
```

### Auto-sync shell hook (optional)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
omp() {
  command omp "$@"
  if [[ "$1" == "plugin" && ("$2" == "install" || "$2" == "uninstall") ]]; then
    ~/project/agentic-setup/omp-sync.sh --commit 2>/dev/null || true
  fi
}
```

## Contents

| File | Purpose |
|---|---|
| `setup.sh` | First-device system install (OMP, Bun, deps) |
| `omp-manifest.yml` | Declares marketplaces, plugins, OMP settings, extension configs |
| `omp-bootstrap.sh` | Applies manifest to this device (idempotent) |
| `omp-sync.sh` | Snapshots live OMP state back into manifest + git |
| `.agents/AGENTS.md` | Global agent instructions |
| `.agents/skills/` | Agent skill definitions (versioned subset) |
| `.agents/rules/` | Code quality guidelines |
| `docs/` | Setup and contribution guides |

## Architecture

```
┌─ Device A ─────────────────────┐     ┌─ Device B ─────────────────────┐
│                                 │     │                                 │
│  ~/project/agentic-setup/       │     │  ~/project/agentic-setup/       │
│  ├── omp-manifest.yml ──git─────┼─────┼──├── omp-manifest.yml          │
│  ├── omp-bootstrap.sh           │     │  ├── omp-bootstrap.sh          │
│  ├── omp-sync.sh               │     │  ├── omp-sync.sh                │
│  └── .agents/                   │     │  └── .agents/                   │
│       │                          │     │       │                         │
│       ├──sync────────────────────┼─────┼───────┘ (git pull)             │
│       │                          │     │                                 │
│       ▼                          │     │  ▼                              │
│  ~/.agents/ (live)               │     │  ~/.agents/ (live)              │
│  ~/.omp/agent/config.yml         │     │  ~/.omp/agent/config.yml        │
│  (plugins installed)             │     │  (plugins installed)            │
│                                 │     │                                 │
└─────────────────────────────────┘     └─────────────────────────────────┘
```

## What's Synced vs Recreated

**Synced via git (user-managed):**
- `omp-manifest.yml` — what to install and how to configure
- `.agents/AGENS.md` — global agent instructions
- `.agents/rules/` — custom rules
- `.agents/skills/` — skill definitions

**Recreated per-device (from manifest + bootstrap):**
- `~/.omp/agent/config.yml` — rewritten from manifest settings
- Plugins — installed via `omp plugin install`
- Extension configs — written from manifest

**Never synced (runtime):**
- `~/.omp/logs/`, `~/.omp/cache/`, `~/.omp/agent/*.db*`
- Plugin download caches — reinstalled on each device

## Other Commands

```bash
./setup.sh --help          # All setup options
./setup.sh --dry-run       # Preview setup
./setup.sh --list-skills   # List available skills
./setup.sh --uninstall     # Remove setup
```
