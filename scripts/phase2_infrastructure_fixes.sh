#!/usr/bin/env bash
# CI Infrastructure Fixes - Phase 2
# Addressing the specific issues identified in the epic

set -euo pipefail

echo "CONFIG CI INFRASTRUCTURE FIXES - PHASE 2"
echo "===================================="
echo "Timestamp: $(date)"
echo ""

# Create repair log
REPAIR_LOG="logs/ci_repair_phase2_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

log() {
    echo "[$( date '+%H:%M:%S' )] $1" | tee -a "$REPAIR_LOG"
}

log "DEPLOY Starting Phase 2: Infrastructure Fixes"

# Fix 1: Terminal Communication Problems
echo "SYMBOL  FIX 1: TERMINAL COMMUNICATION REPAIR"
echo "======================================="

log "Implementing terminal communication fixes..."

# Create robust command execution wrapper
cat > scripts/robust_command.sh << 'EOF'
#!/usr/bin/env bash
# Robust command execution wrapper to fix terminal communication issues

set -euo pipefail

execute_with_output() {
    local cmd="$1"
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        echo "Executing: $cmd" >&2

        # Execute command with explicit output capture and error handling
        if output=$(eval "$cmd" 2>&1); then
            echo "$output"
            return 0
        else
            ((retry++))
            echo "Retry $retry/$max_retries failed" >&2
            sleep 1
        fi
    done

    echo "Command failed after $max_retries attempts" >&2
    return 1
}

# Test the wrapper
execute_with_output "echo 'Terminal communication test successful'"
EOF

chmod +x scripts/robust_command.sh
echo "SUCCESS Created robust command execution wrapper"
log "SUCCESS: Robust command wrapper created"

# Fix 2: Health Score Calculation Accuracy
echo ""
echo "SYMBOL FIX 2: HEALTH SCORE CALCULATION REPAIR"
echo "========================================"

log "Implementing health score calculation fixes..."

# Create fixed health assessment script
cat > scripts/assess_pr_health_robust.sh << 'EOF'
#!/usr/bin/env bash
# Robust PR Health Assessment - Fixes terminal communication and JSON issues

set -euo pipefail

PR_NUMBER="$1"
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "SYMBOL Robust PR Health Assessment #$PR_NUMBER"
echo "========================================"

# Robust GitHub CLI execution with explicit output handling
execute_gh_command() {
    local cmd="$1"
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if result=$(gh $cmd 2>&1); then
            echo "$result"
            return 0
        fi

        ((retry++))
        echo "GitHub CLI retry $retry/$max_retries..." >&2
        sleep 2
    done

    echo "GitHub CLI command failed: gh $cmd" >&2
    return 1
}

# Get PR basic information with error handling
echo "SYMBOL Retrieving PR information..."
if ! PR_INFO=$(execute_gh_command "pr view $PR_NUMBER --json number,title,state,mergeable"); then
    echo "FAILED Failed to retrieve PR information"
    echo "STATS Health Score: Cannot calculate (PR data unavailable)"
    exit 1
fi

echo "SUCCESS PR Information Retrieved:"
echo "  Number: $(echo "$PR_INFO" | jq -r '.number // "unknown"')"
echo "  Title: $(echo "$PR_INFO" | jq -r '.title // "unknown"')"
echo "  State: $(echo "$PR_INFO" | jq -r '.state // "unknown"')"
echo ""

# Get check status with robust error handling
echo "SEARCH Retrieving check status..."
if CHECK_INFO=$(execute_gh_command "pr checks $PR_NUMBER --json name,conclusion,status"); then
    echo "SUCCESS Check information retrieved"
else
    echo "WARNING  Using alternative check retrieval method..."
    # Alternative: Get from status checks if regular checks fail
    if CHECK_INFO=$(execute_gh_command "pr view $PR_NUMBER --json statusCheckRollup"); then
        # Transform statusCheckRollup to match expected format
        CHECK_INFO=$(echo "$CHECK_INFO" | jq '.statusCheckRollup | map({name: .name, conclusion: .conclusion, status: .status})')
        echo "SUCCESS Check information retrieved via alternative method"
    else
        echo "FAILED Cannot retrieve check information"
        echo "STATS Health Score: Cannot calculate (check data unavailable)"
        exit 1
    fi
