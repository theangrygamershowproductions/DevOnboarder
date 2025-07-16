#!/usr/bin/env bash
set -euo pipefail

# Deprecated wrapper that routes notifications through the notify.yml workflow.
# Usage: notify-humans.sh <title> <body-file>
# Requires GH_TOKEN environment variable and the gh CLI.

TITLE="${1:-}"
BODY_FILE="${2:-}"

if [ -z "$TITLE" ] || [ -z "$BODY_FILE" ]; then
  echo "Usage: $0 <title> <body-file>" >&2
  exit 1
fi

if [ ! -f "$BODY_FILE" ]; then
  echo "Body file '$BODY_FILE' not found" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI not installed" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not installed" >&2
  exit 1
fi

DATA=$(jq -n --arg title "$TITLE" --arg body "$(cat "$BODY_FILE")" '{title:$title, body:$body}')
gh workflow run notify.yml -f data="$DATA"
echo "Notification dispatched via notify.yml"
