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
pytest -q
if [ -d bot ] && [ -f bot/package.json ]; then
    (cd bot && npm test)
fi
