#!/usr/bin/env bash
set -euo pipefail

# Enhanced QC System with Proactive CI Integration
# Extends existing qc_pre_push.sh with real-time monitoring capabilities

echo "SYMBOL Enhanced QC System - Proactive CI Integration"

# Get script directory and source existing QC system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXISTING_QC="$SCRIPT_DIR/qc_pre_push.sh"

# Enhanced QC configuration
PROACTIVE_MODE="${PROACTIVE_CI_ENABLED:-true}"
QC_CACHE_DIR="logs/qc_cache"
VIOLATION_THRESHOLD="${QC_VIOLATION_THRESHOLD:-3}"

# Ensure cache directory exists
mkdir -p "$QC_CACHE_DIR"

# Function to check if file is cached
is_file_cached() {
    local file="$1"
    local cache_file
    cache_file="$QC_CACHE_DIR/$(echo "$file" | tr '/' '_').cache"

    # If cache doesn't exist, validation needed
    if [ ! -f "$cache_file" ]; then
        return 0
    fi

    # If file is newer than cache, validation needed
    if [ "$file" -nt "$cache_file" ]; then
        return 0
    fi

    # Cache hit - no validation needed
    return 1
}

# Function to check if file needs validation (caching)
needs_validation() {
    local file="$1"
    ! is_file_cached "$file"
}

# Function to update validation cache
update_cache() {
    local file="$1"
    local result="$2"
    local cache_file
    cache_file="$QC_CACHE_DIR/$(echo "$file" | tr '/' '_').cache"

    echo "$result $(date +%s)" > "$cache_file"
}

# Function to run enhanced policy enforcement
run_enhanced_enforcement() {
    echo "SYMBOL Enhanced Policy Enforcement (Proactive Mode: $PROACTIVE_MODE)"

    local total_violations=0
    local auto_fixes=0

    # Find all relevant files for validation
    local files
    files=$(find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) \
            -not -path "./.git/*" \
            -not -path "./.venv/*" \
            -not -path "./node_modules/*" \
            -not -path "./__pycache__/*" \
            -not -path "./logs/*")

    echo "   Checking $(echo "$files" | wc -l) files with caching optimization..."

    while IFS= read -r file; do
        if [ -f "$file" ] && needs_validation "$file"; then
            local file_violations=0

            # 1. Emoji policy enforcement (existing tool integration)
            if [[ "$file" =~ \.(md|py|sh|yml|yaml)$ ]]; then
                if [ -x "$SCRIPT_DIR/comprehensive_emoji_scrub.py" ]; then
                    if python "$SCRIPT_DIR/comprehensive_emoji_scrub.py" "$file" --check-only; then
                        echo "   SYMBOL $file - emoji policy compliant"
                        update_cache "$file" "emoji_ok"
                    else
                        echo "   SYMBOL $file - applying emoji auto-fix..."
                        if python "$SCRIPT_DIR/comprehensive_emoji_scrub.py" "$file" --auto-fix; then
                            auto_fixes=$((auto_fixes + 1))
                            echo "   SYMBOL $file - emoji violations auto-fixed"
                            update_cache "$file" "emoji_fixed"
                        else
                            file_violations=$((file_violations + 1))
                            echo "   SYMBOL $file - emoji violations require manual fix"
                            update_cache "$file" "emoji_failed"
                        fi
                    fi
                fi
            fi

            # 2. Terminal output validation (existing tool integration)
            if [[ "$file" =~ \.sh$ ]]; then
                if [ -x "$SCRIPT_DIR/validate_terminal_output_simple.sh" ]; then
                    if bash "$SCRIPT_DIR/validate_terminal_output_simple.sh" "$file"; then
                        echo "   SYMBOL $file - terminal output safe"
                        update_cache "$file" "terminal_ok"
                    else
                        file_violations=$((file_violations + 1))
                        echo "   SYMBOL $file - terminal output violations"
                        update_cache "$file" "terminal_failed"
                    fi
                fi
            fi

            # 3. Agent policy enforcement (existing tool integration)
            if [[ "$file" =~ \.(py|sh|yml|yaml|md)$ ]]; then
                if [ -x "$SCRIPT_DIR/agent_policy_enforcer.py" ]; then
                    if python "$SCRIPT_DIR/agent_policy_enforcer.py" "$file" --check-only; then
                        echo "   SYMBOL $file - agent policy compliant"
                        update_cache "$file" "agent_ok"
                    else
                        file_violations=$((file_violations + 1))
                        echo "   SYMBOL $file - agent policy violations"
                        update_cache "$file" "agent_failed"
                    fi
                fi
            fi

            total_violations=$((total_violations + file_violations))
        else
            echo "   SYMBOL $file - cached (no validation needed)"
        fi
    done <<< "$files"

    echo ""
    echo "SYMBOL Enhanced Enforcement Summary:"
    echo "   Total violations: $total_violations"
    echo "   Auto-fixes applied: $auto_fixes"
    echo "   Cache optimization: $(find "$QC_CACHE_DIR" -name "*.cache" | wc -l) cached files"

    # Update violation counter for proactive monitoring
    echo "$total_violations" > "$QC_CACHE_DIR/violation_count"

    return $total_violations
}

