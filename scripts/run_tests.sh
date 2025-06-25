#!/usr/bin/env bash
set -euo pipefail

# Ensure development requirements are installed
if ! command -v pytest >/dev/null 2>&1; then
    echo "Installing dev requirements..."
    pip install -r requirements-dev.txt
fi

# Ensure runtime dependencies are installed
if [ -f pyproject.toml ]; then
    pip install -e .
fi

ruff check .
pytest -q
if [ -d bot ] && [ -f bot/package.json ]; then
    (cd bot && npm test)
fi
