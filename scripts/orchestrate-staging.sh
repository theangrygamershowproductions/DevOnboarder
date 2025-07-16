#!/usr/bin/env bash
set -euo pipefail

if [ -z "${ORCHESTRATION_KEY:-}" ]; then
  echo "ORCHESTRATION_KEY not set" >&2
  exit 1
fi

# Base URL for the orchestration service
ORCHESTRATOR_URL=${ORCHESTRATOR_URL:-https://orchestrator.example.com}

echo "Triggering staging orchestration..."

curl -fsSL -X POST "$ORCHESTRATOR_URL/staging" \
  -H "Authorization: Bearer $ORCHESTRATION_KEY" \
  -d '{}' || echo "Orchestration request failed or skipped."
