# agentic-setup — personal coding-harness configuration

Opinionated coding-agent configuration, installable via one git clone. Supports
**two harnesses in one repo** — [pi](https://pi.dev) (recommended) and **OMP**
(`@oh-my-pi/pi-coding-agent`) — and the installer asks which one you want.

No secrets live in this repo — providers use env-var keys, credentials stay on
each machine.

## Install on a new device

**Prerequisites:** `git`, `node` + `npm`, and `python` (the installer checks these and warns if any are missing). Internet access required.

**1. Run the installer (one command):**

```bash
curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/install.sh | bash
```

It clones the repo into `~/.agents/`, installs the shared CLI tools (`gh`, `uv`, `jarl`, `air`, `ruff`), then **prompts you which config to install**: `1) pi (recommended)` or `2) omp`.

### Option A — pi (recommended)

At the prompt choose **1**. `install-pi.sh` then:

1. Wires `pi/AGENTS.md`, `settings.json`, `models.json`, `extensions/` into `~/.pi/agent/`
2. Deploys `pi/skills` (~100 skills) → shared skills dir and `pi/rules` → rules dir
3. Installs all 19 configured pi packages

**Authenticate** (no credentials ship in the repo — keys are env vars):

```bash
pi /login                        # provider key / subscription
export CMD_API_KEY=...           # commandcode provider (see ~/.pi/agent/models.json)
export UNSLOTH_API_KEY=...       # unsloth provider (see ~/.pi/agent/models.json)
pi update --models               # refresh model catalogs
```

Tip: put the exports in `~/.bashrc` / `~/.zshrc` so they survive reboots.

Start: `pi`.

### Set up sync (pi devices only)

The repo is the single source of truth for pi config across devices. Sync is
manual and explicit:

- **Inside pi:** run `/sync-repo` — pushes your live config to GitHub
- **In a shell:** `bash ~/.agents/agentic-setup/scripts/sync.sh` (same thing)

What it does: `git pull --rebase` → copies live config (settings, models,
extensions, skills, rules) into the repo → commits as `sync from <hostname>` →
pushes. Skips silently when nothing changed. Refuses to run if a hardcoded API
key is detected in models.json, and stops on git conflicts instead of guessing.

To **pull** other machines' changes into this device, re-run the installer:

```bash
cd ~/.agents/agentic-setup && git pull && bash scripts/install.sh pi
```

Typical rhythm: finish work on device A → `/sync-repo`; before starting on
device B → `git pull && bash scripts/install.sh pi`. Memory DB, sessions, and
credentials stay per-device by design.

### Option B — omp

At the prompt choose **2**. `install-omp.sh` then:

1. Installs the `omp` CLI and `yq`
2. Applies `omp/omp-manifest.yml` to `~/.omp/agent/` (settings, extension configs, marketplaces, plugins — incl. claude-plugins-official, python-analytics-skills, ponytail, rtk-optimizer)
3. Wires `omp/AGENTS.md` → `~/.agents/AGENTS.md` and deploys the shared skills → `~/.agents/skills`

**Authenticate:** `omp` then `/login`.

Start: `omp`.

### Non-interactive (skip the prompt)

```bash
bash scripts/install.sh pi    # install pi config only
bash scripts/install.sh omp   # install OMP config only
```

### Update later

```bash
cd ~/.agents && git pull && bash scripts/install.sh
```

Re-running is idempotent: unchanged files are left alone, changed ones are backed up to `*.bak.<timestamp>` before being wired.
## Layout

| Path | Harness | Deployed to | What |
| --- | --- | --- | --- |
| `pi/AGENTS.md` | pi | `~/.pi/agent/AGENTS.md` | Global agent instructions |
| `pi/settings.json` | pi | `~/.pi/agent/settings.json` | Packages, theme, default model/thinking |
| `pi/models.json` | pi | `~/.pi/agent/models.json` | Custom providers (env-var keys only) |
| `pi/extensions/` | pi | `~/.pi/agent/extensions/` | Custom extensions (`sync-repo.ts`, `review.ts`, provider syncs, rtk-optimizer config) |
| `pi/skills/` | pi | shared skills dir | ~100 Agent Skills (loaded on-demand) |
| `pi/rules/` | pi | `~/.pi/agent/rules/` | Coding rules (folded into `pi/AGENTS.md`) |
| `omp/AGENTS.md` | omp | `~/.agents/AGENTS.md` | OMP global instructions (rtk) |
| `omp/omp-manifest.yml` | omp | `~/.omp/agent/` | OMP plugins, settings, extension configs |
| `scripts/install.sh` | both | — | Entry point: prompts `pi` / `omp` |
| `scripts/install-pi.sh` | pi | — | Deploys `pi/` → `~/.pi/agent/` + packages |
| `scripts/install-omp.sh` | omp | — | Applies `omp/` manifest + AGENTS.md + skills |
| `scripts/setup.sh` | both | — | CLI tool installer (gh, uv, air, jarl, ruff) |
| `scripts/sync.sh` | pi | — | Live config → repo sync (used by `/sync-repo`) |
| `.github/workflows/ci.yml` | — | — | CI: validates JSON/YAML + shellchecks scripts on every push |

`pi/` is self-contained: everything pi needs (instructions, settings, models,
extensions, skills, rules) lives under it. `omp/` is likewise self-contained.
The skills are shared: `install-omp.sh` deploys the same portable `pi/skills`.

## Update

```bash
cd ~/.agents && git pull && bash scripts/install.sh
```

Re-running is idempotent. Unchanged files are left alone; changed ones are backed
up to `*.bak.<timestamp>` before being wired.

## Dependencies

| Tool | Used by | Used for | Install |
| --- | --- | --- | --- |
| `git` | both | clone/pull the repo | **prerequisite** — setup.sh checks + warns |
| `node`+`npm` | both | harness installers | **prerequisite** — setup.sh checks + warns |
| `python` | both | package extraction | **prerequisite** — setup.sh checks + warns |
| pi CLI | pi | the harness | `npm install -g --ignore-scripts @earendil-works/pi-coding-agent` (by `install-pi.sh`) |
| omp CLI | omp | the harness | `npm install -g @oh-my-pi/pi-coding-agent` (by `install-omp.sh`) |
| `gh` | both | PR/issue management | system / brew / scoop / winget |
| `uv` | both | Python gates (ruff, pytest) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `yq` | omp | applying the OMP manifest | `uv tool install yq` / brew / scoop (by `install-omp.sh`) |
| `air` | both | R code formatting | `uv tool install air-formatter` |
| `jarl` | both | R code linting | `curl -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh \| sh` |
| `ruff` | both | Python linting | `uv tool install ruff` |

## Contributing to this config

- **Global instructions** for pi live in `pi/AGENTS.md` (not the root `AGENTS.md`, which documents this repo only).
- pi features are **skills** under `pi/skills/` (Agent Skills spec) or **pi packages** (`pi install npm:@scope/pkg`).
- OMP features go in `omp/omp-manifest.yml`.
- **No secrets, ever**: credentials stay out; providers use `$ENV_VAR` keys.
