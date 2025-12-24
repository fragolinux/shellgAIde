# GNU-First Shell Toolchain Makefile
#
# NOTE:
#   - Do NOT pass PATH=... to make. PATH is used by /usr/bin/env.
#   - Use LINT_PATH=... to point lint to a directory or file (default: .).
#   - Use YES=1 to auto-consent for setup/align prompts (CI-friendly).

.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

TOOLCHAIN_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BIN := $(TOOLCHAIN_ROOT)/bin
BASH := bash

# Set YES=1 to auto-consent for alignment prompts.
YES ?= 0
BOOTSTRAP_YES := $(if $(filter 1 yes YES y Y,$(YES)),--yes,)

# Run toolchain commands under bash and source .toolchain/env.sh if present.
RUN_BASH := $(BASH) -lc
ENV_SOURCE := if [[ -f .toolchain/env.sh ]]; then source .toolchain/env.sh; fi;

.PHONY: help setup check align lint test ci ci-only shell

help: ## Show this help
	@printf '%s\n\n' "New user workflow:" \
	  "  1) First time in this repo:" \
	  "       make setup" \
	  "" \
	  "  2) Daily usage (recommended):" \
	  "       make shell" \
	  "       make ci" \
	  "" \
	  "Targets:" \
	  "  help               Show this help" \
	  "  setup              First-time setup: align (if needed) and print next steps (no subshell)" \
	  "  check              Check machine alignment (no changes)" \
	  "  align              Align machine (installs GNU tools). Prompts for consent interactively." \
	  "  lint               Lint scripts (ShellCheck + shfmt diff + structure). Uses LINT_PATH=. by default (override with LINT_PATH=path)." \
	  "  test               Run bats tests" \
	  "  ci                 CI gate: check alignment, lint, and tests" \
	  "  ci-only            CI-only unattended gate (installs deps + runs checks)" \
	  "  shell              Open an interactive shell with toolchain env loaded" \
	  "" \
	  "Examples:" \
	  "  make setup" \
	  "  make shell" \
	  "  make ci" \
	  "  make check" \
	  "  make align" \
	  "  make lint" \
	  "  make lint LINT_PATH=path/to/file.sh" \
	  "  make test" \
	  "" \
	  "CI examples:" \
	  "  make ci-only" \
	  "  make setup YES=1"

setup: ## First-time setup: align (if needed) and print next steps (no subshell)
	@$(BASH) $(BIN)/bootstrap.sh align $(BOOTSTRAP_YES)

check: ## Check machine alignment (no changes)
	@$(RUN_BASH) '$(ENV_SOURCE) $(BASH) $(BIN)/bootstrap.sh check'

align: ## Align machine (installs GNU tools). Prompts for consent interactively.
	@$(BASH) $(BIN)/bootstrap.sh align $(BOOTSTRAP_YES)

lint: ## Lint scripts (ShellCheck + shfmt diff + structure)
	@$(RUN_BASH) '$(ENV_SOURCE) LINT_PATH="$${LINT_PATH:-.}"; $(BASH) $(BIN)/lint.sh "$$LINT_PATH"'

test: ## Run bats tests
	@$(RUN_BASH) '$(ENV_SOURCE) $(BASH) $(BIN)/test.sh'

ci: ## CI gate: check alignment, lint, and tests
	@$(RUN_BASH) '$(ENV_SOURCE) $(BASH) $(BIN)/bootstrap.sh check && $(BASH) $(BIN)/lint.sh "$${LINT_PATH:-.}" && $(BASH) $(BIN)/test.sh'

ci-only: ## CI-only unattended gate (installs deps + runs checks)
	@$(BASH) $(BIN)/ci_only.sh

shell: ## Open an interactive shell with toolchain env loaded
	@$(BASH) $(BIN)/shell.sh
