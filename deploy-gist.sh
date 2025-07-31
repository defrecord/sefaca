#!/bin/bash
# SEFACA Temporary Deployment Script
# Everything runs from /tmp - no permanent changes
#
# To test: 
# 1. Copy this to a GitHub Gist
# 2. In a new shell: curl -sSL https://gist.github.com/YOUR_GIST_ID/raw | bash

set -e

echo "🐕 SEFACA Temporary Deployment Test"
echo "==================================="
echo ""

# Create temp workspace
SEFACA_TEMP="/tmp/sefaca-$(date +%s)"
mkdir -p "$SEFACA_TEMP"
cd "$SEFACA_TEMP"

echo "📍 Working directory: $SEFACA_TEMP"
echo ""

# Download the minimal SEFACA script directly
echo "📥 Downloading SEFACA..."
cat > sefaca.sh << 'SEFACA_SCRIPT'
#!/bin/bash
# SEFACA Minimal Implementation - Embedded for testing

SEFACA_VERSION="0.1.0-minimal"
SEFACA_LOG_DIR="${SEFACA_LOG_DIR:-${HOME}/.sefaca}"
SEFACA_AUDIT_LOG="${SEFACA_LOG_DIR}/audit.log"
SEFACA_DEFAULT_PERSONA="${SEFACA_DEFAULT_PERSONA:-builder}"
SEFACA_DEFAULT_AGENT="${SEFACA_DEFAULT_AGENT:-ai}"

mkdir -p "${SEFACA_LOG_DIR}"

sefaca_get_context() {
    local repo branch
    if git rev-parse --git-dir > /dev/null 2>&1; then
        repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
        branch=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    else
        repo="no-repo"
        branch="no-branch"
    fi
    echo "[${SEFACA_DEFAULT_PERSONA}:${SEFACA_DEFAULT_AGENT}:${USER}@local(${repo}:${branch})]"
}

sefaca_log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${SEFACA_AUDIT_LOG}"
}

sefaca() {
    case "$1" in
        run)
            shift
            local context=$(sefaca_get_context)
            local mode="logging"
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --context) context="$2"; shift 2 ;;
                    --mode) mode="$2"; shift 2 ;;
                    --) shift; break ;;
                    *) break ;;
                esac
            done
            
            sefaca_log "EXEC" "${context} EXEC: $*"
            "$@"
            local exit_code=$?
            sefaca_log "DONE" "${context} DONE: $* (exit=${exit_code})"
            return $exit_code
            ;;
        logs)
            shift
            tail -10 "${SEFACA_AUDIT_LOG}"
            ;;
        status)
            echo "SEFACA v${SEFACA_VERSION} (temp deployment)"
            echo "Log directory: ${SEFACA_LOG_DIR}"
            echo "Current context: $(sefaca_get_context)"
            ;;
        *)
            echo "Usage: sefaca {run|logs|status}"
            ;;
    esac
}

SEFACA_make() {
    sefaca run make "$@"
}

export -f sefaca sefaca_get_context sefaca_log SEFACA_make

echo "🐕 SEFACA v${SEFACA_VERSION} loaded (temporary session)"
echo "📍 Context: $(sefaca_get_context)"
SEFACA_SCRIPT

# Make it executable
chmod +x sefaca.sh

# Source it into current shell
echo "🚀 Loading SEFACA..."
source ./sefaca.sh

echo ""
echo "✅ SEFACA is ready! Try these commands:"
echo ""
echo "  sefaca run echo 'Hello from temp SEFACA!'"
echo "  sefaca run --context '[test:human:user@temp(demo:main)]' ls"
echo "  sefaca logs"
echo "  sefaca status"
echo ""
echo "📂 Everything is in: $SEFACA_TEMP"
echo "🗑️  To cleanup: rm -rf $SEFACA_TEMP"
echo ""

# Run a demo command
echo "Demo:"
sefaca run --context "[builder:bot:demo@temp(test:main)]" echo "SEFACA is working!"

# Export functions so they're available after script ends
export -f sefaca sefaca_get_context sefaca_log SEFACA_make