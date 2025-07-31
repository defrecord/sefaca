#!/bin/bash
# SEFACA Minimal Implementation - Safe Execution Framework for Autonomous Coding Agents
# Deployment ID: sefaca-core-$(date +%Y%m%d-%H%M%S)
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
            local tail_lines="100"
            
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
            
            # Show mode info if not default
            local mode_info=""
            case "$mode" in
                minimal)
                    mode_info=" [MINIMAL: Basic tracking only]"
                    ;;
                logging)
                    mode_info=""  # default, no extra info
                    ;;
                controlled)
                    mode_info=" [CONTROLLED: Resource limits applied]"
                    ;;
                forensic)
                    mode_info=" [FORENSIC: Full audit trail]"
                    ;;
                *)
                    echo "Warning: Unknown mode '$mode', using 'logging'" >&2
                    mode="logging"
                    ;;
            esac
            
            # Log command start with mode
            sefaca_log "EXEC" "${context}${custom_context} EXEC${mode_info}: $*"
            
            # Apply settings based on mode
            (
                # Mode-specific behavior (v0: mostly placeholders)
                case "$mode" in
                    minimal)
                        # Minimal mode: Just execute, basic logging done above
                        ;;
                    controlled)
                        # Controlled mode: Apply resource limits
                        ulimit -m 2097152 2>/dev/null  # 2GB memory
                        ulimit -t 20 2>/dev/null       # 20s CPU
                        ulimit -u 50 2>/dev/null       # 50 processes
                        
                        # Handle custom limits if specified
                        if [[ -n "$memory_limit" ]]; then
                            sefaca_log "INFO" "Memory limit: $memory_limit (v0: placeholder)"
                        fi
                        if [[ -n "$timeout_limit" ]]; then
                            sefaca_log "INFO" "Timeout: $timeout_limit (v0: placeholder)"
                        fi
                        ;;
                    forensic)
                        # Forensic mode: Maximum logging (v0: placeholder)
                        sefaca_log "INFO" "Forensic mode enabled (v0: enhanced logging planned)"
                        ;;
                esac
                
                # Execute command
                "$@"
                local exit_code=$?
                
                # Log completion
                sefaca_log "DONE" "${context}${custom_context} DONE: $* (exit=${exit_code})"
                
                return $exit_code
            )
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
            
            case "${1:-tail}" in
                tail)
                    tail -f "${SEFACA_AUDIT_LOG}"
                    ;;
                all)
                    cat "${SEFACA_AUDIT_LOG}"
                    ;;
                grep)
                    shift
                    grep "$@" "${SEFACA_AUDIT_LOG}"
                    ;;
                *)
                    # Default: show last N lines
                    if [[ -f "${SEFACA_AUDIT_LOG}" ]]; then
                        tail -n "$tail_lines" "${SEFACA_AUDIT_LOG}"
                    else
                        echo "No audit log found at ${SEFACA_AUDIT_LOG}" >&2
                    fi
                    ;;
            esac
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
            echo ""
            
            # Check if we're in a temp deployment
            if [[ "$0" =~ /tmp/sefaca- ]]; then
                local temp_dir=$(dirname "$0")
                echo "Removing temporary installation: $temp_dir"
                rm -rf "$temp_dir"
            elif [[ -d "$HOME/.sefaca/bin" ]]; then
                echo "Removing SEFACA from ~/.sefaca/bin"
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
            cat << EOF
SEFACA v${SEFACA_VERSION} - Safe Execution Framework for Autonomous Coding Agents

USAGE:
  sefaca COMMAND [OPTIONS]

COMMANDS:
  run        Execute command with tracking and limits
  logs       View audit log
  status     Show SEFACA status and configuration
  init       Initialize SEFACA in current shell
  uninstall  Remove SEFACA installation
  help       Show this help message

RUN OPTIONS:
  --mode MODE        Execution mode (default: logging)
                     minimal    - Basic tracking only
                     logging    - Standard audit trail
                     controlled - Apply resource limits
                     forensic   - Maximum monitoring (v0: placeholder)
  
  --context CTX      Custom context string
  --memory SIZE      Memory limit (v0: placeholder, e.g., 4GB)
  --timeout SECS     Timeout in seconds (v0: placeholder, e.g., 600s)

LOGS OPTIONS:
  --tail N           Show last N lines (default: 10)
  
  Subcommands:
  tail               Follow log in real-time
  all                Show entire log
  grep PATTERN       Search log for pattern

EXAMPLES:
  # Basic usage
  sefaca run python script.py
  sefaca run npm install
  sefaca run make build
  
  # With modes
  sefaca run --mode minimal ls
  sefaca run --mode controlled make test
  sefaca run --mode forensic python ai_agent.py
  
  # View logs
  sefaca logs --tail 100
  sefaca logs grep ERROR
  
  # CI/CD usage
  sefaca run --mode controlled npm run build
  sefaca run --mode controlled --timeout 600s ./deploy.sh

ENVIRONMENT:
  SEFACA_LOG_DIR          Log directory (default: ~/.sefaca)
  SEFACA_DEFAULT_PERSONA  Default persona (default: builder)
  SEFACA_DEFAULT_AGENT    Default agent (default: ai)
  SEFACA_VERBOSE          Enable verbose output (0/1)

MODES (v0 Implementation):
  ┌─────────────┬──────────────────────────────────────────┐
  │ Mode        │ Features                                 │
  ├─────────────┼──────────────────────────────────────────┤
  │ minimal     │ ✓ Basic command logging                  │
  │             │ ✗ No resource limits                     │
  │             │ ✗ No enhanced monitoring                 │
  ├─────────────┼──────────────────────────────────────────┤
  │ logging     │ ✓ Full audit trail                       │
  │ (default)   │ ✓ Context tracking                       │
  │             │ ✗ No resource limits                     │
  ├─────────────┼──────────────────────────────────────────┤
  │ controlled  │ ✓ Full audit trail                       │
  │             │ ✓ Basic resource limits (2GB/20s/50proc) │
  │             │ ⚠ Custom limits are placeholders in v0   │
  ├─────────────┼──────────────────────────────────────────┤
  │ forensic    │ ✓ Full audit trail                       │
  │             │ ⚠ Enhanced monitoring planned for v1     │
  │             │ ⚠ Process tree tracking planned          │
  └─────────────┴──────────────────────────────────────────┘

For more: https://github.com/defrecord/sefaca
EOF
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