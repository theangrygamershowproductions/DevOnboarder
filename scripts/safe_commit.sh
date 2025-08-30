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

        # Reset staging area and re-stage only the originally intended files
        # This prevents the "caching cycle" issue where modified files get staged on top of already staged files
        echo "Resetting staging area and re-staging modified files..."
        git reset HEAD --quiet
        echo "$STAGED_FILES" | while read -r file; do
            if [[ -f "$file" ]]; then
                echo "  Re-staging: $file"
                git add "$file"
            fi
        done

        # Commit again - should pass since hooks already fixed the issues
        echo "Committing re-staged files (hooks already validated and fixed content)..."
        if git commit -m "$COMMIT_MSG"; then
            echo "Commit successful after re-staging!"
        else
            SECOND_EXIT_CODE=$?
            echo "❌ CRITICAL: Pre-commit failed AGAIN after re-staging files!"
            echo "Exit code: $SECOND_EXIT_CODE"
            echo ""
            echo "🔍 AUTOMATIC LOG ANALYSIS:"
            echo "=========================="

            # Show recent pre-commit logs
            echo "📋 Recent pre-commit cache logs:"
            find ~/.cache/pre-commit -name "*.log" -type f -mtime -1 2>/dev/null | head -3 | while read -r logfile; do
                echo "📄 Log: $logfile"
                echo "   Last 10 lines:"
                tail -10 "$logfile" 2>/dev/null | sed 's/^/     /'
                echo ""
            done

            # Show git status for debugging
            echo "📋 Current git status:"
            git status --porcelain | sed 's/^/   /'
            echo ""

            # Show what files were supposed to be committed
            if [[ -n "$STAGED_FILES" ]]; then
            echo "📋 Files that should have been staged:"
            # shellcheck disable=SC2001 # Using sed for proper indentation formatting
            echo "$STAGED_FILES" | sed 's/^/   /'
        fi
            echo ""

            # Show current staged files
            echo "📋 Actually staged files:"
            git diff --cached --name-only | sed 's/^/   /'
            echo ""

            echo "🚨 This indicates a systemic pre-commit issue, not just whitespace fixes."
            echo "💡 Recommended actions:"
            echo "   1. Check the log output above for specific error patterns"
            echo "   2. Run: source .venv/bin/activate && pre-commit run --all-files"
            echo "   3. Or run individual hooks: pre-commit run <hook-name> --all-files"
            echo "   4. Check DevOnboarder quality gates documentation"

            exit $SECOND_EXIT_CODE
        fi
    else
        echo "Pre-commit hooks failed but no files were modified. Check the errors above."
        exit $COMMIT_EXIT_CODE
    fi
fi
