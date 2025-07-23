#!/usr/bin/env bash
# Enhanced Potato Policy Enforcement
# Ensures Potato.md is properly ignored in all ignore files

set -euo pipefail

echo "🥔 Potato Policy Enforcement"
echo "==========================="

# Check and update ignore files
FILES=(.gitignore .dockerignore .codespell-ignore)
REQUIRED=("Potato.md")

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        for entry in "${REQUIRED[@]}"; do
            if ! grep -q "^${entry}$" "$file"; then
                echo "Adding $entry to $file"
                echo "$entry" >> "$file"
            fi
        done
        echo "✅ $file updated"
    else
        echo "⚠️  $file not found, creating..."
        for entry in "${REQUIRED[@]}"; do
            echo "$entry" >> "$file"
        done
        echo "✅ $file created"
    fi
done

echo "🥔 Potato policy enforcement complete"
