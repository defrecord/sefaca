#!/bin/bash
# SEFACA Installation Testing Framework
#
# This script tests the installation process in an isolated environment
# without affecting the user's actual system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="/tmp/sefaca-test-$$"
FIXTURE_DIR="/tmp/sefaca.dev"
INSTALL_SCRIPT="${FIXTURE_DIR}/install.sh"
ENV_BEFORE="${TEST_DIR}/env-before.txt"
ENV_AFTER="${TEST_DIR}/env-after.txt"

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Setup test environment
setup_test_env() {
    print_header "Setting up test environment"
    
    # Create test directories
    mkdir -p "${TEST_DIR}"
    mkdir -p "${FIXTURE_DIR}"
    
    # Create a fake home directory for testing
    export TEST_HOME="${TEST_DIR}/home"
    mkdir -p "${TEST_HOME}"
    
    # Save original environment
    export ORIG_HOME="$HOME"
    export ORIG_PATH="$PATH"
    
    print_success "Test environment created at ${TEST_DIR}"
}

# Capture environment state
capture_env_state() {
    local output_file="$1"
    local label="$2"
    
    print_info "Capturing environment state: ${label}"
    
    # Capture environment variables (without values for security)
    echo "=== Environment Variables ===" > "$output_file"
    env | cut -d= -f1 | sort >> "$output_file"
    
    # Capture PATH entries
    echo -e "\n=== PATH Entries ===" >> "$output_file"
    echo "$PATH" | tr ':' '\n' | sort | uniq >> "$output_file"
    
    # Capture shell functions
    echo -e "\n=== Shell Functions ===" >> "$output_file"
    declare -F | cut -d' ' -f3 | sort >> "$output_file"
    
    # Capture aliases
    echo -e "\n=== Aliases ===" >> "$output_file"
    alias 2>/dev/null | cut -d= -f1 | cut -d' ' -f2 | sort >> "$output_file" || true
    
    print_success "Environment state captured to $(basename "$output_file")"
}

# Create fixture install script
create_fixture() {
    print_header "Creating install script fixture"
    
    if [[ -f "scripts/install.sh" ]]; then
        cp "scripts/install.sh" "${INSTALL_SCRIPT}"
        print_success "Copied scripts/install.sh to ${INSTALL_SCRIPT}"
    else
        print_error "scripts/install.sh not found!"
        return 1
    fi
    
    # Also copy the sefaca.sh script to simulate download
    if [[ -f "scripts/sefaca.sh" ]]; then
        mkdir -p "${FIXTURE_DIR}/scripts"
        cp "scripts/sefaca.sh" "${FIXTURE_DIR}/scripts/sefaca.sh"
        
        # Modify install script to use local fixture instead of GitHub
        # Using @ as delimiter since paths contain /
        sed -i.bak "s@https://raw.githubusercontent.com/defrecord/sefaca/main/scripts/sefaca.sh@file://${FIXTURE_DIR}/scripts/sefaca.sh@g" "${INSTALL_SCRIPT}"
        print_success "Modified install script to use local fixtures"
    fi
}

# Run installation test
run_install_test() {
    print_header "Running installation test"
    
    # Capture environment before
    capture_env_state "${ENV_BEFORE}" "BEFORE installation"
    
    # Run installation in test environment
    print_info "Executing: bash ${INSTALL_SCRIPT}"
    
    # Create a subshell with modified environment
    (
        export HOME="${TEST_HOME}"
        export INSTALL_DIR="${TEST_HOME}/.local/bin"
        export PATH="${TEST_HOME}/.local/bin:${ORIG_PATH}"
        export SEFACA_NONINTERACTIVE=1
        
        # Create fake shell RC files
        touch "${TEST_HOME}/.bashrc"
        touch "${TEST_HOME}/.zshrc"
        
        # Run the installation with bash (since script uses bash features)
        bash "${INSTALL_SCRIPT}"
    )
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Installation completed successfully"
    else
        print_error "Installation failed with exit code $exit_code"
    fi
    
    # Capture environment after
    capture_env_state "${ENV_AFTER}" "AFTER installation"
    
    return $exit_code
}

