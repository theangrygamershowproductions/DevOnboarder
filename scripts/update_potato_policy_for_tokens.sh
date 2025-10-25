#!/bin/bash
# =============================================================================
# File: scripts/update_potato_policy_for_tokens.sh
# Purpose: Update Enhanced Potato Policy for Token Architecture v2.0
# Description: Adds .tokens* patterns to all ignore files
# Author: DevOnboarder Team
# Created: 2025-09-04
# =============================================================================

set -euo pipefail

# Token patterns to protect
TOKEN_PATTERNS=(
    ".tokens"
    ".tokens.*"
    "*.tokens"
)

# Files to update
IGNORE_FILES=(
    ".gitignore"
    ".dockerignore"
    ".codespell-ignore"
)

echo "Updating Enhanced Potato Policy for Token Architecture v2.0"

for ignore_file in "${IGNORE_FILES[@]}"; do
    if [ -f "$ignore_file" ]; then
        printf "Updating %s...\n" "$ignore_file"

        # Check if token patterns already exist
        needs_update=false
        for pattern in "${TOKEN_PATTERNS[@]}"; do
            if ! grep -q "^${pattern}$" "$ignore_file" 2>/dev/null; then
                needs_update=true
                break
            fi
        done

        if [ "$needs_update" = "true" ]; then
            # Add token protection section
            echo "" >> "$ignore_file"
            echo "# DevOnboarder Token Architecture v2.0 - Enhanced Potato Policy" >> "$ignore_file"
            for pattern in "${TOKEN_PATTERNS[@]}"; do
                if ! grep -q "^${pattern}$" "$ignore_file" 2>/dev/null; then
                    echo "$pattern" >> "$ignore_file"
                fi
            done
            printf "UPDATED: %s with token patterns\n" "$ignore_file"
        else
            printf "VERIFIED: %s already has token patterns\n" "$ignore_file"
        fi
    else
        printf " %s not found\n" "$ignore_file"
    fi
done

echo "Enhanced Potato Policy updated for Token Architecture v2.0"
