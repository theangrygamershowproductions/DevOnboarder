#!/usr/bin/env bash
# Download ci-failure issue number from the previous CI run if available
# The artifact now stores the issue number in ci_failure_issue.txt
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
    echo "::error::GitHub CLI not installed" >&2
    exit 1
fi

run_id=$(gh run list -w CI --json databaseId,headSha -L 10 \
    --jq 'map(select(.headSha=="'"$GITHUB_SHA"'" && .databaseId != '"$GITHUB_RUN_ID"')) | .[0].databaseId' || true)

if [ -n "${run_id:-}" ]; then
    echo "Downloading ci-failure-issue artifact from run $run_id" >&2
    gh run download "$run_id" --name ci-failure-issue --dir . || true
    if [ -f ci-failure-issue.txt ]; then
        mv ci-failure-issue.txt ci_failure_issue.txt
    fi
fi
