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
        echo " Cannot proceed without required tokens for CI monitoring"
        echo " CI health monitoring requires GitHub API access"
        exit 1
    fi
fi

echo " CI Infrastructure Health Monitor"
echo "=================================="
echo "Post-Repair Monitoring - $(date)"
echo ""

# Monitor recent CI performance
echo "SYNC: CI Performance Analysis:"

# Get recent workflow runs with error handling using proper token
# If AAR_TOKEN is provided by the token loader, prefer it for GH_TOKEN; otherwise
# allow the gh CLI to use its configured authentication. Capture failures so we
# can print diagnostics instead of silently falling through.
get_runs_with_token() {
    local token="$1"
    local out
    set e
    out=$(GH_TOKEN="${token}" gh run list --limit 20 --json conclusion,status,workflowName,createdAt 2>&1)
    local rc=$?
    set -e
    if [ $rc -eq 0 ]; then
        echo "$out"
        return 0
    fi
    # Return non-zero but keep output available via stdout
    echo "__MONITOR_GH_ERROR__:$rc:$out"
    return 1
}

get_failed_runs_with_token() {
    local token="$1"
    local out
    set e
    out=$(GH_TOKEN="${token}" gh run list --limit 10 --json conclusion,status,workflowName,createdAt,url --status failure 2>&1)
    local rc=$?
    set -e
    if [ $rc -eq 0 ]; then
        echo "$out"
        return 0
    fi
    echo "__MONITOR_GH_ERROR__:$rc:$out"
    return 1
}

