#!/bin/bash
# Quick CI Dashboard - Get immediate CI insights
# This script provides instant CI troubleshooting information

# Validate we're in the correct DevOnboarder project BEFORE announcing the script
if [ ! -f "pyproject.toml" ]; then
    echo " Not in DevOnboarder project root. Run from the repository root directory."
    exit 1
fi

# Comprehensive DevOnboarder project validation
if ! grep -q "name = \"devonboarder\"" pyproject.toml 2>/dev/null; then
    echo " Not in the DevOnboarder project directory. Found pyproject.toml but project name mismatch."
    echo "Expected: name = \"devonboarder\" in pyproject.toml"
    exit 1
fi

# Additional validation: Check for DevOnboarder-specific files
if [ ! -d "frameworks" ] || [ ! -f "scripts/qc_pre_push.sh" ]; then
    echo " Missing DevOnboarder-specific directories/files. Ensure you're in the correct repository."
    exit 1
fi

echo " DevOnboarder Quick CI Dashboard"
echo "=================================="
echo ""

# Create logs directory if it doesn't exist
mkdir -p logs

echo " Quick CI Analysis ($(date))"
echo ""

# 1. Quick pattern analysis
echo " CI Pattern Analysis:"
echo "----------------------"
if bash scripts/analyze_ci_patterns.sh 2>/dev/null; then
    echo " Pattern analysis completed"
else
    echo " Pattern analysis failed or found issues"
fi
echo ""

# 2. Quick health check
echo "HEALTHY: CI Health Status:"
echo "-------------------"
if bash scripts/monitor_ci_health.sh 2>/dev/null; then
    echo " Health monitoring completed"
else
    echo " Health issues detected"
fi
echo ""

# 3. Script count
SCRIPT_COUNT=$(find scripts -name "*.py" -o -name "*.sh" | wc -l)
echo " Available Tools: $SCRIPT_COUNT automation scripts"
echo ""

# 4. Recent test status
echo "TEST: Recent Test Status:"
echo "---------------------"
if [ -f "logs/.coverage" ]; then
    echo " Coverage data available"
else
    echo " No recent coverage data"
fi

if [ -d "logs/.pytest_cache" ]; then
    echo " Test cache present"
else
    echo " No test cache found"
fi
echo ""

# 5. Quick actions
echo "QUICK: Quick Actions:"
echo "----------------"
echo "• Generate full dashboard report: python scripts/generate_ci_dashboard_report.py"
echo "• Run comprehensive tests: bash scripts/run_tests.sh"
echo "• Analyze failed CI runs: bash scripts/analyze_failed_ci_runs.sh"
echo "• Monitor CI health: bash scripts/monitor_ci_health.sh"
echo ""

# 6. Dashboard hint
if [ -f "logs/ci_dashboard_report.html" ]; then
    REPORT_AGE=$(stat -c %Y logs/ci_dashboard_report.html)
    CURRENT_TIME=$(date %s)
    AGE_HOURS=$(( (CURRENT_TIME - REPORT_AGE) / 3600 ))

    echo " Dashboard Report:"
    echo "------------------"
    echo " Dashboard report available (${AGE_HOURS}h old)"
    echo "   Open: logs/ci_dashboard_report.html"
    if [ $AGE_HOURS -gt 24 ]; then
        echo " Consider regenerating: python scripts/generate_ci_dashboard_report.py"
    fi
else
    echo " Generate Dashboard:"
    echo "--------------------"
    echo " Run: python scripts/generate_ci_dashboard_report.py"
    echo "   Creates: logs/ci_dashboard_report.html"
fi

echo ""
echo "TARGET: DevOnboarder: Working quietly and reliably in service of those who need it."
