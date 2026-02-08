# ============================================================================
# Self-Documenting Makefile for Software Projects
# ============================================================================
#
# HOW TO USE THIS TEMPLATE:
# 1. Replace [PLACEHOLDER] commands with your actual build/test/lint commands
# 2. Remove sections that don't apply to your project
# 3. Add project-specific targets as needed
# 4. Run `make help` to see all available commands
#
# CONVENTIONS:
# - All user-facing targets have ## comments for self-documentation
# - Internal targets are prefixed with _ (underscore)
# - Phony targets are declared to avoid conflicts with filenames
# - Variables at the top for easy customization
# ============================================================================

# --- Configuration -----------------------------------------------------------
# Customize these variables for your project

# Project
PROJECT_NAME   ?= [YOUR_PROJECT_NAME]
VERSION        ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

# Directories
SRC_DIR        ?= src
TEST_DIR       ?= tests
DOCS_DIR       ?= docs
BUILD_DIR      ?= build
COVERAGE_DIR   ?= coverage

# Tools — replace with your stack's tools
# Examples for common stacks:
#   Python:     BUILD_CMD=python -m build, TEST_CMD=pytest, LINT_CMD=ruff check
#   Node.js:    BUILD_CMD=npm run build, TEST_CMD=npm test, LINT_CMD=eslint .
#   Go:         BUILD_CMD=go build ./..., TEST_CMD=go test ./..., LINT_CMD=golangci-lint run
#   Rust:       BUILD_CMD=cargo build, TEST_CMD=cargo test, LINT_CMD=cargo clippy
BUILD_CMD      ?= echo "[PLACEHOLDER] Replace with your build command"
TEST_CMD       ?= echo "[PLACEHOLDER] Replace with your test command"
TEST_UNIT_CMD  ?= echo "[PLACEHOLDER] Replace with unit test command (e.g., pytest tests/unit)"
TEST_INT_CMD   ?= echo "[PLACEHOLDER] Replace with integration test command (e.g., pytest tests/integration)"
TEST_E2E_CMD   ?= echo "[PLACEHOLDER] Replace with e2e test command"
LINT_CMD       ?= echo "[PLACEHOLDER] Replace with your lint command"
FORMAT_CMD     ?= echo "[PLACEHOLDER] Replace with your format command"
TYPECHECK_CMD  ?= echo "[PLACEHOLDER] Replace with your typecheck command"
SECURITY_CMD   ?= echo "[PLACEHOLDER] Replace with your security audit command"
COVERAGE_CMD   ?= echo "[PLACEHOLDER] Replace with your coverage command"
DEPS_CMD       ?= echo "[PLACEHOLDER] Replace with your dependency install command"
CLEAN_CMD      ?= rm -rf $(BUILD_DIR) $(COVERAGE_DIR)

# Deploy — replace with your deployment commands
DEPLOY_STAGING_CMD    ?= echo "[PLACEHOLDER] Replace with staging deploy command"
DEPLOY_PRODUCTION_CMD ?= echo "[PLACEHOLDER] Replace with production deploy command"

