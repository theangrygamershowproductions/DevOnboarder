#!/usr/bin/env bash
# =============================================================================
# File: scripts/fix_workflow_permissions.sh
# Purpose: Add missing permissions blocks to GitHub Actions workflows
# Author: DevOnboarder Project - Universal Workflow Permissions Policy
# Standards: Compliant with copilot-instructions.md and centralized logging policy
# =============================================================================

set -euo pipefail
shopt -s nullglob

echo "SYMBOL WORKFLOW PERMISSIONS AUTO-FIXER"
echo "=================================="
echo ""

FIXED_COUNT=0
SKIPPED_COUNT=0

for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  # Skip if no files match pattern
  [[ -f "$f" ]] || continue

  # Skip if file already has a top-level permissions block (matching validator logic)
  if grep -q "^permissions:" "$f"; then
    echo "SUCCESS OK   $(basename "$f") (has permissions)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    continue
  fi

  # Create backup
  cp "$f" "$f.backup"

  # Simple insertion after the 'on:' block - find the first blank line after 'on:' section
  awk '
    BEGIN { found_on=0; inserted=0 }
    /^on:/ { found_on=1; print; next }
    found_on && !inserted && /^$/ {
      print ""
      print "permissions:"
      print "  contents: read"
      inserted=1
      next
    }
    found_on && !inserted && /^[a-zA-Z]/ && !/^  / {
      print ""
      print "permissions:"
      print "  contents: read"
      print ""
      print
      inserted=1
      next
    }
    { print }
    END {
      if(!inserted) {
        print ""
        print "permissions:"
        print "  contents: read"
      }
    }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  echo "CONFIG FIX  $(basename "$f") (added permissions: contents: read)"
  FIXED_COUNT=$((FIXED_COUNT + 1))
done

echo ""
echo "STATS SUMMARY:"
echo "==========="
echo "SUCCESS Workflows already compliant: $SKIPPED_COUNT"
echo "CONFIG Workflows fixed: $FIXED_COUNT"
echo ""

if [[ $FIXED_COUNT -gt 0 ]]; then
  echo "TARGET Next steps:"
  echo "  1. Review the changes: git diff .github/workflows/"
  echo "  2. Stage changes: git add .github/workflows/"
  echo "  3. Commit: bash scripts/safe_commit.sh \"FIX(ci): add missing permissions blocks to workflows\""
  echo ""
  echo "IDEA Backup files created (.backup) - remove after confirming changes"
else
  echo "SYMBOL All workflows are already compliant!"
fi
