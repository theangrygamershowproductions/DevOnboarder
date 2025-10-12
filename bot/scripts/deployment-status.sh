#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Discord Bot Deployment Status Check
set -euo pipefail

deploy "Discord Bot Deployment Status Check"
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
    error_msg " Not in bot directory. Please run from /home/potato/DevOnboarder/bot"
    exit 1
fi

echo -e "${BLUE}CHECK: Pre-Flight Checks"
echo "===================="

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "success "Node.js: $NODE_VERSION"
else
    error_msg " Node.js not found"
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "success "npm: $NPM_VERSION"
else
    error_msg " npm not found"
fi

# Check environment file
if [[ -f ".env" ]]; then
    echo -e "success "Environment file: .env exists"

    # Check critical environment variables
    if grep -q "DISCORD_BOT_TOKEN=" .env; then
        echo -e "success "Bot token: Configured"
    else
        error_msg " Bot token: Missing"
    fi

    if grep -q "DISCORD_CLIENT_ID=" .env; then
        echo -e "success "Client ID: Configured"
    else
        error_msg " Client ID: Missing"
    fi
else
    error_msg " Environment file: .env not found"
fi

# Check TypeScript compilation
echo ""
echo -e "${BLUE}🔨 Build Status"
echo "==============="

if [[ -d "dist" ]]; then
    echo -e "success "Build directory exists"
    if [[ -f "dist/main.js" ]]; then
        echo -e "success "Main build file exists"
    else
        debug_msg "  Main build file missing - running build..."
        npm run build
    fi
else
    debug_msg "  Build directory missing - running build..."
    npm run build
fi

# Test guild connections
echo ""
echo -e "${BLUE}🔗 Discord Connection Test"
echo "=========================="

echo "Testing bot connection to Discord servers..."
echo ""

# Run the guild connection test
if timeout 30 node scripts/test-guild-connections.js; then
    echo ""
    success_msg " Discord connection test completed"
else
    echo ""
    error_msg " Discord connection test failed or timed out"
    echo -e "${YELLOW}💡 Troubleshooting tips:"
    echo "   1. Verify bot token is correct"
    echo "   2. Check bot was invited to both servers"
    echo "   3. Ensure bot has proper permissions"
    echo "   4. Generate new invite: npm run invite"
fi

echo ""
echo -e "${BLUE}REPORT: Target Servers"
echo "=================="
echo "Development: TAGS: DevOnboarder (1386935663139749998)"
echo "Production:  TAGS: Command & Control (1065367728992571444)"

echo ""
echo -e "${BLUE}TARGET: Available Commands"
echo "===================="
echo "npm run dev          - Start bot in development mode"
echo "npm run start        - Start bot in production mode"
echo "npm run test-guilds  - Test Discord server connections"
echo "npm run invite       - Generate new bot invite link"
echo "npm run build        - Build TypeScript code"
echo "npm run test         - Run test suite"

echo ""
success_msg " Deployment status check complete!"
