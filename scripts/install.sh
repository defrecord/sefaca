#!/bin/bash
# SEFACA Minimal Installation Script
#
# This script installs the minimal SEFACA implementation
# Usage: curl -sSL https://sefaca.dev/install.sh | sh

set -e

# Configuration
SEFACA_VERSION="${SEFACA_VERSION:-0.1.0-minimal}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
SEFACA_URL="${SEFACA_URL:-https://raw.githubusercontent.com/defrecord/sefaca/main/scripts/sefaca.sh}"
SHELL_RC=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Detect shell and RC file
detect_shell() {
    if [[ -n "$BASH_VERSION" ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.profile" ]]; then
        SHELL_RC="$HOME/.profile"
    else
        print_error "Could not detect shell RC file"
        return 1
    fi
}

# Check requirements
check_requirements() {
    print_info "Checking requirements..."
    
    # Check for required commands
    for cmd in curl git; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "$cmd is required but not installed"
            return 1
        fi
    done
    
    print_success "All requirements met"
}

# Create installation directory
create_install_dir() {
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_info "Creating installation directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi
    
    # Check if directory is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_info "Adding $INSTALL_DIR to PATH"
        echo "" >> "$SHELL_RC"
        echo "# Added by SEFACA installer" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
    fi
}

# Download and install SEFACA
install_sefaca() {
    print_info "Downloading SEFACA v${SEFACA_VERSION}..."
    
    local temp_file=$(mktemp)
    
    # Download the script (supports both https:// and file:// for testing)
    if [[ "$SEFACA_URL" =~ ^file:// ]]; then
        # Handle local file URL for testing
        local file_path="${SEFACA_URL#file://}"
        if [[ -f "$file_path" ]]; then
            cp "$file_path" "$temp_file"
        else
            print_error "Local file not found: $file_path"
            return 1
        fi
    elif curl -sSL "$SEFACA_URL" -o "$temp_file"; then
        # Downloaded successfully
        true
    else
        print_error "Failed to download from $SEFACA_URL"
        return 1
    fi
    
    # Verify download succeeded
    if [[ -f "$temp_file" ]]; then
        # Verify it's a shell script
        if head -1 "$temp_file" | grep -q "^#!/bin/bash"; then
            mv "$temp_file" "$INSTALL_DIR/sefaca"
            chmod +x "$INSTALL_DIR/sefaca"
            print_success "SEFACA installed to $INSTALL_DIR/sefaca"
        else
            print_error "Downloaded file does not appear to be a valid shell script"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_error "Failed to download SEFACA"
        rm -f "$temp_file"
        return 1
    fi
}

# Create wrapper script
create_wrapper() {
    print_info "Creating sefaca wrapper..."
    
    cat > "$INSTALL_DIR/sefaca-init" << 'EOF'
#!/bin/bash
# SEFACA initialization wrapper
# Source this file to load SEFACA functions into your shell

# Find the sefaca script
SEFACA_SCRIPT="$(dirname "$BASH_SOURCE")/sefaca"

if [[ -f "$SEFACA_SCRIPT" ]]; then
    source "$SEFACA_SCRIPT"
else
    echo "Error: SEFACA script not found at $SEFACA_SCRIPT" >&2
    return 1
fi
EOF
    
    chmod +x "$INSTALL_DIR/sefaca-init"
    print_success "Created initialization wrapper"
}

# Add auto-initialization to shell RC (optional)
setup_auto_init() {
    # Skip in non-interactive mode
    if [[ -n "$SEFACA_NONINTERACTIVE" ]]; then
        print_info "Skipping auto-initialization setup (non-interactive mode)"
        return
    fi
    
    read -p "Would you like to automatically load SEFACA in new shells? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> "$SHELL_RC"
        echo "# SEFACA auto-initialization" >> "$SHELL_RC"
        echo "if [[ -f \"$INSTALL_DIR/sefaca-init\" ]]; then" >> "$SHELL_RC"
        echo "    source \"$INSTALL_DIR/sefaca-init\"" >> "$SHELL_RC"
        echo "fi" >> "$SHELL_RC"
        print_success "Added SEFACA auto-initialization to $SHELL_RC"
    fi
}

# Main installation process
main() {
    echo "🐕 SEFACA Minimal Installation"
    echo "=============================="
    echo
    
    # Run installation steps
    detect_shell || exit 1
    check_requirements || exit 1
    create_install_dir || exit 1
    install_sefaca || exit 1
    create_wrapper || exit 1
    setup_auto_init
    
    echo
    print_success "SEFACA installation complete!"
    echo
    echo "To start using SEFACA:"
    echo "  1. Reload your shell: source $SHELL_RC"
    echo "  2. Or source directly: source $INSTALL_DIR/sefaca-init"
    echo
    echo "Quick test:"
    echo "  sefaca run echo 'Hello from SEFACA!'"
    echo
    echo "For more information: sefaca help"
}

# Run main installation
main "$@"