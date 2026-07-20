#!/usr/bin/env bash
# omp-setup — one-shot bootstrap for a new device.
#
# Idempotent. Installs OMP if missing, clones/updates this config,
# installs CLI deps, and applies the OMP manifest.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/antoinelucasfra/omp-setup/main/scripts/bootstrap.sh | bash

set -euo pipefail

REPO="https://github.com/antoinelucasfra/omp-setup.git"
TARGET="${HOME}/.agents"

echo "=== omp-setup bootstrap ==="

# ---- 1. Install OMP if missing ----
if ! command -v omp &>/dev/null; then
  echo "  -> Installing OMP via npm..."
  if command -v npm &>/dev/null; then
    npm install -g @oh-my-pi/pi-coding-agent
  elif command -v bun &>/dev/null; then
    bun install -g @oh-my-pi/pi-coding-agent
  else
    echo "  [warn] Neither npm nor bun found. Install OMP manually:"
    echo "         npm install -g @oh-my-pi/pi-coding-agent"
    echo "         Then re-run this script."
    exit 1
  fi
else
  echo "  [ok] omp already installed"
fi

# ---- 2. Clone or pull config ----
if [ -d "$TARGET/.git" ]; then
  echo "  -> Updating existing ~/.agents..."
  git -C "$TARGET" pull --ff-only
else
  echo "  -> Cloning config to ~/.agents..."
  git clone "$REPO" "$TARGET"
fi

# ---- 3. Install CLI deps ----
echo ""
bash "$TARGET/scripts/setup.sh"

# ---- 4. Apply OMP manifest ----
echo ""
echo "=== Applying OMP manifest ==="
"$TARGET/scripts/apply-manifest.sh"

echo ""
echo "=== Done ==="
echo "Start the agent:  omp"
