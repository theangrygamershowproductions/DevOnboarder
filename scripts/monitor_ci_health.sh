#!/usr/bin/env bash
# CI Health Monitoring - Track infrastructure reliability post-repair

set -euo pipefail

echo "📊 CI Infrastructure Health Monitor"
echo "=================================="
echo "Post-Repair Monitoring - $(date)"
echo ""

# Monitor recent CI performance
echo "🔄 CI Performance Analysis:"

# Get recent workflow runs with error handling
if runs=$(gh run list --limit 20 --json conclusion,status,workflowName,createdAt 2>/dev/null); then
    echo "✅ Retrieved recent CI run data"
    
    # Calculate success metrics
    total_runs=$(echo "$runs" | jq length)
    successful_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "success")] | length')
    failed_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "failure")] | length')
    
    if [ "$total_runs" -gt 0 ]; then
        success_rate=$((successful_runs * 100 / total_runs))
        echo "📈 Success Rate: ${success_rate}% ($successful_runs/$total_runs successful, $failed_runs failed)"
        
        # Assessment based on recalibrated standards
        if [ "$success_rate" -ge 90 ]; then
            echo "🎉 EXCELLENT: CI infrastructure highly reliable"
        elif [ "$success_rate" -ge 75 ]; then
            echo "✅ GOOD: CI infrastructure generally reliable"
        elif [ "$success_rate" -ge 60 ]; then
            echo "⚠️  ACCEPTABLE: CI infrastructure needs attention"
        else
            echo "❌ POOR: CI infrastructure requires immediate repair"
        fi
        
        # Show recent runs
        echo ""
        echo "🕒 Recent Runs:"
        echo "$runs" | jq -r '.[] | "\(.createdAt[0:19]) \(.workflowName): \(.conclusion // .status)"' | head -10
    else
        echo "⚠️  No recent runs found"
    fi
else
    echo "❌ Cannot retrieve CI run data - monitoring limited"
fi

# Test infrastructure components
echo ""
echo "🛠️  Infrastructure Component Health:"

components=("gh" "jq" "git" "node" "python")
healthy_components=0
total_components=${#components[@]}

for component in "${components[@]}"; do
    if command -v "$component" >/dev/null 2>&1; then
        echo "  ✅ $component: Available"
        ((healthy_components++))
    else
        echo "  ❌ $component: Missing"
    fi
done

infrastructure_health=$((healthy_components * 100 / total_components))
echo ""
echo "🏗️  Infrastructure Health: ${infrastructure_health}% ($healthy_components/$total_components components healthy)"

# Overall assessment
echo ""
echo "📋 OVERALL HEALTH ASSESSMENT:"
if [ "${success_rate:-0}" -ge 85 ] && [ "$infrastructure_health" -ge 80 ]; then
    echo "🎉 HEALTHY: Infrastructure repair successful"
elif [ "${success_rate:-0}" -ge 70 ] && [ "$infrastructure_health" -ge 60 ]; then
    echo "✅ STABLE: Infrastructure functional with minor issues"
else
    echo "⚠️  ATTENTION NEEDED: Infrastructure requires continued repair"
fi

echo ""
echo "📝 Monitor completed - check logs for detailed analysis"
