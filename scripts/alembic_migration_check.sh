#!/bin/bash
set -e
if grep -q "sqlite" <<< "$DATABASE_URL"; then
  alembic upgrade --sql head
else
  echo "Non-SQLite DB; skipping SQLite-only migration check."
fi
