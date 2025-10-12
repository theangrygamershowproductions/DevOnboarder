#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Discord Bot Configuration Validation Script
set -euo pipefail

echo "🔍 Discord Bot Configuration Validation"
echo "======================================="

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to validate token format
validate_token() {
    local token="$1"
    local name="$2"

    if [[ -z "$token" || "$token" == "YOUR_BOT_TOKEN_HERE" ]]; then
        error_msg " $name: Token not set"
        return 1
    elif [[ ${#token} -lt 50 ]]; then
        error_msg " $name: Token too short (${#token} chars)"
        return 1
    elif [[ ! "$token" =~ ^[A-Za-z0-9._-]+$ ]]; then
        error_msg " $name: Invalid token format"
        return 1
    else
        success_msg " $name: Token format valid (${#token} chars)"
        return 0
    fi
}

# Function to validate client ID
validate_client_id() {
    local client_id="$1"
    local name="$2"

    if [[ -z "$client_id" || "$client_id" == "YOUR_CLIENT_ID_HERE" ]]; then
        error_msg " $name: Client ID not set"
        return 1
    elif [[ ! "$client_id" =~ ^[0-9]{17,19}$ ]]; then
        error_msg " $name: Invalid client ID format"
        return 1
    else
        success_msg " $name: Client ID valid"
        return 0
    fi
}

# Function to validate guild ID
validate_guild_id() {
    local guild_id="$1"
    local name="$2"

    if [[ -z "$guild_id" ]]; then
        error_msg " $name: Guild ID not set"
        return 1
    elif [[ ! "$guild_id" =~ ^[0-9]{17,19}$ ]]; then
        error_msg " $name: Invalid guild ID format"
        return 1
    else
        success_msg " $name: Guild ID valid"
        return 0
    fi
}

# Check main .env file
echo -e "\n📄 Main Environment File (.env)"
echo "================================"

if [[ -f ".env" ]]; then
    # shellcheck source=/dev/null
    source .env 2>/dev/null || debug_msg "  Some variables may not be loadable"

    validate_token "${DISCORD_BOT_TOKEN:-}" "Main Bot Token"
    validate_client_id "${DISCORD_CLIENT_ID:-}" "Main Client ID"
    validate_guild_id "${DISCORD_DEV_GUILD_ID:-}" "Development Guild ID"
    validate_guild_id "${DISCORD_PROD_GUILD_ID:-}" "Production Guild ID"

    success_msg " Main .env file exists"
else
    error_msg " Main .env file not found"
fi

# Check bot .env file
echo -e "\nBOT: Bot Environment File (bot/.env)"
echo "=================================="

if [[ -f "bot/.env" ]]; then
    # shellcheck source=/dev/null
    source bot/.env 2>/dev/null || debug_msg "  Some variables may not be loadable"

    validate_token "${DISCORD_BOT_TOKEN:-}" "Bot Token"
    validate_client_id "${DISCORD_CLIENT_ID:-}" "Bot Client ID"
    validate_guild_id "${DISCORD_GUILD_ID:-}" "Bot Guild ID"

    success_msg " Bot .env file exists"
else
    error_msg " Bot .env file not found"
fi

# Check bot .env.dev file
echo -e "\nTOOL: Bot Development Environment File (bot/.env.dev)"
echo "================================================="

if [[ -f "bot/.env.dev" ]]; then
    # Temporarily load .env.dev
    ENV_DEV_TOKEN=$(grep "DISCORD_BOT_TOKEN=" bot/.env.dev | cut -d'=' -f2 2>/dev/null || echo "")
    ENV_DEV_CLIENT_ID=$(grep "DISCORD_CLIENT_ID=" bot/.env.dev | cut -d'=' -f2 2>/dev/null || echo "")
    ENV_DEV_GUILD_ID=$(grep "DISCORD_GUILD_ID=" bot/.env.dev | cut -d'=' -f2 2>/dev/null || echo "")

    validate_token "$ENV_DEV_TOKEN" "Dev Bot Token"
    validate_client_id "$ENV_DEV_CLIENT_ID" "Dev Client ID"
    validate_guild_id "$ENV_DEV_GUILD_ID" "Dev Guild ID"

    success_msg " Bot .env.dev file exists"
else
    error_msg " Bot .env.dev file not found"
fi

# Cross-reference validation
echo -e "\nSYNC: Cross-Reference Validation"
echo "============================="

# Compare main .env with bot/.env
MAIN_TOKEN=$(grep "DISCORD_BOT_TOKEN=" .env | cut -d'=' -f2 2>/dev/null || echo "")
BOT_TOKEN=$(grep "DISCORD_BOT_TOKEN=" bot/.env | cut -d'=' -f2 2>/dev/null || echo "")

if [[ "$MAIN_TOKEN" == "$BOT_TOKEN" ]]; then
    success_msg " Main and Bot tokens match"
else
    debug_msg "  Main and Bot tokens differ"
fi

# Compare main .env with bot/.env.dev
if [[ "$MAIN_TOKEN" == "$ENV_DEV_TOKEN" ]]; then
    success_msg " Main and Dev tokens match"
else
    debug_msg "  Main and Dev tokens differ"
fi

# Server mapping validation
echo -e "\n🏠 Server Mapping Validation"
echo "============================"

echo "Development Server (TAGS: DevOnboarder): 1386935663139749998"
echo "Production Server (TAGS: C2C): 1065367728992571444"

MAIN_DEV_GUILD=$(grep "DISCORD_DEV_GUILD_ID=" .env | cut -d'=' -f2 2>/dev/null || echo "")
MAIN_PROD_GUILD=$(grep "DISCORD_PROD_GUILD_ID=" .env | cut -d'=' -f2 2>/dev/null || echo "")

if [[ "$MAIN_DEV_GUILD" == "1386935663139749998" ]]; then
    success_msg " Development guild ID correctly configured"
else
    debug_msg "  Development guild ID: $MAIN_DEV_GUILD"
fi

if [[ "$MAIN_PROD_GUILD" == "1065367728992571444" ]]; then
    success_msg " Production guild ID correctly configured"
else
    debug_msg "  Production guild ID: $MAIN_PROD_GUILD"
fi

# Test bot invite generation
echo -e "\n🔗 Bot Invite Link Test"
echo "======================="

if command -v node &> /dev/null && [[ -f "bot/scripts/generate-invite.js" ]]; then
    echo "Testing invite link generation..."
    cd bot
    if node scripts/generate-invite.js > /dev/null 2>&1; then
        success_msg " Bot invite link generation successful"
    else
        error_msg " Bot invite link generation failed"
    fi
    cd ..
else
    debug_msg "  Cannot test invite generation (Node.js or script not found)"
fi

echo -e "\nTARGET: Summary"
echo "=========="
echo "Configuration validation complete!"
echo ""
echo "Next steps:"
echo "1. Use the invite link to add the bot to Discord servers"
echo "2. Test bot connection: cd bot && npm run dev"
echo "3. Verify bot responds in Discord channels"
