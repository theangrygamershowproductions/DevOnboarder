#!/usr/bin/env bash

# Centralized logging for troubleshooting and repository health
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

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
