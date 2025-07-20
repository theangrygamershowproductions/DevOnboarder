#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <pr-number>" >&2
  exit 1
fi

pr_number="$1"

body=$(gh pr view "$pr_number" --json body --jq '.body')

has_heading=$(echo "$body" | grep -Eiq '^#+[[:space:]]*(✅[[:space:]]*)?Continuous Improvement Checklist' && echo yes || echo no)
has_checkbox=$(echo "$body" | grep -q '\- \[ \]' && echo yes || echo no)

if [ "$has_heading" = "yes" ] && [ "$has_checkbox" = "yes" ]; then
  exit 0
fi

echo "Continuous Improvement Checklist missing or incomplete" >&2
cat docs/checklists/continuous-improvement.md >&2

checklist_file="docs/checklists/continuous-improvement.md"
checklist_content=$(cat "$checklist_file")

comment_body=$(cat <<EOF
\xE2\x9A\xA0\xEF\xB8\x8F **Continuous Improvement Checklist is missing or incomplete**

Please review and complete the following:

```markdown
$checklist_content
```

Once completed, push an update or comment to rerun checks.
EOF
)

if command -v gh >/dev/null 2>&1; then
  gh pr comment "$pr_number" -b "$comment_body" \
    || echo "warning: unable to comment on PR" >&2
fi

exit 1
