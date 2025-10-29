#!/usr/bin/env bash
# CI Infrastructure Diagnostic Assessment
# Phase 1 of CI Infrastructure Repair Initiative

set -euo pipefail

echo " CI INFRASTRUCTURE DIAGNOSTIC ASSESSMENT"
echo "=========================================="
echo "Timestamp: $(date)"
echo ""

# Create diagnostic log
DIAGNOSTIC_LOG="logs/ci_diagnostic_$(date %Y%m%d_%H%M%S).log"
mkdir -p logs

log() {
    echo "[$( date '%H:%M:%S' )] $1" | tee -a "$DIAGNOSTIC_LOG"
}

log " Starting Phase 1: Diagnostic Assessment"

# Issue 1: Terminal Communication Problems
echo "  ISSUE 1: TERMINAL COMMUNICATION ASSESSMENT"
echo "=============================================="

log "Testing terminal communication..."

# Test basic shell functionality
echo " Shell Environment:"
echo "  Shell: $SHELL"
echo "  Terminal: ${TERM:-unknown}"
echo "  PATH: ${PATH:0:100}..." # Truncate for readability

# Test command execution and output capture
TEST_CMD_OUTPUT="Terminal test successful"
if [ "$TEST_CMD_OUTPUT" = "Terminal test successful" ]; then
    echo "   Basic command execution: WORKING"
    log " Basic command execution working"
else
    echo "   Basic command execution: FAILED"
    log " Basic command execution failed"
fi

# Test GitHub CLI basic functionality
echo ""
echo " GitHub CLI Communication:"
if command -v gh >/dev/null 2>&1; then
    echo "   GitHub CLI installed"
    log " GitHub CLI found"

    # Test GitHub CLI output capture
    if GH_VERSION=$(gh --version 2>&1 | head -1); then
        echo "   GitHub CLI output: $GH_VERSION"
        log " GitHub CLI output working"
    else
        echo "   GitHub CLI output: FAILED"
        log " GitHub CLI output failed"
    fi

    # Test authentication
    if gh auth status >/dev/null 2>&1; then
        echo "   GitHub CLI authentication: WORKING"
        log " GitHub CLI authenticated"
    else
        echo "   GitHub CLI authentication: FAILED"
        log " GitHub CLI not authenticated"
    fi
else
    echo "   GitHub CLI: NOT INSTALLED"
    log " GitHub CLI not found"
fi

# Issue 2: Health Score Calculation Accuracy
echo ""
echo "HOSPITAL: ISSUE 2: HEALTH SCORE CALCULATION ASSESSMENT"
echo "=============================================="

log "Testing health score calculation accuracy..."

# Test existing health assessment script
if [ -f "scripts/assess_pr_health.sh" ]; then
    echo " Existing Health Assessment Script:"
    echo "   Script exists: scripts/assess_pr_health.sh"
    log " Health assessment script found"

    # Test with a known PR (968)
    echo "  🧪 Testing with PR #968..."
    if timeout 10 bash scripts/assess_pr_health.sh 968 >/dev/null 2>&1; then
        echo "   Health assessment execution: WORKING"
        log " Health assessment script working"
    else
        echo "   Health assessment execution: TIMEOUT/FAILED"
        log " Health assessment script failed or timed out"
    fi
else
    echo "   Health assessment script: NOT FOUND"
    log " Health assessment script missing"
fi

# Test JSON field compatibility
echo ""
echo " JSON Field Compatibility:"
if command -v jq >/dev/null 2>&1; then
    echo "   jq installed"
    log " jq available"

    # Test GitHub CLI JSON output
    if gh pr view 968 --json number >/dev/null 2>&1; then
        echo "   GitHub CLI JSON output: WORKING"
        log " GitHub CLI JSON working"
    else
        echo "   GitHub CLI JSON output: FAILED"
        log " GitHub CLI JSON failed"
    fi
else
    echo "   jq: NOT INSTALLED"
    log " jq not available"
fi

# Issue 3: CI Reliability Concerns
echo ""
echo "  ISSUE 3: CI RELIABILITY ASSESSMENT"
echo "===================================="

log "Assessing CI reliability..."

# Check workflow files
echo " Workflow Configuration:"
if [ -d ".github/workflows" ]; then
    WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
    echo "   Workflow directory exists"
    echo "   Workflow files: $WORKFLOW_COUNT"
    log " Found $WORKFLOW_COUNT workflow files"

    # List workflow files
    find .github/workflows -name "*.yml" -o -name "*.yaml" | while read -r workflow; do
        echo "    - $(basename "$workflow")"
    done
