# ============================================================
# OMP Agentic Setup - Makefile
# Common automation commands
# ============================================================

SHELL := /usr/bin/env bash
SCRIPT_DIR := $(CURDIR)
AGENT_DIR ?= $(HOME)/.agents

.PHONY: help install validate skills clean test-env lint docs

help:
	@echo "OMP Agentic Setup - Available Commands"
	@echo "========================================="
	@echo "make install      - Install the complete harness"
	@echo "make validate     - Validate the installed environment"
	@echo "make skills       - List available skills"
	@echo "make clean        - Uninstall and clean up"
	@echo "make test-env     - Test environment setup"
	@echo "make lint         - Run linting checks on scripts"
	@echo "make docs         - Generate documentation"
	@echo "make pr           - Create a pull request"

install:
	@echo "Installing OMP Agentic Setup..."
	@$(SCRIPT_DIR)/setup.sh

validate:
	@echo "Validating installation..."
	@$(SCRIPT_DIR)/scripts/validate.sh

skills:
	@echo "Available skills:"
	@find $(SCRIPT_DIR)/.agents/skills -mindepth 1 -maxdepth 1 -type d | while read dir; do \
		name=$$(basename "$$dir"); \
		desc=$$(head -5 "$$dir/SKILL.md" | grep -E "^# " | sed 's/^# //' | head -1); \
		printf "  %-30s %s\n" "$$name" "($$desc)"; \
	done | sort

clean:
	@echo "Cleaning up..."
	@rm -rf ~/.agents

test-env:
	@echo "Testing environment setup..."
	@$(SCRIPT_DIR)/setup.sh --dry-run
	@$(SCRIPT_DIR)/scripts/validate.sh || true

lint:
	@echo "Linting scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SCRIPT_DIR)/setup.sh $(SCRIPT_DIR)/scripts/validate.sh; \
	else \
		echo "shellcheck not installed, skipping"; \
	fi

docs:
	@echo "Documentation files:"
	@ls -1 $(SCRIPT_DIR)/docs/*.md 2>/dev/null || echo "No docs found"

pr:
	@echo "Creating pull request..."
	@if command -v gh >/dev/null 2>&1; then \
		gh pr create; \
	else \
		echo "GitHub CLI (gh) not installed"; \
		echo "Visit: https://github.com/antoinelucasfra/agentic-setup/pull/new/main"; \
	fi