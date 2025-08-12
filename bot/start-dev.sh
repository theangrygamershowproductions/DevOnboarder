#!/bin/bash
set -euo pipefail

echo "Bot Starting Discord Bot - Development Environment"
echo "================================================"

# Load development environment
export NODE_ENV=development
export ENVIRONMENT=dev

# Check if .env.dev exists
if [[ ! -f ".env.dev" ]]; then
    echo "FAILED Development environment file not found: .env.dev"
    echo "   Run: bash ../scripts/setup_discord_env.sh dev"
    exit 1
fi

# Copy dev environment to main .env
cp .env.dev .env

# Install bot dependencies if needed
if [[ ! -d "node_modules" ]]; then
    echo "EMOJI Installing bot dependencies..."
    npm install
fi

# Build if needed
if [[ ! -d "dist" ]] || [[ "src/" -nt "dist/" ]]; then
    echo "EMOJI Building bot..."
    npm run build
fi

echo "DEPLOY Starting bot in development mode..."
npm start
