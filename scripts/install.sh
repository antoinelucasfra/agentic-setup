#!/usr/bin/env bash
# agentic-setup — choose pi or OMP harness and install your config.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/antoinelucasfra/agentic-setup/main/scripts/install.sh | bash
#   bash scripts/install.sh              # prompts: pi | omp
#   bash scripts/install.sh pi           # non-interactive, install pi config
#   bash scripts/install.sh omp          # non-interactive, install OMP config
#
# Both configs live in this repo: pi/ (pi harness) and omp/ (OMP harness).
# The chosen installer wires its full confguration (extensions, skills,
# rules, packages) into the right harness home. No credentials are written.

set -euo pipefail

REPO="https://github.com/antoinelucasfra/agentic-setup.git"
TARGET="${HOME}/.agents" # repo lives here

info() { echo "  -> $*"; }
ok() { echo "  [ok] $*"; }
skip() { echo "  [skip] $*"; }
warn() { echo "  [warn] $*"; }

# ---- Resolve repo root (from a clone) or clone/pull into ~/.agents ----
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd)"
case "$(basename "$SRC")" in
scripts) REPO_ROOT="$(dirname "$SRC")" ;; # bash scripts/install.sh from a clone
.) REPO_ROOT="" ;;                        # piped via curl | bash — clone below
*) REPO_ROOT="$SRC" ;;
esac
if [[ -n "$REPO_ROOT" ]] && [[ ! -d "$REPO_ROOT/pi" ]]; then
  REPO_ROOT=""
fi

if [[ -z "$REPO_ROOT" ]]; then
  if [[ -d "$TARGET/.git" ]] || [[ -f "$TARGET/.git" ]] || [[ -d "$TARGET/pi" ]]; then
    info "Updating existing $TARGET ..."
    git -C "$TARGET" pull --ff-only
  elif [[ -d "$TARGET" ]]; then
    info "$TARGET exists but is not this repo — backing it up ..."
    mv "$TARGET" "$TARGET.bak.$(date +%Y%m%d%H%M%S)"
    git clone "$REPO" "$TARGET"
  else
    info "Cloning config to $TARGET ..."
    git clone "$REPO" "$TARGET"
  fi
  REPO_ROOT="$TARGET"
fi
info "Using config from $REPO_ROOT"

# ---- Shared CLI deps (gh, uv, air, jarl, ruff) ----
bash "$REPO_ROOT/scripts/setup.sh"

# ---- Choose harness: pi | omp ----
MODE=""
case "${1:-}" in
pi | --pi) MODE=pi ;;
omp | --omp) MODE=omp ;;
"") MODE="" ;;
*)
  warn "unknown argument '$1' — treating as interactive"
  MODE=""
  ;;
esac

if [[ -z "$MODE" ]]; then
  echo ""
  echo "=== Which configuration do you want to install? ==="
  echo "  1) pi   — @earendil-works/pi-coding-agent (recommended)"
  echo "  2) omp  — @oh-my-pi/pi-coding-agent"
  while true; do
    read -r -p "Choose [1/2]: " CHOICE
    case "$CHOICE" in
    1 | pi | Pi)
      MODE=pi
      break
      ;;
    2 | omp | Omp)
      MODE=omp
      break
      ;;
    *) echo "  Please enter 1 (pi) or 2 (omp)." ;;
    esac
  done
fi

echo ""
if [[ "$MODE" == "pi" ]]; then
  echo "=== Installing pi configuration ==="
  bash "$REPO_ROOT/scripts/install-pi.sh" "$REPO_ROOT"
else
  echo "=== Installing OMP configuration ==="
  bash "$REPO_ROOT/scripts/install-omp.sh" "$REPO_ROOT"
fi
