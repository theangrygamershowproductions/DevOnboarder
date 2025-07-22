#!/usr/bin/env bash
set -euo pipefail
regex='^(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE)(\([^)]+\))?: .+'
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
    echo "::error ::Commit message '$msg' does not follow <type>(<scope>): <subject> format"
    errors=$((errors+1))
  fi
done <<< "$messages"
if [ $errors -ne 0 ]; then
  echo "::error ::Found $errors commit message(s) that do not follow the required format."
  exit 1
fi
