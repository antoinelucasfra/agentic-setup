SHELL := /usr/bin/env bash
SCRIPT_DIR := $(CURDIR)

.PHONY: install validate

install:
	@$(SCRIPT_DIR)/setup.sh

validate:
	@$(SCRIPT_DIR)/setup.sh --dry-run

