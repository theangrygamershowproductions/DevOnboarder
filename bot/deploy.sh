#!/bin/bash
# Full bot deployment script - builds, deploys commands, and starts bot

set -euo pipefail

echo "Bot DevOnboarder Bot Full Deployment"
echo "==================================="
echo ""

# Build the bot
echo "EMOJI Building bot..."
npm run build

# Deploy commands to both guilds
echo ""
echo "EMOJI Deploying commands to development guild..."
npm run deploy-commands

echo ""
echo "EMOJI Deploying commands to production guild..."
DISCORD_GUILD_ID=1065367728992571444 npm run deploy-commands

echo ""
echo "SUCCESS Bot deployment complete!"
echo ""
echo "DEPLOY Starting bot..."
npm start
