#!/bin/bash
set -euo pipefail

echo "BOT: Starting Discord Bot - Production Environment"
echo "==============================================="

# Load production environment
export NODE_ENV=production
export ENVIRONMENT=prod

# Check if .env.prod exists
if [[ ! -f ".env.prod" ]]; then
    echo " Production environment file not found: .env.prod"
    echo "   Run: bash ../scripts/setup_discord_env.sh prod"
    exit 1
fi

# Copy prod environment to main .env
cp .env.prod .env

# Ensure bot dependencies are installed
npm ci --only=production

# Build for production
npm run build

echo " Starting bot in production mode..."
npm start