# Show environment differences
show_env_diff() {
    print_header "Environment Changes"
    
    echo -e "\n${YELLOW}New environment variables:${NC}"
    comm -13 <(grep "^[A-Z]" "${ENV_BEFORE}" | sort) <(grep "^[A-Z]" "${ENV_AFTER}" | sort) || true
    
    echo -e "\n${YELLOW}New PATH entries:${NC}"
    comm -13 <(grep -A100 "PATH Entries" "${ENV_BEFORE}" | tail -n +2 | grep -v "^===" | sort) \
             <(grep -A100 "PATH Entries" "${ENV_AFTER}" | tail -n +2 | grep -v "^===" | sort) || true
    
    echo -e "\n${YELLOW}New shell functions:${NC}"
    comm -13 <(grep -A100 "Shell Functions" "${ENV_BEFORE}" | tail -n +2 | grep -v "^===" | sort) \
             <(grep -A100 "Shell Functions" "${ENV_AFTER}" | tail -n +2 | grep -v "^===" | sort) || true
}

# Verify installation
verify_installation() {
    print_header "Verifying installation"
    
    local checks_passed=0
    local checks_total=0
    
    # Check if sefaca binary exists
    ((checks_total++))
    if [[ -f "${TEST_HOME}/.local/bin/sefaca" ]]; then
        print_success "sefaca binary installed"
        ((checks_passed++))
    else
        print_error "sefaca binary not found"
    fi
    
    # Check if sefaca-init exists
    ((checks_total++))
    if [[ -f "${TEST_HOME}/.local/bin/sefaca-init" ]]; then
        print_success "sefaca-init wrapper installed"
        ((checks_passed++))
    else
        print_error "sefaca-init wrapper not found"
    fi
    
    # Check if PATH was updated in shell RC
    ((checks_total++))
    if grep -q "/.local/bin" "${TEST_HOME}/.bashrc"; then
        print_success "PATH updated in .bashrc"
        ((checks_passed++))
    else
        print_error "PATH not updated in .bashrc"
    fi
    
    # Check if auto-init was added (if user selected yes)
    ((checks_total++))
    if grep -q "sefaca-init" "${TEST_HOME}/.bashrc"; then
        print_success "Auto-initialization added to .bashrc"
        ((checks_passed++))
    else
        print_info "Auto-initialization not added (user choice)"
    fi
    
    # Test if we can source and use sefaca
    ((checks_total++))
    if (
        export HOME="${TEST_HOME}"
        export PATH="${TEST_HOME}/.local/bin:${ORIG_PATH}"
        source "${TEST_HOME}/.local/bin/sefaca-init" 2>/dev/null
        # Test if function exists
        type sefaca >/dev/null 2>&1
    ); then
        print_success "SEFACA functions can be loaded"
        ((checks_passed++))
        
        # Test basic functionality
        (
            export HOME="${TEST_HOME}"
            export PATH="${TEST_HOME}/.local/bin:${ORIG_PATH}"
            source "${TEST_HOME}/.local/bin/sefaca-init"
            echo -e "\n${YELLOW}Testing SEFACA functionality:${NC}"
            sefaca status
            echo
            sefaca run echo "Test command execution"
        )
    else
        print_error "SEFACA functions failed to load"
    fi
    
    echo -e "\n${BLUE}Test Summary: ${checks_passed}/${checks_total} checks passed${NC}"
}

# Cleanup test environment
cleanup() {
    print_header "Cleaning up"
    
    if [[ -d "${TEST_DIR}" ]]; then
        rm -rf "${TEST_DIR}"
        print_success "Removed test directory"
    fi
    
    if [[ -d "${FIXTURE_DIR}" ]]; then
        rm -rf "${FIXTURE_DIR}"
        print_success "Removed fixture directory"
    fi
}

# Main test execution
main() {
    echo "🧪 SEFACA Installation Test Suite"
    echo "================================="
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Run test steps
    setup_test_env
    create_fixture
    run_install_test
    show_env_diff
    verify_installation
    
    echo -e "\n✅ Test completed!"
    echo "Check ${TEST_DIR} for detailed logs (will be cleaned up on exit)"
}

# Run tests
main "$@"