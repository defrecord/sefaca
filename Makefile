.PHONY: all deps clean test lint help

# Default target
all: deps

# Install dependencies
deps:
	@echo "Installing dependencies..."
	@echo "Note: This is a placeholder repository. Core implementation in development."
	@echo ""
	@echo "Checking system requirements..."
	@command -v python3 >/dev/null 2>&1 || { echo "Python 3.8+ is required but not installed."; exit 1; }
	@command -v node >/dev/null 2>&1 || { echo "Node.js 16+ is required but not installed."; exit 1; }
	@echo "✓ Python $(shell python3 --version 2>&1 | cut -d' ' -f2)"
	@echo "✓ Node.js $(shell node --version)"
	@echo ""
	@echo "Platform check..."
	@uname -s | grep -q "FreeBSD" && echo "✓ FreeBSD detected" || echo "⚠ Warning: SEFACA is optimized for FreeBSD"
	@echo ""
	@echo "Dependencies check complete."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf build/ dist/ *.egg-info/ 2>/dev/null || true
	rm -rf node_modules/ 2>/dev/null || true
	@echo "Clean complete."

# Run tests (placeholder)
test:
	@echo "Tests will be available when core implementation is released."

# Run linters (placeholder)
lint:
	@echo "Linting will be available when core implementation is released."

# Show help
help:
	@echo "SEFACA - Safe Execution Framework for Autonomous Coding Agents"
	@echo ""
	@echo "Available targets:"
	@echo "  make deps    - Check system dependencies"
	@echo "  make clean   - Clean build artifacts"
	@echo "  make test    - Run tests (placeholder)"
	@echo "  make lint    - Run linters (placeholder)"
	@echo "  make help    - Show this help message"
	@echo ""
	@echo "Note: This is a placeholder repository while core code is in development."