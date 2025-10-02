#!/bin/bash

# validate_internal_links.sh - Validate internal markdown links
# Part of DevOnboarder quality assurance framework

set -euo pipefail

# Setup logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== DevOnboarder Internal Link Validation ==="
echo "Timestamp: $(date)"
echo "Validating internal markdown links..."

# Find all markdown files
echo "Scanning markdown links for internal references..."

# Create temp file to track validation failures across subshells
TEMP_ERROR_FILE=$(mktemp)
trap 'rm -f "$TEMP_ERROR_FILE"' EXIT

# Check markdown links to docs/, scripts/, templates/, etc.
while IFS= read -r -d '' file; do
    echo "Checking: $file"

    # Skip very large files that might hang the validator
    if [[ $(wc -l < "$file") -gt 2000 ]]; then
        echo "  Skipping large file (>2000 lines): $file"
        continue
    fi

    # Extract markdown links: [text](path) - timeout protection
    if links=$(timeout 10s grep -oE '\[([^]]+)\]\(([^)]+)\)' "$file" 2>/dev/null); then
        echo "$links" | while IFS= read -r link; do
        # Extract the path part
        path="${link##*](}"
        path="${path%)}"

        # Skip external links (http, https, mailto, etc.)
        if [[ "$path" =~ ^https?:// ]] || [[ "$path" =~ ^mailto: ]] || [[ "$path" =~ ^#.* ]]; then
            continue
        fi

        # Resolve relative paths
        if [[ "$path" =~ ^\./ ]]; then
            # Relative to file directory
            dir=$(dirname "$file")
            full_path="$dir/${path#./}"
        elif [[ "$path" =~ ^/ ]]; then
            # Absolute path (relative to repo root)
            full_path="${path#/}"
        else
            # Relative path
            dir=$(dirname "$file")
            full_path="$dir/$path"
        fi

        # Normalize path
        full_path=$(realpath -m "$full_path" 2>/dev/null || echo "$full_path")

        # Check if target exists
        if [[ ! -e "$full_path" ]]; then
            echo "ERROR: Broken link in $file"
            echo "  Link: $link"
            echo "  Target: $full_path"
            echo "  Status: File does not exist"
            echo "FAILED" > "$TEMP_ERROR_FILE"
        fi
        done
    else
        echo "  No links found or file processing timed out"
    fi
done < <(find . -name "*.md" -type f -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./.venv/*" -print0)

# Check if any validation failures occurred
if [[ -s "$TEMP_ERROR_FILE" ]]; then
    echo ""
    echo "❌ VALIDATION FAILED: Broken internal links found"
    echo "Please fix the broken links before committing."
    exit 1
else
    echo "✅ All internal links validated successfully"
fi
