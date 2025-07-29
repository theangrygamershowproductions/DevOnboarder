#!/bin/bash

# Comprehensive markdown linting fix script
# Fixes MD030 list-marker-space errors across all markdown files

set -e

echo "🔧 Comprehensive markdown linting fixes..."

# Function to fix all common markdown issues in a file
fix_markdown_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "⚠️  File not found: $file"
        return
    fi

    echo "🔨 Fixing: $file"

    # Fix MD030: list-marker-space issues
    # Replace "-   " (dash + 3 spaces) with "- " (dash + 1 space)
    sed -i 's/^-   /- /g' "$file"

    # Fix nested list items with various indentation patterns
    sed -i 's/^    -   /  - /g' "$file"   # 4 spaces + dash + 3 spaces -> 2 spaces + dash + 1 space
    sed -i 's/^        -   /    - /g' "$file" # 8 spaces + dash + 3 spaces -> 4 spaces + dash + 1 space

    # Fix numbered lists with extra spaces
    sed -i 's/^\([0-9]\+\)\.   /\1\. /g' "$file"

    # Fix asterisk list markers
    sed -i 's/^\*   /* /g' "$file"
    sed -i 's/^    \*   /  * /g' "$file"

    # Fix plus list markers
    sed -i 's/^+   /+ /g' "$file"
    sed -i 's/^    +   /  + /g' "$file"
}

# Fix all markdown files in the repository
echo "🔍 Finding all markdown files..."

# Find all .md files excluding node_modules, .venv, etc.
find . -name "*.md" -type f \
    -not -path "./node_modules/*" \
    -not -path "./frontend/node_modules/*" \
    -not -path "./bot/node_modules/*" \
    -not -path "./htmlcov/*" \
    -not -path "./.venv/*" \
    -not -path "./venv/*" \
    -not -path "./*.egg-info/*" \
    -not -path "./archive/*" \
    -not -path "./logs/*" \
    -not -path "./tmp/*" \
    -not -path "./.git/*" | while read -r file; do
    fix_markdown_file "$file"
done

echo "✅ Markdown fixes complete!"
echo "🧪 Testing with markdownlint..."

# Test a few key files to see if issues are resolved
if command -v npx >/dev/null 2>&1; then
    echo "Testing sample files..."
    npx markdownlint-cli2 --config .markdownlint.json README.md CONTRIBUTING.md SECURITY.md 2>/dev/null || echo "Some issues may remain - full scan needed"
else
    echo "npx not available - skipping test"
fi

echo "🎉 Script complete! Run 'npx markdownlint-cli2' to verify all fixes."
