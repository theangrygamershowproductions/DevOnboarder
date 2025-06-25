#!/usr/bin/env bash
set -euo pipefail

if ! command -v alembic >/dev/null 2>&1; then
    echo "Alembic not installed. Install dependencies with 'pip install -r requirements-dev.txt'"
    exit 1
fi

alembic upgrade head
