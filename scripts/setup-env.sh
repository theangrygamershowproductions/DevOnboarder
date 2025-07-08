#!/usr/bin/env bash
# Bootstrap environment for local or Codex usage

set -euo pipefail

# Ensure required domains are reachable before continuing
SCRIPT_DIR="$(dirname "$0")"
if [ -x "$SCRIPT_DIR/check_network_access.sh" ]; then
    "$SCRIPT_DIR/check_network_access.sh"
fi

echo "Checking Docker availability..."
docker_ok=false
if [ -n "${CI:-}" ]; then
    echo "CI environment detected, skipping Codex Docker setup"
elif docker info >/dev/null 2>&1; then
    docker_ok=true
fi

if [ "$docker_ok" = true ]; then
    echo "Docker is available ✅"
    echo "Pulling Codex image..."
    docker pull ghcr.io/openai/codex-universal
    echo "Running universal setup..."
    docker run --rm -v "$(pwd)":/workspace \
        ghcr.io/openai/codex-universal /opt/codex/setup_universal.sh
    echo "Docker-based setup complete ✅"
else
    if [ -z "${CI:-}" ]; then
        echo "Docker not usable, falling back to local setup"
    fi
    python3 -m venv venv
    source venv/bin/activate
    python -m pip install --upgrade pip
    if [ -f requirements-dev.txt ]; then
        pip install -r requirements-dev.txt
    fi
    # Install the project so runtime dependencies are available
    if [ -f pyproject.toml ]; then
        pip install -e .
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

    if [ -d bot ]; then
        cd bot
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
