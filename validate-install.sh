#!/bin/bash
# SEFACA Installation Validation Script
# One-liner tests for both localhost and gist deployment

echo "🧪 SEFACA Installation Validation"
echo "================================"
echo ""

echo "Option 1: Test from localhost:9042"
echo "First run: make serve-local"
echo "Then run this one-liner:"
echo ""
echo 'curl -sSL http://localhost:9042/install.sh | sh && source ~/.sefaca/bin/load-sefaca && sefaca run --context "[builder:bot:you@local(myapp:main)]" "uname -a && hostname && date" && tail -10 ~/.sefaca/audit.log'
echo ""
echo "---"
echo ""

echo "Option 2: Production-style test (simulating sefaca.dev)"
echo "One-liner for testing the exact production flow:"
echo ""
echo '# Step 1: Install'
echo 'curl -sSL http://localhost:9042/install.sh | sh'
echo ""
echo '# Step 2: Load in current shell'
echo 'source ~/.sefaca/bin/load-sefaca'
echo ""
echo '# Step 3: Test'
echo 'sefaca run --context "[builder:bot:you@local(myapp:main)]" "uname -a && hostname && date"'
echo ""
echo '# Complete one-liner (note: requires source in same shell):'
echo 'curl -sSL http://localhost:9042/install.sh | sh && source ~/.sefaca/bin/load-sefaca && sefaca run --context "[builder:bot:you@local(myapp:main)]" hostname'
echo ""
echo "---"
echo ""

echo "Expected output format:"
echo "[2025-01-30 10:15:23] [builder:bot:you@local(myapp:main)] uname -a && hostname && date"
echo "[2025-01-30 10:15:23] [builder:bot:you@local(myapp:main)] (exit=0)"
echo ""

echo "To monitor logs in real-time after installation:"
echo "tail -f ~/.sefaca/audit.log"