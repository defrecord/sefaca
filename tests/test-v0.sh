#!/bin/bash
# Test SEFACA v0 Non-Invasive Installation
#
# This tests the source-only installation method

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🧪 Testing SEFACA v0 Installation"
echo "================================"
echo ""

# Setup fixture
echo "Setting up test fixture..."
FIXTURE_DIR="/tmp/sefaca.dev"
mkdir -p "$FIXTURE_DIR"
cp scripts/install-v0.sh "$FIXTURE_DIR/install.sh"

# Modify to use local sefaca.sh
export SEFACA_URL="file://$(pwd)/scripts/sefaca.sh"

# Capture environment before
echo -e "\n${YELLOW}Environment before installation:${NC}"
echo "Shell functions: $(declare -F | wc -l)"
echo "SEFACA functions: $(declare -F | grep -c sefaca || echo "0")"

# Test the installation
echo -e "\n${YELLOW}Running installation...${NC}"
echo "source $FIXTURE_DIR/install.sh"
echo "---"

# Source the installer
source "$FIXTURE_DIR/install.sh"

# Check results
echo -e "\n${YELLOW}Environment after installation:${NC}"
echo "Shell functions: $(declare -F | wc -l)"
echo "SEFACA functions: $(declare -F | grep -c sefaca || echo "0")"
echo ""

# Test functionality
echo -e "${YELLOW}Testing SEFACA functionality:${NC}"
if type sefaca >/dev/null 2>&1; then
    echo -e "${GREEN}✅ sefaca function loaded${NC}"
    
    # Test commands
    echo ""
    sefaca status
    echo ""
    sefaca run echo "Test execution successful!"
    echo ""
    
    # Show context
    echo "Current context: $(sefaca_get_context)"
else
    echo -e "${RED}❌ sefaca function not found${NC}"
    exit 1
fi

# Show that nothing was permanently changed
echo -e "\n${YELLOW}Verifying no permanent changes:${NC}"
if [[ -f ~/.local/bin/sefaca ]]; then
    echo -e "${RED}❌ Binary was installed (should not happen)${NC}"
else
    echo -e "${GREEN}✅ No binary installed${NC}"
fi

if grep -q "sefaca" ~/.bashrc 2>/dev/null; then
    echo -e "${RED}❌ .bashrc was modified (should not happen)${NC}"
else
    echo -e "${GREEN}✅ .bashrc unchanged${NC}"
fi

# Cleanup
rm -rf "$FIXTURE_DIR"
echo -e "\n${GREEN}✅ Test completed successfully!${NC}"