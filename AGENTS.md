# Project Instructions — this repo

This repository is **your coding-harness configuration**, not a code project.
It is git-clone-installable: new devices clone it and `scripts/install.sh`
asks whether to install the **pi** or **OMP** configuration, then wires the
chosen one into that harness's home.

## Structure

- `pi/` — self-contained pi config, deployed by `scripts/install-pi.sh` into
  `~/.pi/agent/`. `pi/AGENTS.md` = global instructions; `pi/skills/`,
  `pi/rules/`, `pi/extensions/`, `pi/models.json`, `pi/settings.json`.
- `omp/` — self-contained OMP config, deployed by `scripts/install-omp.sh`.
  `omp/omp-manifest.yml` = OMP plugins/settings/extensions; `omp/AGENTS.md` =
  OMP global instructions.
- `scripts/` — `install.sh` (entry point + `pi`/`omp` prompt),
  `install-pi.sh`, `install-omp.sh`, `setup.sh` (shared CLI deps).

## Editing rules

- **pi global instructions**: edit `pi/AGENTS.md`, never the root `AGENTS.md`
  (this file — project instructions only for working in this repo).
- **OMP config**: edit `omp/omp-manifest.yml` / `omp/AGENTS.md`.
- `pi/` encapsulates everything pi needs — keep pi additions under `pi/`
  (skills in `pi/skills/`, packages via `pi install` then commit the settings
  change, extension configs under `pi/extensions/`).
- **No secrets**: never commit API keys or `auth.json`. Providers use
  `$ENV_VAR` keys in `pi/models.json`.
- Keep all installers idempotent — they re-run on any machine, any harness.
- After edits, re-run the relevant installer on this machine to keep the live
  harness wired to the repo.
