# Shell Archive Pattern for SEFACA

## What is a Shell Archive?

A shell archive (shar) is a self-extracting script that contains embedded files. When executed, it creates the necessary files and directories on the target system. SEFACA uses this pattern for reliable, single-file distribution.

## How SEFACA Uses This Pattern

### 1. Structure of `install-standalone.sh`

```bash
#!/bin/sh
# Installation script header
# - Sets up variables
# - Creates directories
# - Shows banner

# Embedded file using heredoc
cat > "${INSTALL_DIR}/sefaca.sh" << 'SEFACA_EOF'
#!/bin/bash
# This is the entire sefaca.sh script
# ... hundreds of lines of code ...
SEFACA_EOF

# Post-installation
# - Set permissions
# - Create loader script
# - Show instructions
```

### 2. Key Benefits

- **Single Download**: One `curl` command gets everything
- **No Network Dependencies**: After initial download, no more network calls
- **No 404 Errors**: Can't fail to find secondary files
- **Self-Contained**: Everything needed is in one file
- **Version Locked**: The embedded content matches the installer version

### 3. The Installation Flow

```
User runs curl
    ↓
Downloads install-standalone.sh (350+ lines)
    ↓
Shell executes the script
    ↓
Script creates ~/.sefaca/bin/
    ↓
Script writes sefaca.sh (embedded content)
    ↓
Script creates load-sefaca wrapper
    ↓
Installation complete!
```

### 4. Why Not Download sefaca.sh Separately?

Our failed attempts taught us:
- GitHub raw URLs can 404
- Gist URLs need exact formatting  
- Multiple downloads = multiple failure points
- Caching delays cause version mismatches

### 5. The Heredoc Technique

```bash
cat > "output_file" << 'END_MARKER'
This content is written exactly as-is.
No variable expansion because marker is quoted.
Perfect for embedding shell scripts.
END_MARKER
```

Using `'SEFACA_EOF'` (quoted) prevents the shell from interpreting variables in the embedded script.

## Creating Your Own Shell Archive

1. **Start with your installer template**:
```bash
#!/bin/sh
set -e
echo "Installing..."
mkdir -p "$HOME/.myapp"
```

2. **Embed your application**:
```bash
cat > "$HOME/.myapp/app.sh" << 'APP_EOF'
#!/bin/bash
# Your entire application here
echo "Hello from embedded app!"
APP_EOF
chmod +x "$HOME/.myapp/app.sh"
```

3. **Test the archive**:
```bash
sh your-installer.sh
```

## Real-World Examples

- **Rustup**: Rust's installer uses this pattern
- **nvm**: Node Version Manager installation
- **rbenv-installer**: Ruby version management
- **SEFACA**: Our implementation for AI agent safety

## Best Practices

1. **Use quoted heredocs** to prevent variable expansion
2. **Include version info** in both installer and embedded content
3. **Make scripts executable** with `chmod +x`
4. **Provide clear post-install instructions**
5. **Test on minimal shells** (sh, not just bash)

## The SEFACA Success

From our deployment experiment:
- ❌ Multi-file download approach: Failed with 404s
- ❌ GitHub raw URLs: Caching and availability issues  
- ✅ Shell archive pattern: Worked first time on pi.lan!

This pattern enabled our "curl|sh" installation to work reliably across platforms.