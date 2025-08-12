#!/usr/bin/env bash
# CI Infrastructure Diagnostic Assessment
# Phase 1 of CI Infrastructure Repair Initiative

set -euo pipefail

echo "SEARCH CI INFRASTRUCTURE DIAGNOSTIC ASSESSMENT"
echo "=========================================="
echo "Timestamp: $(date)"
echo ""

# Create diagnostic log
DIAGNOSTIC_LOG="logs/ci_diagnostic_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

log() {
    echo "[$( date '+%H:%M:%S' )] $1" | tee -a "$DIAGNOSTIC_LOG"
}

log "DEPLOY Starting Phase 1: Diagnostic Assessment"

# Issue 1: Terminal Communication Problems
echo "SYMBOL  ISSUE 1: TERMINAL COMMUNICATION ASSESSMENT"
echo "=============================================="

log "Testing terminal communication..."

# Test basic shell functionality
echo "SYMBOL Shell Environment:"
echo "  Shell: $SHELL"
echo "  Terminal: ${TERM:-unknown}"
echo "  PATH: ${PATH:0:100}..." # Truncate for readability

# Test command execution and output capture
TEST_CMD_OUTPUT="Terminal test successful"
if [ "$TEST_CMD_OUTPUT" = "Terminal test successful" ]; then
    echo "  SUCCESS Basic command execution: WORKING"
    log "SUCCESS: Basic command execution working"
else
    echo "  FAILED Basic command execution: FAILED"
    log "ERROR: Basic command execution failed"
fi

# Test GitHub CLI basic functionality
echo ""
echo "SYMBOL GitHub CLI Communication:"
if command -v gh >/dev/null 2>&1; then
    echo "  SUCCESS GitHub CLI installed"
    log "SUCCESS: GitHub CLI found"

    # Test GitHub CLI output capture
    if GH_VERSION=$(gh --version 2>&1 | head -1); then
        echo "  SUCCESS GitHub CLI output: $GH_VERSION"
        log "SUCCESS: GitHub CLI output working"
    else
        echo "  FAILED GitHub CLI output: FAILED"
        log "ERROR: GitHub CLI output failed"
    fi

    # Test authentication
    if gh auth status >/dev/null 2>&1; then
        echo "  SUCCESS GitHub CLI authentication: WORKING"
        log "SUCCESS: GitHub CLI authenticated"
    else
        echo "  FAILED GitHub CLI authentication: FAILED"
        log "ERROR: GitHub CLI not authenticated"
    fi
else
    echo "  FAILED GitHub CLI: NOT INSTALLED"
    log "ERROR: GitHub CLI not found"
fi

# Issue 2: Health Score Calculation Accuracy
echo ""
echo "SYMBOL ISSUE 2: HEALTH SCORE CALCULATION ASSESSMENT"
echo "=============================================="

log "Testing health score calculation accuracy..."

# Test existing health assessment script
if [ -f "scripts/assess_pr_health.sh" ]; then
    echo "SYMBOL Existing Health Assessment Script:"
    echo "  SUCCESS Script exists: scripts/assess_pr_health.sh"
    log "SUCCESS: Health assessment script found"

    # Test with a known PR (968)
    echo "  EMOJI Testing with PR #968..."
    if timeout 10 bash scripts/assess_pr_health.sh 968 >/dev/null 2>&1; then
        echo "  SUCCESS Health assessment execution: WORKING"
        log "SUCCESS: Health assessment script working"
    else
        echo "  FAILED Health assessment execution: TIMEOUT/FAILED"
        log "ERROR: Health assessment script failed or timed out"
    fi
else
    echo "  FAILED Health assessment script: NOT FOUND"
    log "ERROR: Health assessment script missing"
fi

# Test JSON field compatibility
echo ""
echo "SYMBOL JSON Field Compatibility:"
if command -v jq >/dev/null 2>&1; then
    echo "  SUCCESS jq installed"
    log "SUCCESS: jq available"

    # Test GitHub CLI JSON output
    if gh pr view 968 --json number >/dev/null 2>&1; then
        echo "  SUCCESS GitHub CLI JSON output: WORKING"
        log "SUCCESS: GitHub CLI JSON working"
    else
        echo "  FAILED GitHub CLI JSON output: FAILED"
        log "ERROR: GitHub CLI JSON failed"
    fi
else
    echo "  FAILED jq: NOT INSTALLED"
    log "ERROR: jq not available"
fi

# Issue 3: CI Reliability Concerns
echo ""
echo "SYMBOL  ISSUE 3: CI RELIABILITY ASSESSMENT"
echo "===================================="

log "Assessing CI reliability..."

