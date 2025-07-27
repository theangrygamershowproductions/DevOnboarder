#!/usr/bin/env bash
# Potato Policy Violation Reporter
# Creates GitHub issues and logs violations with timestamps

set -euo pipefail

# Repository info (used for future extensibility)
export REPO_OWNER="theangrygamershowproductions"
export REPO_NAME="DevOnboarder"
VIOLATION_LOG="logs/potato-violations.log"

echo "🚨 Potato Policy Violation Reporter"
echo "=================================="

# Ensure logs directory exists
mkdir -p logs

# Check for violations
if bash scripts/potato_policy_enforce.sh > /dev/null 2>&1; then
    if ! git diff --quiet; then
        # Check if the only changes are ignore file fixes (auto-remediation)
        CHANGED_FILES=$(git diff --name-only)
        if echo "$CHANGED_FILES" | grep -qvE "^(\.gitignore|\.dockerignore|\.codespell-ignore)$"; then
            # Real violations detected (files other than ignore files changed)
            TIMESTAMP=$(date -Iseconds)
            BRANCH=$(git branch --show-current)
            COMMIT=$(git rev-parse --short HEAD)

            # Log violation
            echo "${TIMESTAMP} | VIOLATION | Branch: ${BRANCH} | Commit: ${COMMIT}" >> "$VIOLATION_LOG"

            # Get diff for context
            DIFF_OUTPUT=$(git diff --name-only)

        # Create GitHub issue if GITHUB_TOKEN is available
        if command -v gh &> /dev/null && [ -n "${GITHUB_TOKEN:-}" ]; then
            ISSUE_TITLE="🥔 Potato Policy Violation Detected on ${BRANCH}"
            ISSUE_BODY="**Violation Details:**
- **Branch:** \`${BRANCH}\`
- **Commit:** \`${COMMIT}\`
- **Timestamp:** ${TIMESTAMP}
- **Files Modified:**
\`\`\`
${DIFF_OUTPUT}
\`\`\`

**Automatic Remediation:**
The Potato Policy enforcement script has automatically corrected the ignore files. Please review and commit the changes.

**Files Protected:**
- Potato.md (SSH keys, secrets)
- *.env files
- *.pem, *.key files
- secrets.yaml/yml files

This issue was created automatically by the Potato Policy violation reporter."

            # Create GitHub issue with proper error handling
            if gh issue create \
                --title "$ISSUE_TITLE" \
                --body "$ISSUE_BODY" \
                --label "security,potato-policy,automated" 2>/dev/null; then
                echo "✅ GitHub issue created successfully"
            else
                echo "⚠️ Failed to create GitHub issue (but violation still logged)"
            fi
        fi

            echo "❌ VIOLATION DETECTED AND LOGGED"
            echo "📝 Log entry: ${VIOLATION_LOG}"
            echo "🔧 Real violations found beyond ignore file auto-fixes"

            exit 1
        else
            # Only ignore files were updated (automatic remediation)
            echo "✅ COMPLIANT - Only ignore files auto-updated"
            echo "🔧 Automatic fixes applied to ignore files"
            exit 0
        fi
    else
        echo "✅ COMPLIANT - No violations detected"
        exit 0
    fi
else
    echo "⚠️ ERROR - Policy enforcement script failed"
    exit 2
fi
