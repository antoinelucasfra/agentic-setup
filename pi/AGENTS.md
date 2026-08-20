# Global Agent Instructions

## R Code Formatting & Linting

- **Format R files (.R, .r, .Rmd, .qmd) with `air format`** — never `styler`, never `formatR`.
  - Single file: `air format path/to/file.R`
  - Directory: `air format path/to/dir`
  - Check-only (no write): `air format --check path/to/file.R`
  - Air follows the tidyverse style guide: two-space indents, ~100-char lines.
- **Lint R files with `jarl check`** — never `lintr`.
  - `jarl check path/to/file.R` (or `jarl check .` for a directory)
  - Fix auto-fixable lints: `jarl check --fix path/to/file.R`
- After writing or editing R code, run `air format` and `jarl check` on the touched files and fix any issues they reveal.
- Both tools are CLI binaries: `air` and `jarl` are on PATH (`~/.local/bin/`).
- R LSP diagnostics in this environment come from the `jarl` language server (registered via pi-lens custom server config in `~/.pi-lens/lsp.json`).

## Tool Selection

- Prefer pi's specialized tools (`read`, `ffgrep`, `fffind`, `replace`) over raw shell for listing, searching, and reading files. Don't route exploration through `ls`/`find`/`grep`/`cat` in bash.
- Shell out only when a real subprocess is required (builds, git, docker, data pipelines, inspection). When a shell command is genuinely needed, use the Modern CLI Tools below — never the POSIX originals (`ls`, `cat`, `find`, `grep`, `sed`, `cd`, `diff`).
- When the `rtk` token-optimizing CLI proxy is available and configured, prefix shell commands with it (`rtk git status`). If `rtk` is missing or broken on a machine, use plain commands — never let an unavailable proxy block work.

## Modern CLI Tools

Rust-based replacements for the POSIX originals. All are installed in `~/.pi/agent/bin` (already on PATH). Use them whenever a shell subprocess is required instead of `ls`/`cat`/`find`/`grep`/`sed`/`cd`/`diff`.

| Task | Old | Modern | Usage |
|------|-----|--------|-------|
| List files | `ls` | `eza` | `eza -l --git --icons` (long form, git status, icons) |
| Read / print files | `cat` | `bat` | `bat --paging=never file` (never page when piping/non-interactive) |
| Find files | `find` | `fd` | `fd <pattern>` (respects .gitignore, sane defaults) |
| Search file contents | `grep` | `rg` (ripgrep) | `rg -n <pattern>` (already used by pi's `ffgrep`) |
| Change directory | `cd` | `z` (zoxide) | `z <partial>` jumps to frequent/recent dirs |
| Stream edit | `sed` | `sd` | `sd 'find' 'replace'` (no regex escaping needed) |
| Diff / git diff | `diff` | `delta` | set as the `git` and `git diff` pager |
| Fuzzy pick from a list | — | `fzf` | pipe any list into `fzf` for interactive filtering |

Notes:
- `bat` and `delta` work with zero config. `delta` is wired as the git pager in this environment.
- `z` (zoxide) requires `eval "$(zoxide init bash)"` in the shell profile to define the `z` function; the `zoxide` binary itself works without it. This is already sourced in interactive/bash profiles here.
- If a tool is unexpectedly missing, fall back to the POSIX original rather than failing — and report the gap so it can be reinstalled.

## Security & OWASP (condensed)

Security-first default. When in doubt, choose the more secure option. Flag the risk when you identify a pattern — not just the fix.

- **Access control**: deny by default, least privilege, validate URLs for SSRF, prevent path traversal.
- **Crypto**: Argon2id/bcrypt for passwords, HTTPS in transit, AES-256 at rest. No hardcoded secrets — env vars only.
- **Injection**: parameterized queries (never raw SQL string concat), sanitize shell input, context-aware output encoding (`.textContent` over `.innerHTML`).
- **Config**: disable debug in production, set security headers (CSP, HSTS, X-Content-Type-Options), keep deps updated.
- **Auth**: rotate session IDs on login, HttpOnly+Secure+SameSite cookies, rate-limit login, MFA for privileged accounts.
- **Deserialization**: prefer JSON over Pickle, validate untrusted input.
- **LLM/AI code**: treat LLM output as untrusted input — parameterize, validate against schemas.

## Agent Safety & Governance

- **Fail closed**: deny on ambiguity.
- **Least privilege**: minimum tool access for the task.
- Never hardcode secrets or allow agents to self-modify governance.

## Code Review Priorities

When reviewing code, prioritize issues in this order:

- 🔴 **CRITICAL** (block merge): security vulnerabilities, exposed secrets, auth/authorization issues, logic errors, data corruption/loss risks, race conditions.
- 🟡 **IMPORTANT** (discuss): code quality (SOLID violations, duplication), missing test coverage for critical paths, performance bottlenecks (N+1, leaks), architecture deviations.
- 🟢 **SUGGESTION** (non-blocking): readability, minor optimizations, convention deviations, documentation gaps.

Review principles: be specific (reference exact lines/files), explain WHY + impact, suggest concrete fixes, be constructive, group related comments.

## Post-Merge Branch Cleanup

Once a PR is merged to main, delete the branch:

- Remote: `git push origin --delete <branch>`
- Local: `git checkout main && git branch -d <branch>`

## General

- Keep responses concise.
- Prefer small, focused changes.
