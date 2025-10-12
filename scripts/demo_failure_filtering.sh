#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

# Local CI Analysis Demo
# Demonstrates failure filtering concepts without requiring GitHub CLI authentication

echo "🔍 CI Failure Analysis - Local Demo"
echo "===================================="
echo ""

echo "💡 This demo shows how the 'conclusion: FAILURE' filter works"
echo "   In a real environment with GitHub CLI authentication, you would use:"
echo ""

tool "Basic GitHub CLI Commands with Failure Filter:"
echo ""
echo "   # List only failed runs"
echo "   gh run list --status failure --limit 10"
echo ""
echo "   # Get detailed failed run data"
echo "   gh run list --status failure --json conclusion,workflowName,createdAt,url"
echo ""
echo "   # Failed runs for specific workflow"
echo "   gh run list -w 'Enhanced Potato Policy Enforcement' --status failure"
echo ""

report "Example Failed Run Analysis:"
echo ""

# Simulate failed run data (what would come from GitHub CLI)
cat << 'EOF'
{
  "runs": [
    {
      "conclusion": "FAILURE",
      "workflowName": "Enhanced Potato Policy Enforcement",
      "createdAt": "2025-01-28T10:30:00Z",
      "url": "https://github.com/repo/actions/runs/12345",
      "displayTitle": "JSON parsing error in security metrics"
    },
    {
      "conclusion": "FAILURE",
      "workflowName": "CI",
      "createdAt": "2025-01-28T09:15:00Z",
      "url": "https://github.com/repo/actions/runs/12344",
      "displayTitle": "Test coverage below threshold"
    },
    {
      "conclusion": "FAILURE",
      "workflowName": "Enhanced Potato Policy Enforcement",
      "createdAt": "2025-01-28T08:45:00Z",
      "url": "https://github.com/repo/actions/runs/12343",
      "displayTitle": "Variable sanitization issue"
    }
  ]
}
EOF

echo ""
target "Analysis with jq (simulating what our scripts do):"
echo ""

# Demonstrate filtering and analysis
SAMPLE_DATA='[
  {"conclusion":"FAILURE","workflowName":"Enhanced Potato Policy Enforcement","createdAt":"2025-01-28T10:30:00Z"},
  {"conclusion":"SUCCESS","workflowName":"CI","createdAt":"2025-01-28T10:25:00Z"},
  {"conclusion":"FAILURE","workflowName":"CI","createdAt":"2025-01-28T09:15:00Z"},
  {"conclusion":"FAILURE","workflowName":"Enhanced Potato Policy Enforcement","createdAt":"2025-01-28T08:45:00Z"},
  {"conclusion":"SUCCESS","workflowName":"Documentation","createdAt":"2025-01-28T08:30:00Z"}
]'

echo "📈 Total runs: $(echo "$SAMPLE_DATA" | jq length)"
error "Failed runs: $(echo "$SAMPLE_DATA" | jq '[.[] | select(.conclusion == "FAILURE")] | length')"
success "Successful runs: $(echo "$SAMPLE_DATA" | jq '[.[] | select(.conclusion == "SUCCESS")] | length')"

echo ""
tool "Failures grouped by workflow:"
echo "$SAMPLE_DATA" | jq -r '
  [.[] | select(.conclusion == "FAILURE")] |
  group_by(.workflowName) |
  map({workflow: .[0].workflowName, count: length}) |
  .[] |
  "  \(.count)x \(.workflow)"
'

echo ""
echo "🕒 Recent failures timeline:"
echo "$SAMPLE_DATA" | jq -r '
  [.[] | select(.conclusion == "FAILURE")] |
  sort_by(.createdAt) |
  reverse |
  .[] |
  "\(.createdAt[0:19]) \(.workflowName)"
'

echo ""
target "Key Benefits of Failure Filtering:"
echo "   SUCCESS: Focus only on relevant failures"
echo "   SUCCESS: Reduce analysis time and noise"
echo "   SUCCESS: Better pattern recognition"
echo "   SUCCESS: More efficient troubleshooting"
echo ""

echo "🔗 Available Tools in DevOnboarder:"
echo "   📱 python scripts/ci-monitor.py <PR>"
echo "   🔍 bash scripts/analyze_failed_ci_runs.sh"
echo "   REPORT: bash scripts/monitor_ci_health.sh"
echo ""

echo "💡 For authentication setup:"
echo "   gh auth login"
echo "   gh auth status"
echo ""

docs "Complete guide: docs/ci-failure-analysis-guide.md"
