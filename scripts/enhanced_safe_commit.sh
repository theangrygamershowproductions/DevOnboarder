#!/usr/bin/env bash
# =============================================================================
# File: scripts/enhanced_safe_commit.sh
# Purpose: Enhanced commit wrapper with proactive whitespace management
# Author: DevOnboarder Project - Universal Development Experience Policy v1.0
# Standards: Implements zero-disruption commit workflow
# =============================================================================

set -euo pipefail

# Store the commit message
COMMIT_MSG="$1"

# Check if pre-commit is installed
if ! command -v pre-commit >/dev/null 2>&1; then
    echo "⚠️  pre-commit not found. Install with: pip install pre-commit"
    echo "📋 For best experience, run once: pre-commit install"
    echo "🔄 Falling back to standard safe commit..."
    exec bash scripts/safe_commit.sh "$COMMIT_MSG"
fi

# Check if virtual environment is activated
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo "Activating virtual environment..."
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

echo "🚀 Enhanced Safe Commit - Zero Disruption Mode"
echo "Commit message: $COMMIT_MSG"

# Step 1: PROACTIVE formatting to prevent hook modifications
echo ""
echo "🔧 Step 1: Proactive file formatting (prevents hook disruption)..."

# Run whitespace and end-of-file formatters on ALL tracked files first
echo "  - Running trailing-whitespace cleanup..."
pre-commit run trailing-whitespace --all-files 2>/dev/null || true

echo "  - Running end-of-file normalization..."
pre-commit run end-of-file-fixer --all-files 2>/dev/null || true

# Step 2: Apply automatic Python/JS formatting
echo "  - Running black formatting..."
pre-commit run black --all-files 2>/dev/null || true

echo "  - Running ruff formatting..."
pre-commit run ruff --all-files 2>/dev/null || true

echo "✅ Proactive formatting complete"

# Step 3: NOW stage the files (they should be pre-formatted)
echo ""
echo "📁 Step 2: Staging files after proactive formatting..."

# Check if there are any changes to stage
if [[ $# -gt 1 ]]; then
    # Specific files provided
    shift  # Remove commit message, leaving file paths
    git add "$@"
    echo "   Staged specified files: $*"
else
    # Stage all tracked changes
    git add -u
    echo "   Staged all tracked changes"
fi

# Get list of staged files for reference
STAGED_FILES=$(git diff --cached --name-only)
if [[ -z "$STAGED_FILES" ]]; then
    echo "❌ No files staged for commit. Nothing to commit."
    exit 1
fi

echo "   Files staged for commit:"
echo "$STAGED_FILES" | while IFS= read -r line; do echo "     $line"; done

# Step 4: Run validation-only hooks (should NOT modify files)
echo ""
echo "🔍 Step 3: Running validation hooks (no file modifications expected)..."

# Run the full pre-commit suite - should be validation only now
if git commit -m "$COMMIT_MSG"; then
    echo ""
    echo "🎉 Commit successful - no hook disruptions!"
    exit 0
else
    COMMIT_EXIT_CODE=$?
    echo ""
    echo "⚠️  Pre-commit validation failed (exit code: $COMMIT_EXIT_CODE)"

    # Check if files were STILL modified despite proactive formatting
    MODIFIED_FILES=$(git diff --name-only)
    if [[ -n "$MODIFIED_FILES" ]]; then
        echo ""
        echo "🚨 UNEXPECTED: Files were modified even after proactive formatting!"
        echo "Modified files:"
        echo "$MODIFIED_FILES" | while IFS= read -r line; do echo "   $line"; done
        echo ""
        echo "This suggests either:"
        echo "  1. A pre-commit hook is not idempotent"
        echo "  2. A new hook was added that we don't handle proactively"
        echo "  3. There's a race condition in the formatting tools"
        echo ""
        echo "🔄 Attempting standard safe commit fallback..."

        # Fall back to the standard safe_commit approach
        echo "$STAGED_FILES" | while read -r file; do
            if [[ -f "$file" ]] && echo "$MODIFIED_FILES" | grep -q "^$file$"; then
                echo "  Re-staging: $file"
                git add "$file"
            fi
        done

        if git commit -m "$COMMIT_MSG"; then
            echo "✅ Commit successful after fallback re-staging"
        else
            FINAL_EXIT_CODE=$?
            echo "❌ CRITICAL: Enhanced safe commit failed completely"
            echo "Please run: bash scripts/safe_commit.sh \"$COMMIT_MSG\""
            exit $FINAL_EXIT_CODE
        fi
    else
        echo ""
        echo "❌ Validation failed but no files were modified."
        echo "This indicates a genuine validation error that needs attention."
        echo ""
        echo "🔍 Common validation failures:"
        echo "  - Linting errors (ruff, eslint)"
        echo "  - Type checking errors (mypy)"
        echo "  - Test failures"
        echo "  - YAML syntax errors"
        echo ""
        echo "💡 Run this to see specific errors:"
        echo "   pre-commit run --all-files"

        exit $COMMIT_EXIT_CODE
    fi
fi
