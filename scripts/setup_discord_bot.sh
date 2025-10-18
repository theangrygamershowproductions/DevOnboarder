#!/usr/bin/env bash
# filepath: scripts/setup_discord_bot.sh
set -euo pipefail

echo "🤖 Discord Bot Setup for DevOnboarder"
echo "====================================="

# Check if we're in the right directory
if [[ ! -f ".env" ]]; then
    echo " .env file not found. Please run from the DevOnboarder root directory."
    exit 1
fi

# Load environment variables
set -a
# shellcheck source=/dev/null
source .env
set a

echo " Checking configuration..."
echo ""

# Verify required environment variables
if [[ -z "${DISCORD_CLIENT_ID:-}" ]]; then
    echo " DISCORD_CLIENT_ID not set in .env"
    echo "   Get this from: https://discord.com/developers/applications"
    exit 1
else
    echo " Discord Client ID: $DISCORD_CLIENT_ID"
fi

if [[ -z "${DISCORD_BOT_TOKEN:-}" ]]; then
    echo " DISCORD_BOT_TOKEN not set in .env"
    echo "   Get this from: https://discord.com/developers/applications"
    exit 1
else
    echo " Discord Bot Token: ${DISCORD_BOT_TOKEN:0:10}..."
fi

echo ""
echo "🎯 Target Servers:"
echo "   • TAGS: DevOnboarder (Dev): 1386935663139749998"
echo "   • TAGS: C2C (Prod): 1065367728992571444"
echo ""

# Check if bot directory exists
if [[ ! -d "bot" ]]; then
    echo " Bot directory not found"
    exit 1
fi

# Install bot dependencies if needed
echo "📦 Checking bot dependencies..."
cd bot
if [[ ! -d "node_modules" ]] || [[ "package.json" -nt "node_modules" ]]; then
    echo "   Installing bot dependencies..."
    npm install
else
    echo "    Dependencies up to date"
fi

# Build bot if needed
echo "🔨 Building bot..."
if [[ ! -d "dist" ]] || [[ "src/" -nt "dist/" ]]; then
    echo "   Building TypeScript..."
    npm run build
else
    echo "    Build up to date"
fi

# Generate invite link
echo ""
echo "LINK: Generating bot invite link..."
npm run generate-invite

cd ..

echo ""
echo " Next Steps:"
echo "   1. Use the invite link above to add bot to Discord servers"
echo "   2. Start the bot: cd bot && npm run dev"
echo "   3. Test bot commands in Discord"
echo "   4. Run integration tests: ./scripts/trigger_codex_agent_dryrun.sh"
echo ""
echo " Available Commands:"
echo "   • Generate invite link: cd bot && npm run invite"
echo "   • Check connected guilds: cd bot && npm run guild-check"
echo "   • Start bot: cd bot && npm run dev"
echo "   • Run tests: cd bot && npm test"
echo ""
