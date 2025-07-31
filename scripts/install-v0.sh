#!/bin/bash
# SEFACA v0 - Minimal Non-Invasive Installation
#
# This script loads SEFACA into your current shell session only.
# No files are modified, no permanent changes are made.
#
# Usage: source <(curl -sSL https://sefaca.dev/install.sh)

# Configuration
SEFACA_VERSION="0.1.0-minimal"
SEFACA_URL="${SEFACA_URL:-https://raw.githubusercontent.com/defrecord/sefaca/main/scripts/sefaca.sh}"

# Create a function that does the installation
sefaca_install() {
    local TEMP_DIR="/tmp/sefaca-$$"
    
    # UI Elements
    echo ""
    echo "🐕 SEFACA - Safe Execution Framework for Autonomous Coding Agents"
    echo ""
    echo "   ┌─────────────────────────────────────────────┐"
    echo "   │  Every AI action. Tracked. Controlled. Safe. │"
    echo "   └─────────────────────────────────────────────┘"
    echo ""
    
    # Check bash
    if [[ -z "$BASH_VERSION" ]]; then
        echo "❌ Error: This script requires bash" >&2
        return 1
    fi
    
    # Download SEFACA
    echo "📍 Downloading SEFACA v${SEFACA_VERSION}..."
    
    mkdir -p "$TEMP_DIR"
    local target_file="$TEMP_DIR/sefaca.sh"
    
    # Handle both https:// and file:// URLs
    if [[ "$SEFACA_URL" =~ ^file:// ]]; then
        local file_path="${SEFACA_URL#file://}"
        if [[ -f "$file_path" ]]; then
            cp "$file_path" "$target_file"
        else
            echo "❌ Error: Local file not found: $file_path" >&2
            rm -rf "$TEMP_DIR"
            return 1
        fi
    else
        if ! curl -sSL "$SEFACA_URL" -o "$target_file" 2>/dev/null; then
            echo "❌ Error: Failed to download SEFACA" >&2
            rm -rf "$TEMP_DIR"
            return 1
        fi
    fi
    
    # Verify and source
    if [[ -f "$target_file" ]] && head -1 "$target_file" | grep -q "^#!/bin/bash"; then
        echo "✅ SEFACA downloaded successfully"
        echo ""
        
        # Source the script
        source "$target_file"
        
        # Show usage
        echo ""
        echo "🚀 Quick Start:"
        echo "   sefaca run echo 'Hello from SEFACA!'"
        echo "   sefaca status"
        echo "   sefaca help"
        echo ""
        echo "📚 Note: This is a temporary session. To use SEFACA in a new shell, run:"
        echo "   source <(curl -sSL https://sefaca.dev/install.sh)"
        echo ""
        echo "🔒 Stay safe out there! 🐕"
        
        # Clean up after delay
        (sleep 300 && rm -rf "$TEMP_DIR" 2>/dev/null) &
    else
        echo "❌ Error: Invalid script downloaded" >&2
        rm -rf "$TEMP_DIR"
        return 1
    fi
}

# Run the installation
sefaca_install "$@"

# Clean up the install function
unset -f sefaca_install