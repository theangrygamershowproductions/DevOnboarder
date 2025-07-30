#!/usr/bin/env bash
set -euo pipefail

# Enforce strict conventional commit format per project standards
# Format: <TYPE>(<scope>): <subject>
# Types must be uppercase: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE
# Optional `[no-ci]` prefix skips the CI workflow
regex='^(\[no-ci\]\s*)?(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE)(\([^)]+\))?: .+'

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

  if ! echo "$msg" | grep -E "$regex" >/dev/null; then
    echo "::error ::Commit message '$msg' does not follow <TYPE>(<scope>): <subject> format"
    echo "::error ::Expected format: FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|CI(scope): subject"
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
