#!/bin/bash
# Quick CI Dashboard - Get immediate CI insights
# This script provides instant CI troubleshooting information

echo "TOOLS DevOnboarder Quick CI Dashboard"
echo "=================================="
echo ""

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    echo "FAILED Not in DevOnboarder project root. Run from the repository root directory."
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

echo "STATS Quick CI Analysis ($(date))"
echo ""

# 1. Quick pattern analysis
echo "SEARCH CI Pattern Analysis:"
echo "----------------------"
if bash scripts/analyze_ci_patterns.sh 2>/dev/null; then
    echo "SUCCESS Pattern analysis completed"
else
    echo "FAILED Pattern analysis failed or found issues"
fi
echo ""

# 2. Quick health check
echo "SYMBOL CI Health Status:"
echo "-------------------"
if bash scripts/monitor_ci_health.sh 2>/dev/null; then
    echo "SUCCESS Health monitoring completed"
else
    echo "FAILED Health issues detected"
fi
echo ""

# 3. Script count
SCRIPT_COUNT=$(find scripts -name "*.py" -o -name "*.sh" | wc -l)
echo "TOOLS Available Tools: $SCRIPT_COUNT automation scripts"
echo ""

# 4. Recent test status
echo "EMOJI Recent Test Status:"
echo "---------------------"
if [ -f "logs/.coverage" ]; then
    echo "SUCCESS Coverage data available"
else
    echo "WARNING No recent coverage data"
fi

if [ -d "logs/.pytest_cache" ]; then
    echo "SUCCESS Test cache present"
else
    echo "WARNING No test cache found"
fi
echo ""

# 5. Quick actions
echo "SYMBOL Quick Actions:"
echo "----------------"
echo "• Generate full dashboard report: python scripts/generate_ci_dashboard_report.py"
echo "• Run comprehensive tests: bash scripts/run_tests.sh"
echo "• Analyze failed CI runs: bash scripts/analyze_failed_ci_runs.sh"
echo "• Monitor CI health: bash scripts/monitor_ci_health.sh"
echo ""

# 6. Dashboard hint
if [ -f "logs/ci_dashboard_report.html" ]; then
    REPORT_AGE=$(stat -c %Y logs/ci_dashboard_report.html)
    CURRENT_TIME=$(date +%s)
    AGE_HOURS=$(( (CURRENT_TIME - REPORT_AGE) / 3600 ))

    echo "STATS Dashboard Report:"
    echo "------------------"
    echo "SUCCESS Dashboard report available (${AGE_HOURS}h old)"
    echo "   Open: logs/ci_dashboard_report.html"
    if [ $AGE_HOURS -gt 24 ]; then
        echo "IDEA Consider regenerating: python scripts/generate_ci_dashboard_report.py"
    fi
else
    echo "STATS Generate Dashboard:"
    echo "--------------------"
    echo "IDEA Run: python scripts/generate_ci_dashboard_report.py"
    echo "   Creates: logs/ci_dashboard_report.html"
fi

echo ""
echo "TARGET DevOnboarder: Working quietly and reliably in service of those who need it."
