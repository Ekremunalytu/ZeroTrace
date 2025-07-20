# ZeroTrace - Cross-Platform Development Environment
# Usage: make <target>
#
# This Makefile provides a unified interface for all development tasks
# and automatically detects the best environment (container vs local).

.PHONY: help setup start stop shell build test clean lint format security status reset

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[36m
GREEN := \033[32m
RED := \033[31m
YELLOW := \033[33m
CYAN := \033[96m
RESET := \033[0m

# Cross-platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
endif
ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
endif
ifeq ($(findstring CYGWIN,$(UNAME_S)),CYGWIN)
    PLATFORM := windows
endif
ifeq ($(findstring MINGW,$(UNAME_S)),MINGW)
    PLATFORM := windows
endif

# Development wrapper script
DEV_SCRIPT := "$(PWD)/tools/development/scripts/dev-manager.sh"

help: ## Show this help message
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║                     🛡️  ZeroTrace XDR                      ║$(RESET)"
	@echo "$(CYAN)║                Cross-Platform Development                    ║$(RESET)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(GREEN)Environment Commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / { printf "  $(BLUE)%-15s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | grep -E "(setup|start|stop|shell|status|reset)"
	@echo ""
	@echo "$(GREEN)Development Commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / { printf "  $(BLUE)%-15s$(RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | grep -E "(build|test|clean|lint|format|security)"
	@echo ""
	@echo "$(YELLOW)Quick Start (Platform: $(PLATFORM)):$(RESET)"
	@echo "  1. make setup     # Setup development environment"
	@echo "  2. make start     # Start development environment"
	@echo "  3. make build     # Build all components"
	@echo "  4. make test      # Run tests"
	@echo "  5. make shell     # Open development shell"
	@echo ""

## Environment Management

setup: ## Setup development environment (auto-detects best method)
	@echo "$(GREEN)Setting up ZeroTrace development environment...$(RESET)"
	@$(DEV_SCRIPT) setup

start: ## Start development environment
	@echo "$(GREEN)Starting development environment...$(RESET)"
	@$(DEV_SCRIPT) start

stop: ## Stop development environment
	@echo "$(GREEN)Stopping development environment...$(RESET)"
	@$(DEV_SCRIPT) stop

shell: ## Open development shell
	@echo "$(GREEN)Opening development shell...$(RESET)"
	@$(DEV_SCRIPT) shell

status: ## Show environment status
	@echo "$(GREEN)Checking environment status...$(RESET)"
	@$(DEV_SCRIPT) status

reset: ## Reset entire environment (destructive)
	@echo "$(RED)Resetting environment...$(RESET)"
	@$(DEV_SCRIPT) reset

## Development Commands

build: ## Build all components
	@echo "$(GREEN)Building all components...$(RESET)"
	@$(DEV_SCRIPT) build

build-cpp: ## Build C++ components only
	@echo "$(GREEN)Building C++ components...$(RESET)"
	@$(DEV_SCRIPT) build cpp

build-python: ## Build Python components only
	@echo "$(GREEN)Building Python components...$(RESET)"
	@$(DEV_SCRIPT) build python

security: ## Run security checks
	@echo "$(GREEN)Running security checks...$(RESET)"
	@$(DEV_SCRIPT) security

lint: ## Run linting on all code
	@echo "$(GREEN)Running linters...$(RESET)"
	@$(DEV_SCRIPT) lint

format: ## Format all code (C++, Python)
	@echo "$(GREEN)Formatting code...$(RESET)"
	@$(DEV_SCRIPT) format

pre-commit-install: ## Install pre-commit hooks
	@echo "$(GREEN)Installing pre-commit hooks...$(RESET)"
	@$(DEV_SCRIPT) pre-commit-install

quality: lint security ## Run all quality checks

test: ## Run all tests
	@echo "$(GREEN)Running all tests...$(RESET)"
	@$(DEV_SCRIPT) test

test-unit: ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(RESET)"
	@$(DEV_SCRIPT) test tests/unit/

test-integration: ## Run integration tests only
	@echo "$(GREEN)Running integration tests...$(RESET)"
	@$(DEV_SCRIPT) test tests/integration/

lint: ## Run code linting
	@echo "$(GREEN)Running code linting...$(RESET)"
	@$(DEV_SCRIPT) lint

format: ## Format code
	@echo "$(GREEN)Formatting code...$(RESET)"
	@$(DEV_SCRIPT) format

security: ## Run security checks
	@echo "$(GREEN)Running security checks...$(RESET)"
	@$(DEV_SCRIPT) security

clean: ## Clean build artifacts
	@echo "$(GREEN)Cleaning build artifacts...$(RESET)"
	@$(DEV_SCRIPT) clean

## Service Management

services: ## Start all services (DB, Queue, Redis)
	@echo "$(GREEN)Starting all services...$(RESET)"
	@$(DEV_SCRIPT) services

db: ## Start database only
	@echo "$(GREEN)Starting database...$(RESET)"
	@$(DEV_SCRIPT) db

queue: ## Start message queue only
	@echo "$(GREEN)Starting message queue...$(RESET)"
	@$(DEV_SCRIPT) queue

logs: ## Show container logs
	@echo "$(GREEN)Showing logs...$(RESET)"
	@$(DEV_SCRIPT) logs

## Utility Commands

check: ## Check environment setup
	@echo "$(GREEN)Checking environment...$(RESET)"
	@$(DEV_SCRIPT) check

# Legacy aliases for backward compatibility
up: start ## Alias for start
down: stop ## Alias for stop
dev-setup: setup ## Alias for setup
