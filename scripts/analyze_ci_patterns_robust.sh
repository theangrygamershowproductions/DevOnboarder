#!/usr/bin/env bash
# Robust CI Pattern Analysis - Fixes GitHub CLI issues

set -euo pipefail

PR_NUMBER="$1"
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pr-number>" >&2
    exit 1
fi

echo "🔬 Robust CI Pattern Analysis #$PR_NUMBER"
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

echo "🔍 Analyzing CI failure patterns..."
FAILING_CHECKS=$(get_failing_checks)

if [ -z "$FAILING_CHECKS" ]; then
    echo "✅ No failing checks detected or unable to retrieve data"
    echo "📊 Pattern Analysis: All checks passing or data unavailable"
    exit 0
fi

echo "❌ Failing Checks Detected:"
while read -r check; do
    [ -n "$check" ] && echo "  - $check"
done <<< "$FAILING_CHECKS"

echo ""
echo "🔍 Pattern Analysis:"

# Enhanced pattern detection with categories
PATTERNS=()

# Test failures
if echo "$FAILING_CHECKS" | grep -qi "test\|spec\|pytest\|jest\|mocha\|unit\|integration"; then
    PATTERNS+=("TESTING")
    echo "  🧪 TESTING FAILURES: Unit/integration test issues detected"
fi

# Code quality failures
if echo "$FAILING_CHECKS" | grep -qi "lint\|format\|style\|quality\|eslint\|prettier\|black\|ruff"; then
    PATTERNS+=("CODE_QUALITY")
    echo "  📝 CODE QUALITY: Linting/formatting issues detected"
fi

# Security failures
if echo "$FAILING_CHECKS" | grep -qi "security\|audit\|vulnerability\|snyk\|safety"; then
    PATTERNS+=("SECURITY")
    echo "  🔒 SECURITY ISSUES: Security scan failures detected"
fi

# Build failures
if echo "$FAILING_CHECKS" | grep -qi "build\|compile\|webpack\|rollup\|tsc\|make"; then
    PATTERNS+=("BUILD")
    echo "  🏗️ BUILD FAILURES: Compilation/build issues detected"
fi

# Documentation failures
if echo "$FAILING_CHECKS" | grep -qi "docs\|documentation\|markdown\|readme"; then
    PATTERNS+=("DOCUMENTATION")
    echo "  📚 DOCUMENTATION: Documentation quality issues detected"
fi

# Infrastructure failures
if echo "$FAILING_CHECKS" | grep -qi "deploy\|infrastructure\|terraform\|ansible"; then
    PATTERNS+=("INFRASTRUCTURE")
    echo "  🏗️ INFRASTRUCTURE: Deployment/infrastructure issues detected"
fi

# Generic check failures
if echo "$FAILING_CHECKS" | grep -qi "^check\|validate\|verify"; then
    PATTERNS+=("VALIDATION")
    echo "  ✅ VALIDATION: General validation failures detected"
fi

# Unknown patterns
if [ ${#PATTERNS[@]} -eq 0 ]; then
    PATTERNS+=("UNKNOWN")
    echo "  ❓ UNKNOWN PATTERNS: Unrecognized failure types"
fi

echo ""
echo "🎯 Automated Fix Recommendations:"

for pattern in "${PATTERNS[@]}"; do
    case $pattern in
        "TESTING")
            echo "  🧪 TESTING: Review test logs, fix failing assertions, verify test data"
            ;;
        "CODE_QUALITY")
            echo "  📝 CODE_QUALITY: Run formatters (black, prettier), fix linting errors"
            ;;
        "SECURITY")
            echo "  🔒 SECURITY: Update dependencies, patch vulnerabilities, review security policies"
            ;;
        "BUILD")
            echo "  🏗️ BUILD: Check dependencies, fix compilation errors, verify configurations"
            ;;
        "DOCUMENTATION")
            echo "  📚 DOCUMENTATION: Fix markdown errors, update docs, validate links"
            ;;
        "INFRASTRUCTURE")
            echo "  🏗️ INFRASTRUCTURE: Verify deployment configs, check environment variables"
            ;;
        "VALIDATION")
            echo "  ✅ VALIDATION: Check workflow permissions, verify environment setup"
            ;;
        "UNKNOWN")
            echo "  ❓ UNKNOWN: Manual investigation required, check individual CI logs"
            ;;
    esac
done

echo ""
echo "🤖 Auto-fix Potential Assessment:"
if [[ " ${PATTERNS[*]} " =~ " CODE_QUALITY " ]] || [[ " ${PATTERNS[*]} " =~ " DOCUMENTATION " ]]; then
    echo "  🟢 HIGH: Code quality and documentation issues are auto-fixable"
elif [[ " ${PATTERNS[*]} " =~ " TESTING " ]] && [[ " ${PATTERNS[*]} " =~ " BUILD " ]]; then
    echo "  🟡 MEDIUM: Mixed issues - some auto-fixable, some require manual intervention"
else
    echo "  🔴 LOW: Manual intervention likely required for most issues"
fi

echo ""
echo "✅ Pattern analysis complete"