if [ -n "${AAR_TOKEN:-}" ]; then
    # Early token validity check: verify that AAR_TOKEN is usable before attempting run list queries.
    set e
    auth_check_output=$(GH_TOKEN="${AAR_TOKEN}" gh api user --jq '{login: .login, id: .id}' 2>&1)
    auth_check_rc=$?
    set -e
    if [ $auth_check_rc -ne 0 ]; then
        echo "  AAR_TOKEN appears invalid or expired (gh api user failed)."
        echo "   GH output:";
        while IFS= read -r _line; do
            printf '      %s\n' "$_line"
        done <<<"$auth_check_output"
        echo "   Please rotate AAR_TOKEN or ensure token has 'repo' and 'workflow' permissions."
        # Attempt to discover token scopes (if the token is present but rejected, a simple curl to the API
        # can surface the X-OAuth-Scopes header which lists granted scopes).
        if command -v curl >/dev/null 2>&1; then
            echo "   Attempting to inspect token scopes via GitHub API headers..."
            set e
            scopes_header=$(curl -sI -H "Authorization: token ${AAR_TOKEN}" https://api.github.com/ 2>/dev/null | tr -d '\r' | grep -i '^x-oauth-scopes:' || true)
            set -e
            if [ -n "$scopes_header" ]; then
                echo "   Token scopes: $scopes_header"
            else
                echo "   Could not determine scopes (token likely invalid or missing header)."
            fi
            echo "   Required scopes for AAR_TOKEN: repo, workflow"
        else
            echo "   Note: 'curl' not available to inspect token scopes locally."
        fi
        # Fall back to local gh CLI as before
    fi
    raw_runs=$(get_runs_with_token "${AAR_TOKEN}" || true)
    if echo "$raw_runs" | grep -q '^__MONITOR_GH_ERROR__:'; then
        rc=$(echo "$raw_runs" | sed -n 's/^__MONITOR_GH_ERROR__:\([0-9]*\):.*$/\1/p')
        msg=$(echo "$raw_runs" | sed -n 's/^__MONITOR_GH_ERROR__:[0-9]*:\(.*\)$/\1/p')
        echo "  Failed to list runs using AAR_TOKEN (exit $rc)."
        echo "   GH output:"
        # Use parameter expansion to prefix each line (shellcheck SC2001 fix)
        while IFS= read -r _line; do
            printf '      %s\n' "$_line"
        done <<<"$msg"
        echo "   Running 'gh auth status' to diagnose..."
        set e; gh auth status || true; set -e

        # Try falling back to gh CLI auth if AAR_TOKEN failed (common when token expired/invalid)
        echo "   Attempting fallback to local gh CLI authentication..."
        raw_runs_cli=$( { set e; gh run list --limit 20 --json conclusion,status,workflowName,createdAt 2>&1; } || true )
        if echo "$raw_runs_cli" | grep -q '^gh:' || echo "$raw_runs_cli" | grep -q 'error:'; then
            echo "   Fallback gh run list also failed:"
            while IFS= read -r _line; do
                printf '      %s\n' "$_line"
            done <<<"$raw_runs_cli"
        else
            runs="$raw_runs_cli"
            echo " Retrieved recent CI run data (using local gh CLI auth as fallback)"
        fi
    else
        runs="$raw_runs"
        echo " Retrieved recent CI run data (using AAR_TOKEN)"
    fi

    raw_failed=$(get_failed_runs_with_token "${AAR_TOKEN}" || true)
    if echo "$raw_failed" | grep -q '^__MONITOR_GH_ERROR__:'; then
        echo "  Failed to list failed runs using AAR_TOKEN. Attempting fallback to gh CLI..."
        raw_failed_cli=$( { set e; gh run list --limit 10 --json conclusion,status,workflowName,createdAt,url --status failure 2>&1; } || true )
        if echo "$raw_failed_cli" | grep -q '^gh:' || echo "$raw_failed_cli" | grep -q 'error:'; then
            echo "   Fallback failed-run list also failed. Giving up on failed-run detail for now."
        else
            failed_runs_detailed="$raw_failed_cli"
            echo " Retrieved detailed failed run data (using local gh CLI auth as fallback)"
        fi
    else
        failed_runs_detailed="$raw_failed"
        echo " Retrieved detailed failed run data (using AAR_TOKEN)"
    fi
else
    raw_runs=$( { set e; gh run list --limit 20 --json conclusion,status,workflowName,createdAt 2>&1; } || true )
    if echo "$raw_runs" | grep -q '^gh:' || echo "$raw_runs" | grep -q 'error:'; then
        echo "  gh run list failed when using gh CLI auth."
        echo "   GH output:"
        while IFS= read -r _line; do
            printf '      %s\n' "$_line"
        done <<<"$raw_runs"
        echo "   Diagnosing gh auth status..."
        set e; gh auth status || true; gh api user --jq '{login: .login, id: .id}' || true; set -e
    else
        runs="$raw_runs"
        echo " Retrieved recent CI run data (using gh CLI auth)"
    fi

    raw_failed=$( { set e; gh run list --limit 10 --json conclusion,status,workflowName,createdAt,url --status failure 2>&1; } || true )
    if echo "$raw_failed" | grep -q '^gh:' || echo "$raw_failed" | grep -q 'error:'; then
        echo "  gh run list for failed runs failed. Continuing without failed-run detail."
    else
        failed_runs_detailed="$raw_failed"
        echo " Retrieved detailed failed run data (using gh CLI auth)"
    fi
fi

if [ -n "${runs:-}" ]; then
    # Calculate success metrics
    total_runs=$(echo "$runs" | jq length)
    successful_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "success")] | length')
    failed_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "failure")] | length')

    if [ "$total_runs" -gt 0 ]; then
        success_rate=$((successful_runs * 100 / total_runs))
        echo "GROW: Success Rate: ${success_rate}% ($successful_runs/$total_runs successful, $failed_runs failed)"

        # Assessment based on recalibrated standards
        if [ "$success_rate" -ge 90 ]; then
            echo "🎉 EXCELLENT: CI infrastructure highly reliable"
        elif [ "$success_rate" -ge 75 ]; then
            echo " GOOD: CI infrastructure generally reliable"
        elif [ "$success_rate" -ge 60 ]; then
            echo "  ACCEPTABLE: CI infrastructure needs attention"
        else
            echo " POOR: CI infrastructure requires immediate repair"
        fi

        # Show recent runs
        echo ""
        echo "🕒 Recent Runs:"
        echo "$runs" | jq -r '.[] | "\(.createdAt[0:19]) \(.workflowName): \(.conclusion // .status)"' | head -10

        # Show failed runs detail if available
        if [ -n "${failed_runs_detailed:-}" ]; then
            failed_count=$(echo "$failed_runs_detailed" | jq length)
            if [ "$failed_count" -gt 0 ]; then
                echo ""
                echo "🚨 Recent Failed Runs (detailed):"
                # Print failed runs with safer jq concatenation to avoid quoting issues
                echo "$failed_runs_detailed" | jq -r '.[] | "   "  (.workflowName // "<unknown>")  ": "  (.url // "<no-url>")  " ("  (.createdAt[0:19] // "")  ")"' | head -5
                echo "    Use: bash scripts/analyze_failed_ci_runs.sh for detailed failure analysis"
            fi
        fi

    else
        echo "  No recent runs found"
    fi
else
    echo " Cannot retrieve CI run data - monitoring limited"
fi

# Test infrastructure components
echo ""
echo "  Infrastructure Component Health:"

components=("gh" "jq" "git" "node" "python")
healthy_components=0
total_components=${#components[@]}

for component in "${components[@]}"; do
    if command -v "$component" >/dev/null 2>&1; then
        echo "   $component: Available"
        ((healthy_components))
    else
        echo "   $component: Missing"
    fi
done

infrastructure_health=$((healthy_components * 100 / total_components))
echo ""
echo "BUILD:  Infrastructure Health: ${infrastructure_health}% ($healthy_components/$total_components components healthy)"

# Overall assessment
echo ""
echo " OVERALL HEALTH ASSESSMENT:"
if [ "${success_rate:-0}" -ge 85 ] && [ "$infrastructure_health" -ge 80 ]; then
    echo "🎉 HEALTHY: Infrastructure repair successful"
elif [ "${success_rate:-0}" -ge 70 ] && [ "$infrastructure_health" -ge 60 ]; then
    echo " STABLE: Infrastructure functional with minor issues"
else
    echo "  ATTENTION NEEDED: Infrastructure requires continued repair"
fi

echo ""
echo " Monitor completed - check logs for detailed analysis"
