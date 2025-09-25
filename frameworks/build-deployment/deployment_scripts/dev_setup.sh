#!/usr/bin/env bash
# Install Python and Node.js dependencies for development
set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

pip install -r requirements-dev.txt

if [ -d bot ] && [ -f bot/package.json ]; then
    npm ci --prefix bot
fi

if [ -d frontend ] && [ -f frontend/package.json ]; then
    npm ci --prefix frontend
fi

pre-commit install

echo "Development environment ready"
