.PHONY: help all deps clean test lint ci-status

help: ## Show this help message
	@echo "SEFACA - Safe Execution Framework for Autonomous Coding Agents"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Note: This is a placeholder repository while core code is in development."

all: deps ## Run all checks

deps: ## Check system dependencies
	@echo "Installing dependencies..."
	@echo "Note: This is a placeholder repository. Core implementation in development."
	@echo ""
	@echo "Checking system requirements..."
	@if command -v python3 >/dev/null 2>&1; then \
		PYTHON_CMD=python3; \
	elif command -v python3.9 >/dev/null 2>&1; then \
		PYTHON_CMD=python3.9; \
	elif command -v python3.8 >/dev/null 2>&1; then \
		PYTHON_CMD=python3.8; \
	elif command -v python >/dev/null 2>&1; then \
		PYTHON_CMD=python; \
	else \
		echo "Python 3.8+ is required but not installed."; exit 1; \
	fi; \
	command -v node >/dev/null 2>&1 || { echo "Node.js 16+ is required but not installed."; exit 1; }; \
	echo "✓ Python $$($$PYTHON_CMD --version 2>&1 | cut -d' ' -f2)"; \
	echo "✓ Node.js $$(node --version)"; \
	if command -v guile3 >/dev/null 2>&1; then \
		echo "✓ Guile $$(guile3 --version | head -1 | cut -d' ' -f4)"; \
	elif command -v guile >/dev/null 2>&1; then \
		echo "✓ Guile $$(guile --version | head -1 | cut -d' ' -f4)"; \
	else \
		echo "⚠ Guile 3.0+ not found (optional)"; \
	fi
	@echo ""
	@echo "Platform check..."
	@uname -s | grep -q "FreeBSD" && echo "✓ FreeBSD detected" || echo "⚠ Warning: SEFACA is optimized for FreeBSD"
	@echo ""
	@echo "Dependencies check complete."

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf build/ dist/ *.egg-info/ 2>/dev/null || true
	rm -rf node_modules/ 2>/dev/null || true
	@echo "Clean complete."

test: ## Run tests (placeholder)
	@echo "Tests will be available when core implementation is released."

lint: ## Run linters (placeholder)
	@echo "Linting will be available when core implementation is released."

ci-status: ## Check CI/CD workflow status
	@echo "Checking CI/CD status for SEFACA..."
	@echo ""
	@echo "GitHub Actions workflow status:"
	@echo "https://github.com/defrecord/sefaca/actions/workflows/deps.yml"
	@echo ""
	@command -v gh >/dev/null 2>&1 && gh workflow view deps.yml || echo "Install GitHub CLI (gh) for detailed status"