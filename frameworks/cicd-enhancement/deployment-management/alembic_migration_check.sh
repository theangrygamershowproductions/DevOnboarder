#!/bin/bash
set -euo pipefail

# Load environment variables for CI
if [ -f .env.ci ]; then
    set -a
    # shellcheck source=.env.ci disable=SC1091
    source .env.ci
    set +a
fi

database_url="${DATABASE_URL:-}"

if grep -q "sqlite" <<< "$database_url"; then
    echo "Running Alembic migration check for SQLite database"
    alembic upgrade --sql head
else
    echo "Non-SQLite DB; skipping SQLite-only migration check."
fi
