#!/usr/bin/env bash
# ============================================================
# OMP Agentic Setup - Validation Script
# Checks installation integrity and configuration
# ============================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

AGENT_DIR="${HOME}/.agents"
ERRORS=0
WARNINGS=0

# ============================================================
# Validation Functions
# ============================================================

check_file_exists() {
    local file="$1"
    local desc="${2:-File}"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} ${desc}: $file"
    else
        echo -e "${RED}✗${NC} ${desc} missing: $file"
        ((ERRORS++))
    fi
}

check_dir_exists() {
    local dir="$1"
    local desc="${2:-Directory}"
    
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} ${desc}: $dir"
    else
        echo -e "${RED}✗${NC} ${desc} missing: $dir"
        ((ERRORS++))
    fi
}

check_command_exists() {
    local cmd="$1"
    local desc="${2:-Command}"
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} ${desc}: $cmd ($(command -v "$cmd"))"
    else
        echo -e "${YELLOW}⚠${NC} ${desc} not found: $cmd"
        ((WARNINGS++))
    fi
}

validate_skills() {
    log_section "Skills Validation"
    
    local skill_count
    skill_count=$(find "${AGENT_DIR}/skills" -name "SKILL.md" 2>/dev/null | wc -l)
    
    if [[ "$skill_count" -gt 0 ]]; then
        echo -e "${GREEN}✓${NC} Found ${skill_count} skills"
    else
        echo -e "${RED}✗${NC} No skills found"
        ((ERRORS++))
    fi
}

validate_rules() {
    log_section "Rules Validation"
    
    local rule_count=0
    if [[ -d "${AGENT_DIR}/rules" ]]; then
        rule_count=$(ls "${AGENT_DIR}/rules"/*.md 2>/dev/null | wc -l || echo 0)
    fi
    
    if [[ "$rule_count" -gt 0 ]]; then
        echo -e "${GREEN}✓${NC} Found ${rule_count} rules"
    else
        echo -e "${YELLOW}⚠${NC} No rules found (optional)"
    fi
}

log_section() {
    echo ""
    echo -e "${BLUE}═══ $1 ═══${NC}"
}

# ============================================================
# Main Validation
# ============================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     OMP Agentic Setup - Installation Validation     ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    
    log_section "Core Files"
    check_file_exists "${AGENT_DIR}/AGENTS.md" "AGENTS.md"
    
    log_section "Directory Structure"
    check_dir_exists "${AGENT_DIR}" ".agents directory"
    check_dir_exists "${AGENT_DIR}/skills" "Skills directory"
    check_dir_exists "${AGENT_DIR}/rules" "Rules directory"
    
    log_section "Required Commands"
    check_command_exists "git" "Git"
    check_command_exists "curl" "Curl"
    
    log_section "Optional Components"
    check_command_exists "rtk" "RTK (token-optimized CLI)"
    check_command_exists "python3" "Python 3"
    
    validate_skills
    validate_rules
    
    echo ""
    echo "══════════════════════════════════════════════════════════"
    echo -e "Errors:   ${RED}${ERRORS}${NC}"
    echo -e "Warnings: ${YELLOW}${WARNINGS}${NC}"
    echo "══════════════════════════════════════════════════════════"
    
    if [[ $ERRORS -eq 0 ]]; then
        echo -e "${GREEN}✅ Installation is valid!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Installation has errors that need fixing${NC}"
        exit 1
    fi
}

main "$@"