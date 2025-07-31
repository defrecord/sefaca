#!/bin/bash
set -e

echo "=== Testing SEFACA Standalone Installation ==="
echo ""

# Test in single shell session
source ~/.sefaca/bin/load-sefaca

# Test status
echo "1. Testing status command..."
sefaca status
echo ""

# Test run command
echo "2. Testing run command..."
sefaca run --context "[test:standalone:local@test(sefaca:main)]" sh -c "echo 'Standalone test successful' && date"
echo ""

# Test logs
echo "3. Testing logs command..."
sefaca logs --tail 5
echo ""

echo "=== All tests passed! ==="