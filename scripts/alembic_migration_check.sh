#!/bin/bash
set -euo pipefail

database_url="${DATABASE_URL:-}"

if grep -q "sqlite" <<< "$database_url"; then
  alembic upgrade --sql head
else
  echo "Non-SQLite DB; skipping SQLite-only migration check."
fi