fi

# Calculate health score with proper error handling
if [ "$(echo "$CHECK_INFO" | jq length)" -eq 0 ]; then
    echo "WARNING  No checks found"
    echo "STATS Health Score: 0% (no checks available)"
    exit 0
fi

TOTAL_CHECKS=$(echo "$CHECK_INFO" | jq length)
SUCCESS_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == "success")] | length')
FAILURE_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == "failure")] | length')
PENDING_CHECKS=$(echo "$CHECK_INFO" | jq '[.[] | select(.conclusion == null or .conclusion == "" or .status == "in_progress")] | length')

echo "STATS Check Summary:"
echo "  Total: $TOTAL_CHECKS"
echo "  SUCCESS Success: $SUCCESS_CHECKS"
echo "  FAILED Failed: $FAILURE_CHECKS"
echo "  ⏳ Pending: $PENDING_CHECKS"
echo ""

# Calculate health percentage
HEALTH_SCORE=$((SUCCESS_CHECKS * 100 / TOTAL_CHECKS))
echo "STATS PR Health Score: ${HEALTH_SCORE}%"

# Health recommendations based on recalibrated standards
if [ "$HEALTH_SCORE" -ge 95 ]; then
    echo "SYMBOL EXCELLENT: Meets 95% quality standard"
    echo "TARGET Recommendation: Ready for merge"
elif [ "$HEALTH_SCORE" -ge 85 ]; then
    echo "SUCCESS GOOD: Strong health score"
    echo "TARGET Recommendation: Manual review recommended"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
    echo "WARNING  ACCEPTABLE: Functional but needs improvement"
    echo "TARGET Recommendation: Targeted fixes required"
elif [ "$HEALTH_SCORE" -ge 50 ]; then
    echo "FAILED POOR: Significant issues present"
    echo "TARGET Recommendation: Major fixes required"
else
    echo "SYMBOL FAILING: Critical failures present"
    echo "TARGET Recommendation: Fresh start recommended"
fi

# Show failing checks if any
if [ "$FAILURE_CHECKS" -gt 0 ]; then
    echo ""
    echo "FAILED Failing Checks:"
    echo "$CHECK_INFO" | jq -r '.[] | select(.conclusion == "failure") | "  - \(.name)"'
fi

echo ""
echo "SUCCESS Robust health assessment complete"
EOF

chmod +x scripts/assess_pr_health_robust.sh
echo "SUCCESS Created robust health assessment script"
log "SUCCESS: Robust health assessment created"

# Fix 3: CI Pattern Analysis Repair
echo ""
echo "SYMBOL FIX 3: CI PATTERN ANALYSIS REPAIR"
echo "=================================="

log "Implementing pattern analysis fixes..."

cat > scripts/analyze_ci_patterns_robust.sh << 'EOF'
#!/usr/bin/env bash
# Robust CI Pattern Analysis - Fixes GitHub CLI issues

set -euo pipefail

PR_NUMBER="$1"
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "SYMBOL Robust CI Pattern Analysis #$PR_NUMBER"
echo "======================================"

# Robust check retrieval
get_failing_checks() {
    local max_retries=3
    local retry=0

    while [ $retry -lt $max_retries ]; do
        if check_data=$(gh pr checks "$PR_NUMBER" --json name,conclusion 2>&1); then
            echo "$check_data" | jq -r '.[] | select(.conclusion == "failure") | .name'
            return 0
        fi

        ((retry++))
        echo "Retry $retry/$max_retries for check data..." >&2
        sleep 2
    done

    echo "" # Return empty if all retries fail
    return 1
}

echo "SEARCH Analyzing CI failure patterns..."
FAILING_CHECKS=$(get_failing_checks)

