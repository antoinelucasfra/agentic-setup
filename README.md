# omp-setup

Opiniated OMP coding agent configuration — lives at `~/.agents/` in your home
Skills, rules, and global instructions the OMP coding agent loads on
every session. The repo IS the folder (no symlink, no copy).

## Prerequisites — install OMP

This config requires the **OMP coding agent CLI** (`omp`). Install it first:

```bash
npm install -g @oh-my-pi/pi-coding-agent
# or via bun:  bun install -g @oh-my-pi/pi-coding-agent
```

See the [OMP quickstart](https://omp.sh/docs/quickstart) for other install methods (curl, brew, scoop, docker).

## One-shot device bootstrap

```bash
curl -sL https://raw.githubusercontent.com/antoinelucasfra/omp-setup/main/scripts/bootstrap.sh | bash
```

That command clones this repo into `~/.agents/`, then installs CLI

## Contents

| Path | What |
|---|---|
| `AGENTS.md` | Global agent instructions (always loaded) |
| `skills/` | 80 skills |
| `rules/` | 3 coding rules |
| `scripts/setup.sh` | CLI dependency installer |
| `omp-manifest.yml` | Plugins, settings, extensions manifest |

## Dependencies

| Tool | Required? | Used for | Install |
|------|-----------|----------|---------|
| `gh` | yes | PR creation, issue management | system / brew / scoop |
| `uv` | yes | Python project gates (ruff, pytest) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `yq` | yes | applying OMP manifest settings | system / brew / scoop / `pip install yq` |
| `air` | recommended | R code formatting (`git-workflow` skill) | `cargo install air` or [GH release](https://github.com/posit-dev/air) |
| `jarl` | recommended | R code linting | `cargo install jarl` or [GH release](https://github.com/posit-dev/jarl) |
| `ruff` | recommended | Python linting (`git-workflow` skill) | `uv tool install ruff` |
