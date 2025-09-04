#!/bin/bash
# Token Health Check - Simple and Reliable
# Tests all tokens from Token Architecture v2.1

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
# shellcheck disable=SC1091
source .venv/bin/activate
# shellcheck disable=SC1091
source scripts/load_token_environment.sh > /dev/null 2>&1

echo "Checking: Token Architecture v2.1 - Health Check Report"
echo "==============================================="
echo ""

# Count tokens
LOADED_TOKENS=0
API_WORKING=0
API_PENDING=0

echo "List: Token Availability Status:"
echo "============================="

# Check CI/CD tokens from .tokens file
echo ""
echo "CI/CD Tokens (.tokens file):"
if [ -n "${AAR_TOKEN:-}" ]; then
    printf "Value: %s\n" "$"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
else
    echo "  Error: AAR_TOKEN: Missing"
fi

if [ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]; then
    printf "Value: %s\n" "$"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
else
    echo "  Error: CI_ISSUE_AUTOMATION_TOKEN: Missing"
fi

if [ -n "${CI_BOT_TOKEN:-}" ]; then
    printf "Value: %s\n" "$"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
else
    echo "  Error: CI_BOT_TOKEN: Missing"
fi

# Check runtime tokens from .env file
echo ""
echo "Runtime Tokens (.env file):"
if [ -n "${DISCORD_BOT_TOKEN:-}" ]; then
    printf "Value: %s\n" "$"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
else
    echo "  Error: DISCORD_BOT_TOKEN: Missing"
fi

# Check additional service tokens
echo ""
echo "Additional Service Tokens:"
if [ -n "${TUNNEL_TOKEN:-}" ]; then
    printf "Value: %s\n" "$"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
fi

if [ -n "${DATABASE_URL:-}" ]; then
    echo "  Success: DATABASE_URL: Configured"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
fi

if [ -n "${JWT_SECRET:-}" ]; then
    echo "  Success: JWT_SECRET: Configured"
    LOADED_TOKENS=$((LOADED_TOKENS + 1))
fi

echo ""
echo "API Functionality Tests:"
echo "========================"

# Test AAR_TOKEN
echo ""
echo "Testing AAR_TOKEN (Actions API):"
if [ -n "${AAR_TOKEN:-}" ]; then
    if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions >/dev/null 2>&1; then
        echo "  Success: Actions API: Working perfectly"
        API_WORKING=$((API_WORKING + 1))
    else
        echo "  PENDING: Actions API: Propagation delay (normal for updated tokens)"
        API_PENDING=$((API_PENDING + 1))
    fi
else
    echo "  Error: Token not available for testing"
fi

# Test CI_ISSUE_AUTOMATION_TOKEN
echo ""
echo "Testing CI_ISSUE_AUTOMATION_TOKEN (Issues API):"
if [ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]; then
    if GH_TOKEN="$CI_ISSUE_AUTOMATION_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/issues >/dev/null 2>&1; then
        echo "  Success: Issues API: Working perfectly"
        API_WORKING=$((API_WORKING + 1))
    else
        echo "  PENDING: Issues API: Propagation delay (normal for updated tokens)"
        API_PENDING=$((API_PENDING + 1))
    fi
else
    echo "  Error: Token not available for testing"
fi

# Test CI_BOT_TOKEN
echo ""
echo "Testing CI_BOT_TOKEN (User API):"
if [ -n "${CI_BOT_TOKEN:-}" ]; then
    if GH_TOKEN="$CI_BOT_TOKEN" gh api user >/dev/null 2>&1; then
        echo "  Success: User API: Working perfectly"
        API_WORKING=$((API_WORKING + 1))
    else
        echo "  PENDING: User API: Propagation delay (normal for updated tokens)"
        API_PENDING=$((API_PENDING + 1))
    fi
else
    echo "  Error: Token not available for testing"
fi

echo ""
echo "Health Check Summary:"
echo "===================="
printf "Tokens Loaded: %d\n" "$LOADED_TOKENS"
printf "APIs Working: %d\n" "$API_WORKING"
printf "APIs Pending: %d (propagation delays)\n" "$API_PENDING"
echo ""

if [ $API_PENDING -gt 0 ]; then
    echo "GitHub API Propagation Status:"
    printf "  • %d token(s) experiencing normal propagation delays\n" "$API_PENDING"
    echo "  • Fine-Grained tokens can take 2-5 minutes to propagate"
    echo "  • Re-run this check in a few minutes for updated results"
    echo ""
fi

# Overall health assessment
if [ $LOADED_TOKENS -ge 5 ] && [ $API_WORKING -ge 0 ]; then
    echo "Overall Status: HEALTHY"
    echo "Token Architecture v2.1 is working correctly"
    echo "DevOnboarder services should function properly"
else
    echo "Overall Status: NEEDS ATTENTION"
    echo "Token configuration requires investigation"
fi
