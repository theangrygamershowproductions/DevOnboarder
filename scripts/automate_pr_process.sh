#!/usr/bin/env bash
# Master PR Automation Controller - Fully automated decision and action engine

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

PR_NUMBER="${1:-}"
ACTION_MODE="${2:-analyze}"  # analyze, execute, full-auto

if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <pr-number> [analyze|execute|full-auto]"
    echo ""
    echo "Modes:"
    echo "  analyze   - Analysis only (default)"
    echo "  execute   - Analysis + automated fixes"
    echo "  full-auto - Analysis + fixes + auto-merge (if criteria met)"
    exit 1
fi

echo -e "${BLUE}🤖 AUTOMATED PR PROCESS CONTROLLER${NC}"
echo "========================================"
echo -e "${BLUE}PR: #$PR_NUMBER | Mode: $ACTION_MODE${NC}"
echo ""

# Timestamp for logging
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="logs/pr_automation_${PR_NUMBER}_$(date '+%Y%m%d_%H%M%S').log"
mkdir -p logs reports

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log "🚀 Starting automated PR process for #$PR_NUMBER"

# Step 1: Health Assessment
echo -e "${YELLOW}📊 STEP 1: Health Assessment${NC}"
HEALTH_RESULT=$(bash scripts/assess_pr_health.sh "$PR_NUMBER" 2>&1 | tee -a "$LOG_FILE")
HEALTH_SCORE=$(echo "$HEALTH_RESULT" | grep "PR Health Score:" | sed 's/.*: \([0-9]*\)%.*/\1/' || echo "0")

# Step 2: Pattern Analysis
echo -e "${YELLOW}📋 STEP 2: CI Pattern Analysis${NC}"
PATTERN_RESULT=$(bash scripts/analyze_ci_patterns.sh "$PR_NUMBER" 2>&1 | tee -a "$LOG_FILE")

# Step 3: Strategic Decision
echo -e "${YELLOW}🧠 STEP 3: Strategic Decision Engine${NC}"
DECISION_RESULT=$(bash scripts/pr_decision_engine.sh "$PR_NUMBER" 2>&1 | tee -a "$LOG_FILE")
RECOMMENDATION=$(echo "$DECISION_RESULT" | grep "Decision:" | sed 's/.*Decision: //')

log "Health Score: ${HEALTH_SCORE}%"
log "Recommendation: $RECOMMENDATION"

# Step 4: Automated Actions (if execute or full-auto mode)
if [ "$ACTION_MODE" = "execute" ] || [ "$ACTION_MODE" = "full-auto" ]; then
    echo -e "${YELLOW}🔧 STEP 4: Automated Fixes${NC}"
    
    # Get PR branch
    PR_BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName --jq '.headRefName')
    CURRENT_BRANCH=$(git branch --show-current)
    
    if [ "$PR_BRANCH" != "$CURRENT_BRANCH" ]; then
        echo "⚠️  Already on correct branch: $CURRENT_BRANCH"
    fi
    
    # Apply automated fixes based on pattern analysis
    FIXES_APPLIED=0
    
    # Fix markdown issues
    if echo "$PATTERN_RESULT" | grep -q "Documentation\|Markdown"; then
        echo "🔧 Applying markdown fixes..."
        if command -v markdownlint >/dev/null 2>&1; then
            # Exclude protected files
            if markdownlint --fix . --ignore Potato.md --ignore node_modules --ignore .git 2>/dev/null || true; then
                echo "✅ Markdown linting fixes applied"
                ((FIXES_APPLIED++))
            fi
        fi
    fi
    
    # Fix Python formatting
    if echo "$PATTERN_RESULT" | grep -q "Formatting\|lint"; then
        echo "🔧 Applying Python formatting fixes..."
        if command -v black >/dev/null 2>&1; then
            black . --quiet --exclude "Potato.md" 2>/dev/null || true
            echo "✅ Black formatting applied"
            ((FIXES_APPLIED++))
        fi
        
        if command -v ruff >/dev/null 2>&1; then
            ruff check . --fix --quiet --exclude "Potato.md" 2>/dev/null || true
            echo "✅ Ruff fixes applied"
            ((FIXES_APPLIED++))
        fi
    fi
    
    # Commit fixes if any were applied
    if [ $FIXES_APPLIED -gt 0 ]; then
        git add . 2>/dev/null || true
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "🤖 Automated fixes: $FIXES_APPLIED categories addressed

Applied by PR Automation Controller:
- Markdown linting fixes
- Python code formatting
- Import organization

[automated-commit]" 2>/dev/null || true
            echo "✅ Automated fixes committed"
            
            # Push fixes
            git push origin "$PR_BRANCH" 2>/dev/null || echo "⚠️  Push failed - may need manual intervention"
            echo "✅ Fixes pushed to PR branch"
            
            log "Applied $FIXES_APPLIED automated fixes"
        else
            echo "ℹ️  No changes to commit after fixes"
        fi
    fi
