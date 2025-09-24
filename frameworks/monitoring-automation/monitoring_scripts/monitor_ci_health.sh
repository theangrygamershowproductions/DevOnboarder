#!/usr/bin/env bash
# CI Health Monitoring - Track infrastructure reliability post-repair

set -euo pipefail

# Load tokens using Token Architecture v2.1 with developer guidance
if [ -f "scripts/enhanced_token_loader.sh" ]; then
    # shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
    source scripts/enhanced_token_loader.sh
elif [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback for development
if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

# Check for required tokens with enhanced guidance
if command -v require_tokens >/dev/null 2>&1; then
    if ! require_tokens "AAR_TOKEN"; then
        echo "ERROR: Cannot proceed without required tokens for CI monitoring"
        echo "TIP: CI health monitoring requires GitHub API access"
        exit 1
    fi
fi

echo "STATS: CI Infrastructure Health Monitor"
echo "=================================="
echo "Post-Repair Monitoring - $(date)"
echo ""

# Monitor recent CI performance
echo "RELOAD: CI Performance Analysis:"

# Get recent workflow runs with error handling using proper token
if runs=$(GH_TOKEN="${AAR_TOKEN:-}" gh run list --limit 20 --json conclusion,status,workflowName,createdAt 2>/dev/null); then
    echo "SUCCESS: Retrieved recent CI run data"

    # Also get failed runs specifically for detailed analysis
    if failed_runs_detailed=$(GH_TOKEN="${AAR_TOKEN:-}" gh run list --limit 10 --json conclusion,status,workflowName,createdAt,url --status failure 2>/dev/null); then
        echo "SUCCESS: Retrieved detailed failed run data"
    fi

    # Calculate success metrics
    total_runs=$(echo "$runs" | jq length)
    successful_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "success")] | length')
    failed_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "failure")] | length')

    if [ "$total_runs" -gt 0 ]; then
        success_rate=$((successful_runs * 100 / total_runs))
        echo "TREND: Success Rate: ${success_rate}% ($successful_runs/$total_runs successful, $failed_runs failed)"

        # Assessment based on recalibrated standards
        if [ "$success_rate" -ge 90 ]; then
            echo "COMPLETE: EXCELLENT: CI infrastructure highly reliable"
        elif [ "$success_rate" -ge 75 ]; then
            echo "SUCCESS: GOOD: CI infrastructure generally reliable"
        elif [ "$success_rate" -ge 60 ]; then
            echo "WARNING:  ACCEPTABLE: CI infrastructure needs attention"
        else
            echo "ERROR: POOR: CI infrastructure requires immediate repair"
        fi

        # Show recent runs
        echo ""
        echo "TIME: Recent Runs:"
        echo "$runs" | jq -r '.[] | "\(.createdAt[0:19]) \(.workflowName): \(.conclusion // .status)"' | head -10

        # Show failed runs detail if available
        if [ -n "${failed_runs_detailed:-}" ]; then
            failed_count=$(echo "$failed_runs_detailed" | jq length)
            if [ "$failed_count" -gt 0 ]; then
                echo ""
                echo "ALERT: Recent Failed Runs (detailed):"
                echo "$failed_runs_detailed" | jq -r '.[] | "  ERROR: \(.workflowName): \(.displayTitle // "No title") (\(.createdAt[0:19]))"' | head -5
                echo "   TIP: Use: bash scripts/analyze_failed_ci_runs.sh for detailed failure analysis"
            fi
        fi

    else
        echo "WARNING:  No recent runs found"
    fi
else
    echo "ERROR: Cannot retrieve CI run data - monitoring limited"
fi

# Test infrastructure components
echo ""
echo "TOOLS:  Infrastructure Component Health:"

components=("gh" "jq" "git" "node" "python")
healthy_components=0
total_components=${#components[@]}

for component in "${components[@]}"; do
    if command -v "$component" >/dev/null 2>&1; then
        echo "  SUCCESS: $component: Available"
        ((healthy_components++))
    else
        echo "  ERROR: $component: Missing"
    fi
done

infrastructure_health=$((healthy_components * 100 / total_components))
echo ""
echo "BUILD:  Infrastructure Health: ${infrastructure_health}% ($healthy_components/$total_components components healthy)"

# Overall assessment
echo ""
echo "INFO: OVERALL HEALTH ASSESSMENT:"
if [ "${success_rate:-0}" -ge 85 ] && [ "$infrastructure_health" -ge 80 ]; then
    echo "COMPLETE: HEALTHY: Infrastructure repair successful"
elif [ "${success_rate:-0}" -ge 70 ] && [ "$infrastructure_health" -ge 60 ]; then
    echo "SUCCESS: STABLE: Infrastructure functional with minor issues"
else
    echo "WARNING:  ATTENTION NEEDED: Infrastructure requires continued repair"
fi

echo ""
echo "NOTE: Monitor completed - check logs for detailed analysis"
