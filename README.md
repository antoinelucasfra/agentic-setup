# agentic-setup

Default OMP agent config folder — lives at `~/.agents/` in the user's home
directory. Skills, rules, hooks, and global instructions that the OMP coding
agent loads on every session.

The repo IS the folder: `~/.agents/` is a git clone of this repo, so there is
no symlink, no copy step, and no drift between the two.

## Contents

| Path | What |
|---|---|
| `AGENTS.md` | Global agent instructions (always loaded) |
| `skills/` | 80 skills |
| `rules/` | 2 coding rules |
| `hooks/session-end/` | Auto-commit + PR hook |
| `scripts/` | Setup helpers |

## Dependencies

The agent config expects these tools. The setup script below installs the CLI
ones; R packages are installed separately via `scripts/install-r-deps.R`.

### CLI tools (installed by setup script)

| Tool | Required? | Used for | Install |
|------|-----------|----------|---------|
| `gh` | yes | PR creation, issue management, auto-commit hook | system / brew / scoop |
| `uv` | yes | Python project gates (ruff, pytest) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `yq` | yes | applying OMP manifest settings | system / brew / scoop / `pip install yq` |
| `air` | recommended | R code formatting (`git-workflow` skill) | `cargo install air` or [GH release](https://github.com/posit-dev/air) |
| `jarl` | recommended | R code linting | `cargo install jarl` or [GH release](https://github.com/posit-dev/jarl) |
| `ruff` | recommended | Python linting (`git-workflow` skill) | `uv tool install ruff` |
| `prek` | recommended | pre-commit hook runner (project-level) | install per-project via `pip install prek` or `cargo install prek` |
| `quarto` | optional | site rendering (`antoinelucasfra.github.io`) | system / brew / scoop |
| `eza` | optional | directory tree (`AGENTS.md` recommends) | system / brew / cargo |
| `bat` | optional | file viewing with highlighting | system / brew / cargo |
| `delta` | optional | human-readable diffs | system / brew / cargo |
| `sd` | optional | find/replace in pipelines | cargo / brew |
| `dog` | optional | DNS lookups | cargo / brew |
| `trippy` | optional | network path diagnosis | cargo / brew |
| `tldr` / `cheat` | optional | condensed man pages | npm / pip / brew |
| `dust` | optional | disk usage | cargo / brew |
| `duf` | optional | filesystem free | system / brew |
| `ouch` | optional | archive create/extract | cargo / brew |
| `procs` / `btm` | optional | process inspection | cargo / brew |
| `jq` | optional | JSON query | system / brew |

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

# 2. Run the dependency installer (idempotent — safe to re-run)
bash <(curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/setup.sh)

# 3. Install R packages (if you work with R projects)
Rscript ~/.agents/scripts/install-r-deps.R

# 4. (Optional) Apply the OMP manifest — plugins, settings, extensions.
#    This is device-local tooling config, separate from the agent config above.
yq eval '.settings' ~/.agents/omp-manifest.yml > ~/.omp/agent/config.yml
yq eval '.marketplaces[].source' ~/.agents/omp-manifest.yml \
  | xargs -I{} omp plugin marketplace add "{}" 2>/dev/null
yq eval '.plugins[].id' ~/.agents/omp-manifest.yml \
  | xargs -I{} omp plugin install "{}" 2>/dev/null
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
├── rules/                  # 2 coding rules
├── hooks/session-end/      # Auto-commit + PR hook
├── scripts/                # Setup helpers
│   └── install-r-deps.R    # R package installer
└── skills/                 # 80 skills
```
