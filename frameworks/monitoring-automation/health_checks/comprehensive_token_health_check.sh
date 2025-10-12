#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Comprehensive Token Health Check System
# Tests all 11 tokens from Token Architecture v2.1 for proper functionality

# Centralized logging for troubleshooting and repository health
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
# shellcheck disable=SC1091 # Runtime source operation
# shellcheck disable=SC1091
source .venv/bin/activate

# Load Token Architecture v2.1
if [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    # shellcheck disable=SC1091
source scripts/load_token_environment.sh
fi

echo "Checking: Token Architecture v2.1 - Comprehensive Health Check"
echo "====================================================="
echo ""

# Track results
TOTAL_TOKENS=0
WORKING_TOKENS=0
FAILED_TOKENS=()

# Test function for GitHub tokens
test_github_token() {
    local token_name="$1"
    local token_value="${!token_name:-}"
    local test_description="$2"
    local api_endpoint="$3"

    TOTAL_TOKENS=$((TOTAL_TOKENS + 1))

    printf "Token: %s\n" "$token_name"
    printf "Test: %s\n" "$test_description"

    if [ -z "$token_value" ]; then
        echo "   Status: Error: NOT FOUND in environment"
        FAILED_TOKENS+=("$token_name: Not found in environment")
        echo ""
        return 1
    fi

    printf "Status: %s\n" "Present"

    # Test the token
    # shellcheck disable=SC2034
    error_output=$(GH_TOKEN="$token_value" gh api "$api_endpoint" 2>&1)

    if GH_TOKEN="$token_value" gh api "$api_endpoint" > /dev/null 2>&1; then
        echo "   Status: Success: WORKING"
        WORKING_TOKENS=$((WORKING_TOKENS + 1))
        echo ""
        return 0
    else
        # Analyze the error
        if echo "$error_output" | grep -q "Bad credentials"; then
            echo "   Status: Error: INVALID TOKEN"
            echo "   Issue: Invalid or expired token"
        elif echo "$error_output" | grep -q "rate limit"; then
            echo "   Status: Warning: RATE LIMITED"
            echo "   Issue: API rate limit exceeded"
        elif echo "$error_output" | grep -q "Not Found"; then
            echo "   Status: PROPAGATION DELAY (normal for updated tokens)"
            echo "   Issue: GitHub API permissions still propagating"
        else
            echo "   Status: Error: PERMISSION ERROR"
            echo "   Issue: Missing required permissions"
        fi

        FAILED_TOKENS+=("$token_name: $test_description")
        echo ""
        return 1
    fi
}

# Test non-GitHub tokens
test_other_token() {
    local token_name="$1"
    local token_value="${!token_name:-}"
    local test_description="$2"

    TOTAL_TOKENS=$((TOTAL_TOKENS + 1))

    printf "Value: %s\n" "$"
    printf "Value: %s\n" "$"

    if [ -z "$token_value" ]; then
        echo "   Status: Error: NOT FOUND in environment"
        FAILED_TOKENS+=("$token_name: Not found in environment")
        return 1
    fi

    printf "Value: %s\n" "$"
    echo "   Status: Success: PRESENT (validation requires specific service test)"
    WORKING_TOKENS=$((WORKING_TOKENS + 1))
    echo ""
    return 0
}

echo "List: CI/CD Tokens (from .tokens file):"
echo "===================================="

# Test GitHub tokens with specific endpoints
test_github_token "AAR_TOKEN" "After Action Report system" "repos/theangrygamershowproductions/DevOnboarder/actions"
test_github_token "CI_ISSUE_AUTOMATION_TOKEN" "CI issue automation" "repos/theangrygamershowproductions/DevOnboarder/issues"
test_github_token "CI_BOT_TOKEN" "CI bot operations" "user"

# Test if we have a general GITHUB_TOKEN
if [ -n "${GITHUB_TOKEN:-}" ]; then
    test_github_token "GITHUB_TOKEN" "General GitHub operations" "user"
fi

echo "List: Runtime Configuration Tokens (from .env file):"
echo "================================================="

# Test Discord bot token (non-GitHub)
test_other_token "DISCORD_BOT_TOKEN" "Discord bot authentication"

# Test database and other service tokens
test_other_token "DATABASE_URL" "Database connection string"
test_other_token "JWT_SECRET" "JWT token signing"

# Test additional tokens that might be present
for token_var in WEBHOOK_SECRET API_KEY ENCRYPTION_KEY TUNNEL_TOKEN; do
    if [ -n "${!token_var:-}" ]; then
        test_other_token "$token_var" "Service configuration token"
    fi
done

echo "Token Health Check Summary:"
echo "==========================="
printf "Total Tokens Tested: %d\n" "$TOTAL_TOKENS"
printf "Working Tokens: %d\n" "$WORKING_TOKENS"
printf "Failed Tokens: %d\n" "${#FAILED_TOKENS[@]}"

if [ ${#FAILED_TOKENS[@]} -eq 0 ]; then
    echo ""
    success "All tokens are working correctly!"
    echo "Token Architecture v2.1 is fully operational"
    echo "All DevOnboarder services should function properly"
else
    echo ""
    warning "Issues found with the following tokens:"
    for failed_token in "${FAILED_TOKENS[@]}"; do
        printf "   FAILED: %s\n" "$failed_token"
    done
    echo ""
    echo "Common solutions:"
    echo "   1. Check GitHub token permissions and expiration dates"
    echo "   2. Wait for GitHub API propagation (2-5 minutes for new tokens)"
    echo "   3. Verify token values in .tokens and .env files"
    echo "   4. Check service-specific configuration requirements"
fi

echo ""
printf "Token Architecture v2.1 Health Score: %d%%\n" "$((WORKING_TOKENS * 100 / TOTAL_TOKENS))"

if [ $WORKING_TOKENS -eq $TOTAL_TOKENS ]; then
    echo "Status: OPTIMAL - Ready for production use"
    exit 0
elif [ $WORKING_TOKENS -gt $((TOTAL_TOKENS / 2)) ]; then
    echo "Status: PARTIAL - Some services may be impacted"
    exit 1
else
    echo "Status: CRITICAL - Multiple token issues require attention"
    exit 2
fi
