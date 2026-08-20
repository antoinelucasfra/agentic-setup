#!/usr/bin/env bash
# agentic-setup — CLI dependency installer
#
# Idempotent: safe to re-run. Skips already-installed tools.
# Works on Linux (apt/pacman/dnf/apk/brew) and Windows (scoop/winget/choco via Git Bash).
#
# Usage:
#   bash scripts/setup.sh
#   bash <(curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/setup.sh)

set -euo pipefail

# ---- Detect OS & package manager ----
OS="$(uname -s)"
is_windows=false
case "$OS" in
MINGW* | MSYS* | CYGWIN*) is_windows=true ;;
esac
case "$OSTYPE" in
mingw* | msys*) is_windows=true ;;
esac

install_cmd=""
sudo_prefix=""
pkg_manager=""

detect_pkg_manager() {
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

detect_pkg_manager || warn "No supported package manager found — uv-based installs still work"

# ---- Helpers ----
info() { echo "  -> $*"; }
ok() { echo "  [ok] $*"; }
skip() { echo "  [skip] $* (already installed)"; }
warn() { echo "  [warn] $*"; }

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# ---- Unified installer (method: system|uv) ----
try() {
  local name="$1" method="$2"
  local bin="${3:-$name}" pkg="${4:-$name}"

  command -v "$bin" &>/dev/null && {
    skip "$name"
    return 0
  }

  case "$method" in
  system)
    [[ -z "$install_cmd" ]] && {
      warn "No package manager — install $name manually"
      return 1
    }
    info "Installing $name via $pkg_manager ..."
    $sudo_prefix $install_cmd "$pkg" >/dev/null 2>&1 && {
      ok "$name"
      return 0
    }
    ;;
  uv)
    command -v uv &>/dev/null || {
      warn "uv not found — install $name manually"
      return 1
    }
    info "Installing $name via uv ..."
    uv tool install "$name" >/dev/null 2>&1 && {
      ok "$name"
      return 0
    }
    ;;
  esac
  warn "$method install $name failed"
  return 1
}

# ================================================================
# Required tools
# ================================================================
echo ""
echo "=== Required tools ==="

try "gh" system "gh" "$([ "$pkg_manager" = winget ] && echo 'GitHub.cli' || echo 'gh')"

# uv — Python package manager (installs ruff, air via uv tool)
if ! command -v uv &>/dev/null; then
  info "Installing uv ..."
  if $is_windows; then
    if powershell -Command "irm https://astral.sh/uv/install.ps1 | iex" >/dev/null 2>&1; then
      ok "uv"
    else
      warn "uv install failed — run manually:  powershell -c \"irm https://astral.sh/uv/install.ps1 | iex\""
    fi
  else
    if curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1; then
      ok "uv"
    else
      warn "uv install failed — run manually:  curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi
  fi
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
fi

# ================================================================
# Recommended tools
# ================================================================
echo ""
echo "=== Recommended tools ==="

# ruff — Python linter/formatter
try "ruff" uv

# air — R formatter
try "air" uv "air" "air-formatter"

# jarl — R linter CLI (standalone installer)
if ! command -v jarl &>/dev/null; then
  info "Installing jarl via standalone installer ..."
  if curl -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh >/dev/null 2>&1; then
    ok "jarl"
  else
    warn "jarl install failed (needs curl + POSIX shell)"
  fi
else
  skip "jarl"
fi

echo ""
echo "=== Done ==="
echo ""
echo "  Installed: check the [ok] lines above."
echo "  Missed some? Install manually or re-run after installing a package manager."
