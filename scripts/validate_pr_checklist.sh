#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

if [ $# -ne 1 ]; then
  exit 1
fi

pr_number="$1"

# Get PR title and check if it's process-related
# Use multiple fallback methods for robustness
pr_title=""
if command -v gh >/dev/null 2>&1; then
    pr_title=$(gh pr view "$pr_number" --json title -q '.title' 2>/dev/null || echo "")
fi

# If GitHub CLI failed or unavailable, treat as feature PR (safe default)
if [ -z "$pr_title" ]; then
    # No title available - default to feature PR behavior (skip checklist)
    exit 0
fi

# Only require continuous improvement checklist for process/retrospective PRs
# Avoid false positives from conventional commit prefixes like "FEAT(ci):"
if echo "$pr_title" | grep -iE "(retro|retrospective|process|workflow|checklist|improvement|ci.*workflow|automation.*workflow)" >/dev/null; then
    # Process-related PR detected, validate continuous improvement checklist

    pr_body=$(gh pr view "$pr_number" --json body -q '.body' 2>/dev/null || echo "")

    has_heading=$(echo "$pr_body" | grep -Eiq '^#+[[:space:]]*(SUCCESS:[[:space:]]*)?Continuous Improvement Checklist' && echo yes || echo no)
    has_checkbox=$(echo "$pr_body" | grep -Eq '\- \[[ xX]\]' && echo yes || echo no)

    if [ "$has_heading" = "yes" ] && [ "$has_checkbox" = "yes" ]; then
        exit 0
    fi

    # Only fail and comment for process PRs
    checklist_file="docs/checklists/continuous-improvement.md"
    checklist_content=$(cat "$checklist_file")

    comment_body=$(cat <<EOF
WARNING: **Process PR: Continuous Improvement Checklist Required**

This appears to be a process-related PR. Please complete the continuous improvement checklist:

---

<details>
<summary>CHECK: Continuous Improvement Checklist</summary>

\`\`\`markdown
$checklist_content
\`\`\`

</details>

Once completed, push an update or comment to rerun checks.
EOF
)

    if command -v gh >/dev/null 2>&1; then
        tmpfile=$(mktemp)
        printf '%s\n' "$comment_body" > "$tmpfile"
        gh pr comment "$pr_number" --body-file "$tmpfile" >/dev/null \
            || true
        rm -f "$tmpfile"
    fi

    exit 1
else
    # Feature PR - skip continuous improvement checklist validation
    exit 0
fi
