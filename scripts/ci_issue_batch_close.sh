#!/usr/bin/env bash
# Usage: bash scripts/ci_issue_batch_close.sh <label> <comment>
set -euo pipefail

LABEL="${1:-}"
COMMENT="${2:-}"

export GH_TOKEN="${CI_ISSUE_AUTOMATION_TOKEN:-${CI_BOT_TOKEN:-${GITHUB_TOKEN}}}"

ISSUES=$(gh issue list --label "$LABEL" --state open --json number --jq '.[].number')
for ISSUE in $ISSUES; do
    bash scripts/notify_ci_issue.sh comment "$ISSUE" "$COMMENT" || true
    bash scripts/notify_ci_issue.sh close "$ISSUE" || true
done
