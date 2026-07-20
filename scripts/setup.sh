#!/usr/bin/env bash
# OMP agentic-setup — CLI dependency installer
#
# Idempotent: safe to re-run. Skips already-installed tools.
# Usage: bash scripts/setup.sh
#        bash <(curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/setup.sh)

set -euo pipefail

# ---- Detect package manager ----
install_cmd=""
sudo_prefix=""
if command -v apt-get &>/dev/null; then
  install_cmd="apt-get install -y"
  sudo_prefix="sudo"
elif command -v brew &>/dev/null; then
  install_cmd="brew install"
  sudo_prefix=""
elif command -v scoop &>/dev/null; then
  install_cmd="scoop install"
  sudo_prefix=""
elif command -v pacman &>/dev/null; then
  install_cmd="pacman -S --noconfirm"
  sudo_prefix="sudo"
fi

info()  { echo "  → $*"; }
ok()    { echo "  ✓ $*"; }
skip()  { echo "  - $* (already installed)"; }
warn()  { echo "  ⚠ $*"; }

# ---- Install a tool if missing ----
try_install() {
  local name="$1" cmd="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    skip "$name"
    return 0
  fi
  if [[ -z "$install_cmd" ]]; then
    warn "No package manager found — install $name manually"
    return 1
  fi
  info "Installing $name ..."
  $sudo_prefix $install_cmd "$name" 2>/dev/null && ok "$name" || warn "Failed to install $name"
}

try_cargo() {
  local name="$1"
  if command -v "$name" &>/dev/null; then
    skip "$name"
    return 0
  fi
  if command -v cargo &>/dev/null; then
    info "Installing $name via cargo ..."
    cargo install "$name" 2>/dev/null && ok "$name" || warn "cargo install $name failed"
  else
    warn "cargo not found — install $name manually"
  fi
}

try_uv_tool() {
  local name="$1"
  if command -v "$name" &>/dev/null; then
    skip "$name"
    return 0
  fi
  if command -v uv &>/dev/null; then
    info "Installing $name via uv ..."
    uv tool install "$name" 2>/dev/null && ok "$name" || warn "uv tool install $name failed"
  else
    warn "uv not found — skipping $name"
  fi
}

# ---- Phase 1: Required CLI tools ----
echo ""
echo "=== Required tools ==="

# gh — GitHub CLI
try_install "gh"

# uv — Python package manager
if ! command -v uv &>/dev/null; then
  info "Installing uv ..."
  curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null && ok "uv" || warn "uv install failed"
  # Source it for the current shell
  export UV_HOME="$HOME/.local/bin"
  export PATH="$UV_HOME:$PATH"
fi

# yq — YAML processor
try_install "yq"

# ---- Phase 2: Recommended tools ----
echo ""
echo "=== Recommended tools ==="

# air — R formatter CLI
try_cargo "air"

# jarl — R linter CLI
try_cargo "jarl"

# ruff — Python linter
try_uv_tool "ruff"

# ---- Phase 3: Optional modern CLI replacements ----
echo ""
echo "=== Optional modern CLI tools ==="

try_cargo "eza"
try_cargo "bat"
try_cargo "delta"
try_cargo "sd"
try_install "jq"

# Tools less likely to be in system pkg managers — try cargo
try_cargo "dog"       || true
try_cargo "trippy"    || true
try_cargo "dust"      || true
try_install "duf"     || true
try_cargo "ouch"      || true
try_cargo "procs"     || true
try_cargo "tldr"      || true

echo ""
echo "=== Done ==="
echo "Missing some? Install manually or re-run after installing cargo/brew."
echo ""
echo "Next step:  Rscript scripts/install-r-deps.R   (for R packages)"