if [ -z "$FAILING_CHECKS" ]; then
    echo "SUCCESS No failing checks detected or unable to retrieve data"
    echo "STATS Pattern Analysis: All checks passing or data unavailable"
    exit 0
fi

echo "FAILED Failing Checks Detected:"
while read -r check; do
    [ -n "$check" ] && echo "  - $check"
done <<< "$FAILING_CHECKS"

echo ""
echo "SEARCH Pattern Analysis:"

# Enhanced pattern detection with categories
PATTERNS=()

# Test failures
if echo "$FAILING_CHECKS" | grep -qi "test\|spec\|pytest\|jest\|mocha\|unit\|integration"; then
    PATTERNS+=("TESTING")
    echo "  EMOJI TESTING FAILURES: Unit/integration test issues detected"
fi

# Code quality failures
if echo "$FAILING_CHECKS" | grep -qi "lint\|format\|style\|quality\|eslint\|prettier\|black\|ruff"; then
    PATTERNS+=("CODE_QUALITY")
    echo "  EDIT CODE QUALITY: Linting/formatting issues detected"
fi

# Security failures
if echo "$FAILING_CHECKS" | grep -qi "security\|audit\|vulnerability\|snyk\|safety"; then
    PATTERNS+=("SECURITY")
    echo "  SYMBOL SECURITY ISSUES: Security scan failures detected"
fi

# Build failures
if echo "$FAILING_CHECKS" | grep -qi "build\|compile\|webpack\|rollup\|tsc\|make"; then
    PATTERNS+=("BUILD")
    echo "  SYMBOL BUILD FAILURES: Compilation/build issues detected"
fi

# Documentation failures
if echo "$FAILING_CHECKS" | grep -qi "docs\|documentation\|markdown\|readme"; then
    PATTERNS+=("DOCUMENTATION")
    echo "  SYMBOL DOCUMENTATION: Documentation quality issues detected"
fi

# Infrastructure failures
if echo "$FAILING_CHECKS" | grep -qi "deploy\|infrastructure\|terraform\|ansible"; then
    PATTERNS+=("INFRASTRUCTURE")
    echo "  SYMBOL INFRASTRUCTURE: Deployment/infrastructure issues detected"
fi

# Generic check failures
if echo "$FAILING_CHECKS" | grep -qi "^check\|validate\|verify"; then
    PATTERNS+=("VALIDATION")
    echo "  SUCCESS VALIDATION: General validation failures detected"
fi

# Unknown patterns
if [ ${#PATTERNS[@]} -eq 0 ]; then
    PATTERNS+=("UNKNOWN")
    echo "  SYMBOL UNKNOWN PATTERNS: Unrecognized failure types"
fi

echo ""
echo "TARGET Automated Fix Recommendations:"

for pattern in "${PATTERNS[@]}"; do
    case $pattern in
        "TESTING")
            echo "  EMOJI TESTING: Review test logs, fix failing assertions, verify test data"
            ;;
        "CODE_QUALITY")
            echo "  EDIT CODE_QUALITY: Run formatters (black, prettier), fix linting errors"
            ;;
        "SECURITY")
            echo "  SYMBOL SECURITY: Update dependencies, patch vulnerabilities, review security policies"
            ;;
        "BUILD")
            echo "  SYMBOL BUILD: Check dependencies, fix compilation errors, verify configurations"
            ;;
        "DOCUMENTATION")
            echo "  SYMBOL DOCUMENTATION: Fix markdown errors, update docs, validate links"
            ;;
        "INFRASTRUCTURE")
            echo "  SYMBOL INFRASTRUCTURE: Verify deployment configs, check environment variables"
            ;;
        "VALIDATION")
            echo "  SUCCESS VALIDATION: Check workflow permissions, verify environment setup"
            ;;
        "UNKNOWN")
            echo "  SYMBOL UNKNOWN: Manual investigation required, check individual CI logs"
            ;;
    esac
done

