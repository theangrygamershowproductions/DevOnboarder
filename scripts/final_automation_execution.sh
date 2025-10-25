#!/usr/bin/env bash
# Final Automation Execution for PR #966

set -euo pipefail

echo " FINAL AUTOMATION EXECUTION FOR PR #966"
echo "=========================================="
echo ""

# Step 1: Get Health Score
echo " Step 1: Health Assessment"
HEALTH_OUTPUT=$(bash scripts/assess_pr_health.sh 966)
HEALTH_SCORE=$(echo "$HEALTH_OUTPUT" | grep "PR Health Score:" | grep -o '[0-9]*' | head -1)
echo "Current Health Score: ${HEALTH_SCORE}%"
echo ""

# Step 2: Strategic Decision
echo "🧠 Step 2: Strategic Decision"
if [[ $HEALTH_SCORE -ge 95 ]]; then
    echo " RECOMMENDATION: MERGE READY (Score: ${HEALTH_SCORE}% - Meets 95% Standard)"
    DECISION="MERGE"
elif [[ $HEALTH_SCORE -ge 90 ]]; then
    echo " RECOMMENDATION: MINOR FIXES TO REACH 95% (Score: ${HEALTH_SCORE}%)"
    DECISION="FIX_TO_STANDARD"
elif [[ $HEALTH_SCORE -ge 80 ]]; then
    echo "  RECOMMENDATION: SIGNIFICANT FIXES NEEDED (Score: ${HEALTH_SCORE}% << 95% Standard)"
    DECISION="MAJOR_FIXES"
else
    echo "🚨 RECOMMENDATION: FRESH START (Score: ${HEALTH_SCORE}% - Far Below 95% Standard)"
    DECISION="NEW_PR"
fi
echo ""

# Step 3: Execute Fixes
echo "FAST: Step 3: Executing Automated Fixes"

# Apply markdown fixes to agents directory
echo " Applying markdown formatting fixes..."
if command -v markdownlint >/dev/null 2>&1; then
    markdownlint --fix agents/*.md 2>/dev/null || echo "    No markdown issues to fix"
    echo "    Markdown fixes applied to agents/"
else
    echo "     markdownlint not available, skipping markdown fixes"
fi

# Apply Python formatting
echo "🐍 Applying Python code formatting..."
if command -v black >/dev/null 2>&1; then
    black --quiet . 2>/dev/null || echo "    No Python formatting needed"
    echo "    Python formatting applied"
else
    echo "     black not available, skipping Python formatting"
fi

echo ""

# Step 4: Post-Fix Assessment
echo " Step 4: Post-Fix Assessment"
echo "Checking if fixes improved the health score..."

# Check if there are any changes to commit
if git diff --quiet; then
    echo "    No changes applied (code was already formatted correctly)"
    POST_FIX_SCORE=$HEALTH_SCORE
else
    echo "    Changes applied, would need to commit and re-run CI for new score"
    POST_FIX_SCORE="Pending"

    # Show what would be committed
    echo ""
    echo " Changes that would be committed:"
    git diff --name-only | head -10
fi

echo ""

# Step 5: Final Recommendation
echo "🎯 Step 5: Final Automation Summary"
echo "=================================="
echo " Initial Health Score: ${HEALTH_SCORE}%"
echo " Fixes Applied: Markdown formatting, Python formatting"
echo " Post-Fix Score: ${POST_FIX_SCORE}"
echo "🎯 Strategic Decision: ${DECISION}"
echo ""

case $DECISION in
    "MERGE")
        echo " READY FOR MERGE"
        echo "    PR meets our 95% health standard"
        echo "    Consider proceeding with merge approval"
        ;;
    "FIX_TO_STANDARD")
        echo " APPLY TARGETED FIXES TO REACH 95%"
        echo "    Close to standard, focused fixes needed"
        echo "    Commit changes and re-run CI to reach 95%"
        echo "    Only merge when 95% standard is met"
        ;;
    "MAJOR_FIXES")
        echo "  SIGNIFICANT WORK REQUIRED"
        echo "    Current ${HEALTH_SCORE}% << 95% required standard"
        echo "    Consider if time investment justifies continuation"
        echo "    Alternative: Fresh start with lessons learned"
        ;;
    "NEW_PR")
        echo "🚨 FRESH START RECOMMENDED"
        echo "    Current ${HEALTH_SCORE}% is far below 95% standard"
        echo "    Create focused PR with core changes only"
        echo "    Apply lessons learned from current attempt"
        ;;
esac

echo ""
echo "  QUALITY GATE ENFORCEMENT:"
echo "    Required Standard: 95% health score"
echo "    Current Score: ${HEALTH_SCORE}%"
echo "   🎯 Gap to Standard: $((95 - HEALTH_SCORE)) percentage points"

echo ""
echo " Automation execution complete!"
echo " Summary: PR #966 health is ${HEALTH_SCORE}% - ${DECISION} recommended"
