#!/usr/bin/env bash
# Apply omp-manifest.yml to the local OMP installation.
#
# Reads the single source of truth (omp-manifest.yml) and applies:
#   - settings  → ~/.omp/agent/config.yml
#   - plugins   → omp plugin install
#   - extensions → ~/.omp/agent/extensions/<name>/config.json
#
# Idempotent: safe to re-run.
#
# Usage: bash scripts/apply-manifest.sh

set -euo pipefail

MANIFEST="$(dirname "$0")/../omp-manifest.yml"
OMP_CONFIG="$HOME/.omp/agent/config.yml"
OMP_EXT_DIR="$HOME/.omp/agent/extensions"

info() { echo "  -> $*"; }
ok()   { echo "  [ok] $*"; }
skip() { echo "  [skip] $*"; }
warn() { echo "  [warn] $*"; }

if [ ! -f "$MANIFEST" ]; then
  warn "manifest not found at $MANIFEST"
  exit 1
fi

# ---- Helper: safely write a JSON file ----
write_json() {
  local path="$1" content="$2"
  mkdir -p "$(dirname "$path")"
  echo "$content" > "$path"
  ok "wrote $path"
}

# ================================================================
# 1. Settings → ~/.omp/agent/config.yml
# ================================================================
echo ""
echo "=== OMP settings ==="

if command -v yq &>/dev/null; then
  # Extract .settings from the manifest and write as YAML
  yq eval '.settings' "$MANIFEST" > "$OMP_CONFIG" 2>/dev/null \
    && ok "wrote $OMP_CONFIG" \
    || warn "failed to write settings"

  # Write extension configs
  echo ""
  echo "=== Extension configs ==="
  while IFS=$'\t' read -r name enabled_json; do
    local_config="$OMP_EXT_DIR/$name/config.json"
    echo "$enabled_json" > /dev/null  # just consume

    # Extract full extension config as JSON
    config_json=$(yq eval ".extensions.\"$name\"" "$MANIFEST" -o=json 2>/dev/null)
    if [ -n "$config_json" ] && [ "$config_json" != "null" ]; then
      write_json "$local_config" "$config_json"
    fi
  done < <(yq eval '.extensions | to_entries | .[] | [.key, (.value | tojson)] | @tsv' "$MANIFEST" 2>/dev/null || true)
else
  warn "yq not found — skipping settings and extension configs"
fi

# ================================================================
# 2. Marketplaces + plugins
# ================================================================
echo ""
echo "=== OMP plugin marketplaces ==="

if command -v omp &>/dev/null; then
  if command -v yq &>/dev/null; then
    while IFS=$'\t' read -r source name; do
      [ -z "$source" ] && continue
      if omp plugin marketplace list 2>/dev/null | grep -qF "$source"; then
        skip "marketplace $name ($source)"
      else
        info "adding marketplace $name ($source) ..."
        omp plugin marketplace add "$source" 2>/dev/null \
          && ok "marketplace $name added" \
          || warn "failed to add marketplace $source"
      fi
    done < <(yq eval '.marketplaces[] | [.source, .name] | @tsv' "$MANIFEST" 2>/dev/null)
  fi

  echo ""
  echo "=== OMP plugins ==="

  if command -v yq &>/dev/null; then
    while IFS=$'\t' read -r id; do
      [ -z "$id" ] && continue
      if omp plugin list 2>/dev/null | grep -qF "$id"; then
        skip "plugin $id"
      else
        info "installing plugin $id ..."
        omp plugin install "$id" 2>/dev/null \
          && ok "plugin $id installed" \
          || warn "failed to install plugin $id"
      fi
    done < <(yq eval '.plugins[].id' "$MANIFEST" 2>/dev/null)
  fi
else
  warn "omp not found — skipping plugin setup"
fi

echo ""
echo "=== Done ==="
echo "  OMP config applied from omp-manifest.yml."
echo "  Edit omp-manifest.yml to change settings and re-run this script."
