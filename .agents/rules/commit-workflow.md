---
description: Canonical git workflow — feature branches, conventional commits, prek pre-commit gate, PRs. Apply before any commit.
alwaysApply: true
---
# Commit Workflow

- **Branch**: `<type>/<short-description>` (`feat`/`fix`/`chore`/`docs`/`test`/`refactor`; +`render:` for Quarto). Never commit or push to `main`.
- **Gate**: always run `prek run --all-files` before committing (formatting/styling/lint — `air`+`jarl` for R, `ruff`+`uv-lock` for Python, `quarto render` in CI). `prek` is installed as the repo git `pre-commit` hook, so it runs automatically; run it explicitly first so its auto-fixes get staged.
- **Stage**: intent-specific files; respect `.gitignore`; **never** commit secrets (`.env`, tokens). Relative paths only.
- **Message**: Conventional Commits (`feat:`/`fix:`/`chore:`/`docs:`/`test:`/`refactor:`; `render:` for Quarto doc changes).
- **PR**: open via `gh` from the feature branch; never push `main`.
- **Auto-commit**: the regular auto-commit hook (OMP `turn_end`) runs `prek` then commits WIP as `chore: wip [auto-commit]` on the feature branch only — it never pushes and never commits on `main`.
