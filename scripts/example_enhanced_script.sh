#!/bin/bash
# Example Script Using Enhanced Token Loading Pattern
# Demonstrates superior developer experience with Option 1

set -euo pipefail

# Load enhanced token environment with developer guidance
# shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
source scripts/enhanced_token_loader.sh

echo "Example Script: PR Tracking Issue Creation"
echo "=============================================="
echo

# Check for required tokens with clear guidance
if ! require_tokens "CI_ISSUE_AUTOMATION_TOKEN" "CI_BOT_TOKEN"; then
    echo "Cannot proceed without required tokens"
    echo "Please add the missing tokens and re-run this script"
    exit 1
fi

# Script continues with tokens available
echo "All required tokens available"
echo "CI_ISSUE_AUTOMATION_TOKEN: Available (length: ${#CI_ISSUE_AUTOMATION_TOKEN})"
echo "CI_BOT_TOKEN: Available (length: ${#CI_BOT_TOKEN})"
echo
echo "Script would continue with PR creation logic..."
