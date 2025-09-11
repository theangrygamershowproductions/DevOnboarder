#!/bin/bash
# =============================================================================
# File: scripts/require_tokens.sh
# Purpose: Shell-based token requirement validation
# Description: Provides notification when required tokens are missing
# Author: DevOnboarder Team
# Created: 2025-09-04
# DevOnboarder Standards: Token Architecture v2.0 compliance
# =============================================================================

set -euo pipefail

# Function to check if token exists and is not empty
check_token() {
    local token_name="$1"
    local token_value="${!token_name:-}"

    if [ -z "$token_value" ]; then
        return 1  # Token missing or empty
    else
        return 0  # Token exists and has value
    fi
}

# Function to notify about missing tokens
notify_missing_tokens() {
    local missing_tokens=("$@")
    local ci_env="${CI:-}"

    echo ""
    echo "⚠️  MISSING TOKENS DETECTED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for token in "${missing_tokens[@]}"; do
        echo "❌ $token"
    done

    echo ""
    echo "💡 TO FIX MISSING TOKENS:"

    if [ -n "$ci_env" ]; then
        echo "   CI Environment: Check .tokens.ci file has test values"
        echo "   File: $(pwd)/.tokens.ci"
    else
        echo "   1. Add missing tokens to: $(pwd)/.tokens"
        echo "   2. Run: bash scripts/sync_tokens.sh --sync-all"
        echo "   3. Test: python scripts/token_loader.py validate ${missing_tokens[*]}"
    fi

    echo ""
    echo "📚 For token setup guidance:"
    echo "   See: docs/token-setup-guide.md"
    echo "   Architecture: docs/TOKEN_ARCHITECTURE.md"

    echo ""
    echo "🔍 ENVIRONMENT CHECK:"
    echo "   APP_ENV: ${APP_ENV:-not set}"
    echo "   CI: ${CI:-not set}"
}

# Function to require tokens with notification
require_tokens() {
    local service_name="$1"
    shift
    local required_tokens=("$@")

    echo "🔐 $service_name: Validating required tokens..."

    local missing_tokens=()
    local available_tokens=()

    # Check each required token
    for token in "${required_tokens[@]}"; do
        if check_token "$token"; then
            available_tokens+=("$token")
        else
            missing_tokens+=("$token")
        fi
    done

    # Report results
    if [ ${#missing_tokens[@]} -gt 0 ]; then
        notify_missing_tokens "${missing_tokens[@]}"
        echo ""
        echo "❌ $service_name: CANNOT START - Missing required tokens"
        echo "   Missing: ${missing_tokens[*]}"
        return 1
    else
        echo "✅ $service_name: All required tokens available"
        return 0
    fi
}

# Main function for direct usage
main() {
    if [ $# -lt 2 ]; then
        cat << EOF
DevOnboarder Token Requirement Validation

Usage: $0 <service_name> <token1> [token2] [token3] ...

Examples:
  $0 "AAR Service" AAR_TOKEN CI_ISSUE_AUTOMATION_TOKEN
  $0 "Discord Bot" DISCORD_BOT_TOKEN
  $0 "Backend API" AAR_TOKEN CI_BOT_TOKEN DISCORD_BOT_TOKEN

Exit Codes:
  0 - All required tokens available
  1 - One or more tokens missing

EOF
        exit 1
    fi

    require_tokens "$@"
}

# Allow sourcing this script for the require_tokens function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