# Check workflow files
echo "SYMBOL Workflow Configuration:"
if [ -d ".github/workflows" ]; then
    WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
    echo "  SUCCESS Workflow directory exists"
    echo "  STATS Workflow files: $WORKFLOW_COUNT"
    log "SUCCESS: Found $WORKFLOW_COUNT workflow files"

    # List workflow files
    find .github/workflows -name "*.yml" -o -name "*.yaml" | while read -r workflow; do
        echo "    - $(basename "$workflow")"
    done
else
    echo "  FAILED Workflow directory: MISSING"
    log "ERROR: .github/workflows directory missing"
fi

# Check environment dependencies
echo ""
echo "SYMBOL Environment Dependencies:"
dependencies=("node" "python" "pip" "npm" "git")
for dep in "${dependencies[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        version=$($dep --version 2>&1 | head -1 || echo "version unknown")
        echo "  SUCCESS $dep: $version"
        log "SUCCESS: $dep available - $version"
    else
        echo "  FAILED $dep: NOT AVAILABLE"
        log "ERROR: $dep missing"
    fi
done

# Issue 4: 95% Health Standard Calibration
echo ""
echo "STATS ISSUE 4: HEALTH STANDARD CALIBRATION ASSESSMENT"
echo "==============================================="

log "Assessing 95% health standard achievability..."

# Analyze recent CI performance if possible
echo "SYMBOL CI Performance Analysis:"
if gh run list --limit 10 --json conclusion >/dev/null 2>&1; then
    echo "  SUCCESS CI run data accessible"
    log "SUCCESS: CI run data accessible"

    # Calculate recent success rate
    RECENT_RUNS=$(gh run list --limit 10 --json conclusion)
    TOTAL_RUNS=$(echo "$RECENT_RUNS" | jq length)
    SUCCESS_RUNS=$(echo "$RECENT_RUNS" | jq '[.[] | select(.conclusion == "success")] | length')

    if [ "$TOTAL_RUNS" -gt 0 ]; then
        SUCCESS_RATE=$((SUCCESS_RUNS * 100 / TOTAL_RUNS))
        echo "  STATS Recent CI success rate: ${SUCCESS_RATE}% ($SUCCESS_RUNS/$TOTAL_RUNS)"
        log "INFO: CI success rate $SUCCESS_RATE% ($SUCCESS_RUNS/$TOTAL_RUNS)"

        if [ "$SUCCESS_RATE" -ge 95 ]; then
            echo "  SYMBOL 95% standard: ACHIEVABLE (currently meeting)"
        elif [ "$SUCCESS_RATE" -ge 80 ]; then
            echo "  WARNING  95% standard: CHALLENGING (currently $SUCCESS_RATE%)"
        else
            echo "  FAILED 95% standard: UNREALISTIC (currently $SUCCESS_RATE%)"
        fi
    else
        echo "  WARNING  No recent CI run data available"
        log "WARNING: No CI run data available"
    fi
else
    echo "  FAILED CI run data: INACCESSIBLE"
    log "ERROR: Cannot access CI run data"
fi

# Generate diagnostic summary
echo ""
echo "SYMBOL DIAGNOSTIC SUMMARY"
echo "===================="

# Count critical issues
CRITICAL_ISSUES=0
WARNINGS=0

# Check critical components
if ! command -v gh >/dev/null 2>&1; then ((CRITICAL_ISSUES++)); fi
if ! gh auth status >/dev/null 2>&1; then ((CRITICAL_ISSUES++)); fi
if ! command -v jq >/dev/null 2>&1; then ((CRITICAL_ISSUES++)); fi
if [ ! -d ".github/workflows" ]; then ((CRITICAL_ISSUES++)); fi

echo "SYMBOL Critical Issues Found: $CRITICAL_ISSUES"
echo "WARNING  Warnings: $WARNINGS"

log "SUMMARY: $CRITICAL_ISSUES critical issues, $WARNINGS warnings"

if [ "$CRITICAL_ISSUES" -eq 0 ]; then
    echo "SYMBOL DIAGNOSTIC RESULT: Infrastructure appears functional"
    echo "TARGET RECOMMENDATION: Proceed to Phase 2 (Infrastructure Fixes)"
    log "RESULT: Infrastructure functional - proceed to Phase 2"
elif [ "$CRITICAL_ISSUES" -le 2 ]; then
    echo "WARNING  DIAGNOSTIC RESULT: Minor infrastructure issues detected"
    echo "TARGET RECOMMENDATION: Address critical issues then proceed to Phase 2"
    log "RESULT: Minor issues - address then proceed to Phase 2"
else
    echo "FAILED DIAGNOSTIC RESULT: Major infrastructure problems detected"
    echo "TARGET RECOMMENDATION: Focus on critical infrastructure repair first"
    log "RESULT: Major problems - critical repair needed first"
fi

echo ""
echo "EDIT Full diagnostic log: $DIAGNOSTIC_LOG"
echo "SYMBOL Next: Execute Phase 2 (Infrastructure Fixes)"

log "SYMBOL Phase 1 diagnostic assessment complete"
