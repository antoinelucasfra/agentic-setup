#!/usr/bin/env bash
# omp-setup — CLI dependency installer
#
# Idempotent: safe to re-run. Skips already-installed tools.
# Works on Linux (apt/pacman) and Windows (scoop/winget/choco via Git Bash).
#
# Usage: bash scripts/setup.sh
#        bash <(curl -sL https://raw.githubusercontent.com/antoinelucasfra/omp-setup/main/scripts/setup.sh)

set -euo pipefail

# ---- Detect OS & package manager ----
OS="$(uname -s)"
is_windows=false
case "$OS" in
  MINGW*|MSYS*|CYGWIN*) is_windows=true;;
esac
case "$OSTYPE" in
  mingw*|msys*) is_windows=true;;
esac

install_cmd=""
sudo_prefix=""
pkg_manager=""

detect_pkg_manager() {
  # Windows package managers (checked first in Git Bash)
  if $is_windows; then
    if command -v scoop &>/dev/null; then
      install_cmd="scoop install"
      pkg_manager="scoop"
      return 0
    fi
    if command -v winget &>/dev/null; then
      install_cmd="winget install --silent --accept-package-agreements"
      pkg_manager="winget"
      return 0
    fi
    if command -v choco &>/dev/null; then
      install_cmd="choco install -y"
      pkg_manager="choco"
      return 0
    fi
    return 1
  fi

  # Linux / WSL
  if command -v apt-get &>/dev/null; then
    install_cmd="apt-get install -y"
    sudo_prefix="sudo"
    pkg_manager="apt"
  elif command -v pacman &>/dev/null; then
    install_cmd="pacman -S --noconfirm"
    sudo_prefix="sudo"
    pkg_manager="pacman"
  elif command -v brew &>/dev/null; then
    install_cmd="brew install"
    pkg_manager="brew"
  elif command -v dnf &>/dev/null; then
    install_cmd="dnf install -y"
    sudo_prefix="sudo"
    pkg_manager="dnf"
  elif command -v apk &>/dev/null; then
    install_cmd="apk add"
    sudo_prefix="sudo"
    pkg_manager="apk"
  else
    return 1
  fi
}

detect_pkg_manager || warn "No supported package manager found — will use cargo where possible"

# ---- Helpers ----
info()  { echo "  -> $*"; }
ok()    { echo "  [ok] $*"; }
skip()  { echo "  [skip] $* (already installed)"; }
warn()  { echo "  [warn] $*"; }

# Ensure common cargo/user bin dirs are on PATH
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# ---- Unified installer (method: system|cargo|uv) ----
try() {
  local name="$1" method="$2"
  local bin="${3:-$name}" pkg="${4:-$name}"

  command -v "$bin" &>/dev/null && { skip "$name"; return 0; }

  case "$method" in
    system)
      [[ -z "$install_cmd" ]] && { warn "No package manager — install $name manually"; return 1; }
      info "Installing $name via $pkg_manager ..."
      $sudo_prefix $install_cmd "$pkg" 2>/dev/null && { ok "$name"; return 0; }
      ;;
    cargo)
      command -v cargo &>/dev/null || { warn "cargo not found — install $name manually"; return 1; }
      info "Installing $name via cargo ..."
      cargo install "$name" 2>/dev/null && { ok "$name"; return 0; }
      ;;
    uv)
      command -v uv &>/dev/null || { warn "uv not found — install $name manually"; return 1; }
      info "Installing $name via uv ..."
      uv tool install "$name" 2>/dev/null && { ok "$name"; return 0; }
      ;;
  esac
  warn "$method install $name failed"
  return 1
}
# ================================================================
# Phase 1: Required CLI tools
# ================================================================
echo ""
echo "=== Required tools ==="

try "gh" system "gh" "$([ "$pkg_manager" = winget ] && echo 'GitHub.cli' || echo 'gh')"

# uv — Python package manager
if ! command -v uv &>/dev/null; then
  info "Installing uv ..."
  if $is_windows; then
    # Windows: use PowerShell to run the official installer
    powershell -Command "irm https://astral.sh/uv/install.ps1 | iex" 2>/dev/null && ok "uv" || warn "uv install failed — run manually:  powershell -c \"irm https://astral.sh/uv/install.ps1 | iex\""
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null && ok "uv" || warn "uv install failed"
    # Ensure uv is on PATH for subsequent steps
    if command -v uv &>/dev/null; then
      ok "uv"
    elif [ -f "$HOME/.cargo/bin/uv" ]; then
      ok "uv (in .cargo/bin)"
    elif [ -f "$HOME/.local/bin/uv" ]; then
      ok "uv (in .local/bin)"
    else
      warn "uv installed but not on PATH — add $HOME/.local/bin to your PATH"
    fi
  fi
  # Ensure uv is findable for the rest of the script
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
fi

try "yq" system "yq" "$([ "$pkg_manager" = winget ] && echo 'MikeFarah.yq' || echo 'yq')"

# ================================================================
# Phase 2: Recommended tools
# ================================================================
echo ""
echo "=== Recommended tools ==="

# ruff — Python linter
try "ruff" uv

# jarl — R linter CLI (standalone installer)
if ! command -v jarl &>/dev/null; then
  info "Installing jarl via standalone installer ..."
  curl -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh 2>/dev/null && ok "jarl" || warn "jarl install failed"
else
  skip "jarl"
fi

echo ""
echo "=== Done ==="
echo ""
echo "  Installed: check the [ok] lines above."
echo "  Missed some? Install manually or re-run after installing cargo/brew/scoop."
