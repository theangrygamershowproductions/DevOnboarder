#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <pr-number>" >&2
  exit 1
fi

pr_number="$1"

body=$(gh pr view "$pr_number" --json body --jq '.body')

has_heading=$(echo "$body" | grep -Eiq '^#+[[:space:]]*(✅[[:space:]]*)?Continuous Improvement Checklist' && echo yes || echo no)
has_checkbox=$(echo "$body" | grep -Eq '\- \[[ xX]\]' && echo yes || echo no)

if [ "$has_heading" = "yes" ] && [ "$has_checkbox" = "yes" ]; then
  exit 0
fi

echo "Continuous Improvement Checklist missing or incomplete" >&2
cat docs/checklists/ci-checklist-snippet.md >&2

if command -v gh >/dev/null 2>&1; then
  gh pr comment "$pr_number" -b "Please include the Continuous Improvement Checklist from docs/checklists/ci-checklist-snippet.md." \
    || echo "warning: unable to comment on PR" >&2
fi

exit 1
