# SEFACA Pre-Release Testing Process

## Overview

This document outlines the testing process before deploying SEFACA to the production website at sefaca.dev.

## Testing Stages

### Stage 1: Local Development Testing

1. **Unit Tests**
   ```bash
   # Run isolated tests
   bash tests/test-isolated.sh
   
   # Test installation process
   bash tests/test-install.sh
   ```

2. **Local Server Testing**
   ```bash
   # Terminal 1: Start local server
   make serve-local
   
   # Terminal 2: Test installation
   curl -sSL http://localhost:9042/install.sh | sh
   source ~/.sefaca/bin/load-sefaca
   sefaca run echo "Local test"
   ```

### Stage 2: Gist Deployment Testing

1. **Update Test Gist**
   ```bash
   # Update gist with latest script
   gh gist edit dc1ecee9eafcee7e3b5120306f76371f -f install.sh < deploy-gist.sh
   ```

2. **Test on Remote Systems**
   ```bash
   # SSH to test system (e.g., pi.lan)
   ssh pi.lan
   
   # Run one-liner test
   curl -sSL https://gist.github.com/aygp-dr/dc1ecee9eafcee7e3b5120306f76371f/raw | bash
   
   # Verify functions loaded
   sefaca status
   sefaca run --context "[test:human:user@remote(test:main)]" uname -a
   ```

### Stage 3: Pre-Production Validation

1. **Version Check**
   - Update `SEFACA_VERSION` in `scripts/sefaca.sh`
   - Update version in `scripts/install-pipe.sh`
   - Tag the release: `git tag -a v0.1.0-minimal -m "Pre-release v0.1.0"`

2. **Installation Script Packaging**
   ```bash
   # Package for website deployment
   make package-release
   ```

3. **Validation Checklist**
   - [ ] Installation works via curl|sh
   - [ ] No permanent system changes
   - [ ] Functions load correctly
   - [ ] Context tracking works
   - [ ] Audit logging functions
   - [ ] All execution modes work
   - [ ] Clean uninstall possible

## Deployment Package Structure

```
release/
├── install.sh          # Main installer (from install-pipe.sh)
├── sefaca.sh          # Core script
├── version.txt        # Version info
└── checksums.txt      # SHA256 checksums
```

## Website Team Handoff

### Files to Send

1. **Primary Files**
   - `release/install.sh` → Deploy to `https://sefaca.dev/install.sh`
   - `release/sefaca.sh` → Deploy to `https://sefaca.dev/sefaca.sh`

2. **Documentation**
   - This testing process document
   - Installation verification commands
   - Rollback procedures

### Deployment Instructions for Website Team

```bash
# 1. Upload files to staging
scp release/* staging.sefaca.dev:/var/www/

# 2. Test from staging
curl -sSL https://staging.sefaca.dev/install.sh | sh

# 3. If tests pass, deploy to production
rsync -av staging.sefaca.dev:/var/www/ sefaca.dev:/var/www/
```

### Verification Commands

```bash
# Quick smoke test
curl -sSL https://sefaca.dev/install.sh | sh && \
  source ~/.sefaca/bin/load-sefaca && \
  sefaca run echo "Production test successful"

# Full validation
curl -sSL https://sefaca.dev/install.sh | sh && \
  source ~/.sefaca/bin/load-sefaca && \
  sefaca run --context "[validator:human:ops@prod(sefaca:v0.1.0)]" "uname -a && date" && \
  sefaca logs --tail 5
```

## Rollback Procedure

If issues are discovered:

1. **Immediate Rollback**
   ```bash
   # Restore previous version
   cp /var/www/backup/install.sh.prev /var/www/install.sh
   cp /var/www/backup/sefaca.sh.prev /var/www/sefaca.sh
   ```

2. **Notify Users**
   - Update status page
   - Post to GitHub issues

3. **Debug**
   - Check server logs
   - Review user reports
   - Test locally with exact production URLs

## Testing Matrix

| Platform | Method | Status | Notes |
|----------|--------|--------|-------|
| FreeBSD 14.3 | Local | ✅ | Primary platform |
| FreeBSD 14.3 | Gist | ✅ | Remote testing |
| Ubuntu 22.04 | Local | ✅ | CI/CD testing |
| macOS | Gist | ⚠️ | Limited testing |
| Raspberry Pi | Gist | ✅ | ARM testing |

## Communication Template

### For Website Team

```
Subject: SEFACA v0.1.0-minimal Ready for Deployment

Hi Team,

The minimal SEFACA implementation is ready for deployment to sefaca.dev.

Files attached:
- install.sh (main installer)
- sefaca.sh (core script)
- checksums.txt (integrity verification)

Testing completed:
- Local development ✅
- Gist deployment ✅
- Remote systems ✅

Deployment URLs:
- https://sefaca.dev/install.sh
- https://sefaca.dev/sefaca.sh

Please deploy to staging first and run the verification commands before production.

Verification command:
curl -sSL https://staging.sefaca.dev/install.sh | sh && source ~/.sefaca/bin/load-sefaca && sefaca status

Let me know if you need any clarification.

Thanks!
```

## Post-Deployment Monitoring

1. **First 24 Hours**
   - Monitor GitHub issues
   - Check download metrics
   - Watch for error reports

2. **Success Metrics**
   - Successful installations
   - No critical bugs reported
   - Positive user feedback

3. **Next Steps**
   - Plan v0.2.0 features
   - Address user feedback
   - Expand platform support