# Colors for output
BLUE   := \033[36m
GREEN  := \033[32m
YELLOW := \033[33m
RED    := \033[31m
RESET  := \033[0m
BOLD   := \033[1m

# --- Default Target ----------------------------------------------------------

.DEFAULT_GOAL := help

# --- Phony Targets -----------------------------------------------------------

.PHONY: help build test test-unit test-int test-e2e lint format typecheck \
        check clean deps security coverage \
        deploy-staging deploy-production \
        score _confirm-production

# --- Help --------------------------------------------------------------------

help: ## Show this help message
	@echo ""
	@echo "$(BOLD)$(PROJECT_NAME)$(RESET) $(BLUE)v$(VERSION)$(RESET)"
	@echo ""
	@echo "$(BOLD)Usage:$(RESET) make $(BLUE)<target>$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-22s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# --- Build -------------------------------------------------------------------

build: ## Build the project
	@echo "$(BLUE)Building $(PROJECT_NAME)...$(RESET)"
	@$(BUILD_CMD)
	@echo "$(GREEN)Build complete.$(RESET)"

# --- Testing -----------------------------------------------------------------

test: ## Run full test suite
	@echo "$(BLUE)Running all tests...$(RESET)"
	@$(TEST_CMD)
	@echo "$(GREEN)All tests passed.$(RESET)"

test-unit: ## Run unit tests only
	@echo "$(BLUE)Running unit tests...$(RESET)"
	@$(TEST_UNIT_CMD)

test-int: ## Run integration tests only
	@echo "$(BLUE)Running integration tests...$(RESET)"
	@$(TEST_INT_CMD)

test-e2e: ## Run end-to-end tests only
	@echo "$(BLUE)Running e2e tests...$(RESET)"
	@$(TEST_E2E_CMD)

test-watch: ## Run tests in watch mode (TDD)
	@echo "$(BLUE)Starting test watcher (TDD mode)...$(RESET)"
	@echo "[PLACEHOLDER] Replace with your watch command (e.g., pytest-watch, vitest, cargo watch -x test)"

coverage: ## Generate test coverage report
	@echo "$(BLUE)Generating coverage report...$(RESET)"
	@$(COVERAGE_CMD)

# --- Code Quality ------------------------------------------------------------

lint: ## Run linters and static analysis
	@echo "$(BLUE)Running linters...$(RESET)"
	@$(LINT_CMD)
	@echo "$(GREEN)Lint passed.$(RESET)"

format: ## Auto-format code
	@echo "$(BLUE)Formatting code...$(RESET)"
	@$(FORMAT_CMD)
	@echo "$(GREEN)Formatting complete.$(RESET)"

typecheck: ## Run type checker
	@echo "$(BLUE)Running type checker...$(RESET)"
	@$(TYPECHECK_CMD)
	@echo "$(GREEN)Type check passed.$(RESET)"

# --- Combined Checks --------------------------------------------------------

check: build test lint typecheck ## Run ALL checks (build + test + lint + typecheck)
	@echo "$(GREEN)$(BOLD)All checks passed.$(RESET)"

# --- Security ----------------------------------------------------------------

security: ## Run security audit (dependencies + code)
	@echo "$(BLUE)Running security audit...$(RESET)"
	@$(SECURITY_CMD)
	@echo "$(GREEN)Security audit complete.$(RESET)"

# --- Dependencies ------------------------------------------------------------

deps: ## Install/update project dependencies
	@echo "$(BLUE)Installing dependencies...$(RESET)"
	@$(DEPS_CMD)
	@echo "$(GREEN)Dependencies installed.$(RESET)"

clean: ## Remove build artifacts and caches
	@echo "$(BLUE)Cleaning build artifacts...$(RESET)"
	@$(CLEAN_CMD)
	@echo "$(GREEN)Clean complete.$(RESET)"

# --- Quality Scoring ---------------------------------------------------------

score: ## Run quality score (0-100) against quality gates
	@python3 scripts/score.py --summary

# --- Deployment --------------------------------------------------------------

deploy-staging: ## Deploy to staging environment
	@echo "$(YELLOW)Deploying to staging...$(RESET)"
	@$(DEPLOY_STAGING_CMD)
	@echo "$(GREEN)Staging deployment complete.$(RESET)"

deploy-production: _confirm-production ## Deploy to production (requires confirmation)
	@echo "$(RED)$(BOLD)Deploying to PRODUCTION...$(RESET)"
	@$(DEPLOY_PRODUCTION_CMD)
	@echo "$(GREEN)Production deployment complete.$(RESET)"

_confirm-production:
	@echo "$(RED)$(BOLD)WARNING: You are about to deploy to PRODUCTION.$(RESET)"
	@echo -n "Type 'yes' to confirm: " && read ans && [ "$$ans" = "yes" ] || (echo "$(YELLOW)Aborted.$(RESET)" && exit 1)
