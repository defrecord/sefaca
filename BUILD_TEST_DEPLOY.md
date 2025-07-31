# SEFACA Build, Test, Deploy Workflow

This minimal workflow enables repeatable deployment of SEFACA.

## Quick Deploy (30 seconds)

```bash
# 1. Update Git SHA in both files
SHA=$(git log -1 --format="%h")
sed -i "s/Git SHA: .*/Git SHA: $SHA/" scripts/sefaca.sh scripts/install-standalone.sh

# 2. Create gist
gh gist create scripts/install-standalone.sh --desc "SEFACA v0.1.0 - Git SHA: $SHA" --public

# 3. Test deployment
curl -sSL https://gist.github.com/YOUR_GIST_ID/raw | sh
source ~/.sefaca/bin/load-sefaca
sefaca status
```

## Components

### 1. Core Script (`scripts/sefaca.sh`)
- Main SEFACA functionality
- Updated with Git SHA for tracking
- Sourced by installer

### 2. Installer (`scripts/install-standalone.sh`)
- Self-contained shell archive
- Embeds entire sefaca.sh
- No external downloads

### 3. Deployment
- GitHub Gist for testing
- Future: sefaca.dev CDN

## Build Process

1. **Update Version/SHA**
   ```bash
   # Get current SHA
   git log -1 --format="%h"
   
   # Update both files
   vim scripts/sefaca.sh       # Update Git SHA comment
   vim scripts/install-standalone.sh  # Update Git SHA and embedded content
   ```

2. **Test Locally**
   ```bash
   # Clean install test
   rm -rf ~/.sefaca/bin
   sh scripts/install-standalone.sh
   source ~/.sefaca/bin/load-sefaca
   sefaca run --context "[test:local:user@host(repo:branch)]" date
   sefaca logs
   ```

## Test Process

1. **Local Testing**
   ```bash
   make test-local  # Run test suite
   bash test-standalone.sh  # Test installation
   ```

2. **Remote Testing**
   ```bash
   # On remote machine (e.g., pi.lan)
   curl -sSL https://gist.github.com/aygp-dr/1cc80b2e8156c599f357786b552e462d/raw | sh
   source ~/.sefaca/bin/load-sefaca
   sefaca status
   ```

## Deploy Process

1. **Create Gist**
   ```bash
   gh gist create scripts/install-standalone.sh \
     --desc "SEFACA Installer v0.1.0-minimal" \
     --public
   ```

2. **Document Deployment**
   - Update DEPLOYMENT_EXPERIMENT.md with:
     - Gist ID
     - Git SHA
     - Test results
     - Any issues encountered

3. **Validate**
   ```bash
   # Test the gist URL works
   curl -sSL https://gist.github.com/GIST_ID/raw | head -20
   ```

## Current Deployments

| Date | Gist ID | Git SHA | Status |
|------|---------|---------|--------|
| 2025-07-31 | 1cc80b2e8156c599f357786b552e462d | e384cfa | Active |

## Rollback Process

```bash
# Use previous gist URL
curl -sSL https://gist.github.com/PREVIOUS_GIST_ID/raw | sh
```

## Best Practices

1. **Always test locally first**
2. **Update Git SHA for tracking**
3. **Document each deployment**
4. **Keep gists public for curl access**
5. **Test from clean environment**

## Troubleshooting

### Common Issues

1. **404 Errors**: Check gist URL format
2. **Caching**: GitHub caches for ~5 minutes
3. **Shell Compatibility**: Test on sh, bash, zsh

### Debug Commands

```bash
# Verbose curl
curl -vsSL https://gist.github.com/GIST_ID/raw

# Check what was installed
cat ~/.sefaca/bin/sefaca.sh | head -20

# Manual source test
. ~/.sefaca/bin/sefaca.sh
type sefaca
```