#!/usr/bin/env bash
# Usage: bash scripts/notify_ci_issue.sh <action> <issue> <body_file>
# action: comment|create|close
# issue: issue number or title
# body_file: markdown file to use as body (optional for close)

set -euo pipefail

ACTION="${1:-}"
ISSUE="${2:-}"
BODY_FILE="${3:-}"

export GH_TOKEN="${CI_ISSUE_AUTOMATION_TOKEN:-${CI_BOT_TOKEN:-${GITHUB_TOKEN}}}"

case "$ACTION" in
  comment)
    if [ -n "$ISSUE" ] && [ -f "$BODY_FILE" ]; then
      gh issue comment "$ISSUE" --body-file "$BODY_FILE"
    fi
    ;;
  create)
    if [ -n "$ISSUE" ] && [ -f "$BODY_FILE" ]; then
      gh issue create --title "$ISSUE" --body-file "$BODY_FILE" --label ci-failure
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
