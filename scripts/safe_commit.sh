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
    COMMIT_EXIT_CODE=$?
    echo "Pre-commit hooks failed (exit code: $COMMIT_EXIT_CODE)"

    # Check if files were modified by hooks (like trailing whitespace fixes)
    MODIFIED_FILES=$(git diff --name-only)
    if [[ -n "$MODIFIED_FILES" ]]; then
        echo "Files were modified by pre-commit hooks:"
        echo "$MODIFIED_FILES"

        # Re-add the modified files that were originally staged
        echo "Re-staging modified files..."
        echo "$STAGED_FILES" | while read -r file; do
            if [[ -f "$file" ]] && echo "$MODIFIED_FILES" | grep -q "^$file$"; then
                echo "  Re-staging: $file"
                git add "$file"
            fi
        done

        # Commit again - should pass since hooks already fixed the issues
        echo "Committing re-staged files (hooks already validated and fixed content)..."
        git commit -m "$COMMIT_MSG"
        echo "Commit successful after re-staging!"
    else
        echo "Pre-commit hooks failed but no files were modified. Check the errors above."
        exit $COMMIT_EXIT_CODE
    fi
fi
