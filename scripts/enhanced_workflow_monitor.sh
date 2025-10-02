#!/bin/bash
# Enhanced workflow monitoring and logging system
# Part of DevOnboarder diagnostic enhancement initiative

set -euo pipefail

# Ensure virtual environment is activated for DevOnboarder compliance
if [ -z "${VIRTUAL_ENV:-}" ]; then
    if [ -d ".venv" ]; then
        echo "Activating virtual environment for DevOnboarder compliance..."
        source .venv/bin/activate
    else
        echo "Warning: Virtual environment not found - some operations may be limited"
    fi
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MONITOR_LOG="$LOG_DIR/workflow_monitor_$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Centralized logging setup
exec > >(tee -a "$MONITOR_LOG") 2>&1

echo "=== Enhanced Workflow Monitoring System ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S UTC')"
echo "Monitor Log: $MONITOR_LOG"
echo

# Source the existing log_workflow_failure.sh script for integration
if [ -f "$SCRIPT_DIR/log_workflow_failure.sh" ]; then
    echo "Integrating with existing log_workflow_failure.sh..."
    source "$SCRIPT_DIR/log_workflow_failure.sh"
else
    echo "Warning: log_workflow_failure.sh not found - creating minimal implementation"
fi

monitor_recent_failures() {
    echo "=== Monitoring Recent Workflow Failures ==="

    # Check if GitHub CLI is available and authenticated
    if ! command -v gh >/dev/null 2>&1; then
        echo "GitHub CLI not available - skipping workflow monitoring"
        return 1
    fi

    if ! gh auth status >/dev/null 2>&1; then
        echo "GitHub CLI not authenticated - attempting authentication..."
        if [ -n "${AAR_TOKEN:-}" ]; then
            printf "%s" "$AAR_TOKEN" | gh auth login --with-token
        elif [ -n "${GITHUB_TOKEN:-}" ]; then
            echo "Warning: Using GITHUB_TOKEN for gh auth login; consider using a more specific token like AAR_TOKEN."
            printf "%s" "$GITHUB_TOKEN" | gh auth login --with-token
        else
            echo "No authentication token available - skipping workflow monitoring"
            return 1
        fi
    fi

    echo "Checking recent workflow runs for failures..."

    # Get recent workflow runs with failures
    local failed_runs
    failed_runs=$(gh run list --status failure --limit 10 --json workflowName,databaseId,conclusion,createdAt || echo "[]")

    if [ "$failed_runs" = "[]" ] || [ -z "$failed_runs" ]; then
        echo "No recent workflow failures found"
        return 0
    fi

    echo "Recent workflow failures detected:"
    printf "%s\n" "$failed_runs" | jq -r '.[] | "- \(.workflowName) (ID: \(.databaseId)) - \(.createdAt)"'

    echo
    echo "=== Analyzing Critical Workflow Patterns ==="

    # Analyze patterns in recent failures
    auto_fix_failures=$(printf "%s" "$failed_runs" | jq -r '.[] | select(.workflowName == "Auto Fix") | .databaseId' | wc -l)

    ci_monitor_failures=$(printf "%s" "$failed_runs" | jq -r '.[] | select(.workflowName == "CI Monitor") | .databaseId' | wc -l)

    ci_failure_analyzer_failures=$(printf "%s" "$failed_runs" | jq -r '.[] | select(.workflowName == "CI Failure Analyzer") | .databaseId' | wc -l)

    echo "Failure Pattern Analysis:"
    echo "- Auto Fix failures: $auto_fix_failures"
    echo "- CI Monitor failures: $ci_monitor_failures"
    echo "- CI Failure Analyzer failures: $ci_failure_analyzer_failures"

    # Generate specific recommendations
    if [ "$auto_fix_failures" -gt 2 ]; then
        echo "⚠️  HIGH: Auto Fix showing recurring failures - review patch generation logic"
    fi

    if [ "$ci_monitor_failures" -gt 2 ]; then
        echo "⚠️  HIGH: CI Monitor failing repeatedly - check artifact availability and authentication"
    fi

    if [ "$ci_failure_analyzer_failures" -gt 2 ]; then
        echo "⚠️  HIGH: CI Failure Analyzer not functioning - verify GitHub CLI authentication"
    fi

    return 0
}

