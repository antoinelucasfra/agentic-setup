# agentic-setup

Default OMP agent config folder — lives at `~/.agents/` in your home
directory. Skills, rules, hooks, and global instructions the OMP coding
agent loads on every session. The repo IS the folder (no symlink, no copy).

## Prerequisites — install OMP

This config requires the **OMP coding agent CLI** (`omp`). Install it first:

```bash
npm install -g @oh-my-pi/pi-coding-agent
# or via bun:  bun install -g @oh-my-pi/pi-coding-agent
```

See the [OMP installation guide](https://oh-my-pi.com/docs/install) for
other methods (curl, brew, scoop, docker).

## One-shot device bootstrap

```bash
curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/setup.sh | bash
```

That command clones this repo into `~/.agents/`, then installs CLI
dependencies (gh, uv, yq, air, jarl, ruff) and applies the OMP manifest
(plugins, settings). All operations are idempotent — safe to re-run.

## Contents

| Path | What |
|---|---|
| `AGENTS.md` | Global agent instructions (always loaded) |
| `skills/` | 80 skills |
| `rules/` | 2 coding rules |
<<<<<<< HEAD
| `hooks/session-end/` | Disabled auto-commit + PR hook |
| `scripts/setup.sh` | CLI dependency installer |
=======
| `hooks/session-end/` | Session-end hooks (disabled by default) |
| `scripts/` | Setup helpers |
| `omp-manifest.yml` | OMP device manifest — plugins, settings, extensions |
>>>>>>> origin/main

## Dependencies

| Tool | Required? | Used for | Install |
|------|-----------|----------|---------|
| `gh` | yes | PR creation, issue management | system / brew / scoop |
| `uv` | yes | Python project gates (ruff, pytest) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `yq` | yes | applying OMP manifest settings | system / brew / scoop / `pip install yq` |
| `air` | recommended | R code formatting (`git-workflow` skill) | `cargo install air` or [GH release](https://github.com/posit-dev/air) |
| `jarl` | recommended | R code linting | `cargo install jarl` or [GH release](https://github.com/posit-dev/jarl) |
| `ruff` | recommended | Python linting (`git-workflow` skill) | `uv tool install ruff` |
| `prek` | recommended | pre-commit hook runner (project-level) | install per-project via `pip install prek` or `cargo install prek` |

<<<<<<< HEAD
=======
For optional modern CLI tools (`eza`, `bat`, `delta`, `sd`, `jq`, ...), see the [modern CLI replacements table in AGENTS.md](AGENTS.md#modern-cli-over-legacy-utilities).

### R packages (installed via `scripts/install-r-deps.R`)

| Package | Used for |
|---------|----------|
| `devtools` | `devtools::test()`, `devtools::check()` — commit gates |
| `testthat` | test runner |
| `lintr` | `lintr::lint_dir()` — R linting gate |
| `usethis` | R project automation (referenced across R skills) |
| `roxygen2` | .Rd documentation generation |
| `renv` | R dependency management |
| `pkgdown` | R package site builder |
| `golem` | Shiny app framework |
| `withr` | temporary state for tests |
| `dockerfiler` | Dockerfile generation (golem) |

```bash
Rscript scripts/install-r-deps.R
```

## Device setup

```bash
# 1. Clone the repo directly into the global config path
git clone https://github.com/antoinelucasfra/agentic-setup.git ~/.agents

# 2. Install CLI dependencies (idempotent — safe to re-run)
bash <(curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/setup.sh)

# 3. Apply OMP manifest — plugins, settings, extensions
bash ~/.agents/scripts/apply-manifest.sh

# 4. Install R packages (if you work with R projects)
Rscript ~/.agents/scripts/install-r-deps.R
```

That's it. A new clone at `~/.agents` is immediately the live agent config.

## OMP manifest

`omp-manifest.yml` is the single source of truth for your OMP installation.
It controls:

- **Model roles** — which model to use for default, plan, smol, slow tasks
- **Theme** — color scheme and symbol preset
- **Plugins** — marketplace skills and npm packages (ponytail, rtk optimizer, etc.)
- **Extension configs** — per-plugin settings (rtk output compaction, etc.)

Edit `omp-manifest.yml` to personalize your OMP setup, then re-run:

```bash
bash ~/.agents/scripts/apply-manifest.sh
```

The script is idempotent — it only adds missing marketplaces and plugins, and
overwrites settings and extension configs on each run.

>>>>>>> origin/main
## Daily workflow

Because `~/.agents` *is* the repo, any change shows up as an uncommitted file
there. Commit and push:

```bash
cd ~/.agents
git add -A && git commit -m "chore: update config $(date +%Y%m%d)" && git push
```

<<<<<<< HEAD
## Tree
=======
The hooks directory is reserved for future use, but session-end auto-commit
is disabled by default.
>>>>>>> origin/main

```
~/.agents/
├── AGENTS.md               # Global agent instructions
├── rules/                  # 2 coding rules
<<<<<<< HEAD
├── hooks/session-end/      # Disabled auto-commit + PR hook
├── scripts/setup.sh        # CLI dependency installer
├── omp-manifest.yml        # Plugin and settings manifest
=======
├── hooks/session-end/      # Reserved for session-end hooks (disabled)
├── scripts/                # Setup helpers
│   └── install-r-deps.R    # R package installer
├── omp-manifest.yml        # OMP device manifest
>>>>>>> origin/main
└── skills/                 # 80 skills
```
