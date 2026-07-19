SHELL := /usr/bin/env bash
SCRIPT_DIR := $(CURDIR)

.PHONY: install validate skills

install:
	@$(SCRIPT_DIR)/setup.sh

validate:
	@$(SCRIPT_DIR)/setup.sh --dry-run

skills:
	@find $(SCRIPT_DIR)/.agents/skills -mindepth 1 -maxdepth 1 -type d \
		| while read d; do \
			n=$$(basename "$$d"); \
			t=$$(head -5 "$$d/SKILL.md" | grep -E "^# " | sed 's/^# //' | head -1); \
			printf "  %-30s %s\n" "$$n" "($$t)"; \
		done | sort
