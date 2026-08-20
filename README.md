# agentic-setup — personal coding-harness configuration

Opinionated coding-agent configuration, installable via one git clone. Supports
**two harnesses in one repo** — [pi](https://pi.dev) (recommended) and **OMP**
(`@oh-my-pi/pi-coding-agent`) — and the installer asks which one you want.

No secrets live in this repo — providers use env-var keys, credentials stay on
each machine.

## Install on a new device

```bash
curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/install.sh | bash
```

The installer:

1. Installs the repo into `~/.agents/` (or pulls if already present)
2. Installs shared CLI tools (gh, uv, air, jarl, ruff) if missing
3. **Prompts: install `pi` or `omp` config?** (or pass an argument to skip the prompt)
4. Wires the chosen config's full set — extensions, skills, rules, packages — into that harness's home

Non-interactive:

```bash
bash scripts/install.sh pi    # install pi config only
bash scripts/install.sh omp   # install OMP config only
```

The repo clones to `~/.agents/`. Each chosen config is deployed from there.

### After install: authenticate

The repo ships **no credentials**. On each new machine:

```bash
pi /login                     # pi: store a provider key/subscription
export CMD_API_KEY=...        # commandcode provider key (see models.json)
pi update --models            # refresh model catalogs (pi)
```

(For OMP, run `omp` and `/login` similarly.)

## Layout

| Path | Harness | Deployed to | What |
| --- | --- | --- | --- |
| `pi/AGENTS.md` | pi | `~/.pi/agent/AGENTS.md` | Global agent instructions |
| `pi/settings.json` | pi | `~/.pi/agent/settings.json` | Packages, theme, default model/thinking |
| `pi/models.json` | pi | `~/.pi/agent/models.json` | Custom providers (env-var keys only) |
| `pi/extensions/` | pi | `~/.pi/agent/extensions/` | Extension configs (rtk-optimizer) |
| `pi/skills/` | pi | `~/.pi/agent/skills/` | 97 Agent Skills (loaded on-demand) |
| `pi/rules/` | pi | `~/.pi/agent/rules/` | Coding rules (folded into `pi/AGENTS.md`) |
| `omp/AGENTS.md` | omp | `~/.agents/AGENTS.md` | OMP global instructions (rtk) |
| `omp/omp-manifest.yml` | omp | `~/.omp/agent/` | OMP plugins, settings, extension configs |
| `scripts/install.sh` | both | — | Entry point: prompts `pi` / `omp` |
| `scripts/install-pi.sh` | pi | — | Deploys `pi/` → `~/.pi/agent/` + packages |
| `scripts/install-omp.sh` | omp | — | Applies `omp/` manifest + AGENTS.md + skills |
| `scripts/setup.sh` | both | — | CLI tool installer (gh, uv, air, jarl, ruff) |

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
