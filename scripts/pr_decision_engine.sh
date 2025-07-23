#!/usr/bin/env bash
# Automated PR Decision Engine
# Combines health assessment and pattern analysis to provide strategic recommendations

set -euo pipefail

PR_NUMBER="$1"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "🧠 Automated PR Decision Engine for #$PR_NUMBER"
echo "==============================================="
echo

# Run health assessment
echo "📊 Running Health Assessment..."
HEALTH_OUTPUT=$(bash scripts/assess_pr_health.sh "$PR_NUMBER" 2>/dev/null || echo "Health assessment failed")
HEALTH_SCORE=$(echo "$HEALTH_OUTPUT" | grep "PR Health Score:" | sed 's/.*: \([0-9]*\)%.*/\1/')

echo "📋 Running Pattern Analysis..."
PATTERN_OUTPUT=$(bash scripts/analyze_ci_patterns.sh "$PR_NUMBER" 2>/dev/null || echo "Pattern analysis failed")

# Extract key metrics
PR_DATA=$(gh pr view "$PR_NUMBER" --json commits,changedFiles,additions,title,body)
COMMIT_COUNT=$(echo "$PR_DATA" | jq '.commits | length')
CHANGED_FILES=$(echo "$PR_DATA" | jq '.changedFiles')
ADDITIONS=$(echo "$PR_DATA" | jq '.additions')

# Check for mission-critical indicators in title/body
TITLE=$(echo "$PR_DATA" | jq -r '.title')
BODY=$(echo "$PR_DATA" | jq -r '.body')

# Analyze mission completion indicators
MISSION_INDICATORS=0

# Check for completion keywords
if echo "$TITLE $BODY" | grep -qi "fix\|resolve\|implement\|complete\|add"; then
    ((MISSION_INDICATORS++))
fi

# Check for comprehensive work indicators
if [ "$CHANGED_FILES" -gt 10 ]; then
    ((MISSION_INDICATORS++))
fi

if [ "$ADDITIONS" -gt 500 ]; then
    ((MISSION_INDICATORS++))
fi

# Check for infrastructure/automation work
if echo "$TITLE $BODY" | grep -qi "automation\|ci\|workflow\|agent\|quality"; then
    ((MISSION_INDICATORS++))
fi

echo "🎯 DECISION MATRIX ANALYSIS"
echo "=========================="
echo

echo "📊 Key Metrics:"
echo "  Health Score: ${HEALTH_SCORE:-Unknown}%"
echo "  Commits: $COMMIT_COUNT"
echo "  Files Changed: $CHANGED_FILES"
echo "  Lines Added: $ADDITIONS"
echo "  Mission Indicators: $MISSION_INDICATORS/4"
echo

# Decision logic with 95% standard enforcement
RECOMMENDATION=""
CONFIDENCE=""

if [ "${HEALTH_SCORE:-0}" -ge 95 ]; then
    RECOMMENDATION="PROCEED TO MERGE"
    CONFIDENCE="HIGH"
elif [ "${HEALTH_SCORE:-0}" -ge 90 ] && [ "$MISSION_INDICATORS" -ge 3 ]; then
    RECOMMENDATION="MINOR FIXES THEN MERGE"
    CONFIDENCE="HIGH"
elif [ "${HEALTH_SCORE:-0}" -ge 80 ] && [ "$MISSION_INDICATORS" -ge 3 ]; then
    RECOMMENDATION="EVALUATE CORE MISSION COMPLETION"
    CONFIDENCE="MEDIUM"
elif [ "${HEALTH_SCORE:-0}" -lt 80 ] && [ "$COMMIT_COUNT" -gt 10 ] || [ "$CHANGED_FILES" -gt 20 ]; then
    RECOMMENDATION="CONSIDER FRESH START"
    CONFIDENCE="HIGH"
else
    RECOMMENDATION="SIGNIFICANT FIXES REQUIRED"
    CONFIDENCE="MEDIUM"
fi

echo "🤖 AUTOMATED RECOMMENDATION"
echo "=========================="
echo "  Decision: $RECOMMENDATION"
echo "  Confidence: $CONFIDENCE"
echo

echo "📋 Reasoning:"
case "$RECOMMENDATION" in
    "PROCEED TO MERGE")
        echo "  ✅ Meets 95%+ health standard with clear mission completion"
        echo "  🎯 PR has achieved its objectives successfully"
        echo "  🚀 Ready for production deployment"
        ;;
    "MINOR FIXES THEN MERGE")
        echo "  🔧 Near 95% standard (90%+) with minor issues remaining"
        echo "  ⚡ Quick fixes will meet our quality standards"
        echo "  📈 ROI is positive for completing to 95%+"
        ;;
    "EVALUATE CORE MISSION COMPLETION")
        echo "  🤔 Below 95% standard but strong mission indicators"
        echo "  ❓ Question: Has this PR solved the original problem completely?"
        echo "  ⚖️  Consider if mission completion justifies acceptance"
        echo "  ⚠️  WARNING: 64% is significantly below our 95% standard"
        ;;
    "CONSIDER FRESH START")
        echo "  📊 Health score well below 95% standard"
        echo "  🔄 Fresh approach likely more efficient than fixing"
        echo "  💾 Preserve valuable work for new implementation"
        echo "  🚨 QUALITY GATE: Current state doesn't meet standards"
        ;;
    "SIGNIFICANT FIXES REQUIRED")
        echo "  🚨 BELOW STANDARDS: 64% << 95% required"
        echo "  � Major remediation needed to meet quality gates"
        echo "  ⏱️  Assess time investment vs. fresh start"
        echo "  📋 Systematic approach required for all failures"
        ;;
esac

echo
echo "🔮 NEXT ACTIONS:"

case "$RECOMMENDATION" in
    "PROCEED TO MERGE"|"MINOR FIXES THEN MERGE")
        echo "  1. 🔧 Run automated fixes: markdownlint --fix, ruff --fix"
        echo "  2. 📋 Address any remaining critical failures"
        echo "  3. ✅ Verify 95%+ health score after fixes"
        echo "  4. 🚀 Merge when standards are met"
        ;;
    "EVALUATE CORE MISSION COMPLETION")
        echo "  1. 📝 Review original issue/requirements"
        echo "  2. ✅ Assess if core objectives are COMPLETELY met"
        echo "  3. 🚨 WARNING: 64% << 95% standard - exceptional justification needed"
        echo "  4. 🔄 Strong recommendation: Fix to 95%+ or fresh start"
        ;;
    "CONSIDER FRESH START")
        echo "  1. 📋 Document lessons learned and valuable code"
        echo "  2. 🆕 Create new branch/PR with focused scope"
        echo "  3. 🎯 Target 95%+ health from the start"
        echo "  4. 🗂️  Close current PR with summary"
        ;;
    "SIGNIFICANT FIXES REQUIRED")
        echo "  1. � PRIORITY: Address quality gate violations"
        echo "  2. 🔧 Fix all auto-resolvable issues immediately"
        echo "  3. 📊 Target 95%+ health score"
        echo "  4. ⏰ Consider fresh start if fixes exceed 4 hours"
        ;;
esac

echo
echo "⚠️  QUALITY REMINDER: Our standard is 95%+ health score"
echo "📊 Current: 64% | Required: 95% | Gap: 31 percentage points"

echo
echo "🤖 Decision Engine Complete - Use this guidance for strategic planning"
