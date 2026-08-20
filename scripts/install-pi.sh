#!/usr/bin/env bash
# agentic-setup — install the pi configuration from this repo.
# Wires pi/ into ~/.pi/agent/ (AGENTS.md, settings, models, extensions,
# skills, rules) and installs the configured pi packages.
#
# Invoked by scripts/install.sh, or directly:
#   bash scripts/install-pi.sh                      # repo = this clone
#   bash scripts/install-pi.sh /path/to/repo       # repo elsewhere
#   bash scripts/install-pi.sh /path/to/repo --link # symlink when supported

set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PI_HOME="${HOME}/.pi/agent"
USE_LINK=false
[[ "${2:-}" == "--link" ]] && USE_LINK=true

info() { echo "  -> $*"; }
ok() { echo "  [ok] $*"; }
skip() { echo "  [skip] $*"; }
warn() { echo "  [warn] $*"; }

# ---- 1. pi CLI ----
if ! command -v pi &>/dev/null; then
  info "Installing pi via npm (--ignore-scripts) ..."
  if command -v npm &>/dev/null; then
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
  elif command -v bun &>/dev/null; then
    bun install -g @earendil-works/pi-coding-agent
  else
    warn "Neither npm nor bun found. Install pi manually, then re-run:"
    warn "  npm install -g --ignore-scripts @earendil-works/pi-coding-agent"
    exit 1
  fi
else
  skip "pi CLI already installed ($(pi --version 2>/dev/null || echo unknown))"
fi

# ---- 2. Wire pi/ overlay into ~/.pi/agent/ ----
echo ""
echo "=== Wiring pi config into $PI_HOME ==="
mkdir -p "$PI_HOME"

wire_file() { # $1 = repo-relative path, $2 = target path
  local src="$REPO_ROOT/$1" dst="$2"
  if [[ -L "$dst" ]]; then
    ln -sfn "$src" "$dst" 2>/dev/null && {
      ok "$1 -> $dst"
      return 0
    }
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

wire_file "pi/AGENTS.md" "$PI_HOME/AGENTS.md"
wire_file "pi/settings.json" "$PI_HOME/settings.json"
wire_file "pi/models.json" "$PI_HOME/models.json"
mkdir -p "$PI_HOME/extensions/pi-rtk-optimizer"
wire_file "pi/extensions/pi-rtk-optimizer/config.json" "$PI_HOME/extensions/pi-rtk-optimizer/config.json"

# ---- 3. Deploy pi/skills -> ~/.pi/agent/skills (native pi global skills) ----
deploy_skills() { # $1 = source dir, $2 = target dir
  local src="$1" dst="$2"
  if [[ -e "$dst" ]] && ! [[ -L "$dst" ]] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
    ok "$(basename "$src") already up to date at $dst"
    return 0
  fi
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    info "backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  fi
  if $USE_LINK; then
    if ln -s "$src" "$dst" 2>/dev/null; then
      ok "$(basename "$src") -> $dst (symlink)"
      return 0
    fi
    warn "symlink failed for $dst — copying instead"
  fi
  cp -r "$src" "$dst" && ok "$(basename "$src") -> $dst (copy)"
}
deploy_skills "$REPO_ROOT/pi/skills" "$PI_HOME/skills"

# ---- 4. Deploy pi/rules -> ~/.pi/agent/rules (reference) ----
deploy_skills "$REPO_ROOT/pi/rules" "$PI_HOME/rules"

# ---- 5. Install configured pi packages ----
echo ""
echo "=== Installing pi packages ==="
PACKAGES="$(python -c 'import json,sys;print("\n".join(json.load(open(sys.argv[1])).get("packages",[])))' "$REPO_ROOT/pi/settings.json" 2>/dev/null || true)"
if [[ -z "$PACKAGES" ]]; then
  skip "no packages in pi/settings.json"
else
  for pkg in $PACKAGES; do
    info "pi install $pkg"
    pi install "$pkg" || warn "failed to install $pkg"
  done
fi

echo ""
echo "=== pi configuration installed ==="
echo "Config wired from $REPO_ROOT/pi into $PI_HOME."
echo "Finish authentication on this device:"
echo "  pi /login              # provider key/subscription"
echo "  export CMD_API_KEY=... # commandcode provider (see $PI_HOME/models.json)"
echo "  pi update --models     # refresh model catalogs"
echo "Then:  pi"
