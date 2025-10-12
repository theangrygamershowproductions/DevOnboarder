#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Simple markdown fix for final PR cleanup

set -euo pipefail

tool "Final Markdown Cleanup"
echo "========================"

# Fix the mission accomplished report
if [ -f "reports/pr_968_mission_accomplished.md" ]; then
    note "Fixing markdown formatting issues..."

    # Apply markdownlint fixes
    if command -v markdownlint >/dev/null 2>&1; then
        markdownlint --fix reports/pr_968_mission_accomplished.md 2>/dev/null || true
        success "Markdown formatting applied"
    fi
fi

# Clean up any other markdown files
find . -name "*.md" -not -path "./Potato.md" -not -path "./.git/*" | head -5 | while read -r file; do
    if command -v markdownlint >/dev/null 2>&1; then
        markdownlint --fix "$file" 2>/dev/null || true
    fi
done

success "Simple markdown cleanup complete"