echo ""
echo "Bot Auto-fix Potential Assessment:"
if [[ " ${PATTERNS[*]} " =~ " CODE_QUALITY " ]] || [[ " ${PATTERNS[*]} " =~ " DOCUMENTATION " ]]; then
    echo "  GREEN HIGH: Code quality and documentation issues are auto-fixable"
elif [[ " ${PATTERNS[*]} " =~ " TESTING " ]] && [[ " ${PATTERNS[*]} " =~ " BUILD " ]]; then
    echo "  YELLOW MEDIUM: Mixed issues - some auto-fixable, some require manual intervention"
else
    echo "  RED LOW: Manual intervention likely required for most issues"
fi

echo ""
echo "SUCCESS Pattern analysis complete"
EOF

chmod +x scripts/analyze_ci_patterns_robust.sh
echo "SUCCESS Created robust pattern analysis script"
log "SUCCESS: Robust pattern analysis created"

# Fix 4: Standards Recalibration
echo ""
echo "STATS FIX 4: STANDARDS RECALIBRATION"
echo "================================"

log "Implementing realistic quality standards..."

cat > .ci-quality-standards.json << 'EOF'
{
  "version": "1.0",
  "description": "Recalibrated CI Quality Standards for DevOnboarder",
  "last_updated": "2025-07-23",
  "standards": {
    "excellent": {
      "threshold": 95,
      "description": "Premium quality - suitable for immediate merge",
      "action": "auto_merge_eligible",
      "requirements": "All critical checks passing, documentation complete"
    },
    "good": {
      "threshold": 85,
      "description": "Production ready with minor acceptable issues",
      "action": "manual_review_recommended",
      "requirements": "Core functionality verified, minor issues documented"
    },
    "acceptable": {
      "threshold": 70,
      "description": "Functional but requires targeted improvements",
      "action": "targeted_fixes_required",
      "requirements": "Core features working, style/docs need attention"
    },
    "needs_work": {
      "threshold": 50,
      "description": "Significant issues requiring major fixes",
      "action": "major_fixes_required",
      "requirements": "Core functionality issues, comprehensive fixes needed"
    },
    "failing": {
      "threshold": 0,
      "description": "Critical failures - consider fresh approach",
      "action": "fresh_start_recommended",
      "requirements": "Multiple critical failures, reassess approach"
    }
  },
  "infrastructure_considerations": {
    "expected_ci_reliability": 90,
    "environment_failure_tolerance": 5,
    "recalibration_factor": 0.95,
    "notes": "Standards account for infrastructure reliability limitations"
  },
  "auto_fix_categories": {
    "high_confidence": ["code_formatting", "documentation_style", "linting"],
    "medium_confidence": ["dependency_updates", "simple_test_fixes"],
    "low_confidence": ["logic_errors", "architectural_changes", "security_issues"]
  }
}
EOF

echo "SUCCESS Created recalibrated quality standards"
log "SUCCESS: Quality standards recalibrated"

# Create monitoring script
echo ""
echo "STATS CREATING CI HEALTH MONITORING"
echo "==============================="

cat > scripts/monitor_ci_health.sh << 'EOF'
#!/usr/bin/env bash
# CI Health Monitoring - Track infrastructure reliability post-repair

set -euo pipefail

echo "STATS CI Infrastructure Health Monitor"
echo "=================================="
echo "Post-Repair Monitoring - $(date)"
echo ""

# Monitor recent CI performance
echo "SYMBOL CI Performance Analysis:"

