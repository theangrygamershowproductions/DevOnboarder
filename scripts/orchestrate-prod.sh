#!/usr/bin/env bash
set -euo pipefail

if [ -z "${ORCHESTRATION_KEY:-}" ]; then
  echo "ORCHESTRATION_KEY not set" >&2
  exit 1
fi

echo "Triggering production orchestration..."

curl -fsSL -X POST "https://orchestrator.example.com/prod" \
  -H "Authorization: Bearer $ORCHESTRATION_KEY" \
  -d '{}' || echo "Orchestration request failed or skipped."
