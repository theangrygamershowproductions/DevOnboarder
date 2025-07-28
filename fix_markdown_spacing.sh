#!/bin/bash

# Fix MD030 list-marker-space and MD007 ul-indent issues across all markdown files
# This script fixes "Expected: 1; Actual: 3" spacing issues and indentation

set -e

echo "🔧 Fixing markdown list marker spacing and indentation issues..."

# Function to fix list marker spacing in a file
fix_file() {
    local file="$1"
    echo "Fixing: $file"

    # Fix MD030: Replace "-   " (dash + 3 spaces) with "- " (dash + 1 space)
    sed -i 's/^-   /- /g' "$file"

    # Fix nested lists with various indentation levels
    # MD007: Fix unordered list indentation (Expected: 4; Actual: 2)
    sed -i 's/^  - /    - /g' "$file"  # 2 spaces -> 4 spaces for nested lists

    # Fix other common patterns
    sed -i 's/^   - / - /g' "$file"    # 3 spaces + dash -> 1 space + dash
    sed -i 's/^    -   /    - /g' "$file"  # 4 spaces + dash + 3 spaces -> 4 spaces + dash + 1 space
    sed -i 's/^     - /    - /g' "$file"   # 5 spaces + dash -> 4 spaces + dash
    sed -i 's/^      - /    - /g' "$file"  # 6 spaces + dash -> 4 spaces + dash
    sed -i 's/^        -   /        - /g' "$file"  # 8 spaces + dash + 3 spaces -> 8 spaces + dash + 1 space
}

echo "🔍 Finding all markdown files..."

# Find all markdown files in the repository, excluding certain directories
find . -name "*.md" \
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
    -not -path "./.git/*" \
    | while read -r file; do
        fix_file "$file"
    done

echo "✅ Markdown spacing and indentation fixes complete!"
echo "🔍 Run markdownlint again to verify fixes..."
