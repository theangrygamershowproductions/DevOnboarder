#!/bin/bash
# DevOnboarder Fix PR Automation Script
# Usage: ./scripts/create_fix_pr.sh <component> <short-description> [files...]
#
# Example: ./scripts/create_fix_pr.sh "ci" "add missing checkout step" ".github/workflows/close-codex-issues.yml"

set -euo pipefail

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <component> <short-description> [files...]"
    echo "Example: $0 ci 'add missing checkout step' .github/workflows/close-codex-issues.yml"
    exit 1
fi

COMPONENT="$1"
DESCRIPTION="$2"
shift 2
FILES=("$@")

# Generate branch name (sanitized)
BRANCH_NAME="fix/${COMPONENT}-$(echo "$DESCRIPTION" | tr ' ' '-' | tr -cd '[:alnum:]-')"

# Create branch
echo "Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

# Stage files (if specified, otherwise stage all modified)
if [ ${#FILES[@]} -gt 0 ]; then
    echo "Staging specified files: ${FILES[*]}"
    git add "${FILES[@]}"
else
    echo "No files specified, staging all changes"
    git add -A
fi

# Create commit message
COMMIT_MSG="FIX($COMPONENT): $DESCRIPTION"

# Use safe commit (DevOnboarder standard)
echo "Committing with message: $COMMIT_MSG"
./scripts/safe_commit.sh "$COMMIT_MSG"

# Push branch
echo "Pushing branch to remote..."
git push -u origin "$BRANCH_NAME"

# Create PR body (avoiding shell interpretation issues)
PR_TITLE="FIX($COMPONENT): $DESCRIPTION"

# Write PR body to temp file to avoid shell interpretation
TEMP_BODY=$(mktemp)
cat > "$TEMP_BODY" << 'EOF'
## Problem

Automated fix PR for CI/workflow issues.

## Solution

This PR addresses the identified issue through targeted fixes.

## Files Changed

See commit details for specific changes made.

## Testing

- [ ] All CI checks must pass
- [ ] Manual testing if required
- [ ] Follow-up validation

## DevOnboarder Standards

- Uses safe_commit.sh for quality gates
- Follows conventional commit format
- Automated PR creation process
EOF

# Create PR using temp file
echo "Creating pull request..."
gh pr create --title "$PR_TITLE" --body-file "$TEMP_BODY"

# Cleanup
rm "$TEMP_BODY"

echo " Fix PR created successfully!"
echo "Branch: $BRANCH_NAME"
echo "Next steps: Review and merge when CI passes"
