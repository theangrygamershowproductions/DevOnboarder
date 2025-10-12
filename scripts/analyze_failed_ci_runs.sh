#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

# Enhanced CI Failure Analysis Tool
# Uses --status failure filter to focus on relevant failures only

echo "🔍 Analyzing Failed CI Runs (conclusion: FAILURE)"
echo "=================================================="
echo ""

# Check GitHub CLI availability
if ! command -v gh >/dev/null 2>&1; then
    error "GitHub CLI not available"
    echo "   Install with: https://cli.github.com/"
    exit 1
fi

# Get failed workflow runs with detailed information
report "Fetching recent failed workflow runs..."
if failed_runs=$(gh run list --limit 15 --json conclusion,status,workflowName,createdAt,url,displayTitle,event --status failure 2>/dev/null); then
    success "Retrieved failed run data"

    # Count failed runs
    total_failed=$(echo "$failed_runs" | jq length)
    echo "📈 Total failed runs (last 15): $total_failed"
    echo ""

    if [ "$total_failed" -gt 0 ]; then
        echo "🚨 Recent Failed Runs:"
        echo ""

        # Group by workflow name for better analysis
        echo "$failed_runs" | jq -r '
            group_by(.workflowName) |
            map({
                workflow: .[0].workflowName,
                count: length,
                latest: .[0].createdAt,
                runs: map({
                    title: .displayTitle,
                    created: .createdAt,
                    url: .url,
                    event: .event
                })
            }) |
            sort_by(-.count) |
            .[] |
            "### \(.workflow) (\(.count) failures)\n" +
            (.runs | map("- \(.title) (\(.event) - \(.created))\n  \(.url)") | join("\n")) +
            "\n"
        '

        echo ""
        check "Workflow Failure Summary:"
        echo "$failed_runs" | jq -r '
            group_by(.workflowName) |
            map({workflow: .[0].workflowName, count: length}) |
            sort_by(-.count) |
            .[] |
            "  \(.count)x \(.workflow)"
        '

        echo ""
        tool "Quick Analysis Commands:"
        echo ""
        echo "# Download logs from most recent failure:"
        latest_run_id=$(echo "$failed_runs" | jq -r '.[0].url' | grep -o '[0-9]*$' || echo "")
        if [ -n "$latest_run_id" ]; then
            echo "gh run download $latest_run_id"
        fi
        echo ""
        echo "# View specific run:"
        echo "gh run view <run_id>"
        echo ""
        echo "# List runs for specific workflow:"
        echo "gh run list -w 'workflow-name' --status failure"

    else
        echo "🎉 No recent failed runs found!"
        echo "   All workflows are currently passing."
    fi

else
    error "Failed to fetch workflow run data"
    echo "   Check GitHub CLI authentication: gh auth status"
    exit 1
fi

echo ""
echo "=================================================================="
echo "💡 Tip: Use this script to focus only on failed runs and avoid"
echo "   analyzing successful or pending runs that aren't relevant"
echo "   for troubleshooting."
echo "=================================================================="