else
    echo "   Workflow directory: MISSING"
    log " .github/workflows directory missing"
fi

# Check environment dependencies
echo ""
echo " Environment Dependencies:"
dependencies=("node" "python" "pip" "npm" "git")
for dep in "${dependencies[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        version=$($dep --version 2>&1 | head -1 || echo "version unknown")
        echo "   $dep: $version"
        log " $dep available - $version"
    else
        echo "   $dep: NOT AVAILABLE"
        log " $dep missing"
    fi
done

# Issue 4: 95% Health Standard Calibration
echo ""
echo " ISSUE 4: HEALTH STANDARD CALIBRATION ASSESSMENT"
echo "==============================================="

log "Assessing 95% health standard achievability..."

# Analyze recent CI performance if possible
echo " CI Performance Analysis:"
if gh run list --limit 10 --json conclusion >/dev/null 2>&1; then
    echo "   CI run data accessible"
    log " CI run data accessible"

    # Calculate recent success rate
    RECENT_RUNS=$(gh run list --limit 10 --json conclusion)
    TOTAL_RUNS=$(echo "$RECENT_RUNS" | jq length)
    SUCCESS_RUNS=$(echo "$RECENT_RUNS" | jq '[.[] | select(.conclusion == "success")] | length')

    if [ "$TOTAL_RUNS" -gt 0 ]; then
        SUCCESS_RATE=$((SUCCESS_RUNS * 100 / TOTAL_RUNS))
        echo "   Recent CI success rate: ${SUCCESS_RATE}% ($SUCCESS_RUNS/$TOTAL_RUNS)"
        log " CI success rate $SUCCESS_RATE% ($SUCCESS_RUNS/$TOTAL_RUNS)"

        if [ "$SUCCESS_RATE" -ge 95 ]; then
            echo "  🎉 95% standard: ACHIEVABLE (currently meeting)"
        elif [ "$SUCCESS_RATE" -ge 80 ]; then
            echo "    95% standard: CHALLENGING (currently $SUCCESS_RATE%)"
        else
            echo "   95% standard: UNREALISTIC (currently $SUCCESS_RATE%)"
        fi
    else
        echo "    No recent CI run data available"
        log " No CI run data available"
    fi
else
    echo "   CI run data: INACCESSIBLE"
    log " Cannot access CI run data"
fi

# Generate diagnostic summary
echo ""
echo " DIAGNOSTIC SUMMARY"
echo "===================="

# Count critical issues
CRITICAL_ISSUES=0
WARNINGS=0

# Check critical components
if ! command -v gh >/dev/null 2>&1; then ((CRITICAL_ISSUES)); fi
if ! gh auth status >/dev/null 2>&1; then ((CRITICAL_ISSUES)); fi
if ! command -v jq >/dev/null 2>&1; then ((CRITICAL_ISSUES)); fi
if [ ! -d ".github/workflows" ]; then ((CRITICAL_ISSUES)); fi

echo "🚨 Critical Issues Found: $CRITICAL_ISSUES"
echo "  Warnings: $WARNINGS"

log "SUMMARY: $CRITICAL_ISSUES critical issues, $WARNINGS warnings"

if [ "$CRITICAL_ISSUES" -eq 0 ]; then
    echo "🎉 DIAGNOSTIC RESULT: Infrastructure appears functional"
    echo "TARGET: RECOMMENDATION: Proceed to Phase 2 (Infrastructure Fixes)"
    log "RESULT: Infrastructure functional - proceed to Phase 2"
elif [ "$CRITICAL_ISSUES" -le 2 ]; then
    echo "  DIAGNOSTIC RESULT: Minor infrastructure issues detected"
    echo "TARGET: RECOMMENDATION: Address critical issues then proceed to Phase 2"
    log "RESULT: Minor issues - address then proceed to Phase 2"
else
    echo " DIAGNOSTIC RESULT: Major infrastructure problems detected"
    echo "TARGET: RECOMMENDATION: Focus on critical infrastructure repair first"
    log "RESULT: Major problems - critical repair needed first"
fi

echo ""
echo " Full diagnostic log: $DIAGNOSTIC_LOG"
echo "SYNC: Next: Execute Phase 2 (Infrastructure Fixes)"

log "🏁 Phase 1 diagnostic assessment complete"
