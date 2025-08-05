#!/usr/bin/env bash
# =============================================================================
# File: scripts/safe_commit.sh
# Purpose: Safe commit wrapper that handles pre-commit hook file modifications
# Author: DevOnboarder Project
# Standards: Compliant with copilot-instructions.md and centralized logging policy
# =============================================================================

set -euo pipefail

# Check if virtual environment is activated
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo "Activating virtual environment..."
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

# Store the commit message
COMMIT_MSG="$1"

echo "Starting safe commit process..."
echo "Commit message: $COMMIT_MSG"

# Get list of staged files before pre-commit runs
STAGED_FILES=$(git diff --cached --name-only)
echo "Files currently staged:"
echo "$STAGED_FILES"

# Run pre-commit hooks (this may modify files)
echo "Running pre-commit hooks..."
if git commit -m "$COMMIT_MSG"; then
    echo "Commit successful!"
    exit 0
else
    echo "Pre-commit hooks modified files. Re-staging and committing..."

    # Re-add any files that were modified by pre-commit hooks
    echo "$STAGED_FILES" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "Re-staging: $file"
            git add "$file"
        fi
    done

    # Try commit again
    echo "Attempting commit again with re-staged files..."
    git commit -m "$COMMIT_MSG"
    echo "Commit successful after re-staging!"
fi
