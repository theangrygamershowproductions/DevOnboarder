#!/usr/bin/env bash
# PATCHED v0.1.1 scripts/rotate-secret.sh — Rotate GitHub secret via gh CLI
# Rotate a GitHub repository secret using the gh CLI.
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 SECRET_NAME NEW_VALUE [REPO]" >&2
  exit 1
fi

SECRET_NAME="$1"
NEW_VALUE="$2"
REPO="${3:-$(
  git config --get remote.origin.url | sed -e 's#.*/##' -e 's/\.git$//'
)}"

if ! command -v gh >/dev/null 2>&1; then
  echo "[ERROR] GitHub CLI 'gh' not found" >&2
  exit 1
fi

echo -n "$NEW_VALUE" | gh secret set "$SECRET_NAME" -R "$REPO" -b-
echo "[OK] Secret '$SECRET_NAME' updated for $REPO"