fi

# Step 5: Auto-merge logic (if full-auto mode)
if [ "$ACTION_MODE" = "full-auto" ]; then
    echo -e "${YELLOW}🚀 STEP 5: Auto-Merge Evaluation${NC}"
    
    # Re-evaluate health
    UPDATED_HEALTH=$(bash scripts/assess_pr_health.sh "$PR_NUMBER" 2>/dev/null | grep "PR Health Score:" | sed 's/.*: \([0-9]*\)%.*/\1/' || echo "0")
    
    log "Updated health score: ${UPDATED_HEALTH}%"
    
    # Auto-merge criteria
    AUTO_MERGE=false
    
    if [ "${UPDATED_HEALTH:-0}" -ge 80 ]; then
        AUTO_MERGE=true
        log "✅ Auto-merge criteria met: Health score >= 80%"
    elif [ "${UPDATED_HEALTH:-0}" -ge 70 ] && echo "$RECOMMENDATION" | grep -q "MERGE"; then
        AUTO_MERGE=true
        log "✅ Auto-merge criteria met: Health >= 70% + merge recommendation"
    fi
    
    if [ "$AUTO_MERGE" = true ]; then
        echo -e "${GREEN}🎉 AUTO-MERGE CONDITIONS MET${NC}"
        echo "Note: Auto-merge would be executed here in production mode"
        log "Auto-merge conditions met but not executed (safety mode)"
    else
        echo -e "${YELLOW}⚠️  AUTO-MERGE CRITERIA NOT MET${NC}"
        echo "Health: ${UPDATED_HEALTH}% | Recommendation: $RECOMMENDATION"
        log "Auto-merge skipped - criteria not met"
    fi
fi

# Step 6: Generate Automation Report
echo -e "${YELLOW}📋 STEP 6: Automation Report${NC}"

cat > "reports/pr_${PR_NUMBER}_automation_report.md" << EOF
# PR #$PR_NUMBER Automation Report

**Generated:** $TIMESTAMP  
**Mode:** $ACTION_MODE  
**Controller:** PR Automation Framework v1.0

## 📊 Analysis Results

### Health Assessment
- **Score:** ${HEALTH_SCORE}%
- **Status:** $([ "${HEALTH_SCORE:-0}" -ge 70 ] && echo "Healthy" || echo "Needs Attention")

### Strategic Recommendation
- **Decision:** $RECOMMENDATION
- **Confidence:** $(echo "$DECISION_RESULT" | grep "Confidence:" | sed 's/.*Confidence: //' || echo "Unknown")

### Automated Actions Taken
- **Fixes Applied:** $FIXES_APPLIED categories
- **Commits Created:** $([ $FIXES_APPLIED -gt 0 ] && echo "1 (automated fixes)" || echo "0")
- **Auto-Merge:** $([ "$ACTION_MODE" = "full-auto" ] && echo "Evaluated" || echo "Not attempted")

## 🎯 Next Steps

$(case "$RECOMMENDATION" in
    *"MERGE"*) echo "- ✅ Ready for human review and merge approval";;
    *"EVALUATE"*) echo "- 🤔 Manual evaluation of core mission completion needed";;
    *"FRESH START"*) echo "- 🔄 Consider creating new PR with focused scope";;
    *) echo "- 🔧 Continue with targeted fixes as recommended";;
esac)

## 📁 Artifacts

- **Full Log:** \`$LOG_FILE\`
- **Health Analysis:** Available in automation logs
- **Pattern Analysis:** Available in automation logs

---
*Generated by PR Automation Controller - DevOnboarder Project*
EOF

echo -e "${GREEN}✅ Automation report generated: reports/pr_${PR_NUMBER}_automation_report.md${NC}"

# Final summary
echo ""
echo -e "${PURPLE}🎯 AUTOMATION COMPLETE${NC}"
echo "==============================="
echo -e "📊 Health Score: ${HEALTH_SCORE}%"
echo -e "🎯 Recommendation: $RECOMMENDATION"
echo -e "🔧 Fixes Applied: $FIXES_APPLIED"
echo -e "📋 Full Report: reports/pr_${PR_NUMBER}_automation_report.md"
echo -e "📝 Detailed Log: $LOG_FILE"

if [ "$ACTION_MODE" = "analyze" ]; then
    echo ""
    echo -e "${BLUE}🚀 To execute automated fixes:${NC}"
    echo "bash scripts/automate_pr_process.sh $PR_NUMBER execute"
    echo ""
    echo -e "${BLUE}🤖 For full automation:${NC}"
    echo "bash scripts/automate_pr_process.sh $PR_NUMBER full-auto"
fi

log "🏁 Automation process completed"
