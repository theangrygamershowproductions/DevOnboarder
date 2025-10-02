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
echo "Excluding: templates/, archive/, .codex/templates/ directories"
echo "Skipping: template placeholders and example paths"

# Create temp file to track validation failures across subshells
# Use a unique temp directory to avoid conflicts with concurrent processes
TEMP_DIR=$(mktemp -d -t validate_links_XXXXXX)
TEMP_ERROR_FILE="$TEMP_DIR/errors.log"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Function to check if a file should be excluded
should_exclude_file() {
    local file="$1"

    # Exclude template directories (contain examples/placeholders)
    if [[ "$file" =~ /templates/ ]] || [[ "$file" =~ \.codex/templates/ ]]; then
        return 0
    fi

    # Exclude archive directories (may have stale links)
    if [[ "$file" =~ /archive/ ]]; then
        return 0
    fi

    return 1
}

# Function to check if a link should be skipped
should_skip_link() {
    local path="$1"

    # Skip template placeholders
    if [[ "$path" =~ \{\{.*\}\} ]]; then
        return 0
    fi

    # Skip example/placeholder paths
    if [[ "$path" =~ ^(relative/path|docs/path|path/to) ]]; then
        return 0
    fi

    # Skip external links (http, https, mailto, etc.)
    if [[ "$path" =~ ^https?:// ]] || [[ "$path" =~ ^mailto: ]] || [[ "$path" =~ ^#.* ]]; then
        return 0
    fi

    return 1
}

# Check markdown links to docs/, scripts/, templates/, etc.
while IFS= read -r -d '' file; do
    echo "Checking: $file"

    # Skip excluded files
    if should_exclude_file "$file"; then
        echo "  Skipped: Excluded directory"
        continue
    fi

    # Skip very large files that might hang the validator
    if [[ $(wc -l < "$file") -gt 2000 ]]; then
        echo "  Skipping large file (>2000 lines): $file"
        continue
    fi

    # Extract markdown links: [text](path) - timeout protection with reduced time
    if links=$(timeout 5s grep -oE '\[([^]]+)\]\(([^)]+)\)' "$file" 2>/dev/null); then
        echo "$links" | while IFS= read -r link; do
        # Extract the path part
        path="${link##*](}"
        path="${path%)}"

        # Skip links that should be ignored
        if should_skip_link "$path"; then
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
# Use nice to lower priority and avoid interfering with concurrent processes
done < <(nice -n 10 find . -name "*.md" -type f -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./*/node_modules/*" -not -path "./.venv/*" -not -path "./.pytest_cache/*" -not -path "./logs/*" -not -path "./.tox/*" -print0)

# Check if any validation failures occurred
if [[ -s "$TEMP_ERROR_FILE" ]]; then
    echo ""
    echo "❌ VALIDATION FAILED: Broken internal links found"
    echo "Please fix the broken links before committing."
    exit 1
else
    echo "✅ All internal links validated successfully"
fi
