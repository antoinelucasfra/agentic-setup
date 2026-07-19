#!/bin/bash
# omp-bootstrap.sh — apply omp-manifest.yml to this device
# Idempotent: safe to run repeatedly.
# Intended for device 2+ (new machine setup after setup.sh ran).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$REPO_DIR/omp-manifest.yml"
AGENTS_TARGET="$HOME/.agents"
OMP_CONFIG="$HOME/.omp/agent/config.yml"

if [ ! -f "$MANIFEST" ]; then
  echo "✘ Manifest not found at $MANIFEST"
  exit 1
fi

echo "=== OMP Bootstrap ==="

# --- 1. Apply OMP settings ---
echo "→ Writing OMP config to $OMP_CONFIG"
mkdir -p "$(dirname "$OMP_CONFIG")"
yq eval '.settings' "$MANIFEST" > "$OMP_CONFIG"
echo "  ✓ config.yml written"

# --- 2. Add marketplaces (idempotent) ---
echo "→ Adding marketplaces"
for source in $(yq eval '.marketplaces[].source' "$MANIFEST"); do
  omp plugin marketplace add "$source" 2>/dev/null && echo "  ✓ added $source" || echo "  • $source already present"
done

# --- 3. Install plugins (idempotent) ---
echo "→ Installing plugins"
for id in $(yq eval '.plugins[].id' "$MANIFEST"); do
  omp plugin install "$id" 2>/dev/null && echo "  ✓ installed $id" || echo "  • $id already installed"
done

# --- 4. Copy .agents/ content ---
echo "→ Setting up ~/.agents/"
if [ -d "$REPO_DIR/.agents" ]; then
  cp -r "$REPO_DIR/.agents/"* "$AGENTS_TARGET/" 2>/dev/null || true
  echo "  ✓ copied .agents/ content"
fi

# --- 5. Apply extension configs ---
echo "→ Applying extension configs"
for ext in $(yq eval '.extensions | keys | .[]' "$MANIFEST"); do
  ext_dir="$HOME/.omp/agent/extensions/$ext"
  mkdir -p "$ext_dir"
  yq eval ".extensions.$ext" "$MANIFEST" > "$ext_dir/config.json"
  echo "  ✓ $ext config"
done

# --- 6. Write .omp/.gitignore to keep runtime junk out of version control ---
OMP_GITIGNORE="$HOME/.omp/.gitignore"
if [ ! -f "$OMP_GITIGNORE" ]; then
  cat > "$OMP_GITIGNORE" << 'GITIGNORE'
logs/
cache/
agent/*.db
agent/*.db-wal
agent/*.db-shm
run/
puppeteer/
plugins/bun.lock
plugins/node_modules/
plugins/cache/
gpu_cache.json
GITIGNORE
  echo "  ✓ wrote ~/.omp/.gitignore"
fi

echo "=== Bootstrap complete ==="
echo "Start a new OMP session to pick up changes."
