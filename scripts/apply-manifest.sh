#!/usr/bin/env bash
# Apply omp-manifest.yml to local OMP: settings, marketplaces, plugins, extensions.
# Idempotent. Usage: bash scripts/apply-manifest.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/omp-manifest.yml"
OMP_CONFIG="$HOME/.omp/agent/config.yml"
OMP_EXT_DIR="$HOME/.omp/agent/extensions"

[ -f "$MANIFEST" ] || { echo "manifest not found: $MANIFEST"; exit 1; }

# Settings + extension configs (requires yq)
if command -v yq &>/dev/null; then
  mkdir -p "$(dirname "$OMP_CONFIG")"
  yq eval '.settings' "$MANIFEST" > "$OMP_CONFIG"
  for name in $(yq eval '.extensions | keys | .[]' "$MANIFEST" 2>/dev/null); do
    d="$OMP_EXT_DIR/$name"
    mkdir -p "$d"
    yq eval ".extensions.\"$name\"" "$MANIFEST" -o=json > "$d/config.json" 2>/dev/null || true
  done
fi

# Marketplaces + plugins (requires omp + yq)
if command -v omp &>/dev/null && command -v yq &>/dev/null; then
  while IFS= read -r source; do
    [ -z "$source" ] && continue
    omp plugin marketplace list 2>/dev/null | grep -qF "$source" || \
      omp plugin marketplace add "$source" 2>/dev/null || true
  done < <(yq eval '.marketplaces[].source' "$MANIFEST" 2>/dev/null)

  while IFS= read -r id; do
    [ -z "$id" ] && continue
    omp plugin list 2>/dev/null | grep -qF "$id" || \
      omp plugin install "$id" 2>/dev/null || true
  done < <(yq eval '.plugins[].id' "$MANIFEST" 2>/dev/null)
fi
