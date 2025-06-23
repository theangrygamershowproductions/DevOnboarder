#!/usr/bin/env bash
# Bootstrap environment for local or Codex usage

set -euo pipefail

echo "Checking Docker availability..."
if docker info >/dev/null 2>&1; then
    echo "Docker is available ✅"
    echo "Pulling Codex image..."
    docker pull ghcr.io/openai/codex-universal
    echo "Running universal setup..."
    docker run --rm -v "$(pwd)":/workspace \
        ghcr.io/openai/codex-universal /opt/codex/setup_universal.sh
    echo "Docker-based setup complete ✅"
else
    echo "Docker not usable, falling back to local setup"
    python3 -m venv venv
    source venv/bin/activate
    python -m pip install --upgrade pip
    if [ -f requirements-dev.txt ]; then
        pip install -r requirements-dev.txt
    fi
    if [ -d frontend ]; then
        cd frontend
        if command -v pnpm >/dev/null 2>&1; then
            pnpm install
        else
            echo "pnpm not found, using npm"
            npm install
        fi
        cd ..
    fi
    export PYTHONPATH="$(pwd)"
    echo "Local environment ready ✅"
fi
