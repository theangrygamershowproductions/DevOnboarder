#!/usr/bin/env bash
set -euo pipefail

# Always ensure development requirements are installed
echo "Installing dev requirements..."
pip install -e ".[test]"
pip check

# Ensure runtime dependencies are installed
if [ -f pyproject.toml ]; then
    pip check
fi

ruff check .
mkdir -p test-results

# Capture pytest output so we can surface helpful hints on failure
pytest_log=$(mktemp)
set +e
pytest --cov=src --cov-fail-under=95 \
    --junitxml=test-results/pytest-results.xml 2>&1 | tee "$pytest_log"
pytest_exit=${PIPESTATUS[0]}
set -e

# Print installation hint when tests fail due to missing packages
if grep -q "ModuleNotFoundError" "$pytest_log"; then
    echo
    echo "ModuleNotFoundError detected during tests."
    echo "Make sure you've installed the project and test requirements:"
    echo "  pip install -e .[test]"
    echo "See the troubleshooting section in docs/README.md for details."
fi

if [ "$pytest_exit" -ne 0 ]; then
    exit "$pytest_exit"
fi
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
