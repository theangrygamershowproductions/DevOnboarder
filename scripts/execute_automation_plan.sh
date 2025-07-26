#!/usr/bin/env bash
# Simplified PR automation execution for PR #966

set -euo pipefail

PR_NUMBER=966
MODE=${1:-analyze}

echo "🚀 Executing Automation Plan for PR #966"
echo "========================================"
echo "Mode: $MODE"
echo ""

# Step 1: Health Assessment
echo "📊 Step 1: Health Assessment"
HEALTH_SCORE=$(bash scripts/assess_pr_health.sh $PR_NUMBER | grep "PR Health Score:" | grep -o '[0-9]*%' | tr -d '%')
echo "Health Score: ${HEALTH_SCORE}%"
echo ""

# Step 2: Pattern Analysis  
echo "📋 Step 2: CI Pattern Analysis"
bash scripts/simple_pattern_analysis.sh $PR_NUMBER
echo "Pattern analysis saved to reports/pattern_analysis_$PR_NUMBER.txt"
echo ""

# Step 3: Decision Matrix
echo "🧠 Step 3: Strategic Decision"
if [[ $HEALTH_SCORE -ge 80 ]]; then
    DECISION="MERGE"
    echo "✅ RECOMMENDATION: MERGE (Health Score: ${HEALTH_SCORE}%)"
    echo "   → PR is healthy and ready for merge"
elif [[ $HEALTH_SCORE -ge 40 ]]; then
    DECISION="FIX_AND_MERGE"
    echo "🔧 RECOMMENDATION: FIX AND MERGE (Health Score: ${HEALTH_SCORE}%)"
    echo "   → Apply targeted fixes, then merge"
else
    DECISION="NEW_PR"
    echo "🆕 RECOMMENDATION: NEW PR (Health Score: ${HEALTH_SCORE}%)"
    echo "   → Consider creating a new PR with focused changes"
fi
echo ""

# Step 4: Execute Actions Based on Mode
if [[ "$MODE" == "analyze" ]]; then
    echo "📋 ANALYZE MODE: Recommendations only"
    echo "Current Assessment: $DECISION"
    
elif [[ "$MODE" == "execute" ]]; then
    echo "⚡ EXECUTE MODE: Applying automated fixes"
    
    # Apply markdown fixes if pattern analysis shows documentation issues
    if grep -q "DOCUMENTATION QUALITY" reports/pattern_analysis_$PR_NUMBER.txt; then
        echo "🔧 Applying markdown fixes..."
        if command -v markdownlint >/dev/null 2>&1; then
            # Run markdownlint fix on agent files
            find agents/ -name "*.md" -exec markdownlint --fix {} \; 2>/dev/null || true
            echo "   ✅ Applied markdownlint fixes to agents/"
        fi
    fi
    
    # Apply Python code fixes if needed
    if grep -q "TEST FAILURE" reports/pattern_analysis_$PR_NUMBER.txt; then
        echo "🐍 Checking Python code formatting..."
        if command -v black >/dev/null 2>&1; then
            black --check --diff . || {
                echo "   🔧 Applying black formatting..."
                black . 2>/dev/null || true
            }
        fi
    fi
    
    echo "   ✅ Automated fixes applied"
    
elif [[ "$MODE" == "full-auto" ]]; then
    echo "🤖 FULL-AUTO MODE: Complete automation"
    echo "⚠️  This would apply fixes AND potentially auto-merge"
    echo "🛡️  Safety check: Potato.md protection active"
    
    # Safety check
    if git diff --name-only | grep -q "Potato.md"; then
        echo "🚨 SAFETY STOP: Potato.md changes detected - manual review required"
        exit 1
    fi
    
    echo "   → Would execute: $DECISION"
fi

echo ""
echo "✅ Automation execution complete for PR #966"
echo "📊 Final Status: Health Score ${HEALTH_SCORE}% | Recommendation: $DECISION"
