#!/bin/bash
# Token Architecture v2.1 - Complete Health Check
# Tests all tokens for availability and basic functionality

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
# shellcheck disable=SC1091
source .venv/bin/activate

# Load Token Architecture v2.1
# shellcheck disable=SC1091
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Checking: Token Architecture v2.1 - Complete Health Check"
echo "=================================================="
echo ""

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
PROPAGATION_DELAYS=0

# Simple token test function
test_token_exists() {
    local token_name="$1"
    # shellcheck disable=SC2034
    local description="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    local token_value="${!token_name:-}"
    if [ -n "$token_value" ]; then
        echo "   Status: Available"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "   Status: Error: MISSING"
    fi
    echo ""
}

# Test GitHub API functionality
test_github_api() {
    local token_name="$1"
    local endpoint="$2"
    # shellcheck disable=SC2034
    local description="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    printf "Value: %s\n" "$"
    printf "Value: %s\n" "$"

    local token_value="${!token_name:-}"
    if [ -z "$token_value" ]; then
        echo "   Status: Error: TOKEN NOT FOUND"
        echo ""
        return 1
    fi

    # Test API endpoint
    # shellcheck disable=SC2034
    result=$(GH_TOKEN="$token_value" gh api "$endpoint" 2>&1)

    if GH_TOKEN="$token_value" gh api "$endpoint" > /dev/null 2>&1; then
        echo "   Status: Success: API WORKING"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        if printf "Value: %s\n" "$"; then
            echo "   Status: ⏳ PROPAGATION DELAY"
            PROPAGATION_DELAYS=$((PROPAGATION_DELAYS + 1))
        else
            echo "   Status: Error: API FAILED"
        fi
    fi
    echo ""
}

echo "List: Part 1: Token Availability Check"
echo "===================================="

# Test all expected tokens
test_token_exists "AAR_TOKEN" "After Action Report generation"
test_token_exists "CI_ISSUE_AUTOMATION_TOKEN" "CI issue automation"
test_token_exists "CI_BOT_TOKEN" "CI bot operations"
test_token_exists "DISCORD_BOT_TOKEN" "Discord bot authentication"
test_token_exists "GITHUB_TOKEN" "General GitHub operations"
test_token_exists "DATABASE_URL" "Database connection"
test_token_exists "JWT_SECRET" "JWT token signing"

# Check for additional environment tokens
for var in WEBHOOK_SECRET API_KEY ENCRYPTION_KEY TUNNEL_TOKEN; do
    if [ -n "${!var:-}" ]; then
        test_token_exists "$var" "Additional service token"
    fi
done

echo "List: Part 2: GitHub API Functionality Tests"
echo "=========================================="

# Test GitHub tokens with API calls
if [ -n "${AAR_TOKEN:-}" ]; then
    test_github_api "AAR_TOKEN" "repos/theangrygamershowproductions/DevOnboarder/actions" "Actions API access"
fi

if [ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]; then
    test_github_api "CI_ISSUE_AUTOMATION_TOKEN" "repos/theangrygamershowproductions/DevOnboarder/issues" "Issues API access"
fi

if [ -n "${CI_BOT_TOKEN:-}" ]; then
    test_github_api "CI_BOT_TOKEN" "user" "User API access"
fi

if [ -n "${GITHUB_TOKEN:-}" ]; then
    test_github_api "GITHUB_TOKEN" "user" "General GitHub access"
fi

echo "Health Check Results Summary"
echo "============================"
printf "Total Tests: %d\n" "$TOTAL_TESTS"
printf "Passed: %d\n" "$PASSED_TESTS"
printf "Propagation Delays: %d\n" "$PROPAGATION_DELAYS"
printf "Failed: %d\n" "$((TOTAL_TESTS - PASSED_TESTS - PROPAGATION_DELAYS))"
echo ""

# Calculate health score
HEALTH_SCORE=$(((PASSED_TESTS * 100) / TOTAL_TESTS))
printf "Token Health Score: %d%%\n" "$HEALTH_SCORE"

if [ $PROPAGATION_DELAYS -gt 0 ]; then
    printf "Note: %d token(s) experiencing GitHub API propagation delays\n" "$PROPAGATION_DELAYS"
    echo "   This is normal for recently updated Fine-Grained tokens"
    echo "   Wait 2-5 minutes and re-run this check"
fi

echo ""
if [ $HEALTH_SCORE -ge 80 ]; then
    echo "Overall Status: HEALTHY"
    echo "Token Architecture v2.1 is working well!"
else
    echo "Overall Status: NEEDS ATTENTION"
    echo "Multiple token issues require investigation"
fi
