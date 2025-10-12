#!/usr/bin/env bash
COMMIT_MSG="FIX(permissions): make token monitoring scripts executable"
echo "Starting safe commit process..."
printf "Commit message: %s\n" "$COMMIT_MSG"
echo "Validating commit message format..."
COMMIT_MSG_REGEX='^(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|SECURITY|BUILD|REVERT|Build|PERF|CI|OPS|WIP|INIT|TAG|POLICY|HOTFIX|CLEANUP)\([^)]+\): .+'
if ! echo "$COMMIT_MSG" | grep -E "$COMMIT_MSG_REGEX" >/dev/null; then
    echo "ERROR: Invalid commit message format!"
    echo ""
    echo "Required format: <TYPE>(<scope>): <subject>"
    echo ""
    echo "Standard types: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, SECURITY, BUILD, REVERT"
    echo "Extended types: PERF, CI, OPS, WIP, INIT, TAG, POLICY, HOTFIX, CLEANUP"
    echo "Build/Build types allowed for Dependabot compatibility"
    echo ""
    echo "Examples:"
    echo "  FIX(auth): resolve bcrypt password truncation issue"
    echo "  FEAT(ci): add automated dependency updates"
    echo "  CHORE(deps): update Python requirements"
    echo ""
    printf "Your message: %s\n" "$COMMIT_MSG"
    exit 1
fi
echo "Commit message format validated"
