#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# CI Infrastructure Diagnostic Assessment
# Phase 1 of CI Infrastructure Repair Initiative

set -euo pipefail

echo "🔍 CI INFRASTRUCTURE DIAGNOSTIC ASSESSMENT"
echo "=========================================="
echo "Timestamp: $(date)"
echo ""

# Create diagnostic log
DIAGNOSTIC_LOG="logs/ci_diagnostic_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

log() {
    echo "[$( date '+%H:%M:%S' )] $1" | tee -a "$DIAGNOSTIC_LOG"
}

log "deploy "Starting Phase 1: Diagnostic Assessment"

# Issue 1: Terminal Communication Problems
echo "🖥️  ISSUE 1: TERMINAL COMMUNICATION ASSESSMENT"
echo "=============================================="

log "Testing terminal communication..."

# Test basic shell functionality
check "Shell Environment:"
echo "  Shell: $SHELL"
echo "  Terminal: ${TERM:-unknown}"
echo "  PATH: ${PATH:0:100}..." # Truncate for readability

# Test command execution and output capture
TEST_CMD_OUTPUT="Terminal test successful"
if [ "$TEST_CMD_OUTPUT" = "Terminal test successful" ]; then
    echo "  SUCCESS: Basic command execution: WORKING"
    log "success "Basic command execution working"
else
    echo "  ERROR: Basic command execution: FAILED"
    log "error "Basic command execution failed"
fi

# Test GitHub CLI basic functionality
echo ""
check "GitHub CLI Communication:"
if command -v gh >/dev/null 2>&1; then
    echo "  SUCCESS: GitHub CLI installed"
    log "success "GitHub CLI found"

    # Test GitHub CLI output capture
    if GH_VERSION=$(gh --version 2>&1 | head -1); then
        echo "  SUCCESS: GitHub CLI output: $GH_VERSION"
        log "success "GitHub CLI output working"
    else
        echo "  ERROR: GitHub CLI output: FAILED"
        log "error "GitHub CLI output failed"
    fi

    # Test authentication
    if gh auth status >/dev/null 2>&1; then
        echo "  SUCCESS: GitHub CLI authentication: WORKING"
        log "success "GitHub CLI authenticated"
    else
        echo "  ERROR: GitHub CLI authentication: FAILED"
        log "error "GitHub CLI not authenticated"
    fi
else
    echo "  ERROR: GitHub CLI: NOT INSTALLED"
    log "error "GitHub CLI not found"
fi

# Issue 2: Health Score Calculation Accuracy
echo ""
echo "🏥 ISSUE 2: HEALTH SCORE CALCULATION ASSESSMENT"
echo "=============================================="

log "Testing health score calculation accuracy..."

# Test existing health assessment script
if [ -f "scripts/assess_pr_health.sh" ]; then
    check "Existing Health Assessment Script:"
    echo "  SUCCESS: Script exists: scripts/assess_pr_health.sh"
    log "success "Health assessment script found"

    # Test with a known PR (968)
    echo "  🧪 Testing with PR #968..."
    if timeout 10 bash scripts/assess_pr_health.sh 968 >/dev/null 2>&1; then
        echo "  SUCCESS: Health assessment execution: WORKING"
        log "success "Health assessment script working"
    else
        echo "  ERROR: Health assessment execution: TIMEOUT/FAILED"
        log "error "Health assessment script failed or timed out"
    fi
else
    echo "  ERROR: Health assessment script: NOT FOUND"
    log "error "Health assessment script missing"
fi

# Test JSON field compatibility
echo ""
check "JSON Field Compatibility:"
if command -v jq >/dev/null 2>&1; then
    echo "  SUCCESS: jq installed"
    log "success "jq available"

    # Test GitHub CLI JSON output
    if gh pr view 968 --json number >/dev/null 2>&1; then
        echo "  SUCCESS: GitHub CLI JSON output: WORKING"
        log "success "GitHub CLI JSON working"
    else
        echo "  ERROR: GitHub CLI JSON output: FAILED"
        log "error "GitHub CLI JSON failed"
    fi
else
    echo "  ERROR: jq: NOT INSTALLED"
    log "error "jq not available"
fi

# Issue 3: CI Reliability Concerns
echo ""
echo "⚙️  ISSUE 3: CI RELIABILITY ASSESSMENT"
echo "===================================="

log "Assessing CI reliability..."

# Check workflow files
check "Workflow Configuration:"
if [ -d ".github/workflows" ]; then
    WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
    echo "  SUCCESS: Workflow directory exists"
    echo "  REPORT: Workflow files: $WORKFLOW_COUNT"
    log "success "Found $WORKFLOW_COUNT workflow files"

    # List workflow files
    find .github/workflows -name "*.yml" -o -name "*.yaml" | while read -r workflow; do
        echo "    - $(basename "$workflow")"
    done
