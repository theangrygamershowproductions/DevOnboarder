#!/usr/bin/env bash
set -euo pipefail

# Enforce strict conventional commit format per project standards
# Format: <TYPE>(<scope>): <subject>
# Standard types: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, SECURITY, BUILD, REVERT
# Extended types: PERF, CI, OPS, WIP, INIT, TAG, POLICY, HOTFIX, CLEANUP
# Exception: Build (title case) allowed for Dependabot compatibility
# The <scope> section is optional, matching the commit-msg hook
regex='^(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|SECURITY|BUILD|REVERT|Build|PERF|CI|OPS|WIP|INIT|TAG|POLICY|HOTFIX|CLEANUP)(\([^)]+\))?: .+'

messages=$(git log --format=%s origin/main..HEAD)
if [ -z "$messages" ]; then
  echo "No new commits to lint"
  exit 0
fi

# Use a temp file approach instead of while loop
temp_file=$(mktemp)
echo "$messages" > "$temp_file"

errors=0
while IFS= read -r msg || [ -n "$msg" ]; do
  # Skip empty lines
  [ -z "$msg" ] && continue

  # Skip merge commits
  if [[ $msg =~ ^Merge ]]; then
    echo "Skipping merge commit: $msg"
    continue
  fi

  # Legacy commit exceptions - allow these specific patterns during transition
  if [[ $msg =~ ^(RESOLVE:|Revert) ]]; then
    echo "Skipping legacy commit format: $msg"
    continue
  fi

  if ! echo "$msg" | grep -E "$regex" >/dev/null; then
    echo "::error ::Commit message '$msg' does not follow <TYPE>(<scope>): <subject> format"
    echo "::error ::Expected format: Standard types: FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|SECURITY|BUILD|REVERT"
    echo "::error ::Extended types: PERF|CI|OPS|WIP|INIT|TAG|POLICY|HOTFIX|CLEANUP or Build(deps): for Dependabot"
    errors=$((errors+1))
  fi
done < "$temp_file"

rm -f "$temp_file"

if [ $errors -ne 0 ]; then
  echo "::error ::Found $errors commit message(s) that do not follow the required format."
  echo "::error ::See scripts/commit-msg for the enforced standard"
  exit 1
fi

echo "SUCCESS: All commit messages pass validation!"
