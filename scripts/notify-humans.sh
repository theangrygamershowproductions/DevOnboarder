#!/usr/bin/env bash
set -euo pipefail

# Create an issue or comment to escalate an event.
# Usage: notify-humans.sh <title> <body-file> [issue-number]
# Requires GH_TOKEN environment variable and the gh CLI.

TITLE="${1:-}"
BODY_FILE="${2:-}"
ISSUE="${3:-}"

if [ -z "$TITLE" ] || [ -z "$BODY_FILE" ]; then
  echo "Usage: $0 <title> <body-file> [issue-number]" >&2
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

if [ -n "$ISSUE" ]; then
  gh issue comment "$ISSUE" --body-file "$BODY_FILE"
else
  gh issue create --title "$TITLE" --body-file "$BODY_FILE" --label ops
fi

echo "Notification sent"
