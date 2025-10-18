#!/bin/bash

# display_ci_health_bot_credentials.sh
# DevOnboarder CI Health Framework Bot - User-Friendly Configuration Guide
# Part of DevOnboarder's framework-based bot architecture POC

set -euo pipefail

# Color output functions (DevOnboarder standard pattern)
red() { printf "\033[31m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
blue() { printf "\033[34m%s\033[0m\n" "$1"; }
cyan() { printf "\033[36m%s\033[0m" "$1"; }
bold() { printf "\033[1m%s\033[0m" "$1"; }

# Bot configuration
BOT_EMAIL="ci-health@theangrygamershow.com"

blue "=== CI Health Framework Bot - Configuration Guide ==="
echo ""

# Validate we're in the DevOnboarder project root
if [[ ! -f "pyproject.toml" ]] || ! grep -q "devonboarder" pyproject.toml 2>/dev/null; then
    red " Must be run from DevOnboarder project root"
    exit 1
fi

# Check if key files exist
if [[ ! -f "ci-health-bot-public.gpg" ]] || [[ ! -f "ci-health-bot-private-base64.txt" ]]; then
    red " CI Health Bot key files not found"
    echo "Run $(cyan "scripts/setup_ci_health_bot_gpg_key.sh") first"
    exit 1
fi

# Get the key ID
KEY_ID=$(gpg --list-keys --with-colons "$BOT_EMAIL" | awk -F: '/^pub/ {print $5}' | head -1)

if [[ -z "$KEY_ID" ]]; then
    red " Could not retrieve CI Health Bot key ID"
    exit 1
fi

# File size info for user confidence
PUBLIC_SIZE=$(wc -c < ci-health-bot-public.gpg)
PRIVATE_SIZE=$(wc -c < ci-health-bot-private-base64.txt)

# Summary section
yellow "CREDENTIALS READY FOR GITHUB SETUP:"
echo ""
echo "  $(bold "Bot Name:") CI Health Framework Bot"
echo "  $(bold "Email:") $BOT_EMAIL"
echo "  $(bold "Key ID:") $(cyan "$KEY_ID")"
echo "  $(bold "Purpose:") CI Health monitoring automation"
echo ""
green "Files Ready for Upload:"
echo "  $(cyan "ci-health-bot-public.gpg") ($PUBLIC_SIZE bytes) - Upload to GitHub account"
echo "  $(cyan "ci-health-bot-private-base64.txt") ($PRIVATE_SIZE bytes) - Add as repository secret"
echo ""

blue "=== GITHUB CONFIGURATION STEPS ==="
echo ""

yellow "1. Add Public Key to GitHub Account"
echo ""
echo "   Open: $(cyan "https://github.com/settings/keys")"
echo "   Click: $(green "New GPG key")"
echo "   Title: $(cyan "CI Health Framework Bot")"
echo "   Key: Copy entire contents of $(cyan "ci-health-bot-public.gpg")"
echo ""
echo "   $(bold "Quick copy command:")"
echo "   $(cyan "cat ci-health-bot-public.gpg | pbcopy")  # macOS"
echo "   $(cyan "cat ci-health-bot-public.gpg | xclip -selection clipboard")  # Linux"
echo ""

yellow "2. Add Repository Secret"
echo ""
echo "   Open: $(cyan "https://github.com/theangrygamershowproductions/DevOnboarder/settings/secrets/actions")"
echo "   Click: $(green "New repository secret")"
echo "   Name: $(cyan "CI_HEALTH_BOT_GPG_PRIVATE")"
echo "   Value: Copy entire contents of $(cyan "ci-health-bot-private-base64.txt")"
echo ""
echo "   $(bold "Quick copy command:")"
echo "   $(cyan "cat ci-health-bot-private-base64.txt | pbcopy")  # macOS"
echo "   $(cyan "cat ci-health-bot-private-base64.txt | xclip -selection clipboard")  # Linux"
echo ""

yellow "3. Add Repository Variables"
echo ""
echo "   Open: $(cyan "https://github.com/theangrygamershowproductions/DevOnboarder/settings/variables/actions")"
echo "   Add these three variables:"
echo ""
printf "   %s = %s\n" "$(cyan "CI_HEALTH_BOT_GPG_KEY_ID")" "$KEY_ID"
echo "   $(cyan "CI_HEALTH_BOT_NAME") = CI Health Framework Bot"
printf "   %s = %s\n" "$(cyan "CI_HEALTH_BOT_EMAIL")" "$BOT_EMAIL"
echo ""

yellow "4. Security Cleanup (After GitHub Upload)"
echo ""
echo "   $(red "Delete private key files:")"
echo "   $(red "rm ci-health-bot-private.gpg")"
echo "   $(red "rm ci-health-bot-private-base64.txt")"
echo ""
echo "   $(green "Keep for reference:")"
echo "   $(green "ci-health-bot-public.gpg")"
echo ""

blue "=== VERIFICATION ==="
echo ""
echo "Test GPG key locally:"
printf "  %s\n" "$(cyan "echo 'test signing' | gpg --clearsign --default-key $BOT_EMAIL")"
echo ""
echo "After GitHub setup, the CI Health Framework Bot will:"
echo "  - Sign commits with GPG for cryptographic verification"
printf "  - Use %s for clear attribution\n" "$(cyan "$BOT_EMAIL")"
echo "  - Operate independently from other framework bots"
echo "  - Demonstrate corporate governance compliance"
echo ""

green "Next: Create test workflow and validate POC implementation!"
