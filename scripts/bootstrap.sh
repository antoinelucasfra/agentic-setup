#!/usr/bin/env bash
# ============================================================
# OMP Agentic Setup - Bootstrap Script
# Simplified alternative setup script for end users
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

show_help() {
    cat << HELP_USAGE
Usage: $(basename "$0") [OPTIONS]

Simple OMP agent setup for new devices.

Options:
  -h, --help    Show this message
  --dry-run      Preview actions without making changes
  --validate     Validate existing setup

Examples:
  $(basename "$0")              # Quick setup
  $(basename "$0") --dry-run    # Preview setup
  $(basename "$0") --validate   # Validate
HELP_USAGE
}

main() {
    # Parse args
    DRY_RUN=false
    VALIDATE=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help; exit 0 ;;
            --dry-run) DRY_RUN=true ;;
            --validate) VALIDATE=true ;;
            *) log_error "Unknown option: $1"; show_help; exit 1 ;;
        esac
        shift
    done
    
    echo "╔════════════════════════════════════════╗"
    echo "║  OMP Agentic Setup - Bootstrap      ║"
    echo "╚════════════════════════════════════════╝"
    
    if [[ "$VALIDATE" == true ]]; then
        echo "Validating current setup..."
        $0/setup.sh scripts/validate.sh
        exit $?
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "Dry run - would perform:"
        log_info "  - Install system dependencies (apt/get install curl git jq)"
        log_info "  - Download and run setup script"
        log_info "  - Install OMP agent skills"
        log_info "  - Run validation"
        exit 0
    fi
    
    # Quick setup
    log_info "Running complete setup..."
    
    # Install core dependencies
    if [[ "$(uname -s)" == "Linux" ]]; then
        log_info "Installing system dependencies..."
        $0/sudo apt update && $0/sudo apt install -y curl git jq
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        log_info "Installing system dependencies with Homebrew..."
        $0/brew install curl git jq
    fi
    
    # Download and run setup
    log_info "Downloading and running setup script..."
    $0/curl -fsSL https://github.com/antoinelucasfra/agentic-setup/raw/main/setup.sh | bash
    
    echo ""
    log_success "Setup complete!"
    log_info "Run 'bash setup.sh --validate' to verify installation"
    log_info "Visit the repo for skills documentation"
}

main "$@"
