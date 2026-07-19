#!/usr/bin/env bash
# ============================================================
# OMP Agentic Setup Script
# Automated installation for the OMP coding agent harness
# ============================================================

set -euo pipefail

log() {
  local c
  case $1 in ok) c=32;; warn) c=33;; err) c=31;; *) c=34;; esac
  echo -e "\033[${c}m$2\033[0m"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="${HOME}/.agents"
SKIP_SYSTEM_CHECKS=false

show_help() {
    cat << EOF_USAGE
Usage: $(basename "$0") [OPTIONS]

Automated setup for the OMP coding agent harness.

Options:
  -h, --help          Show this help message
  -v, --verbose       Enable verbose output
  -s, --skip-system   Skip system dependency checks
  -d, --dry-run       Show what would be done without making changes
  -u, --uninstall     Remove the agent setup
  -b, --bootstrap     Apply omp-manifest.yml to this device (plugins, settings)

Examples:
  $(basename "$0")              # Full installation (first device)
  $(basename "$0") --bootstrap  # Apply manifest (device 2+)
  $(basename "$0") --uninstall  # Remove setup
EOF_USAGE
}

check_required_commands() {
    local missing=()
    for cmd in git curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log err "Missing required commands: ${missing[*]}"
        log info "Install with: apt install ${missing[*]} (Debian/Ubuntu)"
        log info "               brew install ${missing[*]} (macOS)"
        return 1
    fi
    log ok "All required commands available"
}

install_dependencies() {
    log info "Checking system dependencies..."
    check_required_commands || return 1
    log ok "System checks passed"
}

setup_agent_directory() {
    log info "Setting up agent directory at ${AGENT_DIR}..."
    mkdir -p "${AGENT_DIR}" "${AGENT_DIR}/rules"

    if [[ -f "${SCRIPT_DIR}/.agents/AGENTS.md" ]]; then
        cp "${SCRIPT_DIR}/.agents/AGENTS.md" "${AGENT_DIR}/AGENTS.md"
        log ok "AGENTS.md installed"
    else
        log warn "AGENTS.md not found, skipping"
    fi

    if [[ -d "${SCRIPT_DIR}/.agents/rules" ]]; then
        cp -r "${SCRIPT_DIR}/.agents/rules/"* "${AGENT_DIR}/rules/"
        log ok "Rules installed: $(find "${AGENT_DIR}/rules" -name '*.md' 2>/dev/null | wc -l) rules"
    fi
}

bootstrap_from_manifest() {
    local manifest="${SCRIPT_DIR}/omp-manifest.yml"
    if [[ ! -f "$manifest" ]]; then
        log err "Manifest not found at $manifest"
        return 1
    fi
    if ! command -v yq &>/dev/null; then
        log err "yq is required for --bootstrap. Install: pip install yq or brew install yq"
        return 1
    fi

    log info "Applying omp-manifest.yml..."

    # OMP settings → config.yml
    mkdir -p "$HOME/.omp/agent"
    yq eval '.settings' "$manifest" > "$HOME/.omp/agent/config.yml"
    log ok "config.yml written"

    # Marketplaces
    for source in $(yq eval '.marketplaces[].source' "$manifest"); do
        omp plugin marketplace add "$source" 2>/dev/null && log ok "added marketplace $source" || log warn "$source already present"
    done

    # Plugins
    for id in $(yq eval '.plugins[].id' "$manifest"); do
        omp plugin install "$id" 2>/dev/null && log ok "installed $id" || log warn "$id already installed"
    done

    # Copy .agents/
    if [[ -d "${SCRIPT_DIR}/.agents" ]]; then
        cp -r "${SCRIPT_DIR}/.agents/"* "$AGENT_DIR/" 2>/dev/null || true
    fi

    # Extension configs
    for ext in $(yq eval '.extensions | keys | .[]' "$manifest"); do
        ext_dir="$HOME/.omp/agent/extensions/$ext"
        mkdir -p "$ext_dir"
        yq eval ".extensions.$ext" "$manifest" > "$ext_dir/config.json"
        log ok "$ext extension config applied"
    done

    # .omp/.gitignore
    if [[ ! -f "$HOME/.omp/.gitignore" ]]; then
        cat > "$HOME/.omp/.gitignore" << 'GITIGNORE'
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
    fi

    log ok "Bootstrap complete. Start a new OMP session."
}

validate_installation() {
    log info "Validating installation..."
    local errors=0

    if [[ -f "${AGENT_DIR}/AGENTS.md" ]]; then
        log ok "AGENTS.md exists"
    else
        log err "AGENTS.md not installed"
        ((errors++))
    fi

    if [[ -d "${AGENT_DIR}/rules" ]]; then
        local rule_count
        rule_count=$(find "${AGENT_DIR}/rules" -name '*.md' 2>/dev/null | wc -l)
        log ok "Rules directory ready (${rule_count} rules)"
    fi

    return $errors
}

uninstall_agent() {
    log info "Uninstalling OMP agent setup..."
    if [[ -d "${AGENT_DIR}" ]]; then
        read -p "Remove ${AGENT_DIR}? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "${AGENT_DIR}"
            log ok "Agent directory removed"
        else
            log info "Uninstall cancelled"
        fi
    else
        log info "Agent directory not found, nothing to remove"
    fi
}

main() {
    local dry_run=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            -v|--verbose) set -x ;;
            -s|--skip-system) SKIP_SYSTEM_CHECKS=true ;;
            -d|--dry-run) dry_run=true; log info "Dry run mode - no changes will be made" ;;
            -u|--uninstall) uninstall_agent; exit 0 ;;
            -b|--bootstrap) bootstrap_from_manifest; exit $? ;;
            *) log err "Unknown option: $1"; show_help; exit 1 ;;
        esac
        shift
    done

    if [[ "$dry_run" == true ]]; then
        log info "Would perform the following:"
        log info "  - Install system dependencies"
        log info "  - Set up agent directory at ${AGENT_DIR}"
        log info "  - Copy AGENTS.md"
        log info "  - Install rules"
        return 0
    fi

    [[ "$SKIP_SYSTEM_CHECKS" != true ]] && (install_dependencies || exit 1)
    setup_agent_directory
    echo ""
    validate_installation
    echo ""
    log ok "Installation complete!"
    log info "Start OMP with: omp"
}

main "$@"
