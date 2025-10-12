#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

# Load tokens using Token Architecture v2.1 with developer guidance
if [ -f "scripts/enhanced_token_loader.sh" ]; then
    # shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
    source scripts/enhanced_token_loader.sh
elif [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback for development
if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

# Check for required tokens with enhanced guidance
if command -v require_tokens >/dev/null 2>&1; then
    if ! require_tokens "STAGING_ORCHESTRATION_BOT_KEY"; then
        error "Cannot proceed without required tokens for staging orchestration"
        echo "💡 Staging orchestration requires API access to orchestration service"
        exit 1
    fi
fi

# Use the enhanced token (fallback to old name for backward compatibility)
ORCHESTRATION_KEY="${STAGING_ORCHESTRATION_BOT_KEY:-${ORCHESTRATION_KEY:-}}"

if [ -z "${ORCHESTRATION_KEY}" ]; then
    error "No orchestration key available"
    echo "💡 Please ensure STAGING_ORCHESTRATION_BOT_KEY is set in your .tokens file"
    exit 1
fi

# Base URL for the orchestration service
ORCHESTRATOR_URL=${ORCHESTRATOR_URL:-https://orchestrator.example.com}

echo "Triggering staging orchestration..."

curl -fsSL -X POST "$ORCHESTRATOR_URL/staging" \
  -H "Authorization: Bearer $ORCHESTRATION_KEY" \
  -d '{}' || echo "Orchestration request failed or skipped."
