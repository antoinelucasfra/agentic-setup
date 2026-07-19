#!/bin/bash
# omp-sync.sh — snapshot current OMP state into the repo and push
#
# Usage:
#   ./omp-sync.sh                    # dry-run preview
#   ./omp-sync.sh --commit           # snapshot + commit
#   ./omp-sync.sh --commit --push    # snapshot + commit + push
#
# Call from a shell hook (e.g. after `omp plugin install`) or manually.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_SRC="$HOME/.agents"
OMP_CONFIG_SRC="$HOME/.omp/agent/config.yml"
MANIFEST="$REPO_DIR/omp-manifest.yml"

DO_COMMIT=false
DO_PUSH=false
for arg in "$@"; do
  case "$arg" in
    --commit) DO_COMMIT=true ;;
    --push)   DO_PUSH=true ;;
  esac
done

echo "=== OMP Sync ==="

CHANGES=false

# --- Snapshot current plugins into manifest ---
if omp plugin list --json 2>/dev/null | yq eval -e '.marketplace[] | {"id": .id}' - > /dev/null 2>&1; then
  TMP=$(mktemp)
  omp plugin list --json | yq eval '
    .
    | {"plugins": ([(.marketplace[] // []) | {"id": .id}] + [(.npm[] // []) | {"id": "npm:\(.name)"}])}
  ' - > "$TMP"

  yq eval-all '
    select(fileIndex == 0) * {"plugins": (select(fileIndex == 1) | .plugins)}
  ' "$MANIFEST" "$TMP" > "${MANIFEST}.new"
  mv "${MANIFEST}.new" "$MANIFEST"
  rm -f "$TMP"
  echo "  ✓ manifest plugins updated from live state"
  CHANGES=true
fi

# --- Snapshot OMP config ---
if [ -f "$OMP_CONFIG_SRC" ]; then
  TMP=$(mktemp)
  yq eval '{
    "symbolPreset": .symbolPreset,
    "theme": .theme,
    "modelRoles": .modelRoles,
    "setupVersion": .setupVersion
  }' "$OMP_CONFIG_SRC" > "$TMP"

  yq eval-all '
    select(fileIndex == 0) * {"settings": (select(fileIndex == 1) | .)}
  ' "$MANIFEST" "$TMP" > "${MANIFEST}.new"
  mv "${MANIFEST}.new" "$MANIFEST"
  rm -f "$TMP"
  echo "  ✓ manifest settings updated from live config"
  CHANGES=true
fi

# --- Snapshot .agents/ content ---
if ! diff -q "$AGENTS_SRC/AGENTS.md" "$REPO_DIR/.agents/AGENTS.md" 2>/dev/null; then
  cp "$AGENTS_SRC/AGENTS.md" "$REPO_DIR/.agents/AGENTS.md"
  echo "  ✓ AGENTS.md synced"
  CHANGES=true
fi

for f in "$AGENTS_SRC/rules/"*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  if ! diff -q "$f" "$REPO_DIR/.agents/rules/$name" 2>/dev/null; then
    cp "$f" "$REPO_DIR/.agents/rules/$name"
    echo "  ✓ rules/$name synced"
    CHANGES=true
  fi
done

if [ "$CHANGES" = false ]; then
  echo "  No changes detected."
  exit 0
fi

if [ "$DO_COMMIT" = true ]; then
  cd "$REPO_DIR"
  git add -A
  git commit -m "chore: sync OMP config $(date +%Y-%m-%d-%H%M)"
  echo "  ✓ committed"

  if [ "$DO_PUSH" = true ]; then
    git push
    echo "  ✓ pushed"
  fi
else
  echo "  Changes pending. Run with --commit to snapshot, --commit --push to push."
fi