check_workflow_health() {
    echo "=== Workflow Health Assessment ==="

    # Get success rate for key workflows over last 50 runs
    local workflows=("CI" "Auto Fix" "CI Monitor" "CI Failure Analyzer")

    for workflow in "${workflows[@]}"; do
        echo "Analyzing: $workflow"

        local runs
        runs=$(gh run list --workflow="$workflow" --limit 50 --json conclusion || echo "[]")

        if [ "$runs" = "[]" ] || [ -z "$runs" ]; then
            echo "  No recent runs found"
            continue
        fi

        local total_runs
        total_runs=$(printf "%s" "$runs" | jq 'length')

        local successful_runs
        successful_runs=$(printf "%s" "$runs" | jq '[.[] | select(.conclusion == "success")] | length')

        local failed_runs
        failed_runs=$(printf "%s" "$runs" | jq '[.[] | select(.conclusion == "failure")] | length')

        if [ "$total_runs" -gt 0 ]; then
            local success_rate
            success_rate=$(( (successful_runs * 100) / total_runs ))

            echo "  Success Rate: $success_rate% ($successful_runs/$total_runs)"
            echo "  Recent Failures: $failed_runs"

            if [ "$success_rate" -lt 80 ]; then
                echo "  🔴 CRITICAL: Success rate below 80%"
            elif [ "$success_rate" -lt 90 ]; then
                echo "  🟡 WARNING: Success rate below 90%"
            else
                echo "  ✅ HEALTHY: Success rate above 90%"
            fi
        else
            echo "  No conclusive runs found"
        fi
        echo
    done
}

generate_monitoring_summary() {
    echo "=== Monitoring Summary ==="

    local summary_file="$LOG_DIR/workflow_health_summary_$TIMESTAMP.md"

    cat > "$summary_file" << EOF
# Workflow Health Monitoring Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S UTC')
**Monitoring Session**: $TIMESTAMP

## Recent Activity

$(gh run list --limit 10 --json workflowName,conclusion,createdAt,databaseId | jq -r '.[] | "- **\(.workflowName)**: \(.conclusion) (ID: \(.databaseId)) - \(.createdAt)"' || echo "Unable to retrieve workflow data")

## Key Metrics

- **Total Workflows Monitored**: 4 (CI, Auto Fix, CI Monitor, CI Failure Analyzer)
- **Monitoring Window**: Last 50 runs per workflow
- **Health Threshold**: 90% success rate

## Recommendations

Based on recent patterns:

1. **Auto Fix Workflow**: $([ "$auto_fix_failures" -gt 2 ] && echo "⚠️ Requires attention - recurring failures detected" || echo "✅ Operating normally")
2. **CI Monitor Workflow**: $([ "$ci_monitor_failures" -gt 2 ] && echo "⚠️ Requires attention - check artifact handling" || echo "✅ Operating normally")
3. **CI Failure Analyzer**: $([ "$ci_failure_analyzer_failures" -gt 2 ] && echo "⚠️ Requires attention - verify authentication" || echo "✅ Operating normally")

## Next Steps

- Continue monitoring for recurring patterns
- Address any workflows with <90% success rate
- Review authentication and artifact handling for failing workflows

---
*Generated by Enhanced Workflow Monitoring System*
*Part of DevOnboarder CI Health Initiative*
EOF

    echo "Summary report generated: $summary_file"

    # Also create a JSON summary for programmatic use
    local json_summary="$LOG_DIR/workflow_health_data_$TIMESTAMP.json"

    cat > "$json_summary" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "monitoring_session": "$TIMESTAMP",
    "recent_failures": {
        "auto_fix": $auto_fix_failures,
        "ci_monitor": $ci_monitor_failures,
        "ci_failure_analyzer": $ci_failure_analyzer_failures
    },
    "health_status": {
        "overall": "$([ $((auto_fix_failures + ci_monitor_failures + ci_failure_analyzer_failures)) -lt 3 ] && echo "healthy" || echo "attention_required")",
        "critical_workflows": $([ $((auto_fix_failures + ci_monitor_failures + ci_failure_analyzer_failures)) -gt 5 ] && echo "true" || echo "false")
    },
    "log_files": {
        "monitor_log": "$MONITOR_LOG",
        "summary_report": "$summary_file"
    }
}
EOF

    echo "JSON data file generated: $json_summary"
}

# Main execution
main() {
    echo "Starting enhanced workflow monitoring session..."

    # Initialize failure counters for summary generation
    auto_fix_failures=0
    ci_monitor_failures=0
    ci_failure_analyzer_failures=0

    # Run monitoring functions to set actual failure counts
    if monitor_recent_failures; then
        echo "✅ Recent failure monitoring completed"
    else
        echo "⚠️ Recent failure monitoring encountered issues"
    fi

    echo

    if check_workflow_health; then
        echo "✅ Workflow health assessment completed"
    else
        echo "⚠️ Workflow health assessment encountered issues"
    fi

    echo

    generate_monitoring_summary

    echo
    echo "=== Monitoring Session Complete ==="
    echo "All logs and reports saved to: $LOG_DIR"
    echo "Monitor log: $MONITOR_LOG"

    # Return status based on overall health
    if [ $((auto_fix_failures + ci_monitor_failures + ci_failure_analyzer_failures)) -gt 5 ]; then
        echo "🔴 CRITICAL: Multiple workflow systems require immediate attention"
        return 1
    elif [ $((auto_fix_failures + ci_monitor_failures + ci_failure_analyzer_failures)) -gt 2 ]; then
        echo "🟡 WARNING: Some workflow systems may need attention"
        return 0
    else
        echo "✅ HEALTHY: All monitored workflows operating within normal parameters"
        return 0
    fi
}

# Execute if called directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
