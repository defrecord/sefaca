# SEFACA Quick Test Guide

You have two options for testing the installation:

## Option 1: Local Mock Server (30 seconds)

**Terminal 1:**
```bash
make serve-local
# This starts a server at http://localhost:8080
# Leave it running
```

**Terminal 2 (fresh, no SEFACA):**
```bash
# Test the installation
curl -sSL http://localhost:8080/install.sh | sh

# Follow the instructions to load SEFACA
source ~/.sefaca/bin/load-sefaca

# Test it
sefaca run --context "[builder:bot:you@local(myapp:main)]" echo "Hello"
sefaca logs
```

## Option 2: GitHub Gist

1. Copy the content of `deploy-gist.sh` to your gist:
   https://gist.github.com/aygp-dr/dc1ecee9eafcee7e3b5120306f76371f

2. In a fresh terminal:
```bash
curl -sSL https://gist.github.com/aygp-dr/dc1ecee9eafcee7e3b5120306f76371f/raw | bash
```

## What Gets Installed

Both methods install to `~/.sefaca/bin/` with:
- `sefaca.sh` - The main script
- `load-sefaca` - The loader script

To use in any shell:
```bash
source ~/.sefaca/bin/load-sefaca
```

## Complete Test Flow

```bash
# 1. Install (pick one method above)

# 2. Load SEFACA
source ~/.sefaca/bin/load-sefaca

# 3. Test commands
sefaca run --context "[builder:bot:you@local(myapp:main)]" git status
sefaca run --context "[builder:bot:you@local(myapp:main)]" make build
sefaca run --mode controlled echo "Resource limited"

# 4. Check logs
sefaca logs --tail 10

# Expected output format:
# [2025-01-30 10:15:23] [builder:bot:you@local(myapp:main)] git status
# [2025-01-30 10:15:24] [builder:bot:you@local(myapp:main)] make build
# [2025-01-30 10:15:25] [builder:bot:you@local(myapp:main)] resource_limit_enforced
```

## Cleanup

```bash
# Remove installation
rm -rf ~/.sefaca/bin

# Logs are in ~/.sefaca/audit.log (remove if desired)
```