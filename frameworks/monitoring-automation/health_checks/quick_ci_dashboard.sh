#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Quick CI Dashboard - Get immediate CI insights
# This script provides instant CI troubleshooting information

# Validate we're in the correct DevOnboarder project BEFORE announcing the script
if [ ! -f "pyproject.toml" ]; then
    error "Not in DevOnboarder project root. Run from the repository root directory."
    exit 1
fi

# Comprehensive DevOnboarder project validation
if ! grep -q "name = \"devonboarder\"" pyproject.toml 2>/dev/null; then
    error "Not in the DevOnboarder project directory. Found pyproject.toml but project name mismatch."
    echo "Expected: name = \"devonboarder\" in pyproject.toml"
    exit 1
fi

# Additional validation: Check for DevOnboarder-specific files
if [ ! -d "frameworks" ] || [ ! -f "scripts/qc_pre_push.sh" ]; then
    error "Missing DevOnboarder-specific directories/files. Ensure you're in the correct repository."
    exit 1
fi

echo "TOOLS: DevOnboarder Quick CI Dashboard"
echo "=================================="
echo ""

# Create logs directory if it doesn't exist
mkdir -p logs

echo "STATS: Quick CI Analysis ($(date))"
echo ""

# 1. Quick pattern analysis
echo "INFO: CI Pattern Analysis:"
echo "----------------------"
if bash scripts/analyze_ci_patterns.sh 2>/dev/null; then
    success "Pattern analysis completed"
else
    error "Pattern analysis failed or found issues"
fi
echo ""

# 2. Quick health check
echo "HEALTHY: CI Health Status:"
echo "-------------------"
if bash scripts/monitor_ci_health.sh 2>/dev/null; then
    success "Health monitoring completed"
else
    error "Health issues detected"
fi
echo ""

# 3. Script count
SCRIPT_COUNT=$(find scripts -name "*.py" -o -name "*.sh" | wc -l)
echo "TOOLS: Available Tools: $SCRIPT_COUNT automation scripts"
echo ""

# 4. Recent test status
echo "TEST: Recent Test Status:"
echo "---------------------"
if [ -f "logs/.coverage" ]; then
    success "Coverage data available"
else
    warning "No recent coverage data"
fi

if [ -d "logs/.pytest_cache" ]; then
    success "Test cache present"
else
    warning "No test cache found"
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
    CURRENT_TIME=$(date +%s)
    AGE_HOURS=$(( (CURRENT_TIME - REPORT_AGE) / 3600 ))

    echo "STATS: Dashboard Report:"
    echo "------------------"
    success "Dashboard report available (${AGE_HOURS}h old)"
    echo "   Open: logs/ci_dashboard_report.html"
    if [ $AGE_HOURS -gt 24 ]; then
        echo "TIP: Consider regenerating: python scripts/generate_ci_dashboard_report.py"
    fi
else
    echo "STATS: Generate Dashboard:"
    echo "--------------------"
    echo "TIP: Run: python scripts/generate_ci_dashboard_report.py"
    echo "   Creates: logs/ci_dashboard_report.html"
fi

echo ""
target "DevOnboarder: Working quietly and reliably in service of those who need it."
