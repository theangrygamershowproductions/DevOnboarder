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

    py_cmd="python3"
    if ! python3 - <<'EOF'
import sys
sys.exit(0 if sys.version_info >= (3, 12) else 1)
EOF
    then
        echo "::warning file=scripts/setup-env.sh,line=$LINENO::Active Python $(python3 --version 2>&1) is below 3.12" >&2
    fi
    if ! python3 --version 2>/dev/null | grep -q "3.12"; then
        if command -v python3.12 >/dev/null 2>&1; then
            py_cmd="python3.12"
        elif command -v mise >/dev/null 2>&1; then
            echo "Installing Python 3.12 via mise..."
            mise install python >/dev/null
            eval "$(mise env)"
            py_cmd="$(which python3)"
        elif command -v asdf >/dev/null 2>&1; then
            echo "Installing Python 3.12 via asdf..."
            asdf install python 3.12 || true
            asdf global python 3.12
            py_cmd="$(asdf which python3)"
        fi
    fi

    if ! "$py_cmd" --version 2>/dev/null | grep -q "3.12"; then
        echo "Python 3.12 is required. Install it with mise or asdf." >&2
        exit 1
    fi

    "$py_cmd" -m venv venv
    source venv/bin/activate
    python -m pip install --upgrade pip
    if [ -f requirements-dev.txt ]; then
        pip install -r requirements-dev.txt
    fi
    # Install the project with test extras so runtime dependencies are available
    if [ -f pyproject.toml ]; then
        pip install -e ".[test]"
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
    PYTHONPATH="$(pwd)"
    export PYTHONPATH
    echo "Local environment ready ✅"
fi
