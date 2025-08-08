#!/bin/bash
# Smart Markdown Fixer for DevOnboarder
# Integrates intelligent auto-fixing with existing markdownlint workflow

set -euo pipefail

# Change to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "Smart Markdown Fixer: Implementing 'Quiet Reliability' philosophy"
echo

# Step 1: Run intelligent auto-fixer for obvious patterns
echo "Step 1: Applying intelligent pattern recognition..."
python scripts/intelligent_markdown_fixer.py "$@"
echo

# Step 2: Run standard markdownlint auto-fix for remaining issues
echo "Step 2: Running standard markdownlint auto-fix..."
npx markdownlint-cli2 --fix "$@"
echo

# Step 3: Final validation
echo "Step 3: Final validation..."
if npx markdownlint-cli2 "$@"; then
    echo "✅ All markdown files are now compliant!"
else
    echo "⚠️  Some manual fixes may still be required for complex cases"
    echo "   Run 'npx markdownlint-cli2 \$FILES' to see remaining issues"
fi
