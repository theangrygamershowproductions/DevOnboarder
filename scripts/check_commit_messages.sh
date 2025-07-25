#!/usr/bin/env bash
set -euo pipefail

# Enforce strict conventional commit format per project standards
# Format: <TYPE>(<scope>): <subject> OR <TYPE>: <subject>
# Types must be uppercase: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, CI
regex='^(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|CI)(\([^)]+\))?: .+'

messages=$(git log --format=%s origin/main..HEAD)
if [ -z "$messages" ]; then
  echo "No new commits to lint"
  exit 0
fi
errors=0
while IFS= read -r msg; do
  # Skip merge commits
  if [[ $msg =~ ^Merge ]]; then
    echo "Skipping merge commit: $msg"
    continue
  fi
  if [[ ! $msg =~ $regex ]]; then
    echo "::error ::Commit message '$msg' does not follow <TYPE>(<scope>): <subject> format"
    echo "::error ::Expected format: FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|CI(scope): subject"
    errors=$((errors+1))
  fi
done <<< "$messages"
if [ $errors -ne 0 ]; then
  echo "::error ::Found $errors commit message(s) that do not follow the required format."
  echo "::error ::See scripts/commit-msg for the enforced standard"
  exit 1
fi
