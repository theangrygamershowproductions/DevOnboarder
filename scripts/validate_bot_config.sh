#!/usr/bin/env bash
# Discord Bot Configuration Validation Script
set -euo pipefail

echo "SEARCH Discord Bot Configuration Validation"
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
        echo -e "${RED}FAILED $name: Token not set${NC}"
        return 1
    elif [[ ${#token} -lt 50 ]]; then
        echo -e "${RED}FAILED $name: Token too short (${#token} chars)${NC}"
        return 1
    elif [[ ! "$token" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo -e "${RED}FAILED $name: Invalid token format${NC}"
        return 1
    else
        echo -e "${GREEN}SUCCESS $name: Token format valid (${#token} chars)${NC}"
        return 0
    fi
}

# Function to validate client ID
validate_client_id() {
    local client_id="$1"
    local name="$2"

    if [[ -z "$client_id" || "$client_id" == "YOUR_CLIENT_ID_HERE" ]]; then
        echo -e "${RED}FAILED $name: Client ID not set${NC}"
        return 1
    elif [[ ! "$client_id" =~ ^[0-9]{17,19}$ ]]; then
        echo -e "${RED}FAILED $name: Invalid client ID format${NC}"
        return 1
    else
        echo -e "${GREEN}SUCCESS $name: Client ID valid${NC}"
        return 0
    fi
}

# Function to validate guild ID
validate_guild_id() {
    local guild_id="$1"
    local name="$2"

    if [[ -z "$guild_id" ]]; then
        echo -e "${RED}FAILED $name: Guild ID not set${NC}"
        return 1
    elif [[ ! "$guild_id" =~ ^[0-9]{17,19}$ ]]; then
        echo -e "${RED}FAILED $name: Invalid guild ID format${NC}"
        return 1
    else
        echo -e "${GREEN}SUCCESS $name: Guild ID valid${NC}"
        return 0
    fi
}

# Check main .env file
echo -e "\nFILE Main Environment File (.env)"
echo "================================"

if [[ -f ".env" ]]; then
    # shellcheck source=/dev/null
    source .env 2>/dev/null || echo -e "${YELLOW}WARNING  Some variables may not be loadable${NC}"

    validate_token "${DISCORD_BOT_TOKEN:-}" "Main Bot Token"
    validate_client_id "${DISCORD_CLIENT_ID:-}" "Main Client ID"
    validate_guild_id "${DISCORD_DEV_GUILD_ID:-}" "Development Guild ID"
    validate_guild_id "${DISCORD_PROD_GUILD_ID:-}" "Production Guild ID"

    echo -e "${GREEN}SUCCESS Main .env file exists${NC}"
else
    echo -e "${RED}FAILED Main .env file not found${NC}"
fi

# Check bot .env file
echo -e "\nBot Bot Environment File (bot/.env)"
echo "=================================="

if [[ -f "bot/.env" ]]; then
    # shellcheck source=/dev/null
    source bot/.env 2>/dev/null || echo -e "${YELLOW}WARNING  Some variables may not be loadable${NC}"

    validate_token "${DISCORD_BOT_TOKEN:-}" "Bot Token"
    validate_client_id "${DISCORD_CLIENT_ID:-}" "Bot Client ID"
    validate_guild_id "${DISCORD_GUILD_ID:-}" "Bot Guild ID"

    echo -e "${GREEN}SUCCESS Bot .env file exists${NC}"
else
    echo -e "${RED}FAILED Bot .env file not found${NC}"
fi

# Check bot .env.dev file
echo -e "\nCONFIG Bot Development Environment File (bot/.env.dev)"
echo "================================================="

if [[ -f "bot/.env.dev" ]]; then
    # Temporarily load .env.dev
    ENV_DEV_TOKEN=$(grep "DISCORD_BOT_TOKEN=" bot/.env.dev | cut -d'=' -f2 2>/dev/null || echo "")
    ENV_DEV_CLIENT_ID=$(grep "DISCORD_CLIENT_ID=" bot/.env.dev | cut -d'=' -f2 2>/dev/null || echo "")
    ENV_DEV_GUILD_ID=$(grep "DISCORD_GUILD_ID=" bot/.env.dev | cut -d'=' -f2 2>/dev/null || echo "")

    validate_token "$ENV_DEV_TOKEN" "Dev Bot Token"
    validate_client_id "$ENV_DEV_CLIENT_ID" "Dev Client ID"
    validate_guild_id "$ENV_DEV_GUILD_ID" "Dev Guild ID"

    echo -e "${GREEN}SUCCESS Bot .env.dev file exists${NC}"
else
    echo -e "${RED}FAILED Bot .env.dev file not found${NC}"
fi

# Cross-reference validation
echo -e "\nSYMBOL Cross-Reference Validation"
echo "============================="

# Compare main .env with bot/.env
MAIN_TOKEN=$(grep "DISCORD_BOT_TOKEN=" .env | cut -d'=' -f2 2>/dev/null || echo "")
BOT_TOKEN=$(grep "DISCORD_BOT_TOKEN=" bot/.env | cut -d'=' -f2 2>/dev/null || echo "")

if [[ "$MAIN_TOKEN" == "$BOT_TOKEN" ]]; then
    echo -e "${GREEN}SUCCESS Main and Bot tokens match${NC}"
else
    echo -e "${YELLOW}WARNING  Main and Bot tokens differ${NC}"
fi

# Compare main .env with bot/.env.dev
if [[ "$MAIN_TOKEN" == "$ENV_DEV_TOKEN" ]]; then
    echo -e "${GREEN}SUCCESS Main and Dev tokens match${NC}"
else
    echo -e "${YELLOW}WARNING  Main and Dev tokens differ${NC}"
fi

# Server mapping validation
echo -e "\nSYMBOL Server Mapping Validation"
echo "============================"

echo "Development Server (TAGS: DevOnboarder): 1386935663139749998"
echo "Production Server (TAGS: C2C): 1065367728992571444"

MAIN_DEV_GUILD=$(grep "DISCORD_DEV_GUILD_ID=" .env | cut -d'=' -f2 2>/dev/null || echo "")
MAIN_PROD_GUILD=$(grep "DISCORD_PROD_GUILD_ID=" .env | cut -d'=' -f2 2>/dev/null || echo "")

if [[ "$MAIN_DEV_GUILD" == "1386935663139749998" ]]; then
    echo -e "${GREEN}SUCCESS Development guild ID correctly configured${NC}"
else
    echo -e "${YELLOW}WARNING  Development guild ID: $MAIN_DEV_GUILD${NC}"
fi

if [[ "$MAIN_PROD_GUILD" == "1065367728992571444" ]]; then
    echo -e "${GREEN}SUCCESS Production guild ID correctly configured${NC}"
else
    echo -e "${YELLOW}WARNING  Production guild ID: $MAIN_PROD_GUILD${NC}"
fi

# Test bot invite generation
echo -e "\nLINK Bot Invite Link Test"
echo "======================="

if command -v node &> /dev/null && [[ -f "bot/scripts/generate-invite.js" ]]; then
    echo "Testing invite link generation..."
    cd bot
    if node scripts/generate-invite.js > /dev/null 2>&1; then
        echo -e "${GREEN}SUCCESS Bot invite link generation successful${NC}"
    else
        echo -e "${RED}FAILED Bot invite link generation failed${NC}"
    fi
    cd ..
else
    echo -e "${YELLOW}WARNING  Cannot test invite generation (Node.js or script not found)${NC}"
fi

echo -e "\nTARGET Summary"
echo "=========="
echo "Configuration validation complete!"
echo ""
echo "Next steps:"
echo "1. Use the invite link to add the bot to Discord servers"
echo "2. Test bot connection: cd bot && npm run dev"
echo "3. Verify bot responds in Discord channels"
