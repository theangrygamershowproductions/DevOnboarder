#!/usr/bin/env bash
# Install Python and Node.js dependencies for development
set -euo pipefail

pip install -r requirements-dev.txt

if [ -d bot ] && [ -f bot/package.json ]; then
    npm ci --prefix bot
fi

if [ -d frontend ] && [ -f frontend/package.json ]; then
    npm ci --prefix frontend
fi

pre-commit install

echo "Development environment ready ✅"
