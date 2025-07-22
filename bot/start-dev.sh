#!/bin/bash
set -euo pipefail

echo "🤖 Starting Discord Bot - Development Environment"
echo "================================================"

# Load development environment
export NODE_ENV=development
export ENVIRONMENT=dev

# Check if .env.dev exists
if [[ ! -f ".env.dev" ]]; then
    echo "❌ Development environment file not found: .env.dev"
    echo "   Run: bash ../scripts/setup_discord_env.sh dev"
    exit 1
fi

# Copy dev environment to main .env
cp .env.dev .env

# Install dependencies if needed
if [[ ! -d "node_modules" ]]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build if needed
if [[ ! -d "dist" ]] || [[ "src/" -nt "dist/" ]]; then
    echo "🔨 Building bot..."
    npm run build
fi

echo "🚀 Starting bot in development mode..."
npm start
