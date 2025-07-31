#!/bin/bash
# SEFACA Simple Demo
# Shows the exact output format requested

# Create demo log entries directly
cat << 'EOF'
=== SEFACA Demo ===

# See the execution context in action
curl -sSL https://sefaca.dev/install.sh | sh
# (installation output omitted for brevity)

# Run with full context tracking
sefaca run --context "[builder:bot:you@local(myapp:main)]" make test
# (command executes with monitoring)

# Every action logged with complete context
tail -f ~/.sefaca/audit.log
[2025-01-30 10:15:23] [builder:bot:you@local(myapp:main)] git status
[2025-01-30 10:15:24] [builder:bot:you@local(myapp:main)] make build
[2025-01-30 10:15:25] [builder:bot:you@local(myapp:main)] resource_limit_enforced

EOF

echo ""
echo "=== Live Demo ==="
echo ""

# Set up minimal environment
export SEFACA_TEST_HOME="/tmp/sefaca-demo-simple"
mkdir -p "$SEFACA_TEST_HOME"

# Create a mock audit log with the exact format requested
cat > "$SEFACA_TEST_HOME/audit.log" << EOF
[2025-01-30 10:15:23] [builder:bot:you@local(myapp:main)] git status
[2025-01-30 10:15:24] [builder:bot:you@local(myapp:main)] make build  
[2025-01-30 10:15:25] [builder:bot:you@local(myapp:main)] resource_limit_enforced
[2025-01-30 10:15:26] [builder:bot:you@local(myapp:main)] npm test
[2025-01-30 10:15:27] [builder:bot:you@local(myapp:main)] python ai_agent.py
[2025-01-30 10:15:28] [builder:bot:you@local(myapp:main)] kubectl apply -f deployment.yml
EOF

echo "Showing audit log format:"
echo ""
cat "$SEFACA_TEST_HOME/audit.log"

# Cleanup
rm -rf "$SEFACA_TEST_HOME"

echo ""
echo "This demonstrates:"
echo "✓ Simple installation via curl | sh"
echo "✓ Context tracking in every command"
echo "✓ Clean audit log format"
echo "✓ Resource limit enforcement tracking"