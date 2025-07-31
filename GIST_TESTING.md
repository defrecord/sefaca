# SEFACA Gist Testing Instructions

## Quick Test Process

1. **Copy deploy-gist.sh content to your Gist**
   - Go to: https://gist.github.com/aygp-dr/dc1ecee9eafcee7e3b5120306f76371f
   - Replace content with `deploy-gist.sh`
   - Save the gist

2. **Open a fresh terminal** (no SEFACA loaded)

3. **Run the deployment test**:
   ```bash
   curl -sSL https://gist.github.com/aygp-dr/dc1ecee9eafcee7e3b5120306f76371f/raw | bash
   ```

4. **Test SEFACA commands**:
   ```bash
   # Basic test
   sefaca run echo "Hello from SEFACA"
   
   # With custom context
   sefaca run --context "[tester:human:aygp@gist(sefaca:test)]" ls
   
   # Check logs
   sefaca logs
   
   # Check status
   sefaca status
   ```

## What This Tests

- ✅ Zero installation footprint (everything in /tmp)
- ✅ Functions load properly in current shell
- ✅ Context tracking works
- ✅ Audit logging functions
- ✅ No permanent changes to system

## Cleanup

Everything is contained in a temp directory. To clean up:
```bash
# The script will show the temp directory path
rm -rf /tmp/sefaca-TIMESTAMP
```

Or just close the terminal - next reboot cleans /tmp automatically.

## Expected Output

```
🐕 SEFACA Temporary Deployment Test
===================================

📍 Working directory: /tmp/sefaca-1234567890

📥 Downloading SEFACA...
🚀 Loading SEFACA...
🐕 SEFACA v0.1.0-minimal loaded (temporary session)
📍 Context: [builder:ai:username@local(no-repo:no-branch)]

✅ SEFACA is ready! Try these commands:

  sefaca run echo 'Hello from temp SEFACA!'
  sefaca run --context '[test:human:user@temp(demo:main)]' ls
  sefaca logs
  sefaca status

📂 Everything is in: /tmp/sefaca-1234567890
🗑️  To cleanup: rm -rf /tmp/sefaca-1234567890

Demo:
SEFACA is working!
```

## Notes

- This is a minimal implementation for testing
- No resource limits applied (to avoid fork issues)
- Logs are stored in ~/.sefaca (can be changed with SEFACA_LOG_DIR)
- Everything runs from memory/temp storage