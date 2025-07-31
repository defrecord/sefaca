#!/bin/bash
# SEFACA Quick Install - For testing via gist
# This installs SEFACA and makes it immediately available
#
# Usage: eval "$(curl -sSL https://gist.../raw)"

# Install SEFACA to ~/.sefaca/bin
install_sefaca() {
    local INSTALL_DIR="${HOME}/.sefaca/bin"
    local SEFACA_VERSION="0.1.0-minimal"
    
    echo "🐕 SEFACA Quick Install" >&2
    echo "" >&2
    
    # Create directory
    mkdir -p "$INSTALL_DIR"
    
    # Download sefaca.sh (embedded for gist)
    cat > "$INSTALL_DIR/sefaca.sh" << 'SEFACA_EOF'
#!/bin/bash
# SEFACA Minimal Implementation

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
            if [[ -f "${SEFACA_AUDIT_LOG}" ]]; then
                tail -10 "${SEFACA_AUDIT_LOG}"
            else
                echo "No audit log found"
            fi
            ;;
        status)
            echo "SEFACA v${SEFACA_VERSION}"
            echo "Log directory: ${SEFACA_LOG_DIR}"
            echo "Current context: $(sefaca_get_context)"
            ;;
        uninstall)
            echo "🗑️  Uninstalling SEFACA..."
            if [[ -d "$HOME/.sefaca/bin" ]]; then
                rm -rf "$HOME/.sefaca/bin"
                echo "✅ SEFACA removed"
            fi
            echo "To remove functions: unset -f sefaca sefaca_get_context sefaca_log sefaca_make"
            ;;
        *)
            echo "Usage: sefaca {run|logs|status|uninstall}"
            ;;
    esac
}

sefaca_make() {
    sefaca run make "$@"
}

export -f sefaca sefaca_get_context sefaca_log sefaca_make

echo "🐕 SEFACA v${SEFACA_VERSION} loaded" >&2
echo "📍 Context: $(sefaca_get_context)" >&2
SEFACA_EOF

    chmod +x "$INSTALL_DIR/sefaca.sh"
    
    echo "✅ SEFACA installed to ~/.sefaca/bin" >&2
    echo "" >&2
    
    # Output the source command for eval
    echo "source $INSTALL_DIR/sefaca.sh"
}

# Run installation and output source command
install_sefaca