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
cat docs/checklists/continuous-improvement.md >&2

checklist_file="docs/checklists/continuous-improvement.md"
checklist_content=$(cat "$checklist_file")

comment_body=$(cat <<EOF
\xE2\x9A\xA0\xEF\xB8\x8F **Continuous Improvement Checklist is missing or incomplete**

Please review and complete the following checklist before merging:

---

<details>
<summary>\xF0\x9F\x93\x8B Continuous Improvement Checklist</summary>

\`\`\`markdown
$checklist_content
\`\`\`

</details>

Once completed, push an update or comment to rerun checks.
EOF
)

if command -v gh >/dev/null 2>&1; then
  pr_id=$(gh pr view "$pr_number" --json id -q '.id' 2>/dev/null || echo "")
  if [ -n "$pr_id" ]; then
    gh api graphql -F subjectId="$pr_id" -F body="$comment_body" \
      -f query='mutation($subjectId: ID!, $body: String!) { addComment(input:{subjectId:$subjectId, body:$body}) { commentEdge { node { url } } } }' \
      >/dev/null || echo "warning: unable to comment on PR" >&2
  fi
fi

exit 1
