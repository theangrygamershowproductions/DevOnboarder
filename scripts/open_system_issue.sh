#!/usr/bin/env bash
# Helper script to create tracking issues for system failures/exceptions
# Usage: ./scripts/open_system_issue.sh <doc_path> <issue_title>

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <doc_path> <issue_title>"
    echo "Example: $0 docs/PRIORITY_MATRIX_GPG_STATUS.md 'INFRA: Fix Priority Matrix Bot GPG signing'"
    exit 1
fi

DOC_PATH="$1"
TITLE="$2"

if [ ! -f "$DOC_PATH" ]; then
    echo "Error: Document not found: $DOC_PATH"
    exit 1
fi

echo "Creating issue from: $DOC_PATH"
echo "Title: $TITLE"
echo ""

gh issue create \
  --title "$TITLE" \
  --body-file "$DOC_PATH"
