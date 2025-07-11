#!/usr/bin/env bash
# Verify optional tools are installed
set -euo pipefail

missing=0

check_npx_tool() {
    local tool=$1
    local install_hint=$2
    if ! npx --no-install "$tool" --version >/dev/null 2>&1; then
        echo "$tool not found. $install_hint"
        missing=1
    fi
}

if ! command -v npx >/dev/null 2>&1; then
    echo "Node.js and npx are required to run Jest and Vitest."
    missing=1
else
    check_npx_tool jest "Run 'npm install' or 'pnpm install' in the bot/ directory."
    check_npx_tool vitest "Run 'npm install' or 'pnpm install' in the frontend/ directory."
fi

if ! command -v vale >/dev/null 2>&1; then
    echo "Vale not found. Install it from https://vale.sh/docs/installation/ or with 'brew install vale'."
    missing=1
fi

check_python_module() {
    local module=$1
    local hint=$2
    if ! python -c "import $module" >/dev/null 2>&1; then
        echo "$module not found. $hint"
        missing=1
    fi
}

check_python_module devonboarder "Run 'pip install -e .' before running the tests."
check_python_module pytest "Run 'pip install -r requirements-dev.txt'."

if [ "$missing" -eq 0 ]; then
    echo "All optional dependencies installed ✅"
fi