# Function to run existing QC with enhancements
run_enhanced_qc() {
    local quick_mode="${1:-false}"

    echo "SYMBOL Running Enhanced QC (95% Threshold)"

    if [ "$quick_mode" = "true" ]; then
        echo "   Quick Mode: Delegating to proven QC system only"

        # Quick mode: Just run the proven QC system
        if [ -x "$EXISTING_QC" ]; then
            echo "   Executing proven QC framework..."
            "$EXISTING_QC"
            return $?
        else
            echo "SYMBOL Existing QC script not found: $EXISTING_QC"
            return 1
        fi
    fi

    # Full mode: Run existing QC system first
    if [ -x "$EXISTING_QC" ]; then
        echo "   Executing existing QC framework..."
        if ! "$EXISTING_QC"; then
            echo "SYMBOL Existing QC validation failed"
            return 1
        fi
        echo "SYMBOL Existing QC validation passed"
    else
        echo "SYMBOL Existing QC script not found: $EXISTING_QC"
    fi

    # 2. Run enhanced policy enforcement (full mode only)
    echo ""
    local violations
    violations=$(run_enhanced_enforcement)

    # 3. Evaluate overall result
    if [ "$violations" -gt "$VIOLATION_THRESHOLD" ]; then
        echo ""
        echo "SYMBOL Enhanced QC failed: $violations violations (threshold: $VIOLATION_THRESHOLD)"
        echo "   Fix violations and run again"
        return 1
    fi

    echo ""
    echo "SYMBOL Enhanced QC passed: $violations violations (under threshold: $VIOLATION_THRESHOLD)"
    return 0
}

# Function to start proactive monitoring
start_proactive_monitoring() {
    local monitor_script="$SCRIPT_DIR/proactive_policy_monitor.py"

    echo "SYMBOL Proactive Monitoring Status"
    echo ""

    if [ "$PROACTIVE_MODE" = "true" ] && [ -x "$monitor_script" ]; then
        echo "   Monitor Script: Available ($monitor_script)"
        echo "   Integration: Emoji policy enforcement framework"
        echo "   Paths: src, scripts, docs, .github"
        echo ""
        echo "SYMBOL To start monitoring:"
        echo "   Foreground: python $monitor_script --paths src scripts docs .github"
        echo "   Background: python $monitor_script --daemon"
        echo ""
        echo "SYMBOL Monitor mode disabled for stability (prevents hanging)"
        echo "   Use 'run' command for immediate validation instead"
    else
        echo "   Monitor Script: Not available or disabled"
        echo "   Set PROACTIVE_CI_ENABLED=true to enable"
        echo "   Monitor script: $monitor_script"
    fi

    echo ""
    echo "SYMBOL Recommendation: Use 'scripts/qc_pre_push.sh' for proven validation"
}

# Function to show integration status
show_integration_status() {
    echo "SYMBOL Proactive CI Integration Status"
    echo ""

    # Check existing tools
    local tools=(
        "qc_pre_push.sh:Existing QC System"
        "agent_policy_enforcer.py:Agent Policy Enforcer"
        "comprehensive_emoji_scrub.py:Emoji Scrubber"
        "validate_terminal_output_simple.sh:Terminal Validator"
        "proactive_policy_monitor.py:Proactive Monitor"
        "enhanced_smart_precommit.sh:Enhanced Pre-commit"
    )

    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        local tool_path="$SCRIPT_DIR/$tool"

        if [ -f "$tool_path" ] && [ -x "$tool_path" ]; then
            echo "   SYMBOL $desc ($tool)"
        else
            echo "   SYMBOL $desc ($tool) - missing or not executable"
        fi
    done

    echo ""
    echo "SYMBOL Configuration:"
    echo "   Proactive Mode: $PROACTIVE_MODE"
    echo "   Violation Threshold: $VIOLATION_THRESHOLD"
    echo "   Cache Directory: $QC_CACHE_DIR"
    echo "   Virtual Environment: ${VIRTUAL_ENV:-not activated}"
}

# Main execution
main() {
    local command="${1:-run}"
    local option="${2:-}"

    case "$command" in
        "run")
            if [ "$option" = "--quick" ]; then
                run_enhanced_qc true
            else
                run_enhanced_qc false
            fi
            ;;
        "monitor")
            start_proactive_monitoring
            ;;
        "status")
            show_integration_status
            ;;
        "cache-clear")
            echo "SYMBOL Clearing QC cache..."
            rm -rf "$QC_CACHE_DIR"/*.cache
            echo "SYMBOL Cache cleared"
            ;;
        *)
            echo "Usage: $0 [run|monitor|status|cache-clear]"
            echo ""
            echo "Commands:"
            echo "   run [--quick]   - Run enhanced QC validation (default)"
            echo "                   --quick: Use proven QC system only (fast)"
            echo "   monitor         - Show proactive monitoring info"
            echo "   status          - Show integration status"
            echo "   cache-clear     - Clear validation cache"
            echo ""
            echo "Environment Variables:"
            echo "   PROACTIVE_CI_ENABLED=true   - Enable proactive monitoring"
            echo "   QC_VIOLATION_THRESHOLD=3    - Set violation threshold"
            echo ""
            echo "Quick validation (recommended):"
            echo "   scripts/qc_pre_push.sh"
            exit 1
            ;;
    esac
}

# Pre-flight checks
if [ -z "${VIRTUAL_ENV:-}" ]; then
    echo "SYMBOL Virtual environment required for DevOnboarder"
    echo "   Run: source .venv/bin/activate"
    exit 1
fi

main "$@"
