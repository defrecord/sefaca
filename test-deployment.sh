#!/bin/bash
# Test deployment script that runs in a single shell session

echo "Testing SEFACA deployment from gist..."
echo ""

# Clean previous installation
rm -rf ~/.sefaca/bin

# Install from gist
curl -sSL https://gist.github.com/aygp-dr/c6e9235adf7812cd7b329172075285d1/raw | sh

# Source and test in same session
source ~/.sefaca/bin/load-sefaca
sefaca run --context "[test:gist:local@test(sefaca:main)]" "echo 'Deployment successful' && date"
sefaca logs --tail 5