# Get recent workflow runs with error handling
if runs=$(gh run list --limit 20 --json conclusion,status,workflowName,createdAt 2>/dev/null); then
    echo "SUCCESS Retrieved recent CI run data"

    # Calculate success metrics
    total_runs=$(echo "$runs" | jq length)
    successful_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "success")] | length')
    failed_runs=$(echo "$runs" | jq '[.[] | select(.conclusion == "failure")] | length')

    if [ "$total_runs" -gt 0 ]; then
        success_rate=$((successful_runs * 100 / total_runs))
        echo "SYMBOL Success Rate: ${success_rate}% ($successful_runs/$total_runs successful)"

        # Assessment based on recalibrated standards
        if [ "$success_rate" -ge 90 ]; then
            echo "SYMBOL EXCELLENT: CI infrastructure highly reliable"
        elif [ "$success_rate" -ge 75 ]; then
            echo "SUCCESS GOOD: CI infrastructure generally reliable"
        elif [ "$success_rate" -ge 60 ]; then
            echo "WARNING  ACCEPTABLE: CI infrastructure needs attention"
        else
            echo "FAILED POOR: CI infrastructure requires immediate repair"
        fi

        # Show recent runs
        echo ""
        echo "SYMBOL Recent Runs:"
        echo "$runs" | jq -r '.[] | "\(.createdAt[0:19]) \(.workflowName): \(.conclusion // .status)"' | head -10
    else
        echo "WARNING  No recent runs found"
    fi
else
    echo "FAILED Cannot retrieve CI run data - monitoring limited"
fi

# Test infrastructure components
echo ""
echo "TOOLS  Infrastructure Component Health:"

components=("gh" "jq" "git" "node" "python")
healthy_components=0
total_components=${#components[@]}

for component in "${components[@]}"; do
    if command -v "$component" >/dev/null 2>&1; then
        echo "  SUCCESS $component: Available"
        ((healthy_components++))
    else
        echo "  FAILED $component: Missing"
    fi
done

infrastructure_health=$((healthy_components * 100 / total_components))
echo ""
echo "SYMBOL  Infrastructure Health: ${infrastructure_health}% ($healthy_components/$total_components components healthy)"

# Overall assessment
echo ""
echo "SYMBOL OVERALL HEALTH ASSESSMENT:"
if [ "${success_rate:-0}" -ge 85 ] && [ "$infrastructure_health" -ge 80 ]; then
    echo "SYMBOL HEALTHY: Infrastructure repair successful"
elif [ "${success_rate:-0}" -ge 70 ] && [ "$infrastructure_health" -ge 60 ]; then
    echo "SUCCESS STABLE: Infrastructure functional with minor issues"
else
    echo "WARNING  ATTENTION NEEDED: Infrastructure requires continued repair"
fi

echo ""
echo "EDIT Monitor completed - check logs for detailed analysis"
EOF

chmod +x scripts/monitor_ci_health.sh
echo "SUCCESS Created CI health monitoring script"
log "SUCCESS: CI health monitoring created"

# Phase 2 Summary
echo ""
echo "SYMBOL PHASE 2 REPAIR SUMMARY"
echo "========================"

echo "SUCCESS Completed Infrastructure Fixes:"
echo "  1. SYMBOL  Terminal communication wrapper created"
echo "  2. SYMBOL Robust health assessment script implemented"
echo "  3. SYMBOL Enhanced pattern analysis with retry logic"
echo "  4. STATS Recalibrated quality standards (95%→85%→70%→50%)"
echo "  5. STATS CI health monitoring framework deployed"

echo ""
echo "TARGET Infrastructure Repair Status:"
echo "  SUCCESS Terminal communication issues: ADDRESSED"
echo "  SUCCESS Health score calculation: ROBUST VERSION CREATED"
echo "  SUCCESS GitHub CLI reliability: RETRY LOGIC IMPLEMENTED"
echo "  SUCCESS Quality standards: RECALIBRATED FOR REALITY"

echo ""
echo "DEPLOY Next Steps:"
echo "  1. Test robust scripts: bash scripts/assess_pr_health_robust.sh 968"
echo "  2. Monitor CI health: bash scripts/monitor_ci_health.sh"
echo "  3. Validate pattern analysis: bash scripts/analyze_ci_patterns_robust.sh 968"
echo "  4. Proceed to Phase 3 (Standards Validation)"

echo ""
echo "EDIT Full repair log: $REPAIR_LOG"
log "SYMBOL Phase 2 infrastructure fixes complete"
