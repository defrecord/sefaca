#!/bin/sh
# SEFACA Installation Script for Piped Execution
# Git SHA: 304dd02
# This handles: curl -sSL https://sefaca.dev/install.sh | sh
#
# Since we're in a subshell, we can't modify the parent environment.
# Instead, we'll download files and provide instructions.

set -e

# Configuration
SEFACA_VERSION="0.1.0-minimal"
SEFACA_SHA="304dd02"
SEFACA_URL="${SEFACA_URL:-https://raw.githubusercontent.com/defrecord/sefaca/main/scripts/sefaca.sh}"
INSTALL_DIR="${HOME}/.sefaca/bin"

# Display banner
echo ""
echo "🐕 SEFACA - Safe Execution Framework for Autonomous Coding Agents"
echo "📋 Version: ${SEFACA_VERSION} (${SEFACA_SHA})"
echo ""
echo "   ┌─────────────────────────────────────────────┐"
echo "   │  Every AI action. Tracked. Controlled. Safe. │"
echo "   └─────────────────────────────────────────────┘"
echo ""

# Create installation directory
echo "📍 Installing SEFACA v${SEFACA_VERSION}..."
mkdir -p "${INSTALL_DIR}"

# Download sefaca.sh
target_file="${INSTALL_DIR}/sefaca.sh"
if [ "${SEFACA_URL#file://}" != "$SEFACA_URL" ]; then
    # Handle file:// URL for testing
    cp "${SEFACA_URL#file://}" "$target_file"
elif [ -n "$SEFACA_URL" ] && [ "$SEFACA_URL" != "${SEFACA_URL#http://localhost}" ]; then
    # Handle localhost URLs - URL is already set correctly by make test-install
    curl -sSL "$SEFACA_URL" -o "$target_file" || {
        echo "❌ Error: Failed to download from localhost"
        exit 1
    }
else
    # Download from URL
    curl -sSL "$SEFACA_URL" -o "$target_file" || {
        echo "❌ Error: Failed to download SEFACA"
        exit 1
    }
fi

chmod +x "$target_file"
echo "✅ SEFACA downloaded to ${INSTALL_DIR}/sefaca.sh"

# Create a loader script with absolute path
cat > "${INSTALL_DIR}/load-sefaca" << EOF
#!/bin/sh
# Load SEFACA into current shell
SEFACA_BIN_DIR="${INSTALL_DIR}"
if [ -f "\${SEFACA_BIN_DIR}/sefaca.sh" ]; then
    . "\${SEFACA_BIN_DIR}/sefaca.sh"
else
    echo "Error: sefaca.sh not found in \${SEFACA_BIN_DIR}"
    return 1
fi
EOF
chmod +x "${INSTALL_DIR}/load-sefaca"

# Show instructions
echo ""
echo "🚀 Installation complete! To start using SEFACA:"
echo ""
echo "   source ${INSTALL_DIR}/load-sefaca"
echo ""
echo "Or add this line to your shell profile (~/.bashrc or ~/.zshrc):"
echo ""
echo "   # Load SEFACA"
echo "   [ -f \"${INSTALL_DIR}/load-sefaca\" ] && source \"${INSTALL_DIR}/load-sefaca\""
echo ""
echo "Then you can use:"
echo "   sefaca run --context \"[builder:bot:you@local(myapp:main)]\" make test"
echo "   sefaca logs --tail 100"
echo ""
echo "🔒 Stay safe out there! 🐕"