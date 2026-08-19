#!/usr/bin/env bash
# agentic-setup — one-shot bootstrap for a new device.
#
# Idempotent. Installs the pi CLI if missing, clones/updates this config
# into ~/.agents, installs CLI deps, wires the pi/ overlay into ~/.pi/agent/,
# and installs the configured pi packages.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/install.sh | bash
#   bash scripts/install.sh          # from a clone
#   bash scripts/install.sh --link   # prefer symlinks over copies (Unix)
#
# No credentials are written. On a fresh device finish with:
#   pi /login            # store a provider API key / subscription
#   pi update --models   # refresh model catalogs (e.g. opencode-go)

set -euo pipefail

REPO="https://github.com/antoinelucasfra/agentic-setup.git"
TARGET="${HOME}/.agents"        # repo lives here; pi reads ~/.agents/skills natively
PI_HOME="${HOME}/.pi/agent"     # pi global config dir
USE_LINK=false
[[ "${1:-}" == "--link" ]] && USE_LINK=true

info()  { echo "  -> $*"; }
ok()    { echo "  [ok] $*"; }
skip()  { echo "  [skip] $*"; }
warn()  { echo "  [warn] $*"; }

# Repo root: when run from a clone, wire that clone; when piped via curl, clone fresh.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd)"
case "$(basename "$SRC")" in
  scripts) REPO_ROOT="$(dirname "$SRC")" ;;  # bash scripts/install.sh from a clone
  .)       REPO_ROOT="" ;;                   # piped via curl | bash — clone below
  *)       REPO_ROOT="$SRC" ;;
esac
if [[ -n "$REPO_ROOT" ]] && [[ ! -f "$REPO_ROOT/pi/AGENTS.md" ]]; then
  REPO_ROOT=""
fi

echo "=== agentic-setup install ==="

# ---- 1. pi CLI ----
if ! command -v pi &>/dev/null; then
  info "Installing pi via npm (--ignore-scripts) ..."
  if command -v npm &>/dev/null; then
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
  elif command -v bun &>/dev/null; then
    bun install -g @earendil-works/pi-coding-agent
  else
    warn "Neither npm nor bun found. Install pi manually:"
    warn "  npm install -g --ignore-scripts @earendil-works/pi-coding-agent"
    exit 1
  fi
else
  skip "pi CLI already installed ($(pi --version 2>/dev/null || echo unknown))"
fi

# ---- 2. Clone or update config into ~/.agents ----
if [[ -z "$REPO_ROOT" ]]; then
  if [[ -d "$TARGET/.git" ]] || [[ -f "$TARGET/.git" ]] || [[ -f "$TARGET/pi/AGENTS.md" ]]; then
    info "Updating existing $TARGET ..."
    git -C "$TARGET" pull --ff-only
  elif [[ -d "$TARGET" ]]; then
    info "$TARGET exists but is not this repo — backing up to $TARGET.bak ..."
    mv "$TARGET" "$TARGET.bak.$(date +%Y%m%d%H%M%S)"
    git clone "$REPO" "$TARGET"
  else
    info "Cloning config to $TARGET ..."
    git clone "$REPO" "$TARGET"
  fi
  REPO_ROOT="$TARGET"
fi
info "Using config from $REPO_ROOT"

# ---- 3. CLI deps (air, jarl, ruff, uv, gh) ----
bash "$REPO_ROOT/scripts/setup.sh"

# ---- 4. Wire pi/ overlay into ~/.pi/agent/ ----
echo ""
echo "=== Wiring config into $PI_HOME ==="
mkdir -p "$PI_HOME"

wire_file() {  # $1 = repo-relative path, $2 = target path
  local src="$REPO_ROOT/$1" dst="$2"
  if [[ -L "$dst" ]]; then
    # already a symlink — refresh target
    ln -sfn "$src" "$dst" 2>/dev/null && { ok "$1 -> $dst"; return 0; }
  fi
  if [[ -f "$dst" ]] && ! cmp -s "$src" "$dst"; then
    local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    info "backing up existing $dst -> $bak"
    cp "$dst" "$bak"
  fi
  if $USE_LINK; then
    if ln -sfn "$src" "$dst" 2>/dev/null; then
      ok "$1 -> $dst (symlink)"
    else
      warn "symlink failed for $dst — copying instead"
      cp "$src" "$dst" && ok "$1 -> $dst (copy)"
    fi
  else
    cp "$src" "$dst" && ok "$1 -> $dst (copy)"
  fi
}

wire_file "pi/AGENTS.md"            "$PI_HOME/AGENTS.md"
wire_file "pi/settings.json"        "$PI_HOME/settings.json"
wire_file "pi/models.json"          "$PI_HOME/models.json"
mkdir -p "$PI_HOME/extensions/pi-rtk-optimizer"
wire_file "pi/extensions/pi-rtk-optimizer/config.json" "$PI_HOME/extensions/pi-rtk-optimizer/config.json"

# ---- 5. Skills: pi reads ~/.agents/skills natively; link/copy when repo is elsewhere ----
if [[ "$REPO_ROOT" != "$TARGET" ]]; then
  mkdir -p "$HOME/.agents"
  if [[ -e "$HOME/.agents/skills" ]] && [[ ! -L "$HOME/.agents/skills" ]]; then
    info "backing up existing ~/.agents/skills -> ~/.agents/skills.bak"
    mv "$HOME/.agents/skills" "$HOME/.agents/skills.bak.$(date +%Y%m%d%H%M%S)"
  fi
  if $USE_LINK; then
    ln -sfn "$REPO_ROOT/skills" "$HOME/.agents/skills" 2>/dev/null && ok "skills -> $HOME/.agents/skills (symlink)" \
      || { cp -r "$REPO_ROOT/skills" "$HOME/.agents/skills" && ok "skills copied to $HOME/.agents/skills"; }
  else
    [[ -L "$HOME/.agents/skills" ]] || cp -r "$REPO_ROOT/skills" "$HOME/.agents/skills" && ok "skills copied to $HOME/.agents/skills"
  fi
else
  skip "skills already at $TARGET/skills (native pi discovery)"
fi

# ---- 6. Install configured pi packages ----
echo ""
echo "=== Installing pi packages ==="
PACKAGES="$(grep -oE '"(npm|git|https?)://?[^"]+"' "$REPO_ROOT/pi/settings.json" | tr -d '"' || true)"
if ! command -v pi &>/dev/null; then
  warn "pi not on PATH after install — open a new shell, then run:  pi install <package>"
elif [[ -z "$PACKAGES" ]]; then
  skip "no packages in pi/settings.json"
else
  for pkg in $PACKAGES; do
    info "pi install $pkg"
    pi install "$pkg" || warn "failed to install $pkg"
  done
fi

echo ""
echo "=== Done ==="
echo "Config wired from $REPO_ROOT into $PI_HOME."
echo "Finish authentication on this device:"
echo "  pi /login              # provider key/subscription"
echo "  export CMD_API_KEY=... # commandcode provider (see ~/.pi/agent/models.json)"
echo "  pi update --models     # refresh model catalogs"
echo "Then:  pi"