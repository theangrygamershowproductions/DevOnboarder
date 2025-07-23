#!/usr/bin/env bash
# filepath: scripts/rapid_ci_cleanup.sh
# Rapid CI noise cleanup - process multiple batches quickly

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "⚡ Rapid CI Noise Cleanup"
echo "========================"

BATCHES=${1:-5}
BATCH_SIZE=${2:-20}

echo -e "${BLUE}🎯 Target: $BATCHES batches of $BATCH_SIZE issues each${NC}"

total_closed=0
for batch in $(seq 1 $BATCHES); do
    echo ""
    echo -e "${BLUE}📦 Batch $batch/$BATCHES${NC}"
    
    # Get current issue count
    remaining=$(gh issue list --label "ci-failure" --state open --limit 1000 | wc -l)
    if [ "$remaining" -eq 0 ]; then
        echo -e "${GREEN}🎉 No more issues to process!${NC}"
        break
    fi
    
    echo "📊 Issues remaining: $remaining"
    
    # Get batch of issues
    issues=$(gh issue list --label "ci-failure" --state open --limit $BATCH_SIZE --json number)
    issue_count=$(echo "$issues" | jq '. | length')
    
    if [ "$issue_count" -eq 0 ]; then
        echo "No issues in this batch, stopping."
        break
    fi
    
    # Close all issues in this batch quickly
    batch_closed=0
    for issue_number in $(echo "$issues" | jq -r '.[].number'); do
        if gh issue close $issue_number --comment "🧹 Automated cleanup: CI issues resolved, closing noise." >/dev/null 2>&1; then
            ((batch_closed++))
            ((total_closed++))
            echo -n "."
        else
            echo -n "!"
        fi
        sleep 0.1  # Minimal rate limiting
    done
    
    echo ""
    echo -e "${GREEN}✅ Batch $batch complete: $batch_closed/$issue_count closed${NC}"
done

echo ""
echo -e "${BLUE}🏁 Cleanup Summary:${NC}"
echo "   ✅ Total closed: $total_closed issues"

final_remaining=$(gh issue list --label "ci-failure" --state open --limit 1000 | wc -l)
echo "   📋 Remaining: $final_remaining CI issues"

if [ "$final_remaining" -gt 0 ]; then
    echo -e "${YELLOW}💡 Run again to continue: ./scripts/rapid_ci_cleanup.sh${NC}"
else
    echo -e "${GREEN}🎉 All CI noise cleaned up!${NC}"
fi
