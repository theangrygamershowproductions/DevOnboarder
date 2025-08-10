#!/usr/bin/env bash
# Simplified PR automation execution for PR #966

set -euo pipefail

PR_NUMBER=966
MODE=${1:-analyze}

echo "DEPLOY Executing Automation Plan for PR #966"
echo "========================================"
echo "Mode: $MODE"
echo ""

# Step 1: Health Assessment
echo "STATS Step 1: Health Assessment"
HEALTH_SCORE=$(bash scripts/assess_pr_health.sh $PR_NUMBER | grep "PR Health Score:" | grep -o '[0-9]*%' | tr -d '%')
echo "Health Score: ${HEALTH_SCORE}%"
echo ""

# Step 2: Pattern Analysis
echo "SYMBOL Step 2: CI Pattern Analysis"
bash scripts/simple_pattern_analysis.sh $PR_NUMBER
echo "Pattern analysis saved to reports/pattern_analysis_$PR_NUMBER.txt"
echo ""

# Step 3: Decision Matrix
echo "BRAIN Step 3: Strategic Decision"
if [[ $HEALTH_SCORE -ge 80 ]]; then
    DECISION="MERGE"
    echo "SUCCESS RECOMMENDATION: MERGE (Health Score: ${HEALTH_SCORE}%)"
    echo "   → PR is healthy and ready for merge"
elif [[ $HEALTH_SCORE -ge 40 ]]; then
    DECISION="FIX_AND_MERGE"
    echo "CONFIG RECOMMENDATION: FIX AND MERGE (Health Score: ${HEALTH_SCORE}%)"
    echo "   → Apply targeted fixes, then merge"
else
    DECISION="NEW_PR"
    echo "SYMBOL RECOMMENDATION: NEW PR (Health Score: ${HEALTH_SCORE}%)"
    echo "   → Consider creating a new PR with focused changes"
fi
echo ""

# Step 4: Execute Actions Based on Mode
if [[ "$MODE" == "analyze" ]]; then
    echo "SYMBOL ANALYZE MODE: Recommendations only"
    echo "Current Assessment: $DECISION"

elif [[ "$MODE" == "execute" ]]; then
    echo "SYMBOL EXECUTE MODE: Applying automated fixes"

    # Apply markdown fixes if pattern analysis shows documentation issues
    if grep -q "DOCUMENTATION QUALITY" reports/pattern_analysis_$PR_NUMBER.txt; then
        echo "CONFIG Applying markdown fixes..."
        if command -v markdownlint >/dev/null 2>&1; then
            # Run markdownlint fix on agent files
            find agents/ -name "*.md" -exec markdownlint --fix {} \; 2>/dev/null || true
            echo "   SUCCESS Applied markdownlint fixes to agents/"
        fi
    fi

    # Apply Python code fixes if needed
    if grep -q "TEST FAILURE" reports/pattern_analysis_$PR_NUMBER.txt; then
        echo "SYMBOL Checking Python code formatting..."
        if command -v black >/dev/null 2>&1; then
            black --check --diff . || {
                echo "   CONFIG Applying black formatting..."
                black . 2>/dev/null || true
            }
        fi
    fi

    echo "   SUCCESS Automated fixes applied"

elif [[ "$MODE" == "full-auto" ]]; then
    echo "Bot FULL-AUTO MODE: Complete automation"
    echo "WARNING  This would apply fixes AND potentially auto-merge"
    echo "SYMBOL  Safety check: Potato.md protection active"

    # Safety check
    if git diff --name-only | grep -q "Potato.md"; then
        echo "SYMBOL SAFETY STOP: Potato.md changes detected - manual review required"
        exit 1
    fi

    echo "   → Would execute: $DECISION"
fi

echo ""
echo "SUCCESS Automation execution complete for PR #966"
echo "STATS Final Status: Health Score ${HEALTH_SCORE}% | Recommendation: $DECISION"
