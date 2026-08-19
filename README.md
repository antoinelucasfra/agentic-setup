# agentic-setup — personal pi configuration

Opinionated [pi](https://pi.dev) coding harness configuration. Clone once,
run one script, get the same setup everywhere.

This repo **is** the config: `git clone` + `install.sh` wires it into
`~/.pi/agent/` (pi home). No secrets live in this repo — providers use
env-var keys, credentials stay on each machine.

## Install on a new device

```bash
curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/install.sh | bash
```

That script:

1. Installs the pi CLI if missing (`npm i -g --ignore-scripts @earendil-works/pi-coding-agent`)
2. Clones (or pulls) this repo into `~/.agents/`
3. Installs CLI tools (gh, uv, air, jarl, ruff) if missing
4. Wires `pi/` overlay files into `~/.pi/agent/` (backs up existing files first; `--link` uses symlinks when supported)
5. Installs the configured pi packages (`pi install` for each entry in `pi/settings.json`)

Manual alternative:

```bash
git clone https://github.com/antoinelucasfra/agentic-setup.git ~/.agents
bash ~/.agents/scripts/install.sh
```

### After install: authenticate

The repo ships **no credentials**. On each new machine:

```bash
pi /login                    # select provider (opencode-go, ...) or
export CMD_API_KEY=...       # commandcode provider key (see pi/models.json)
pi update --models           # refresh model catalogs (e.g. opencode-go)
```

Start `pi` in any project; global config is picked up automatically.

## Layout

| Path | Wired to | What |
| --- | --- | --- |
| `pi/AGENTS.md` | `~/.pi/agent/AGENTS.md` | Global agent instructions |
| `pi/settings.json` | `~/.pi/agent/settings.json` | Packages, theme, default model/thinking |
| `pi/models.json` | `~/.pi/agent/models.json` | Custom providers (env-var keys only) |
| `pi/extensions/` | `~/.pi/agent/extensions/` | Extension configs (rtk-optimizer) |
| `skills/` | `~/.agents/skills/` (native pi discovery) | 97 Agent Skills, loaded on-demand |
| `rules/` | reference only | Coding rules (content folded into `pi/AGENTS.md`) |
| `scripts/install.sh` | — | Bootstrap: install pi + deps, wire config, install packages |
| `scripts/setup.sh` | — | CLI tool installer (air, jarl, ruff, uv, gh) |

pi natively loads `~/.agents/skills/`, so on machines where the repo is
cloned to `~/.agents` the skills are picked up with no extra wiring.

## Update

```bash
cd ~/.agents && git pull && bash scripts/install.sh
```

## Dependencies

| Tool | Required? | Used for | Install |
| --- | --- | --- | --- |
| pi CLI | yes | the harness | `npm install -g --ignore-scripts @earendil-works/pi-coding-agent` |
| `gh` | yes | PR creation, issue management (`github-issues` skill) | system / brew / scoop / winget |
| `uv` | yes | Python project gates (ruff, pytest) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `air` | recommended | R code formatting | `uv tool install air-formatter` |
| `jarl` | recommended | R code linting | `curl -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh \| sh` |
| `ruff` | recommended | Python linting | `uv tool install ruff` |

## Contributing to this config

- Global instructions live in `pi/AGENTS.md` — edit there, not in the root `AGENTS.md` (that one is project instructions for this repo only).
- Add features as **skills** under `skills/` (Agent Skills spec) or as **pi packages** (`pi install npm:@scope/pkg`).
- No secrets, ever: `auth.json`-style credentials stay out; providers use `$ENV_VAR` keys.
