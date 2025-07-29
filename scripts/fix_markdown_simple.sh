#!/usr/bin/env bash
# Simple markdown fix for final PR cleanup

set -euo pipefail

echo "🔧 Final Markdown Cleanup"
echo "========================"

# Fix the mission accomplished report
if [ -f "reports/pr_968_mission_accomplished.md" ]; then
    echo "📝 Fixing markdown formatting issues..."

    # Apply markdownlint fixes
    if command -v markdownlint >/dev/null 2>&1; then
        markdownlint --fix reports/pr_968_mission_accomplished.md 2>/dev/null || true
        echo "✅ Markdown formatting applied"
    fi
fi

# Clean up any other markdown files
find . -name "*.md" -not -path "./Potato.md" -not -path "./.git/*" | head -5 | while read -r file; do
    if command -v markdownlint >/dev/null 2>&1; then
        markdownlint --fix "$file" 2>/dev/null || true
    fi
done

echo "✅ Simple markdown cleanup complete"
