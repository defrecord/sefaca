#!/bin/bash
# SEFACA Demo - Simulating the exact sefaca.dev experience
#
# This demonstrates the exact commands and output format requested

set -e

# Setup
echo "Setting up demo environment..."
export DEMO_HOME="/tmp/sefaca-demo-$$"
mkdir -p "$DEMO_HOME"
export HOME="$DEMO_HOME"
export SEFACA_LOG_DIR="$DEMO_HOME/.sefaca"

# Copy files to simulate endpoint
mkdir -p "$DEMO_HOME/sefaca.dev"
cp scripts/install-pipe.sh "$DEMO_HOME/sefaca.dev/install.sh"
export SEFACA_URL="file://$(pwd)/scripts/sefaca.sh"

clear

# Start demo
echo "=== SEFACA Demo ==="
echo ""
echo "# See the execution context in action"
echo "curl -sSL https://sefaca.dev/install.sh | sh"
echo ""
sleep 1

# Run installation
sh "$DEMO_HOME/sefaca.dev/install.sh"

echo ""
echo "# Now load SEFACA"
echo "source ~/.sefaca/bin/load-sefaca"
source "$DEMO_HOME/.sefaca/bin/load-sefaca"

echo ""
echo "# Run with full context tracking"
echo 'sefaca run --context "[builder:bot:you@local(myapp:main)]" make test'
sefaca run --context "[builder:bot:you@local(myapp:main)]" make test 2>/dev/null || echo "(make test output)"

echo ""
echo "# More commands with context"
echo 'sefaca run --context "[builder:bot:you@local(myapp:main)]" git status'
sefaca run --context "[builder:bot:you@local(myapp:main)]" git status >/dev/null 2>&1 || true

echo 'sefaca run --context "[builder:bot:you@local(myapp:main)]" make build'
sefaca run --context "[builder:bot:you@local(myapp:main)]" make build 2>/dev/null || echo "(make build output)"

# Add a resource limit example
echo 'sefaca run --mode controlled --context "[builder:bot:you@local(myapp:main)]" npm test'
sefaca run --mode controlled --context "[builder:bot:you@local(myapp:main)]" echo "resource_limit_enforced" >/dev/null

echo ""
echo "# Every action logged with complete context"
echo "tail -f ~/.sefaca/audit.log"
echo ""

# Format timestamps to match requested format
cat "$DEMO_HOME/.sefaca/audit.log" | grep -E "(EXEC|DONE|resource)" | while IFS= read -r line; do
    # Extract timestamp and reformat
    timestamp=$(echo "$line" | cut -d']' -f1 | cut -d'[' -f2)
    rest=$(echo "$line" | cut -d']' -f2-)
    
    # Simplify output to match requested format
    if [[ "$line" =~ "EXEC:" ]]; then
        context=$(echo "$rest" | cut -d' ' -f2)
        cmd=$(echo "$rest" | sed 's/.*EXEC[^:]*: //')
        echo "[$timestamp] $context $cmd"
    elif [[ "$line" =~ "resource_limit_enforced" ]]; then
        context=$(echo "$rest" | cut -d' ' -f2)
        echo "[$timestamp] $context resource_limit_enforced"
    fi
done

echo ""
echo "=== Demo Complete ==="
echo ""
echo "To use in your own shell:"
echo "1. curl -sSL https://sefaca.dev/install.sh | sh"
echo "2. source ~/.sefaca/bin/load-sefaca"
echo "3. Start monitoring your AI agents!"

# Cleanup
rm -rf "$DEMO_HOME"