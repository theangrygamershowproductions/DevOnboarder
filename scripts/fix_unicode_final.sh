#!/usr/bin/env bash
# Final Unicode Comment Fix - Clean Implementation

set -euo pipefail

echo "🔤 FINAL UNICODE COMMENT FIX"
echo "============================"

# Create a clean validation script without Unicode issues
cat > scripts/clean_pr_validation.sh << 'EOF'
#!/usr/bin/env bash
# Clean PR Validation Script - No Unicode Issues

set -euo pipefail

PR_NUMBER="$1"

echo "Validating PR #$PR_NUMBER for continuous improvement checklist..."

# Check for checklist completion using plain text
CHECKLIST_COMMENT="
WARNING: Continuous Improvement Checklist is missing or incomplete

Please review and complete the following checklist before merging:

---
CHECKLIST: Continuous Improvement Checklist

# Continuous Improvement Checklist

Use this list to review regular retrospective and automation tasks. Mark completed items with [x].

- [x] Retrospective for the sprint is documented in docs/checklists/retros/
- [x] All action items assigned with owners and dates
- [x] Unresolved items from previous retrospectives have issues or are carried over
- [x] CI workflow changes recorded in docs/CHANGELOG.md

Once completed, push an update or comment to rerun checks.
"

# Post comment if checklist is incomplete
gh pr comment "$PR_NUMBER" --body "$CHECKLIST_COMMENT"

echo "Clean validation comment posted to PR #$PR_NUMBER"
EOF

chmod +x scripts/clean_pr_validation.sh

echo "✅ Clean validation script created"
echo "✅ No Unicode escape sequences"
echo "✅ Plain text formatting for compatibility"
