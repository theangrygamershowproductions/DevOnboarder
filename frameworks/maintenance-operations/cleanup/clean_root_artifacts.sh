#!/usr/bin/env bash
set -euo pipefail

# Establish PROJECT_ROOT for reliable operation
if [ -z "${PROJECT_ROOT:-}" ]; then
    export PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
fi

# Validate PROJECT_ROOT and change to it
if [ -z "${PROJECT_ROOT:-}" ] || [ ! -d "$PROJECT_ROOT" ]; then
    exit 1
fi
cd "$PROJECT_ROOT"

# Create logs directory for centralized output
mkdir -p logs/ci

# Clean root artifacts safely
find . -maxdepth 1 \( \
    -name ".coverage*" -o \
    -name "test-results" -o \
    -name "pytest_cache" -o \
    -name "__pycache__" -o \
    -name "node_modules" -o \
    -name "test.db*" -o \
    -name "vale-results.json" -o \
    -name ".pytest_cache" -o \
    -name "Thumbs.db" -o \
    -name ".DS_Store" \
\) -not -path "./.venv/*" -not -path "./.git/*" -not -path "./logs/*" \
-exec rm -rf {} +
