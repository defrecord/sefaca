# 🧪 Test SEFACA Right Now!

Want to try SEFACA? It takes 30 seconds.

## Quick Test (Any Unix System)

```bash
# Install SEFACA
curl -sSL https://gist.github.com/aygp-dr/1cc80b2e8156c599f357786b552e462d/raw | sh

# The installer will tell you exactly what to do next!
# It will show something like:
#   source /home/yourname/.sefaca/bin/load-sefaca
```

## How This Works

1. **One Command**: The curl command downloads and runs a self-contained installer
2. **No Dependencies**: Everything is included in a single shell script
3. **Follow Instructions**: The installer provides exact commands for YOUR system
4. **Start Tracking**: Begin monitoring AI agent commands immediately

## Test It

After installation, try:
```bash
sefaca run --context "[test:user:me@local(test:main)]" date
sefaca logs
```

## Clean Up

```bash
sefaca uninstall
```

---
*Created: 2025-07-31 @ 07:15 EDT*
*Deployment: Git SHA e384cfa*
*Gist: 1cc80b2e8156c599f357786b552e462d*