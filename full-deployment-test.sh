#!/bin/bash
set -e

echo "=== SEFACA Full Deployment Test ==="
echo ""

# Clean previous installation
echo "1. Cleaning previous installation..."
rm -rf ~/.sefaca/bin
echo "✓ Cleaned"
echo ""

# Test installation
echo "2. Testing installation from gist..."
curl -sSL https://gist.github.com/aygp-dr/c6e9235adf7812cd7b329172075285d1/raw > /tmp/install.sh
if grep -q "404" /tmp/install.sh; then
    echo "✗ Failed: Gist returned 404"
    exit 1
fi

sh /tmp/install.sh
echo ""

# Test sourcing
echo "3. Testing source and function availability..."
source ~/.sefaca/bin/load-sefaca

# Test commands
echo "4. Testing sefaca commands..."
sefaca status
echo ""

sefaca run --context "[test:deployment:auto@local(sefaca:test)]" "echo 'Hello from SEFACA' && date"
echo ""

echo "5. Checking audit log..."
sefaca logs --tail 5
echo ""

echo "=== TEST COMPLETE ==="
echo "✓ All tests passed!"