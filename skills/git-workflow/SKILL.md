---
name: git-workflow
description: Use this skill for any git task — creating branches, committing, opening PRs, or running pre-commit quality checks. Covers the full PR lifecycle adapted for R and Python projects in this workspace.
---

# Git Workflow

## Branch Naming

`<type>/<short-description>` — e.g. `fix/ingredient-parsing`, `feat/add-calendar-tab`, `chore/update-deps`

## Commit Message Format

- Conventional prefixes: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`
- **Extra type for `antoinelucasfra.github.io` only:** `render:` — used exclusively for commits that only update `docs/` or `_freeze/`
- Imperative mood, first line ≤ 72 characters
- Separate subject from body with a blank line; body explains *what* and *why*, not *how*
- One logical change per commit

## Pre-Commit Quality Gates

Run the appropriate gates for the project type before every commit.

### R Projects (`fitness-app`, `groupOrganizeR`, `recipeR`)

```bash
Rscript -e "air::format_project()"       # format R files (if air is available)
Rscript -e "lintr::lint_dir('R')"        # lint — fix all warnings and errors
Rscript -e "devtools::test()"            # tests — zero failures
Rscript -e "devtools::check()"           # package check — zero errors, zero warnings
```

### Python Projects (`fake-news-detection`, `voice-to-data`, `linksmith`)

```bash
uv run ruff format .                     # format
uv run ruff check .                      # lint — zero errors
uv run pytest                            # tests — zero failures (if tests exist)
```

### Quarto Site (`antoinelucasfra.github.io`)

```bash
air format .                             # format R code in .qmd chunks
uv run ruff check .                      # lint Python code
quarto render                            # render to docs/ — must succeed before pushing
```

## Full PR Lifecycle

Follow every step. Do not skip.

```bash
# 1. Start from a clean, up-to-date main
git checkout main
git fetch origin
git pull origin main

# 2. Create a feature branch
git checkout -b <type>/<short-description>

# 3. Implement changes (code, tests, docs)

# 4. Quality gates (see above for project-specific commands)

# 5. Stage and commit — stage only relevant files
git add <files>
git commit -m "<type>: <concise description>"

# 6. Push and open PR
git push -u origin <branch-name>
gh pr create --fill-first
gh pr merge --auto --squash              # enable auto-merge

# 7. Wait for CI
gh pr checks --watch
gh pr view --json state -q '.state'      # confirm MERGED

# 8. Clean up
git checkout main
git fetch origin
git pull origin main
git branch -d <branch-name>
git remote prune origin
```

## Git Rules

- Always branch from `main` unless told otherwise.
- Confirm current branch and target branch before merging or pushing.
- Never push directly to `main` — always use feature branches and PRs.
- Never amend or rebase commits already pushed to shared branches.
- Never use git worktrees without explicit user request.
- Do not squash-merge without asking.
- Never commit secrets, API keys, or credentials — use `.env` files (gitignored) and environment variables.

## Before Creating a Pull Request

1. Ensure all commits follow the commit message guidelines.
2. Run the full quality gates for the project type — zero failures, zero warnings.
3. Review the diff: look for unnecessary complexity, redundant code, and unclear naming.
4. Ensure the branch is up to date with `main` to avoid merge conflicts.
5. Conduct an iterative code review loop (max 5 rounds, stop when no new findings):
   - Categories to check each round:
     1. API misuse and platform best practices
     2. Logic bugs, edge cases, off-by-one errors
     3. Security issues (injection, path traversal, unchecked input)
     4. Error handling gaps (swallowed errors, missing guards)
     5. Resource leaks (unclosed connections, file handles, reactive observers)
     6. Cross-module duplication or inconsistency
   - Per round: find → verify against source → dismiss false positives → fix genuine issues → commit fixes
   - After convergence: run full test suite, fix any new failures, commit and push

## PR Description Guidelines

- Describe what the code does **now** — not discarded approaches or prior iterations
- Plain, factual language. Avoid: *critical*, *crucial*, *significant*, *comprehensive*, *robust*, *elegant*
- Each PR should have one clear, focused purpose — don't batch unrelated changes
- PR title follows the same conventional commit format as commit messages

## Quarto Site — Extra Rule

For `antoinelucasfra.github.io`, always make two separate commits:

```bash
# Content commit
git add posts/ projects/ index.qmd blog.qmd   # whichever .qmd files changed
git commit -m "feat(blog): Add post on <topic>"

# Render commit — always separate
git add docs/ _freeze/
git commit -m "render: Render website"
```
