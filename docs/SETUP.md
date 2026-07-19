# Device Setup Guide

Platform-specific instructions for setting up the OMP coding agent harness.

## Prerequisites

### Linux (Debian/Ubuntu)
```bash
sudo apt update && sudo apt install -y curl git
```

### macOS
```bash
brew install git curl
```

### Windows (WSL2)
Install WSL2, then follow Linux instructions above.

## First Device Installation

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup
./setup.sh
```

## Additional Device (device 2, 3, ...)

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git
cd agentic-setup
./setup.sh                              # system prerequisites (Bun, OMP)
./omp-bootstrap.sh                      # plugins, settings, skills from manifest
```

`omp-bootstrap.sh` is idempotent — runs `omp plugin marketplace add`, `omp plugin install`, copies `.agents/` content, and applies settings to `~/.omp/agent/config.yml`.

## Syncing Changes Between Devices

After installing a plugin or changing config on one device:

```bash
cd ~/project/agentic-setup
./omp-sync.sh --commit --push
```

On the other device:

```bash
cd ~/project/agentic-setup
git pull
./omp-bootstrap.sh
```

## Verification

```bash
./setup.sh --dry-run       # Preview without making changes
./setup.sh --list-skills   # List available agent skills
```

## Uninstall

```bash
./setup.sh --uninstall
```
