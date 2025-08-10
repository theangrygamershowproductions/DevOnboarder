#!/usr/bin/env bash
# Discord Bot Deployment Status Check
set -euo pipefail

echo "DEPLOY Discord Bot Deployment Status Check"
echo "======================================"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the bot directory
if [[ ! -f "package.json" ]]; then
    echo -e "${RED}FAILED Not in bot directory. Please run from /home/potato/DevOnboarder/bot${NC}"
    exit 1
fi

echo -e "${BLUE}EMOJI Pre-Flight Checks${NC}"
echo "===================="

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "SUCCESS Node.js: $NODE_VERSION"
else
    echo -e "${RED}FAILED Node.js not found${NC}"
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "SUCCESS npm: $NPM_VERSION"
else
    echo -e "${RED}FAILED npm not found${NC}"
fi

# Check environment file
if [[ -f ".env" ]]; then
    echo -e "SUCCESS Environment file: .env exists"

    # Check critical environment variables
    if grep -q "DISCORD_BOT_TOKEN=" .env; then
        echo -e "SUCCESS Bot token: Configured"
    else
        echo -e "${RED}FAILED Bot token: Missing${NC}"
    fi

    if grep -q "DISCORD_CLIENT_ID=" .env; then
        echo -e "SUCCESS Client ID: Configured"
    else
        echo -e "${RED}FAILED Client ID: Missing${NC}"
    fi
else
    echo -e "${RED}FAILED Environment file: .env not found${NC}"
fi

# Check TypeScript compilation
echo ""
echo -e "${BLUE}EMOJI Build Status${NC}"
echo "==============="

if [[ -d "dist" ]]; then
    echo -e "SUCCESS Build directory exists"
    if [[ -f "dist/main.js" ]]; then
        echo -e "SUCCESS Main build file exists"
    else
        echo -e "${YELLOW}WARNING  Main build file missing - running build...${NC}"
        npm run build
    fi
else
    echo -e "${YELLOW}WARNING  Build directory missing - running build...${NC}"
    npm run build
fi

# Test guild connections
echo ""
echo -e "${BLUE}LINK Discord Connection Test${NC}"
echo "=========================="

echo "Testing bot connection to Discord servers..."
echo ""

# Run the guild connection test
if timeout 30 node scripts/test-guild-connections.js; then
    echo ""
    echo -e "${GREEN}SUCCESS Discord connection test completed${NC}"
else
    echo ""
    echo -e "${RED}FAILED Discord connection test failed or timed out${NC}"
    echo -e "${YELLOW}IDEA Troubleshooting tips:${NC}"
    echo "   1. Verify bot token is correct"
    echo "   2. Check bot was invited to both servers"
    echo "   3. Ensure bot has proper permissions"
    echo "   4. Generate new invite: npm run invite"
fi

echo ""
echo -e "${BLUE}STATS Target Servers${NC}"
echo "=================="
echo "Development: TAGS: DevOnboarder (1386935663139749998)"
echo "Production:  TAGS: Command & Control (1065367728992571444)"

echo ""
echo -e "${BLUE}TARGET Available Commands${NC}"
echo "===================="
echo "npm run dev          - Start bot in development mode"
echo "npm run start        - Start bot in production mode"
echo "npm run test-guilds  - Test Discord server connections"
echo "npm run invite       - Generate new bot invite link"
echo "npm run build        - Build TypeScript code"
echo "npm run test         - Run test suite"

echo ""
echo -e "${GREEN}SUCCESS Deployment status check complete!${NC}"
