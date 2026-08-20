# catalog — extensions, plugins, and skills

Every item shipped in this config, with its original GitHub source URL where
available. Data resolved from package.json `repository` fields, SKILL.md
citations, and the OMP manifest on 2026-08-20.

Skills with no recorded origin in the repo are listed under
[bundled skills](#bundled-skills--origin-not-recorded).

---

## pi extensions

Pi extensions are config files written to `~/.pi/agent/extensions/`. Each is
provided by a pi npm package.

| Extension | Package | GitHub |
| --- | --- | --- |
| `pi-rtk-optimizer` | `npm:pi-rtk-optimizer` | [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) |
| `pi-lens` (ast-grep, lsp-navigation, tree-sitter rules) | `npm:pi-lens` | [apmantza/pi-lens](https://github.com/apmantza/pi-lens) |
| `pi-mcp-adapter` | `npm:pi-mcp-adapter` | [nicobailon/pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter) |
| `pi-fff` | `npm:@ff-labs/pi-fff` | [dmtrKovalenko/fff](https://github.com/dmtrKovalenko/fff) |
| `pi-web-access` | `npm:pi-web-access` | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) |
| `pi-agent-browser-native` | `npm:pi-agent-browser-native` | [fitchmultz/pi-agent-browser-native](https://github.com/fitchmultz/pi-agent-browser-native) |
| `pi-background-tasks` | `npm:pi-background-tasks` | [ismailsaleekh/pi-background-tasks](https://github.com/ismailsaleekh/pi-background-tasks) |
| `pi-hashline-edit-pro` | `npm:pi-hashline-edit-pro` | [YuGiMob/pi-hashline-edit-pro](https://github.com/YuGiMob/pi-hashline-edit-pro) |
| `pi-subagents` | `npm:@tintinweb/pi-subagents` | [tintinweb/pi-subagents](https://github.com/tintinweb/pi-subagents) |
| `pi-blackhole` | `npm:pi-blackhole` | [k0valik/pi-blackhole](https://github.com/k0valik/pi-blackhole) |

---

## pi plugins (packages)

Installed into `~/.pi/agent/npm/node_modules` via `pi install`. Each package
may register extensions, skills, or both.

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
| `npm:@tintinweb/pi-subagents` | [tintinweb/pi-subagents](https://github.com/tintinweb/pi-subagents) |
| `npm:pi-background-tasks` | [ismailsaleekh/pi-background-tasks](https://github.com/ismailsaleekh/pi-background-tasks) |
| `npm:pi-hashline-edit-pro` | [YuGiMob/pi-hashline-edit-pro](https://github.com/YuGiMob/pi-hashline-edit-pro) |
| `npm:pi-agent-browser-native` | [fitchmultz/pi-agent-browser-native](https://github.com/fitchmultz/pi-agent-browser-native) |

---

## OMP plugins

Applied from `omp/omp-manifest.yml` into `~/.omp/agent/`. Installed via
`omp plugin install`.

### Marketplace plugins (from `anthropics/claude-plugins-official`)

Installed as `marketplace-id@anthropics/claude-plugins-official`. Source repo:
[github.com/anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)

| Plugin ID |
| --- |
| `context7` |
| `github` |
| `claude-md-management` |
| `data` |
| `duckdb-skills` |
| `code-review` |
| `code-simplifier` |
| `skill-creator` |
| `session-report` |
| `remember` |
| `firecrawl` |
| `hookify` |
| `claude-code-setup` |
| `pr-review-toolkit` |

### Marketplace plugins (from `pymc-labs/python-analytics-skills`)

Source repo:
[github.com/pymc-labs/python-analytics-skills](https://github.com/pymc-labs/python-analytics-skills)

| Plugin ID |
| --- |
| `analytics` |

### npm plugins

| Package | GitHub |
| --- | --- |
| `npm:@dietrichgebert/ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |
| `npm:pi-rtk-optimizer` | [MasuRii/pi-rtk-optimizer](https://github.com/MasuRii/pi-rtk-optimizer) |
| `npm:omp-cache-optimizer` | npm only |
| `npm:omp-headroom` | npm only |
| `npm:omp-mode-switch` | npm only |
| `npm:@oh-my-pi/omp-stats` | npm only |

---

## skills with a recorded origin

These 35 skills have a verifiable source: either provided by a pi npm package
(package.json `pi.skills`) or cited in the skill's own SKILL.md / lockfile.

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

---

## bundled skills — origin not recorded

These 72 skills are shipped directly in `pi/skills/`. No origin URL is embedded
in their SKILL.md and they are not provided by any pi npm package. They were
collected from the [agent-skills.io](https://agentskills.io) ecosystem and
related communities. If you know the source repo for one, open a PR.

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
