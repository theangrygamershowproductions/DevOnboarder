#!/usr/bin/env bash
# Review and close resolved issues for DevOnboarder
# This script helps identify and close issues that have been resolved

set -euo pipefail

# Logging setup following DevOnboarder standards
mkdir -p logs
LOG_FILE="logs/review_resolved_issues_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🔍 DevOnboarder Issue Resolution Review"
echo "======================================"
echo "Log: $LOG_FILE"
echo "Timestamp: $(date)"
echo ""

# Check for common resolved issue patterns
echo "📋 Reviewing open issues for resolution patterns..."
echo ""

# 1. Check CI failure issues for merged PRs
echo "🔍 Checking CI failure issues..."
ci_issues=$(gh issue list --label "ci-failure" --state open --json number,title,body)
if [[ "$ci_issues" != "[]" ]]; then
    echo "Found CI failure issues to review:"
    echo "$ci_issues" | jq -r '.[] | "  #\(.number): \(.title)"'
    echo ""
    echo "💡 Review these CI issues manually - they may be resolved if PRs merged"
else
    echo "✅ No open CI failure issues found"
fi
echo ""

# 2. Check artifact pollution issues
echo "🔍 Checking artifact pollution status..."
if bash scripts/enhanced_root_artifact_guard.sh --check | grep -q "Repository root is clean"; then
    # Look for open artifact pollution issues
    artifact_issues=$(gh issue list --label "artifact-pollution" --state open --json number,title)
    if [[ "$artifact_issues" != "[]" ]]; then
        echo "Found artifact pollution issues that may be resolved:"
        echo "$artifact_issues" | jq -r '.[] | "  #\(.number): \(.title)"'
        echo ""
        echo "💡 Consider closing these if artifact guard shows clean status"
    else
        echo "✅ No open artifact pollution issues found"
    fi
else
    echo "⚠️  Artifact pollution still detected - keeping related issues open"
fi
echo ""

# 3. Check for dependency update issues where dependencies are current
echo "🔍 Checking dependency-related issues..."
dep_issues=$(gh issue list --label "dependencies" --state open --json number,title)
if [[ "$dep_issues" != "[]" ]]; then
    echo "Found dependency issues to review:"
    echo "$dep_issues" | jq -r '.[] | "  #\(.number): \(.title)"'
    echo ""
    echo "💡 Review these dependency issues - check if updates completed"
else
    echo "✅ No open dependency issues found"
fi
echo ""

# 4. Look for automation/chore issues that might be complete
echo "🔍 Checking automation and chore issues..."
auto_issues=$(gh issue list --label "automation,chore" --state open --json number,title,updatedAt)
if [[ "$auto_issues" != "[]" ]]; then
    echo "Found automation/chore issues to review:"
    echo "$auto_issues" | jq -r '.[] | "  #\(.number): \(.title) (updated: \(.updatedAt))"'
    echo ""
    echo "💡 Review these automation issues - they may be completed"
else
    echo "✅ No open automation/chore issues found"
fi
echo ""

# 5. Summary and recommendations
echo "📊 Issue Resolution Summary"
echo "=========================="
total_open=$(gh issue list --state open --json number | jq length)
echo "Total open issues: $total_open"
echo ""

echo "🔧 Recommended Actions:"
echo "1. Review CI failure issues for merged PRs"
echo "2. Close artifact pollution issues if repository is clean"
echo "3. Check dependency issues against current package versions"
echo "4. Review automation issues for completion status"
echo "5. Use 'gh issue close <number> --comment \"<reason>\"' to close resolved issues"
echo ""

echo "💡 For automated closure patterns, consider implementing:"
echo "   - CI failure issues when associated PR merges successfully"
echo "   - Artifact pollution issues when guard reports clean status"
echo "   - Dependency issues when automation completes updates"
echo ""

echo "✅ Issue resolution review complete!"
echo "Check log: $LOG_FILE"
