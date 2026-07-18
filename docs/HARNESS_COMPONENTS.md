# 🗺️ OMP Harness Components Mapping

This document maps all components of the OMP coding agent harness that should be included in this repository.

## 📁 Core Components

### 1. AGENTS.md (Global Instructions)
- **Location**: `.agents/AGENTS.md`
- **Purpose**: Standing, always-loaded instructions for the OMP coding agent
- **Key Sections**:
  - Tool selection preferences (glob, read, grep, edit, write, lsp over shell)
  - RTK token-optimized CLI usage
  - Modern CLI tool preferences over legacy utilities
  - Scope definitions for when to use modern vs traditional tools
  - Replacement mappings (ps→procs/bottom, du→dust, etc.)

### 2. Skills Directory
- **Location**: `.agents/skills/`
- **Purpose**: Specialized agent capabilities for different domains
- **Structure**: Each skill has its own directory with SKILL.md and potentially references/examples

#### Skill Categories:
```
Development & Automation
├── devops-expert/
├── golem-create-golem/
├── golem-add-function/
├── golem-add-module/
├── golem-check-app/
├── golem-run-tests/
├── golem-upgrade/
├── golem-fix-missing-ns-colin/
├── r-cli-app/
├── cli/
├── r-oop/
├── r-package-development-guide/
├── r-performance/
├── r-style-guide/
├── r-bayes/
├── rlang-patterns/
├── plan/
├── pytest-coverage/
├── quality-playbook/
├── testing-r-packages/
├── tidyverse-patterns/
├── cran-extrachecks/
├── create-release-checklist/
├── package-docs-preference/
├── describe-design/
├── brand-yml/
├── datanalysis/
├── autoresearch/
━
├── alt-text/
├── markdown-accessibility-assistant/
└── review-testing/

Shiny & Web Development
├── shiny-bslib/
├── shiny-bslib-theming/
├── shiny-testing/
└── ggsql/

Documentation & Publishing
├── quarto-authoring/
├── release-post/
└── create-release-checklist/
```

### 3. Rules Directory
- **Location**: `.agents/rules/`
- **Purpose**: Code quality, safety, and assistance guidelines
- **Files**:
  - commit-workflow.md - Git commit standards and workflow
  - (Additional rules from .agents/rules/ when available)

### 4. Configuration Files
- **Location**: `.agents/` (root)
- **Files**:
  - settings.json - Agent-specific configuration
  - (Other potential config files)

## 🔧 Automation Components

### 5. Setup Scripts
- **Location**: Repository root
- **Files**:
  - setup.sh - Main installation script with options
  - scripts/validate.sh - Installation verification
  - scripts/pre-commit - Git hook for code quality
  - Makefile - Common automation commands

### 6. Documentation
- **Location**: `docs/` and repository root
- **Files**:
  - README.md - Project overview and quick start
  - SETUP.md - Detailed device-specific setup guide
  - CONTRIBUTING.md - Contribution guidelines
  - PROJECT_GOALS.md - This document

## 🌐 Platform Support Matrix

| Component | Linux | macOS | WSL2 | Notes |
|-----------|-------|-------|------|-------|
| Core Agent | ✅ | ✅ | ✅ | Via .agents/AGENTS.md |
| Skills | ✅ | ✅ | ✅ | Platform-independent |
| Setup Script | ✅ | ✅ | ✅ | Bash-based |
| RTK Integration | ✅ | ✅ | ✅ | Token optimization |
| Modern CLI Tools | ✅ | ✅ | ✅ | Recommendations only |
| Git Hooks | ✅ | ✅ | ✅ | Via .git/hooks |
| Validation | ✅ | ✅ | ✅ | Script-based |

## 📦 Dependency Tree

### Runtime Dependencies
- Bash 4+ (for arrays and advanced features)
- Git (for cloning skills/updates)
- Curl (for downloading resources)
- Optional: RTK (token-optimized CLI)
- Optional: Modern CLI replacements (bat, dust, procs, etc.)

### Build-Time Dependencies  
- None (pure bash/scripts)

## 🔄 Update Mechanism

### Skill Updates
1. Git pull in each skill directory: `cd .agents/skills/skill-name && git pull`
2. Or full repo pull and selective skill sync

### Configuration Updates
- AGENTS.md: Git pull or manual update
- Rules: Git pull or manual update
- Setup scripts: Git pull for improvements

## 🧩 Integration Points

### With OMP Agent
- AGENTS.md is sourced by the agent on startup
- Skills are auto-discovered from .agents/skills/
- Rules are loaded for validation and guidance

### With Developer Workflow
- Pre-commit hooks validate code before commits
- Setup script enables reproducible environments
- Documentation guides usage and contribution

## 📏 Version Compatibility

### Minimum Requirements
- Bash 4.0+
- Git 2.0+
- Curl 7.0+

### Tested On
- Ubuntu 20.04+
- macOS 12+ (Intel & Apple Silicon)
- WSL2 Ubuntu 20.04+

### Backward Compatibility
- Designed to work with existing OMP agent installations
- Non-destructive installation (backs up or skips existing)
- Version-agnostic skill loading