#!/usr/bin/env bash
set -euo pipefail

# Always ensure development requirements are installed
echo "Installing dev requirements..."
pip install -r requirements-dev.txt

# Ensure runtime dependencies are installed
if [ -f pyproject.toml ]; then
    pip install -e .
fi

ruff check .
pytest --cov=src --cov-fail-under=95
if [ -d bot ] && [ -f bot/package.json ]; then
    npm ci --prefix bot
    (cd bot && npm run coverage)
fi

# Optionally run frontend tests when they exist
if [ -d frontend ] && [ -f frontend/package.json ]; then
    if grep -q "\"test\"" frontend/package.json; then
        npm ci --prefix frontend
        (cd frontend && npm run coverage)
    fi
fi
