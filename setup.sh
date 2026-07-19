#!/usr/bin/env bash
# ============================================================
# OMP Agentic Setup Script
# Automated installation for the OMP coding agent harness
# ============================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="${HOME}/.agents"
SKIP_SYSTEM_CHECKS=false

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

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
  -l, --list-skills   List available skills

Examples:
  $(basename "$0")              # Full installation
  $(basename "$0") --dry-run    # Preview installation
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
        log_error "Missing required commands: ${missing[*]}"
        log_info "Install with: apt install ${missing[*]} (Debian/Ubuntu)"
        log_info "               brew install ${missing[*]} (macOS)"
        return 1
    fi
    
    log_success "All required commands available"
}

install_dependencies() {
    log_info "Checking system dependencies..."
    

    check_required_commands || return 1
    
    log_success "System checks passed"
}

setup_agent_directory() {
    log_info "Setting up agent directory at ${AGENT_DIR}..."
    
    mkdir -p "${AGENT_DIR}"
    mkdir -p "${AGENT_DIR}/skills"
    mkdir -p "${AGENT_DIR}/rules"
    
    # Copy AGENTS.md
    if [[ -f "${SCRIPT_DIR}/AGENTS.md" ]]; then
        cp "${SCRIPT_DIR}/AGENTS.md" "${AGENT_DIR}/AGENTS.md"
        log_success "AGENTS.md installed"
    else
        log_warning "AGENTS.md not found, skipping"
    fi
    
    # Copy skills
    if [[ -d "${SCRIPT_DIR}/.agents/skills" ]]; then
        cp -r "${SCRIPT_DIR}/.agents/skills/"* "${AGENT_DIR}/skills/"
        log_success "Skills installed: $(find "${AGENT_DIR}/skills" -name SKILL.md 2>/dev/null | wc -l) skills"
    fi
    
    # Copy rules
    if [[ -d "${SCRIPT_DIR}/.agents/rules" ]]; then
        cp -r "${SCRIPT_DIR}/.agents/rules/"* "${AGENT_DIR}/rules/"
        log_success "Rules installed: $(find "${AGENT_DIR}/rules" -name '*.md' 2>/dev/null | wc -l) rules"
    fi
}

validate_installation() {
    log_info "Validating installation..."
    local errors=0
    
    # Check AGENTS.md
    if [[ -f "${AGENT_DIR}/AGENTS.md" ]]; then
        log_success "AGENTS.md exists"
    else
        log_error "AGENTS.md not installed"
        ((errors++))
    fi
    
    # Check skills directory
    if [[ -d "${AGENT_DIR}/skills" ]]; then
        local skill_count
        skill_count=$(find "${AGENT_DIR}/skills" -name "SKILL.md" 2>/dev/null | wc -l)
        
        if [[ "$skill_count" -gt 0 ]]; then
            log_success "Skills directory populated (${skill_count} skills)"
        else
            log_warning "No skills found"
        fi
    else
        log_error "Skills directory not found"
        ((errors++))
    fi
    
    # Check rules
    if [[ -d "${AGENT_DIR}/rules" ]]; then
        local rule_count=0
        rule_count=$(find "${AGENT_DIR}/rules" -name '*.md' 2>/dev/null | wc -l || echo 0)
        
        log_success "Rules directory ready (${rule_count} rules)"
    fi
    
    return $errors
}

uninstall_agent() {
    log_info "Uninstalling OMP agent setup..."
    
    if [[ -d "${AGENT_DIR}" ]]; then
        read -p "Remove ${AGENT_DIR}? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "${AGENT_DIR}"
            log_success "Agent directory removed"
        else
            log_info "Uninstall cancelled"
        fi
    else
        log_info "Agent directory not found, nothing to remove"
    fi
}

list_skills() {
    log_info "Available skills:"
    echo ""
    
    if [[ -d "${SCRIPT_DIR}/.agents/skills" ]]; then
        find "${SCRIPT_DIR}/.agents/skills" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
            local skill_name
            skill_name=$(basename "$dir")
            local skill_desc=""
            if [[ -f "${dir}/SKILL.md" ]]; then
                skill_desc=$(head -5 "${dir}/SKILL.md" | grep -E "^# " | sed 's/^# //' | head -1)
            fi
            printf "  %-30s %s\n" "$skill_name" "($skill_desc)"
        done | sort
    else
        log_warning "No skills directory found"
    fi
}

main() {
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                set -x
                ;;
            -s|--skip-system)
                SKIP_SYSTEM_CHECKS=true
                ;;
            -d|--dry-run)
                dry_run=true
                log_info "Dry run mode - no changes will be made"
                ;;
            -u|--uninstall)
                uninstall_agent
                exit 0
                ;;
            -l|--list-skills)
                list_skills
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    if [[ "$dry_run" == true ]]; then
        log_info "Would perform the following:"
        log_info "  - Install system dependencies"
        log_info "  - Set up agent directory at ${AGENT_DIR}"
        log_info "  - Copy AGENTS.md"
        log_info "  - Install $(find "${SCRIPT_DIR}/.agents/skills" -name "SKILL.md" 2>/dev/null | wc -l) skills"
        log_info "  - Install $(find "${SCRIPT_DIR}/.agents/rules" -name '*.md' 2>/dev/null | wc -l) rules"
        return 0
    fi
    
    # Run installation
    if [[ "$SKIP_SYSTEM_CHECKS" != true ]]; then
        install_dependencies || exit 1
    fi
    
    setup_agent_directory
    
    echo ""
    validate_installation
    
    echo ""
    log_success "Installation complete!"
    log_info "Run 'source ${AGENT_DIR}/AGENTS.md' or restart your shell"
    log_info "Visit ${SCRIPT_DIR}/docs/SETUP.md for advanced configuration"
}

main "$@"