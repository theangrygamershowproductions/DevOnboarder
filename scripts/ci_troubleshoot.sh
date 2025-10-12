#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

# DevOnboarder CI Troubleshooting Shortcut
# This script automatically detects the current PR and runs CI diagnostics
# Because every CI issue we encounter is in PR context!

tool "DevOnboarder CI Auto-Troubleshoot"
echo "===================================="

# Auto-detect current PR number
if PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null); then
    success "Auto-detected PR #$PR_NUM"
else
    error "No active PR detected. Please specify PR number:"
    echo "Usage: $0 [PR_NUMBER]"
    exit 1
fi

# Allow manual override
if [ $# -gt 0 ]; then
    PR_NUM="$1"
    target "Using specified PR #$PR_NUM"
fi

echo ""
deploy "Running comprehensive CI analysis for PR #$PR_NUM..."
echo ""

# Run the full DevOnboarder automation suite
report "Step 1: Health Assessment"
bash scripts/assess_pr_health.sh "$PR_NUM" || warning "Health assessment issues"

echo ""
echo "🔍 Step 2: CI Failure Analysis"
bash scripts/analyze_failed_ci_runs.sh || warning "CI analysis issues"

echo ""
bot "Step 3: Automated PR Process"
bash scripts/automate_pr_process.sh "$PR_NUM" analyze

echo ""
target "Quick Actions:"
echo "• Run automated fixes: bash scripts/automate_pr_process.sh $PR_NUM execute"
echo "• Monitor CI health: bash scripts/monitor_ci_health.sh"
echo "• Check specific test failures: bash scripts/run_tests.sh"
echo ""
check "This script exists because CI issues are ALWAYS in PR context!"
echo "No more manual PR number specification needed."