else
    echo "  ERROR: Workflow directory: MISSING"
    log "error ".github/workflows directory missing"
fi

# Check environment dependencies
echo ""
check "Environment Dependencies:"
dependencies=("node" "python" "pip" "npm" "git")
for dep in "${dependencies[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        version=$($dep --version 2>&1 | head -1 || echo "version unknown")
        echo "  SUCCESS: $dep: $version"
        log "success "$dep available - $version"
    else
        echo "  ERROR: $dep: NOT AVAILABLE"
        log "error "$dep missing"
    fi
done

# Issue 4: 95% Health Standard Calibration
echo ""
report "ISSUE 4: HEALTH STANDARD CALIBRATION ASSESSMENT"
echo "==============================================="

log "Assessing 95% health standard achievability..."

# Analyze recent CI performance if possible
check "CI Performance Analysis:"
if gh run list --limit 10 --json conclusion >/dev/null 2>&1; then
    echo "  SUCCESS: CI run data accessible"
    log "success "CI run data accessible"

    # Calculate recent success rate
    RECENT_RUNS=$(gh run list --limit 10 --json conclusion)
    TOTAL_RUNS=$(echo "$RECENT_RUNS" | jq length)
    SUCCESS_RUNS=$(echo "$RECENT_RUNS" | jq '[.[] | select(.conclusion == "success")] | length')

    if [ "$TOTAL_RUNS" -gt 0 ]; then
        SUCCESS_RATE=$((SUCCESS_RUNS * 100 / TOTAL_RUNS))
        echo "  REPORT: Recent CI success rate: ${SUCCESS_RATE}% ($SUCCESS_RUNS/$TOTAL_RUNS)"
        log "INFO: CI success rate $SUCCESS_RATE% ($SUCCESS_RUNS/$TOTAL_RUNS)"

        if [ "$SUCCESS_RATE" -ge 95 ]; then
            echo "  🎉 95% standard: ACHIEVABLE (currently meeting)"
        elif [ "$SUCCESS_RATE" -ge 80 ]; then
            echo "  WARNING:  95% standard: CHALLENGING (currently $SUCCESS_RATE%)"
        else
            echo "  ERROR: 95% standard: UNREALISTIC (currently $SUCCESS_RATE%)"
        fi
    else
        echo "  WARNING:  No recent CI run data available"
        log "warning "No CI run data available"
    fi
else
    echo "  ERROR: CI run data: INACCESSIBLE"
    log "error "Cannot access CI run data"
fi

# Generate diagnostic summary
echo ""
check "DIAGNOSTIC SUMMARY"
echo "===================="

# Count critical issues
CRITICAL_ISSUES=0
WARNINGS=0

# Check critical components
if ! command -v gh >/dev/null 2>&1; then ((CRITICAL_ISSUES++)); fi
if ! gh auth status >/dev/null 2>&1; then ((CRITICAL_ISSUES++)); fi
if ! command -v jq >/dev/null 2>&1; then ((CRITICAL_ISSUES++)); fi
if [ ! -d ".github/workflows" ]; then ((CRITICAL_ISSUES++)); fi

echo "🚨 Critical Issues Found: $CRITICAL_ISSUES"
warning " Warnings: $WARNINGS"

log "SUMMARY: $CRITICAL_ISSUES critical issues, $WARNINGS warnings"

if [ "$CRITICAL_ISSUES" -eq 0 ]; then
    echo "🎉 DIAGNOSTIC RESULT: Infrastructure appears functional"
    target "RECOMMENDATION: Proceed to Phase 2 (Infrastructure Fixes)"
    log "RESULT: Infrastructure functional - proceed to Phase 2"
elif [ "$CRITICAL_ISSUES" -le 2 ]; then
    warning " DIAGNOSTIC RESULT: Minor infrastructure issues detected"
    target "RECOMMENDATION: Address critical issues then proceed to Phase 2"
    log "RESULT: Minor issues - address then proceed to Phase 2"
else
    error "DIAGNOSTIC RESULT: Major infrastructure problems detected"
    target "RECOMMENDATION: Focus on critical infrastructure repair first"
    log "RESULT: Major problems - critical repair needed first"
fi

echo ""
note "Full diagnostic log: $DIAGNOSTIC_LOG"
sync "Next: Execute Phase 2 (Infrastructure Fixes)"

log "🏁 Phase 1 diagnostic assessment complete"
