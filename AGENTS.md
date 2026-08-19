# Project Instructions — this repo

This repository is **your pi coding harness configuration**, not a code
project. It is git-clone-installable: new devices clone it and
`scripts/install.sh` wires it into `~/.pi/agent/`.

## Structure (source of truth)

- `pi/` — overlay written into `~/.pi/agent/` by `scripts/install.sh`.
  `pi/AGENTS.md` holds the **global agent instructions**.
- `skills/` — Agent Skills (agentskills.io spec). pi loads
  `~/.agents/skills/` natively; install.sh symlinks/copies `skills/` there.
- `rules/` — reference rules; content is folded into `pi/AGENTS.md`.
- `scripts/` — `install.sh` (bootstrap/wiring), `setup.sh` (CLI deps).

## Editing rules

- **Global instructions**: edit `pi/AGENTS.md`, not the root `AGENTS.md`
  (this file). Root AGENTS.md only documents how to work in this repo.
- Changes under `pi/` take effect on machines after
  `git pull && bash scripts/install.sh` in the clone (or re-run install).
- **No secrets**: never commit API keys or `auth.json`. New providers go in
  `pi/models.json` with `$ENV_VAR` key references.
- Keep `scripts/install.sh` idempotent — it may re-run on any machine.
- Before pushing `skills/` changes, keep the repo in sync with the live
  `~/.agents/skills/` superset (97 skills).
- After edits, run `bash scripts/install.sh` on this machine to keep the
  live `~/.pi/agent/` wired to the repo.
