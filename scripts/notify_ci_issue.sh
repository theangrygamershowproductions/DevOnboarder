#!/usr/bin/env bash
# Usage: bash scripts/notify_ci_issue.sh <action> <issue> <body>
# action: comment|close
# issue: issue number
# body: message (for comment)

set -euo pipefail

ACTION="${1:-}"
ISSUE="${2:-}"
BODY="${3:-}"

export GH_TOKEN="${CI_ISSUE_AUTOMATION_TOKEN:-${CI_BOT_TOKEN:-${GITHUB_TOKEN}}}"

case "$ACTION" in
  comment)
    if [ -n "$ISSUE" ] && [ -n "$BODY" ]; then
      gh issue comment "$ISSUE" --body "$BODY"
    fi
    ;;
  close)
    if [ -n "$ISSUE" ]; then
      gh issue close "$ISSUE"
    fi
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac
