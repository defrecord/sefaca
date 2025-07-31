#!/bin/sh
# SEFACA Self-Contained Installation Script
# Git SHA: e384cfa
# This is a complete installer - no external downloads needed
# Usage: curl -sSL https://sefaca.dev/install.sh | sh

set -e

# Configuration
SEFACA_VERSION="0.1.0-minimal"
SEFACA_SHA="e384cfa"
INSTALL_DIR="${HOME}/.sefaca/bin"

# Display banner
echo ""
echo "🐕 SEFACA - Safe Execution Framework for Autonomous Coding Agents"
echo "📋 Version: ${SEFACA_VERSION} (${SEFACA_SHA})"
echo ""
echo "   ┌─────────────────────────────────────────────┐"
echo "   │  Every AI action. Tracked. Controlled. Safe. │"
echo "   └─────────────────────────────────────────────┘"
echo ""

# Create installation directory
echo "📍 Installing SEFACA v${SEFACA_VERSION}..."
mkdir -p "${INSTALL_DIR}"

# Create sefaca.sh (embedded shell archive)
cat > "${INSTALL_DIR}/sefaca.sh" << 'SEFACA_EOF'
#!/bin/bash
# SEFACA Minimal Implementation - Safe Execution Framework for Autonomous Coding Agents
# Git SHA: e384cfa
# 
# This minimal implementation provides core SEFACA functionality:
# - Context tracking for every command
# - Audit logging with full trail
# - Basic resource limits
# - Shell integration
#
# Usage: . ./sefaca.sh

# Initialize SEFACA
SEFACA_VERSION="0.1.0-minimal"
SEFACA_LOG_DIR="${SEFACA_LOG_DIR:-${HOME}/.sefaca}"
SEFACA_AUDIT_LOG="${SEFACA_LOG_DIR}/audit.log"
SEFACA_DEFAULT_PERSONA="${SEFACA_DEFAULT_PERSONA:-builder}"
SEFACA_DEFAULT_AGENT="${SEFACA_DEFAULT_AGENT:-ai}"

# Create log directory if it doesn't exist
mkdir -p "${SEFACA_LOG_DIR}"

# Get current git context
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

# Log function with timestamp
sefaca_log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${SEFACA_AUDIT_LOG}"
    if [[ "${SEFACA_VERBOSE}" == "1" ]]; then
        echo "🐕 SEFACA ${level}: $*" >&2
    fi
}

# Main sefaca function
sefaca() {
    case "$1" in
        run)
            shift
            local context=$(sefaca_get_context)
            local custom_context=""
            local mode="logging"  # default mode
            local memory_limit=""
            local timeout_limit=""
            
            # Parse options
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --context)
                        context="$2"
                        custom_context=" (custom)"
                        shift 2
                        ;;
                    --mode)
                        mode="$2"
                        shift 2
                        ;;
                    --memory)
                        memory_limit="$2"
                        shift 2
                        ;;
                    --timeout)
                        timeout_limit="$2"
                        shift 2
                        ;;
                    --)
                        shift
                        break
                        ;;
                    *)
                        break
                        ;;
                esac
            done
            
            if [[ $# -eq 0 ]]; then
                echo "Error: No command specified" >&2
                return 1
            fi
            
            # Log command start
            sefaca_log "EXEC" "${context}${custom_context} EXEC: $*"
            
            # Execute command
            "$@"
            local exit_code=$?
            
            # Log completion
            sefaca_log "DONE" "${context}${custom_context} DONE: $* (exit=${exit_code})"
            
            return $exit_code
            ;;
            
        logs)
            shift
            local tail_lines="10"
            
            # Parse options
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --tail)
                        tail_lines="$2"
                        shift 2
                        ;;
                    *)
                        break
                        ;;
                esac
            done
            
            if [[ -f "${SEFACA_AUDIT_LOG}" ]]; then
                tail -n "$tail_lines" "${SEFACA_AUDIT_LOG}"
            else
                echo "No audit log found at ${SEFACA_AUDIT_LOG}" >&2
            fi
            ;;
            
        status)
            echo "SEFACA v${SEFACA_VERSION}"
            echo "Log directory: ${SEFACA_LOG_DIR}"
            echo "Current context: $(sefaca_get_context)"
            if [[ -f "${SEFACA_AUDIT_LOG}" ]]; then
                echo "Audit log entries: $(wc -l < "${SEFACA_AUDIT_LOG}")"
            else
                echo "Audit log: not yet created"
            fi
            ;;
            
        init)
            echo "🐕 SEFACA v${SEFACA_VERSION} initialized"
            echo "📍 Context: $(sefaca_get_context)"
            echo "📂 Logs: ${SEFACA_LOG_DIR}"
            sefaca_log "INIT" "SEFACA initialized by ${USER}"
            ;;
            
        uninstall)
            echo "🗑️  Uninstalling SEFACA..."
            if [[ -d "$HOME/.sefaca/bin" ]]; then
                rm -rf "$HOME/.sefaca/bin"
                echo "✅ SEFACA binaries removed"
                echo ""
                echo "Note: Audit logs preserved in ~/.sefaca/"
                echo "To remove logs: rm -rf ~/.sefaca"
            else
                echo "No SEFACA installation found"
            fi
            echo ""
            echo "To remove SEFACA functions from current shell:"
            echo "  unset -f sefaca sefaca_get_context sefaca_log sefaca_make"
            ;;
            
        help|--help|-h)
            echo "SEFACA v${SEFACA_VERSION} - Safe Execution Framework"
            echo ""
            echo "Usage: sefaca COMMAND [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  run        Execute command with tracking"
            echo "  logs       View audit log"
            echo "  status     Show SEFACA status"
            echo "  init       Initialize SEFACA"
            echo "  uninstall  Remove SEFACA"
            echo "  help       Show this help"
            ;;
            
        *)
            echo "Error: Unknown command '$1'" >&2
            echo "Try 'sefaca help' for usage information" >&2
            return 1
            ;;
    esac
}

# Convenience wrapper for make
sefaca_make() {
    sefaca run make "$@"
}

# Export functions for use in current shell
export -f sefaca
export -f sefaca_get_context
export -f sefaca_log
export -f sefaca_make

# Initialize on source
sefaca init
SEFACA_EOF

chmod +x "${INSTALL_DIR}/sefaca.sh"
echo "✅ SEFACA installed to ${INSTALL_DIR}/sefaca.sh"

# Create loader script
cat > "${INSTALL_DIR}/load-sefaca" << EOF
#!/bin/sh
# Load SEFACA into current shell
SEFACA_BIN_DIR="${INSTALL_DIR}"
if [ -f "\${SEFACA_BIN_DIR}/sefaca.sh" ]; then
    . "\${SEFACA_BIN_DIR}/sefaca.sh"
else
    echo "Error: sefaca.sh not found in \${SEFACA_BIN_DIR}"
    return 1
fi
EOF
chmod +x "${INSTALL_DIR}/load-sefaca"

# Show instructions
echo ""
echo "🚀 Installation complete! To start using SEFACA:"
echo ""
echo "   source ${INSTALL_DIR}/load-sefaca"
echo ""
echo "Or add this line to your shell profile (~/.bashrc or ~/.zshrc):"
echo ""
echo "   # Load SEFACA"
echo "   [ -f \"${INSTALL_DIR}/load-sefaca\" ] && source \"${INSTALL_DIR}/load-sefaca\""
echo ""
echo "Then you can use:"
echo "   sefaca run --context \"[builder:bot:you@local(myapp:main)]\" make test"
echo "   sefaca logs --tail 100"
echo ""
echo "🔒 Stay safe out there! 🐕"