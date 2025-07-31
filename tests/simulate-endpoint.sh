#!/bin/bash
# Simulate sefaca.dev endpoint locally
#
# This test simulates the real installation experience from sefaca.dev

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🌐 Simulating sefaca.dev endpoint${NC}"
echo "=================================="
echo ""

# Step 1: Set up fake endpoint
echo -e "${YELLOW}1. Setting up /tmp/sefaca.dev/install.sh${NC}"
mkdir -p /tmp/sefaca.dev
cp scripts/install-v0.sh /tmp/sefaca.dev/install.sh
chmod +x /tmp/sefaca.dev/install.sh

# Copy sefaca.sh to simulate download
cp scripts/sefaca.sh /tmp/sefaca.dev/sefaca.sh

# Update install script to use local file
export SEFACA_URL="file:///tmp/sefaca.dev/sefaca.sh"

echo -e "${GREEN}✓ Endpoint ready at /tmp/sefaca.dev/install.sh${NC}"
echo ""

# Step 2: Show what users will experience
echo -e "${YELLOW}2. User experience simulation:${NC}"
echo -e "${BLUE}$ curl -sSL https://sefaca.dev/install.sh | sh${NC}"
echo "(simulated as: source /tmp/sefaca.dev/install.sh)"
echo "---"

# Run the installation (need to source it)
source /tmp/sefaca.dev/install.sh

echo ""
echo -e "${YELLOW}3. Testing installed SEFACA:${NC}"

# Test basic command
echo -e "\n${BLUE}$ sefaca run --context \"[builder:bot:you@local(myapp:main)]\" echo \"Hello SEFACA\"${NC}"
sefaca run --context "[builder:bot:you@local(myapp:main)]" echo "Hello SEFACA"

# Test make command
echo -e "\n${BLUE}$ sefaca run --context \"[builder:bot:you@local(myapp:main)]\" make test${NC}"
sefaca run --context "[builder:bot:you@local(myapp:main)]" make test || echo "(make test is placeholder)"

# Show logs
echo -e "\n${BLUE}$ sefaca logs --tail 5${NC}"
sefaca logs --tail 5

echo ""
echo -e "${YELLOW}4. Demonstrating execution modes:${NC}"

# Test different modes
echo -e "\n${BLUE}$ sefaca run --mode minimal ls /tmp | head -3${NC}"
sefaca run --mode minimal ls /tmp | head -3

echo -e "\n${BLUE}$ sefaca run --mode controlled echo \"Resource limited\"${NC}"
sefaca run --mode controlled echo "Resource limited"

echo -e "\n${BLUE}$ sefaca run --mode forensic echo \"Full monitoring\"${NC}"
sefaca run --mode forensic echo "Full monitoring"

# Show final log entries
echo -e "\n${YELLOW}5. Audit trail demonstration:${NC}"
echo -e "${BLUE}$ tail -f ~/.sefaca/audit.log${NC}"
echo "(showing last 10 entries)"
echo "---"
tail -10 ~/.sefaca/audit.log | while IFS= read -r line; do
    # Highlight different parts
    if [[ "$line" =~ EXEC ]]; then
        echo -e "${GREEN}$line${NC}"
    elif [[ "$line" =~ DONE ]]; then
        echo -e "${BLUE}$line${NC}"
    elif [[ "$line" =~ INFO ]]; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo "$line"
    fi
done

echo ""
echo -e "${GREEN}✅ Simulation complete!${NC}"
echo ""
echo "This demonstrates:"
echo "- ✓ Non-invasive installation (no permanent changes)"
echo "- ✓ Context tracking for every command"
echo "- ✓ Multiple execution modes"
echo "- ✓ Complete audit trail"
echo ""
echo "To use in another shell: source <(cat /tmp/sefaca.dev/install.sh)"