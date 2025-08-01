#!/usr/bin/env bash
set -euo pipefail

# List violations in clean, parseable format
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
-printf "- %p\n" | sort
