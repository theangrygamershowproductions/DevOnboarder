#!/usr/bin/env bash
# DevOnboarder PR Tracking Issue Creation Script
# Creates GitHub issues automatically when PRs are opened

set -euo pipefail
PR_NUMBER="${1:-}"
PR_TITLE="${2:-No title provided}"
PR_AUTHOR="${3:-unknown}"
PR_BRANCH="${4:-unknown}"

if [[ -z "$PR_NUMBER" ]]; then
    printf 'Usage: %s <pr-number> <pr-title> <pr-author> <pr-branch>\n' "$0"
    exit 1
fi

printf 'Creating tracking issue for PR #%s\n' "$PR_NUMBER"
printf 'Title: %s\n' "$PR_TITLE"
printf 'Author: %s\n' "$PR_AUTHOR"
printf 'Branch: %s\n' "$PR_BRANCH"

# Ensure centralized logging directory exists
mkdir -p logs

# Log file for tracking
LOG_FILE="logs/pr_issue_creation_${PR_NUMBER}.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    printf '[%s] %s\n' "$TIMESTAMP" "$1" | tee -a "$LOG_FILE"
}

log "Starting PR tracking issue creation for #$PR_NUMBER"

# Determine issue type and labels based on PR title and branch
ISSUE_TYPE="feature-development"
PRIORITY="medium"
LABELS="pr-tracking,automated,development"

if [[ "$PR_TITLE" =~ ^FEAT ]]; then
    ISSUE_TYPE="feature-development"
    LABELS="$LABELS,type-feature"
elif [[ "$PR_TITLE" =~ ^FIX ]]; then
    ISSUE_TYPE="bugfix-development"
    LABELS="$LABELS,type-bugfix"
    PRIORITY="high"
elif [[ "$PR_TITLE" =~ ^DOCS ]]; then
    ISSUE_TYPE="documentation-update"
    LABELS="$LABELS,type-documentation"
    PRIORITY="low"
elif [[ "$PR_TITLE" =~ ^CHORE ]]; then
    ISSUE_TYPE="maintenance-task"
    LABELS="$LABELS,type-maintenance"
fi

# Create comprehensive issue title
ISSUE_TITLE="Track PR #$PR_NUMBER: $PR_TITLE"

# Create detailed issue body
ISSUE_BODY=$(cat << EOF
# PR Tracking Issue: #$PR_NUMBER

## SYMBOL Overview

This issue tracks the development and review progress of **Pull Request #$PR_NUMBER**.

### LINK PR Details

- **Title**: $PR_TITLE
- **Author**: @$PR_AUTHOR
- **Branch**: \`$PR_BRANCH\`
- **Type**: $ISSUE_TYPE
- **Priority**: $PRIORITY

### STATS Development Progress

- [ ] **Initial Implementation**: Code changes committed to feature branch
- [ ] **Code Review**: PR reviewed by maintainers
- [ ] **CI/CD Validation**: All automated checks passing
- [ ] **Testing Complete**: Manual testing validated
- [ ] **Documentation Updated**: Any required docs updated
- [ ] **Ready for Merge**: PR approved and ready for integration

### TARGET Acceptance Criteria

**Definition of Done**:
- All CI checks passing (coverage, linting, security)
- Code reviewed and approved by maintainers
- Documentation updated where applicable
- No breaking changes or proper migration provided
- Follows DevOnboarder quality standards

### CONFIG Technical Details

**Implementation Scope**:
- Feature/fix implementation in \`$PR_BRANCH\`
- Integration with existing DevOnboarder architecture
- Compliance with project coding standards

### EDIT Notes

- This issue will be automatically closed when PR #$PR_NUMBER is merged
- Progress updates will be posted as comments
- Links to related issues or dependencies will be added as needed

---

**Automated Tracking**: This issue was created automatically by DevOnboarder PR Issue Automation
**Created**: $(date '+%Y-%m-%d %H:%M:%S')
**PR Link**: https://github.com/$GITHUB_REPOSITORY/pull/$PR_NUMBER
EOF
)

# Use DevOnboarder token hierarchy for issue creation
TOKEN=""
if [[ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]]; then
    TOKEN="$CI_ISSUE_AUTOMATION_TOKEN"
    log "Using CI_ISSUE_AUTOMATION_TOKEN for issue creation"
elif [[ -n "${CI_BOT_TOKEN:-}" ]]; then
    TOKEN="$CI_BOT_TOKEN"
    log "Using CI_BOT_TOKEN for issue creation"
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
    TOKEN="$GITHUB_TOKEN"
    log "Using GITHUB_TOKEN for issue creation"
else
    printf 'ERROR: No GitHub token available for issue creation\n'
    log "ERROR: No GitHub token available"
    exit 1
fi

# Create the GitHub issue
printf 'Creating GitHub issue...\n'

if ISSUE_URL=$(GITHUB_TOKEN="$TOKEN" gh issue create \
    --title "$ISSUE_TITLE" \
    --body "$ISSUE_BODY" \
    --label "$LABELS" 2>&1); then

    ISSUE_NUMBER=$(printf '%s' "$ISSUE_URL" | grep -o '[0-9]\+$')
    printf 'Issue #%s created successfully\n' "$ISSUE_NUMBER"
    printf 'URL: %s\n' "$ISSUE_URL"

    log "Issue #$ISSUE_NUMBER created successfully: $ISSUE_URL"

    # Save issue number for linking
    printf 'Issue #%s\n' "$ISSUE_NUMBER" >> "$LOG_FILE"

    # Add initial progress comment
    PROGRESS_COMMENT="## DEPLOY Development Started

PR #$PR_NUMBER has been opened and is now being tracked.

### SYMBOL Current Status
- **Development Phase**: Implementation in progress
- **Branch**: \`$PR_BRANCH\`
- **Author**: @$PR_AUTHOR

Development progress will be updated as the PR advances through review and validation stages."

    if GITHUB_TOKEN="$TOKEN" gh issue comment "$ISSUE_NUMBER" --body "$PROGRESS_COMMENT" 2>/dev/null; then
        log "Initial progress comment added to issue #$ISSUE_NUMBER"
    else
        log "Could not add initial progress comment"
    fi

else
    printf 'Failed to create GitHub issue\n'
    printf 'Error: %s\n' "$ISSUE_URL"
    log "ERROR: Failed to create issue - $ISSUE_URL"
    exit 1
fi

printf 'PR tracking issue creation complete\n'
log "PR tracking issue creation completed successfully"
