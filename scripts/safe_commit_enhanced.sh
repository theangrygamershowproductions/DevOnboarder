#!/bin/bash

# safe_commit_enhanced.sh - Enhanced safe commit wrapper with improved error handling
# Addresses edge cases in pre-commit hook re-staging failures

set -euo pipefail

# Enhanced re-staging logic for pre-commit hook failures
#
# CRITICAL: This function returns 1 on FATAL errors that indicate repository
# corruption or inconsistency. Callers MUST check the return code:
#
# Example correct usage:
#   if ! handle_precommit_modifications "$msg" "$files" "$attempt"; then
#       echo "FATAL: Pre-commit modification handling failed" >&2
#       exit 1
#   fi
#
# Example INCORRECT usage (silent failure risk):
#   handle_precommit_modifications "$msg" "$files" "$attempt"
#   # Continues execution even on fatal errors!
#
# RECOMMENDED: Use safe_handle_precommit_modifications() instead, which
# automatically enforces proper error handling and prevents silent failures.
#
handle_precommit_modifications() {
    local commit_msg="$1"
    local original_staged_files="$2"
    local attempt_number="${3:-1}"

    echo "=== Pre-commit Hook Modification Handler (Attempt #$attempt_number) ==="

    # Check what files were modified by hooks
    local modified_files
    modified_files=$(git diff --name-only)

    if [[ -z "$modified_files" ]]; then
        echo "No files were modified by pre-commit hooks"
        return 1
    fi

    echo "Files modified by pre-commit hooks:"
    printf "%s\n" "$modified_files" | sed 's/^/  /'

    # Check for unstaged changes that weren't part of original commit
    local unstaged_changes
    unstaged_changes=$(git diff --name-only)

    if [[ -n "$unstaged_changes" ]]; then
        echo " Unstaged changes detected alongside hook modifications"
        echo "Unstaged files:"
        printf "%s\n" "$unstaged_changes" | sed 's/^/  /'
    fi

    # Enhanced re-staging with validation
    echo "Performing enhanced re-staging..."

    # Refresh index to catch mode/perm flips
    git update-index --refresh >/dev/null 2>&1 || true

    # Reset and re-stage with validation
    git reset HEAD --quiet

    # Re-stage files with enhanced validation
    local restaged_count=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            if git add "$file"; then
                printf "   Re-staged: %s\n" "$file"
                ((restaged_count))
            else
                printf "   Failed to re-stage: %s\n" "$file"
                return 1
            fi
        else
            printf "  ⚠ File no longer exists: %s\n" "$file"
        fi
    done <<< "$original_staged_files"

    echo "Re-staged $restaged_count files successfully"

    # Assert clean delta to avoid silent drift
    if ! git diff --quiet --cached; then
        echo "FATAL  Re-stage incomplete: staged delta remains." >&2
        echo "This indicates a critical issue with pre-commit hook modifications." >&2
        echo "Repository state may be inconsistent." >&2
        git status --porcelain
        echo "" >&2
        echo "CRITICAL: This function returns 1 to indicate FATAL failure." >&2
        echo "Callers MUST check return code and treat as fatal error." >&2
        echo "DO NOT proceed with commit operations after this failure." >&2
        return 1
    fi

    # Verify staged files match expectation
    local post_restage_staged
    post_restage_staged=$(git diff --cached --name-only | sort)
    local expected_staged
    expected_staged=$(echo "$original_staged_files" | sort)

    if [[ "$post_restage_staged" != "$expected_staged" ]]; then
        echo " Re-staged files don't match original staging"
        echo "Expected:"
        printf "%s\n" "$expected_staged" | sed 's/^/  /'
        echo "Actually staged:"
        printf "%s\n" "$post_restage_staged" | sed 's/^/  /'
        return 1
    fi

    # Attempt commit with timeout protection
    echo "Attempting commit with enhanced validation..."

    # Run commit in subshell with timeout to prevent hanging
    local commit_output
    local exit_code

    commit_output=$(timeout 60s git commit -m "$commit_msg" 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        echo " Enhanced re-staging commit successful!"
        echo "$commit_output"
        return 0
    else
        if [[ $exit_code -eq 124 ]]; then
            echo " Enhanced re-staging commit timed out after 60 seconds"
            echo "This may indicate hanging pre-commit hooks or slow validation processes"
            echo "Timeout occurred during commit operation"
        else
            echo " Enhanced re-staging commit failed (exit code: $exit_code)"
            echo "$commit_output"
        fi

        # Enhanced diagnostics
        echo ""
        echo "=== Enhanced Diagnostic Information ==="
        echo "Git status:"
        git status --porcelain | sed 's/^/  /'
        echo ""
        echo "Staged files:"
        git diff --cached --name-only | sed 's/^/  /'
        echo ""
        echo "Modified files:"
        git diff --name-only | sed 's/^/  /'
        echo ""

        # Check for specific hook failures
        echo "Checking for specific pre-commit hook issues..."
        if command -v pre-commit >/dev/null 2>&1; then
            echo "Running individual hook diagnostics..."
            pre-commit run --all-files --verbose 2>&1 | tail -20 | sed 's/^/  /'
        fi

        return $exit_code
    fi
}

# Safe wrapper that enforces proper error handling
# This function ensures that fatal errors from handle_precommit_modifications
# are treated as fatal and don't continue execution
safe_handle_precommit_modifications() {
    local commit_msg="$1"
    local original_staged_files="$2"
    local attempt_number="${3:-1}"

    echo "=== Safe Pre-commit Handler Wrapper ==="

    # Set environment variable to indicate proper error handling context
    export SAFE_COMMIT_ERROR_HANDLING=1

    if ! handle_precommit_modifications "$commit_msg" "$original_staged_files" "$attempt_number"; then
        local exit_code=$?
        echo "" >&2
        echo "FATAL: handle_precommit_modifications failed with exit code $exit_code" >&2
        echo "This indicates a critical repository state issue." >&2
        echo "Aborting all commit operations to prevent data loss." >&2
        echo "" >&2
        exit $exit_code
    fi

    echo " Pre-commit modifications handled successfully"

    # Clean up environment variable
    unset SAFE_COMMIT_ERROR_HANDLING
    return 0
}

# Export the functions for use in main safe_commit.sh
# This would be integrated into the existing safe_commit.sh script
echo "Enhanced safe commit handler functions loaded"
echo "Available functions:"
echo "  - handle_precommit_modifications() [REQUIRES EXPLICIT ERROR CHECKING]"
echo "  - safe_handle_precommit_modifications() [RECOMMENDED - ENFORCES ERROR CHECKING]"
echo ""
echo "CRITICAL USAGE NOTES:"
echo "  • handle_precommit_modifications() MUST be called with error checking:"
echo "    if ! handle_precommit_modifications \"\$msg\" \"\$files\" \"\$attempt\"; then"
echo "        echo \"FATAL: Pre-commit handling failed\" >&2"
echo "        exit 1"
echo "    fi"
echo "  • safe_handle_precommit_modifications() automatically handles errors (RECOMMENDED)"
echo "  • Silent failures in commit process can corrupt repository state"
