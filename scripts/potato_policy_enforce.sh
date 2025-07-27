#!/usr/bin/env bash
# Enhanced Potato Policy Enforcement
# "Every rule has a scar behind it" - Born from real-world security incidents
# Ensures sensitive files are properly ignored in all ignore files
#
# Protected patterns: .env, .pem, .key, secrets.yaml, Potato.md, and more
# Because automation is better than hoping humans remember
#
# Philosophy: Pain → Protocol → Protection
# This script exists because someone, somewhere, leaked something they shouldn't have.
# Now it's our job to make sure it never happens again.

set -euo pipefail

echo "🥔 Potato Policy Enforcement"
echo "==========================="

# Check and update ignore files
FILES=(.gitignore .dockerignore .codespell-ignore)
REQUIRED=("Potato.md" "*.env" "*.pem" "*.key" "secrets.yaml" "secrets.yml" ".env.local" ".env.production" ".codex/private/" ".codex/cache/" "config/secrets.json" "webhook-config.json")

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
