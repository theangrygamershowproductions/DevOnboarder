#!/bin/bash
# scripts/create_pr_safe.sh - Safe PR creation for zsh terminals
#
# This script prevents zsh interpretation issues when creating PRs with complex markdown content
# Usage: bash scripts/create_pr_safe.sh "PR Title" "path/to/body.md" [--draft]

set -euo pipefail

# Validate arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: bash scripts/create_pr_safe.sh \"PR Title\" \"path/to/body.md\" [--draft]"
    echo "Example: bash scripts/create_pr_safe.sh \"Phase 1: Framework\" \"pr_body.md\""
    exit 1
fi

PR_TITLE="$1"
BODY_FILE="$2"
DRAFT_FLAG="${3:-}"

# Validate body file exists
if [[ ! -f "$BODY_FILE" ]]; then
    echo "Error: Body file '$BODY_FILE' does not exist"
    exit 1
fi

# Create PR with body file (avoids zsh parsing issues)
echo "Creating PR with title: $PR_TITLE"
echo "Using body from file: $BODY_FILE"

if [[ "$DRAFT_FLAG" == "--draft" ]]; then
    gh pr create --title "$PR_TITLE" --body-file "$BODY_FILE" --draft
else
    gh pr create --title "$PR_TITLE" --body-file "$BODY_FILE"
fi

echo "PR created successfully!"
echo "Note: Using --body-file prevents zsh interpretation of markdown special characters"
