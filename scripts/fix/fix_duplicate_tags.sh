#!/bin/bash

# Script to fix duplicate documentation tags in frontmatter

echo "Fixing duplicate documentation tags..."

# Find all files with duplicate documentation tags and fix them
find . -name "*.md" -type f | while read -r file; do
    if grep -q "tags:" "$file" && grep -A 10 "tags:" "$file" | grep -q "- documentation" && grep -A 10 "tags:" "$file" | grep -c "- documentation" | grep -q "2"; then
        echo "Fixing duplicate tags in: $file"
        # Use sed to replace duplicate documentation tags
        sed -i '/^tags:/,/^[^[:space:]-]/ {
            /- documentation$/N
            s/- documentation\n- documentation/- documentation/
        }' "$file"
    fi
done

echo "Duplicate tag fix complete!"
