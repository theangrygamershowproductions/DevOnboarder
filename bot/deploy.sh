#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Full bot deployment script - builds, deploys commands, and starts bot

set -euo pipefail

bot "DevOnboarder Bot Full Deployment"
echo "==================================="
echo ""

# Build the bot
echo "🔨 Building bot..."
npm run build

# Deploy commands to both guilds
echo ""
echo "📤 Deploying commands to development guild..."
npm run deploy-commands

echo ""
echo "📤 Deploying commands to production guild..."
DISCORD_GUILD_ID=1065367728992571444 npm run deploy-commands

echo ""
success "Bot deployment complete!"
echo ""
deploy "Starting bot..."
npm start
