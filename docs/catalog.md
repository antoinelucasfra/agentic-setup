# catalog — extensions, plugins, and skills

Everything shipped in this config, organized by what's harness-specific versus
what works with any coding agent. Source URLs resolved from package.json
`repository` fields, SKILL.md citations, and the OMP manifest on 2026-08-20.

---

## harness-agnostic elements

These work with **any coding agent** that supports the
[Agent Skills spec](https://agentskills.io) (SKILL.md format) or standalone
CLI tools. They are not tied to pi or OMP.

### portable skills (97)

Skills are harness-agnostic markdown instructions. Each lives in a directory
with a `SKILL.md` — loadable by pi, OMP, Copilot, Cursor, Aider, Cline,
Continue, Windsurf, or any agent that reads the Agent Skills spec.

#### skills with a recorded origin

These 35 skills have a verifiable source — either provided by a pi npm
package or cited in the skill's own SKILL.md / lockfile.

| Skill | Origin | GitHub |
| --- | --- | --- |
| `ponytail` | `@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `ponytail-audit` | `@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `ponytail-debt` | `@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `ponytail-gain` | `@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `ponytail-help` | `@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `ponytail-review` | `@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `mcp-scripting` | `pi-mcp-adapter` | [nicobailon/pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter) |
| `pi-lens-ast-grep` | `pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `pi-lens-lsp-navigation` | `pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `pi-lens-write-ast-grep-rule` | `pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `pi-lens-write-tree-sitter-rule` | `pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `autoresearch` | SKILL.md citation | [karpathy/autoresearch](https://github.com/karpathy/autoresearch) |
| `code-reviewer` | SKILL.md citation | [posit-dev/skills](https://github.com/posit-dev/skills) |
| `critical-code-reviewer` | SKILL.md citation | [posit-dev/skills](https://github.com/posit-dev/skills) |
| `review-testing` | SKILL.md citation | [posit-dev/skills](https://github.com/posit-dev/skills) |
| `datanalysis` | SKILL.md citation | [github/awesome-copilot](https://github.com/github/awesome-copilot) |
| `quality-playbook` | SKILL.md citation | [github/awesome-copilot](https://github.com/github/awesome-copilot) |
| `planner-r` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `r-bayes` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `r-code-reviewer` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `r-oop` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `r-package-development-guide` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `r-performance` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `r-style-guide` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `rlang-patterns` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `tdd-workflow` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `tidyverse-patterns` | SKILL.md citation | [ab604/claude-code-r-skills](https://github.com/ab604/claude-code-r-skills) |
| `pymc-testing` | SKILL.md citation | [pymc-labs/pymc-marketing](https://github.com/pymc-labs/pymc-marketing) |
| `caveman` | SKILL.md citation | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `caveman-commit` | SKILL.md citation | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `caveman-compress` | SKILL.md citation | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `caveman-help` | SKILL.md citation | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `caveman-review` | SKILL.md citation | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `caveman-stats` | SKILL.md citation | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `microsoft-foundry` | lockfile | [microsoft/azure-skills](https://github.com/microsoft/azure-skills) |

#### bundled skills — origin not recorded

These 62 skills are shipped directly in `pi/skills/`. No origin URL is
embedded in their SKILL.md and they are not provided by any pi npm package.
They were collected from the
[agent-skills.io](https://agentskills.io) ecosystem and related communities.
If you know the source repo for one, open a PR.

`agentic-eval` `alt-text` `automate-this` `brand-yml` `breakdown-epic-arch`
`breakdown-epic-pm` `breakdown-feature-implementation` `cavecrew` `cli`
`context-architect` `cran-extrachecks`
`create-github-issues-feature-from-implementation-plan`
`create-implementation-plan` `create-release-checklist` `create-technical-spike`
`custom-agent-foundry` `dependabot` `describe-design` `devils-advocate`
`devops-expert` `eval-driven-dev` `ggsql` `git-workflow` `github-issues`
`golem-add-function` `golem-add-module` `golem-check-app` `golem-create-golem`
`golem-fix-missing-ns-colin` `golem-new-module` `golem-run-tests` `golem-upgrade`
`implement` `implementation-plan` `linksmith-new-adapter` `maintainer-decline`
`marimo-notebook` `markdown-accessibility-assistant` `mirai` `model-evaluation`
`multi-stage-dockerfile` `package-docs-preference` `plan` `polyglot-test-agent`
`postgresql-optimization` `pr-create` `pr-threads-address` `pr-threads-resolve`
`prior-elicitation` `pymc-extras` `pymc-modeling` `pytest-coverage`
`quarto-alt-text` `quarto-authoring` `quarto-new-post` `r-cli-app`
`r-package-development` `refactor-plan` `release-post` `renv-add-package`
`repo-architect` `resources-catalog-entry` `ruff-recursive-fix` `shiny-bslib`
`shiny-bslib-theming` `shiny-testing` `specification` `sql-optimization`
`structured-autonomy-plan` `testing-r-packages` `uv-python-project`
`what-context-needed` `working-on`

### portable CLI tools

These work with any coding agent on any project. Installed by `scripts/setup.sh`
(shared across both harnesses).

| Tool | Used for | Install |
| --- | --- | --- |
| `git` | version control | system package manager |
| `node` + `npm` | package management | system package manager |
| `python` | scripting, package extraction | system package manager |
| `gh` | PR/issue management | system / brew / scoop / winget |
| `uv` | Python gates (ruff, pytest) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `ruff` | Python linting/formatting | `uv tool install ruff` |
| `air` | R code formatting | `uv tool install air-formatter` |
| `jarl` | R code linting | [jarl releases](https://github.com/etiennebacher/jarl/releases/latest) |
| `yq` | YAML processing (OMP manifest) | `uv tool install yq` / brew |
| `eza` | `ls` replacement — file listing | scoop/winget/choco/apt/brew `eza` |
| `bat` | `cat` replacement — paged file view | scoop/winget/choco/apt/brew `bat` |
| `fzf` | fuzzy finder — interactive list filtering | scoop/winget/choco/apt/brew `fzf` |
| `zoxide` | `cd` replacement — smart directory jump (`z`) | scoop/winget/choco/apt/brew `zoxide` |
| `delta` | `diff` replacement — git pager | scoop/winget/choco `delta`; apt/brew `git-delta` |
| `sd` | `sed` replacement — stream edit | scoop/winget/choco/apt/brew `sd` |
| `fd` | `find` replacement | shipped by pi harness in `~/.pi/agent/bin` |
| `rg` | `grep` replacement (ripgrep) | shipped by pi harness in `~/.pi/agent/bin` |

---

## pi-specific elements

These are specific to the [pi](https://pi.dev) harness
(`@earendil-works/pi-coding-agent`). They use pi's extension/package system
and deploy into `~/.pi/agent/`.

### pi extensions

Config files written to `~/.pi/agent/extensions/`. Each is provided by a pi
npm package and registers runtime behavior (linter, browser, MCP adapter, etc.).

| Extension | Package | GitHub |
| --- | --- | --- |
| `pi-rtk-optimizer` | `npm:pi-rtk-optimizer` | [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) |
| `pi-lens` (ast-grep, lsp, tree-sitter) | `npm:pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `pi-mcp-adapter` | `npm:pi-mcp-adapter` | [nicobailon/pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter) |
| `pi-fff` | `npm:@ff-labs/pi-fff` | [dmtrKovalenko/fff](https://github.com/dmtrKovalenko/fff) |
| `pi-web-access` | `npm:pi-web-access` | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) |
| `pi-background-tasks` | `npm:pi-background-tasks` | [ismailsaleekh/pi-background-tasks](https://github.com/ismailsaleekh/pi-background-tasks) |
| `pi-blackhole` | `npm:pi-blackhole` | [k0valik/pi-blackhole](https://github.com/k0valik/pi-blackhole) |
| `pi-interactive-shell` | `npm:pi-interactive-shell` | [nicobailon/pi-interactive-shell](https://github.com/nicobailon/pi-interactive-shell) |
| `checkpoint` (rewind) | `npm:@pi-plugins/checkpoint` | [k3dom/pi-plugins](https://github.com/k3dom/pi-plugins) |
| `hermes-memory` (persistent memory, SQLite FTS5) | `npm:pi-hermes-memory` | [chandra447/pi-hermes-memory](https://github.com/chandra447/pi-hermes-memory) |
| `plan-mode` (`/plan`) | `npm:@narumitw/pi-plan-mode` | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) |
| `statusline` (context/tokens/cost footer) | `npm:@narumitw/pi-statusline` | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) |
| `worktree` (managed worktrees) | `npm:@narumitw/pi-worktree` | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) |
| `btw` (`/btw` side notes) | `npm:pi-btw` | [dbachelder/pi-btw](https://github.com/dbachelder/pi-btw) |

### pi packages (npm)

Installed into `~/.pi/agent/npm/node_modules` via `pi install`. Each may
register extensions, skills, or both. The skills they ship are listed above
under "portable skills with a recorded origin".

| Package | GitHub |
| --- | --- |
| `npm:pi-blackhole` | [k0valik/pi-blackhole](https://github.com/k0valik/pi-blackhole) |
| `npm:pi-caveman` | [jonjonrankin/pi-caveman](https://github.com/jonjonrankin/pi-caveman) |
| `npm:@juicesharp/rpiv-ask-user-question` | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono) |
| `npm:@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `npm:@juicesharp/rpiv-todo` | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono) |
| `npm:@ff-labs/pi-fff` | [dmtrKovalenko/fff](https://github.com/dmtrKovalenko/fff) |
| `npm:pi-rtk-optimizer` | [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) |
| `npm:pi-web-access` | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) |
| `npm:pi-mcp-adapter` | [nicobailon/pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter) |
| `npm:pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `npm:pi-subagents` | — |
| `npm:pi-background-tasks` | [ismailsaleekh/pi-background-tasks](https://github.com/ismailsaleekh/pi-background-tasks) |
| `npm:pi-interactive-shell` | [nicobailon/pi-interactive-shell](https://github.com/nicobailon/pi-interactive-shell) |
| `npm:@pi-plugins/checkpoint` | [k3dom/pi-plugins](https://github.com/k3dom/pi-plugins) |
| `npm:pi-hermes-memory` | [chandra447/pi-hermes-memory](https://github.com/chandra447/pi-hermes-memory) |
| `npm:@narumitw/pi-plan-mode` | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) |
| `npm:@narumitw/pi-statusline` | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) |
| `npm:@narumitw/pi-worktree` | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) |
| `npm:pi-btw` | [dbachelder/pi-btw](https://github.com/dbachelder/pi-btw) |

### pi config files

Deployed into `~/.pi/agent/` by `scripts/install-pi.sh`.

| File | Deployed to | What it does |
| --- | --- | --- |
| `pi/AGENTS.md` | `~/.pi/agent/AGENTS.md` | Global agent instructions (R/air/jarl workflow, security, review priorities) |
| `pi/settings.json` | `~/.pi/agent/settings.json` | Packages list, theme, default model, thinking level |
| `pi/models.json` | `~/.pi/agent/models.json` | Custom providers with env-var API keys (commandcode) |
| `pi/extensions/pi-rtk-optimizer/config.json` | `~/.pi/agent/extensions/pi-rtk-optimizer/config.json` | RTK output compaction settings |

---

## omp-specific elements

These are specific to the OMP harness
(`@oh-my-pi/pi-coding-agent`). They use OMP's marketplace/plugin system and
deploy into `~/.omp/agent/`.

### OMP marketplace plugins

Installed via `omp plugin install`. The marketplace is the plugin registry
that OMP queries to find and install plugins.

#### from `anthropics/claude-plugins-official`

Source repo: [github.com/anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)

| Plugin ID | What it provides |
| --- | --- |
| `context7` | Upstream docs lookup |
| `github` | GitHub CLI integration |
| `claude-md-management` | CLAUDE.md file management |
| `data` | Data analysis tools |
| `duckdb-skills` | DuckDB SQL integration |
| `code-review` | Structured code review |
| `code-simplifier` | Code simplification |
| `skill-creator` | Create new skills |
| `session-report` | Session summaries |
| `remember` | Cross-session memory |
| `firecrawl` | Web scraping |
| `hookify` | Hook management |
| `claude-code-setup` | Setup wizard |
| `pr-review-toolkit` | PR review workflow |

#### from `pymc-labs/python-analytics-skills`

Source repo: [github.com/pymc-labs/python-analytics-skills](https://github.com/pymc-labs/python-analytics-skills)

| Plugin ID | What it provides |
| --- | --- |
| `analytics` | Python analytics (PyMC, ArviZ, Stan, JAX, PyTensor) |

### OMP npm plugins

| Package | GitHub |
| --- | --- |
| `npm:@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `npm:pi-rtk-optimizer` | [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) |
| `npm:omp-cache-optimizer` | npm only |
| `npm:omp-headroom` | npm only |
| `npm:omp-mode-switch` | npm only |
| `npm:@oh-my-pi/omp-stats` | npm only |

### OMP config files

Deployed into `~/.omp/agent/` and `~/.agents/` by `scripts/install-omp.sh`.

| File | Deployed to | What it does |
| --- | --- | --- |
| `omp/AGENTS.md` | `~/.agents/AGENTS.md` | Global agent instructions (rtk workflow) |
| `omp/omp-manifest.yml` | `~/.omp/agent/` | Plugin registry, settings, extension configs |
