# SEFACA Testing Guide

## Overview

This guide describes how to test SEFACA installation and functionality without affecting your system environment.

## Installation Testing

### Quick Test

```bash
# Run the installation test suite
bash tests/test-install.sh
```

### What the Test Does

1. **Environment Isolation**
   - Creates temporary directories in `/tmp/sefaca-test-$$`
   - Sets up a fake HOME directory
   - Preserves your original environment

2. **Environment Auditing**
   - Captures environment state before installation
   - Captures environment state after installation
   - Shows differences without exposing sensitive values

3. **Fixture System**
   - Copies install script to `/tmp/sefaca.dev/install.sh`
   - Simulates the real installation process
   - Uses local files instead of downloading

4. **Verification**
   - Checks if binaries are installed
   - Verifies PATH modifications
   - Confirms shell integration

### Environment Variables Captured

The test captures (without values for security):
- All environment variable names
- PATH entries (sorted and unique)
- Shell functions
- Aliases

### Expected Changes

After installation, you should see:
- New shell functions: `sefaca`, `sefaca_get_context`, `sefaca_log`, `sefaca_make`
- New PATH entry: `~/.local/bin`
- New files: `~/.local/bin/sefaca`, `~/.local/bin/sefaca-init`

## Manual Testing

### Testing the Fixture

```bash
# Create the fixture
mkdir -p /tmp/sefaca.dev
cp scripts/install.sh /tmp/sefaca.dev/install.sh

# Run as if from sefaca.dev
cat /tmp/sefaca.dev/install.sh | sh
```

### Testing SEFACA Functions

After installation:

```bash
# Source the functions
source ~/.local/bin/sefaca-init

# Test basic functionality
sefaca status
sefaca run echo "Hello from SEFACA"
sefaca logs tail
```

### Environment Reset

To reset between tests:

```bash
# Remove SEFACA installation
rm -rf ~/.sefaca
rm -f ~/.local/bin/sefaca*

# Remove from shell RC (manually edit)
# Remove lines between:
# "# Added by SEFACA installer"
# and
# "# SEFACA auto-initialization"
```

## Continuous Integration Testing

For CI environments:

```yaml
# .github/workflows/test.yml
- name: Test Installation
  run: |
    bash tests/test-install.sh
    
- name: Test Functionality
  run: |
    source ~/.local/bin/sefaca-init
    sefaca run echo "CI Test"
    sefaca status
```

## Security Testing

### Environment Variable Safety

The test framework uses `env | cut -d= -f1` to capture only variable names, not values. This ensures:
- No secrets are logged
- No sensitive paths are exposed
- Only structural changes are tracked

### Isolation Testing

```bash
# Verify isolation
TEST_VAR="sensitive" bash tests/test-install.sh
# TEST_VAR should not appear in any logs
```

## Debugging

### Verbose Mode

```bash
# Enable verbose output
SEFACA_VERBOSE=1 bash tests/test-install.sh
```

### Manual Inspection

```bash
# Keep test directory for inspection
bash tests/test-install.sh
# Before it exits, check /tmp/sefaca-test-*/
```

### Common Issues

1. **Permission Denied**
   - Ensure scripts are executable: `chmod +x scripts/*.sh tests/*.sh`

2. **Command Not Found**
   - Check PATH includes `~/.local/bin`
   - Source shell RC file: `source ~/.bashrc`

3. **No Functions Loaded**
   - Use `source` not `sh` for sefaca-init
   - Check shell compatibility (bash/zsh)

## Test Development

### Adding New Tests

1. Create test functions in `tests/test-*.sh`
2. Follow the pattern:
   - Setup phase
   - Execution phase
   - Verification phase
   - Cleanup phase

3. Use provided helpers:
   - `print_success` / `print_error` for results
   - `capture_env_state` for environment auditing
   - `TEST_HOME` for isolated testing

### Test Checklist

- [ ] Installation completes without errors
- [ ] Environment variables are set correctly
- [ ] Shell functions are available
- [ ] Audit logging works
- [ ] Resource limits are applied
- [ ] Context detection works
- [ ] No sensitive data in logs