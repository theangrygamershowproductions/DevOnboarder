#!/bin/bash

# Bulk fix for all markdown files
set -e

echo "Starting markdown fixes..."

# Fix MD030 and MD007 issues
for file in $(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.venv/*"); do
    echo "Processing: $file"

    # MD030: Fix list marker spacing (dash + 3 spaces -> dash + 1 space)
    sed -i 's/^-   /- /g' "$file"

    # MD007: Fix nested list indentation (2 spaces -> 4 spaces)
    sed -i 's/^  - /    - /g' "$file"

    # Fix other common patterns
    sed -i 's/^   - / - /g' "$file"
    sed -i 's/^    -   /    - /g' "$file"
    sed -i 's/^     - /    - /g' "$file"
    sed -i 's/^      - /    - /g' "$file"
    sed -i 's/^        -   /        - /g' "$file"
done

# Fix specific MD041 issue in journal file
if [[ -f "codex/journal/2025-07-05.md" ]]; then
    echo "Fixing MD041 in journal file..."
    sed -i '1i# DevOnboarder Journal - July 5, 2025\n' "codex/journal/2025-07-05.md"
fi

echo "Markdown fixes completed!"
