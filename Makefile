# ============================================================
# OMP Agentic Setup - Makefile
# Common automation commands
# ============================================================

# Variables
AGENTS_DIR ?= $(HOME)/.agents
SCRIPT_DIR := $(CURDIR)
PYTHON ?= python3
BASH ?= bash

# Default target
.PHONY: help
help:
	@echo "OMP Agentic Setup - Available Commands"
	@echo "========================================="
	@echo "make install      - Install the complete harness"
	@echo "make validate     - Validate the installed environment"
	@echo "make skills       - List available skills"
	@echo "make clean        - Uninstall and clean up"
	@echo "make test-env     - Test environment setup"
	@echo "make skills-update - Update skills to latest versions"
	@echo "make check-upgrade - Validate and upgrade if needed"
	@echo "make lint         - Run linting checks on scripts"
	@echo "make docs         - Generate documentation"

# Installation commands
.PHONY: install
install:
	@echo "Installing OMP Agentic Setup..."
	@$(BASH) $(SCRIPT_DIR)/setup.sh

.PHONY: install-skill
install-skill:
	@echo "Installing specific skill: $(SKILL)"
	@$(BASH) $(SCRIPT_DIR)/setup.sh --install-skill "$(SKILL)"

# Validation commands
.PHONY: validate
validate:
	@echo "Validating installation..."
	@$(BASH) $(SCRIPT_DIR)/scripts/validate.sh

.PHONY: test-env
test-env:
	@echo "Testing environment setup..."
	@$(BASH) $(SCRIPT_DIR)/setup.sh --dry-run
	@$(BASH) $(SCRIPT_DIR)/scripts/validate.sh || true

# Skills management
.PHONY: skills
skills:
	@echo "Available skills:"
	@$(BASH) $(SCRIPT_DIR)/setup.sh --list-skills

.PHONY: skills-update
skills-update:
	@echo "Updating skills..."
	@if [ -d "$(AGENTS_DIR)/skills" ]; then \
		for skill in $(AGENTS_DIR)/skills/*/; do \
			echo "Updating $$skill"; \
			if [ -d "$$skill/.git" ]; then \
				(cd "$$skill" && git pull); \
			fi; \
		done; \
	fi

.PHONY: check-upgrade
check-upgrade: validate
	@echo "Checking for upgrades..."
	@$(BASH) $(SCRIPT_DIR)/scripts/check-upgrade.sh

# Cleanup
.PHONY: clean
clean:
	@echo "Cleaning up..."
	@$(BASH) $(SCRIPT_DIR)/setup.sh --uninstall

# Linting
.PHONY: lint
lint:
	@echo "Linting scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SCRIPT_DIR)/setup.sh $(SCRIPT_DIR)/scripts/*.sh; \
	else \
		echo "shellcheck not installed, skipping"; \
	fi
	@if command -v markdownlint >/dev/null 2>&1; then \
		markdownlint $(SCRIPT_DIR)/*.md $(SCRIPT_DIR)/docs/*.md; \
	else \
		echo "markdownlint not installed, skipping"; \
	fi

# Documentation
.PHONY: docs
docs:
	@echo "Generating documentation..."
	@$(PYTHON) $(SCRIPT_DIR)/scripts/generate-docs.py

# Development
.PHONY: dev-setup
dev-setup:
	@echo "Setting up development environment..."
	@$(BASH) $(SCRIPT_DIR)/setup.sh --skip-system
	@$(BASH) $(SCRIPT_DIR)/scripts/validate.sh

# CI targets
.PHONY: ci
ci: lint validate
	@echo "Running CI checks..."

.PHONY: all
all: install validate