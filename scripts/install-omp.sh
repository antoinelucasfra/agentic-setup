#!/usr/bin/env bash
# agentic-setup — install the OMP configuration from this repo.
# Installs the omp CLI, applies omp/omp-manifest.yml (settings, extension
# configs, marketplaces, plugins) to ~/.omp/agent/, wires omp/AGENTS.md into
# ~/.agents/AGENTS.md, and deploys the shared skills to ~/.agents/skills.
#
# Invoked by scripts/install.sh, or directly:
#   bash scripts/install-omp.sh                      # repo = this clone
#   bash scripts/install-omp.sh /path/to/repo        # repo elsewhere
#   bash scripts/install-omp.sh /path/to/repo --link

set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
USE_LINK=false
[[ "${2:-}" == "--link" ]] && USE_LINK=true

OMP_CONFIG_HOME="${HOME}/.omp/agent"
AGENTS_TARGET="${HOME}/.agents/AGENTS.md"
SKILLS_TARGET="${HOME}/.agents/skills"

info()  { echo "  -> $*"; }
ok()    { echo "  [ok] $*"; }
skip()  { echo "  [skip] $*"; }
warn()  { echo "  [warn] $*"; }

# ---- 1. omp CLI ----
if ! command -v omp &>/dev/null; then
  info "Installing omp via npm ..."
  if command -v npm &>/dev/null; then
    npm install -g @oh-my-pi/pi-coding-agent
  elif command -v bun &>/dev/null; then
    bun install -g @oh-my-pi/pi-coding-agent
  else
    warn "Neither npm nor bun found. Install omp manually, then re-run:"
    warn "  npm install -g @oh-my-pi/pi-coding-agent"
    exit 1
  fi
else
  skip "omp CLI already installed"
fi

# ---- 2. yq (needed to apply the manifest) ----
if ! command -v yq &>/dev/null; then
  info "Installing yq ..."
  if command -v uv &>/dev/null; then
    uv tool install yq >/dev/null 2>&1 && ok "yq" || warn "yq install failed — install yq and re-run"
  elif command -v brew &>/dev/null; then
    brew install yq >/dev/null 2>&1 && ok "yq" || warn "yq install failed"
  else
    warn "yq not found and no installer — manifest not applied"
  fi
else
  skip "yq already installed"
fi

# ---- 3. Apply omp-manifest.yml (settings, extension configs, plugins) ----
MANIFEST="$REPO_ROOT/omp/omp-manifest.yml"
if command -v yq &>/dev/null && [[ -f "$MANIFEST" ]]; then
  echo ""
  echo "=== Applying OMP manifest ==="
  mkdir -p "$OMP_CONFIG_HOME" "$OMP_CONFIG_HOME/extensions"
  yq eval '.settings' "$MANIFEST" > "$OMP_CONFIG_HOME/config.yml" && ok "settings -> $OMP_CONFIG_HOME/config.yml"
  for name in $(yq eval '.extensions | keys | .[]' "$MANIFEST" 2>/dev/null); do
    d="$OMP_CONFIG_HOME/extensions/$name"
    mkdir -p "$d"
    yq eval ".extensions.\"$name\"" "$MANIFEST" -o=json > "$d/config.json" 2>/dev/null && ok "extension config -> $d/config.json"
  done
  for source in $(yq eval '.marketplaces[].source' "$MANIFEST" 2>/dev/null); do
    omp plugin marketplace list 2>/dev/null | grep -qF "$source" || omp plugin marketplace add "$source" >/dev/null 2>&1 || true
  done
  for id in $(yq eval '.plugins[].id' "$MANIFEST" 2>/dev/null); do
    omp plugin list 2>/dev/null | grep -qF "$id" || omp plugin install "$id" >/dev/null 2>&1 || true
  done
  ok "marketplaces + plugins reconciled (see 'omp plugin list')"
else
  warn "yq or manifest missing — skipping manifest apply"
fi

# ---- 4. Wire omp/AGENTS.md -> ~/.agents/AGENTS.md ----
mkdir -p "${HOME}/.agents"
if [[ -f "$AGENTS_TARGET" ]] && ! cmp -s "$REPO_ROOT/omp/AGENTS.md" "$AGENTS_TARGET"; then
  cp "$AGENTS_TARGET" "$AGENTS_TARGET.bak.$(date +%Y%m%d%H%M%S)"
  info "backed up existing $AGENTS_TARGET"
fi
cp "$REPO_ROOT/omp/AGENTS.md" "$AGENTS_TARGET" && ok "AGENTS.md -> $AGENTS_TARGET"

# ---- 5. Deploy shared skills -> ~/.agents/skills ----
if [[ -L "$SKILLS_TARGET" ]]; then
  rm "$SKILLS_TARGET"
elif [[ -e "$SKILLS_TARGET" ]]; then
  info "backing up existing $SKILLS_TARGET"
  mv "$SKILLS_TARGET" "$SKILLS_TARGET.bak.$(date +%Y%m%d%H%M%S)"
fi
if $USE_LINK; then
  if ln -s "$REPO_ROOT/pi/skills" "$SKILLS_TARGET" 2>/dev/null; then
    ok "skills -> $SKILLS_TARGET (symlink)"
  else
    cp -r "$REPO_ROOT/pi/skills" "$SKILLS_TARGET" && ok "skills copied to $SKILLS_TARGET"
  fi
else
  cp -r "$REPO_ROOT/pi/skills" "$SKILLS_TARGET" && ok "skills copied to $SKILLS_TARGET"
fi

echo ""
echo "=== OMP configuration installed ==="
echo "Config applied from $REPO_ROOT/omp into $OMP_CONFIG_HOME + ~/.agents."
echo "Start the agent:  omp"