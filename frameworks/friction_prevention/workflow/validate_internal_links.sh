#!/bin/bash

# validate_internal_links.sh - Validate internal markdown links
# Part of DevOnboarder quality assurance framework

set -euo pipefail

# Setup logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== DevOnboarder Internal Link Validation ==="
echo "Timestamp: $(date)"
echo "Validating internal markdown links..."

# Counters for metrics
files_scanned=0
broken_count=0

# Create temp file to track validation failures across parallel processes
TEMP_DIR=$(mktemp -d -t validate_links_XXXXXX)
TEMP_COUNTER_FILE="$TEMP_DIR/counters"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Initialize counters file
echo "0 0" > "$TEMP_COUNTER_FILE"

# Function to validate a single file's links
validate_file_links() {
    local file="$1"
    local temp_dir="$2"
    local local_broken=0
    local local_scanned=1

    # Skip excluded directories
    if [[ "$file" =~ /templates/ ]] || [[ "$file" =~ \.codex/templates/ ]] || [[ "$file" =~ ^archive/ ]]; then
        return 0
    fi

    # Skip very large files that might hang the validator
    if [[ $(wc -l < "$file" 2>/dev/null || echo "0") -gt 2000 ]]; then
        echo "  Skipping large file (>2000 lines): $file"
        return 0
    fi

    echo "Checking: $file"

    # Extract markdown links: [text](path) - timeout protection
    if links=$(timeout 5s grep -oE '\[([^]])\]\(([^)])\)' "$file" 2>/dev/null); then
        echo "$links" | while IFS= read -r link; do
            # Extract the path part
            path="${link##*](}"
            path="${path%)}"

            # Skip external links
            if [[ "$path" =~ ^https?:// ]] || [[ "$path" =~ ^mailto: ]]; then
                continue
            fi

            # Skip template placeholders and examples
            if [[ "$path" =~ \{\{.*\}\} ]] || [[ "$path" =~ ^(relative/path|docs/path|path/to) ]]; then
                continue
            fi

            # Handle fragment-only links (e.g., #section)
            if [[ "$path" =~ ^#(.) ]]; then
                fragment="${BASH_REMATCH[1]}"

                # Use GitHub-style anchor checking with duplicate handling
                if command -v python3 >/dev/null 2>&1 && [[ -f "scripts/anchors_github.py" ]]; then
                    mkdir -p logs
                    if ! anchors_json="$(python3 scripts/anchors_github.py < "$file" 2>logs/anchors_github_error.log)"; then
                        echo " anchors_github.py failed for $file. See logs/anchors_github_error.log for details." >&2
                        anchors_json='{"anchors":[]}'
                    fi
                    if ! printf '%s' "$anchors_json" | grep -q "\"$fragment\""; then
                        echo " Broken fragment link in $file"
                        echo "  Link: $link"
                        echo "  Target: $file#$fragment"
                        echo "  Status: Section does not exist"
                        echo "FAILED" >> "$temp_dir/errors.log"
                        local_broken=$((local_broken  1))
                        continue
                    fi
                else
                    # Fallback: direct text search in headers
                    if ! grep -Eq "^#{1,6} .*${fragment}.*" "$file"; then
                        echo " Broken fragment link in $file"
                        echo "  Link: $link"
                        echo "  Target: $file#$fragment"
                        echo "  Status: Section does not exist"
                        echo "FAILED" >> "$temp_dir/errors.log"
                        local_broken=$((local_broken  1))
                        continue
                    fi
                fi
                continue
            fi

            # Resolve relative/absolute paths
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
                echo " Broken link in $file"
                echo "  Link: $link"
                echo "  Target: $full_path"
                echo "  Status: File does not exist"
                echo "FAILED" >> "$temp_dir/errors.log"
                local_broken=$((local_broken  1))
            fi
        done
    fi

    # Update shared counters atomically
    (
        flock -x 200
        read -r current_scanned current_broken < "$temp_dir/counters"
        echo "$((current_scanned  local_scanned)) $((current_broken  local_broken))" > "$temp_dir/counters"
    ) 200>"$temp_dir/counters.lock"
}

# Export function for xargs
export -f validate_file_links

# Get list of markdown files efficiently
echo "Scanning markdown files..."
mapfile -t files < <(git ls-files -- '**/*.md' ':!:node_modules/**' ':!:.venv/**' ':!:.git/**' ':!:.pytest_cache/**' ':!:logs/**' ':!:.tox/**')

echo "Found ${#files[@]} markdown files to validate"

# Limit parallelism to avoid overwhelming the system
MAX_PROCS=$(($(nproc)<8 ? $(nproc) : 8))
# Process files in parallel
printf "%s\n" "${files[@]}" | xargs -n1 -P"$MAX_PROCS" -I {} bash -c 'validate_file_links "$@"' _ {} "$TEMP_DIR"

# Count actual errors from error log
if [[ -s "$TEMP_DIR/errors.log" ]]; then
    broken_count=$(wc -l < "$TEMP_DIR/errors.log")
else
    broken_count=0
fi
files_scanned=${#files[@]}

# Generate metrics report
report="logs/link_validation_report.json"
mkdir -p logs
printf '{ "ts":"%s","files_scanned":%d,"broken":%d }\n' \
  "$(date -u %FT%TZ)" "$files_scanned" "$broken_count" > "$report"
echo "Report: $report"

# Check if any validation failures occurred
if [[ $broken_count -gt 0 ]]; then
    echo ""
    echo " VALIDATION FAILED: $broken_count broken internal links found in $files_scanned files"
    echo "Please fix the broken links before committing."
    exit 1
else
    echo " All internal links validated successfully ($files_scanned files checked)"
fi
