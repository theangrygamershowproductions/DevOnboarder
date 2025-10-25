#!/bin/bash

# Clean Existing Markdown Compliance Violations
# Removes emojis from existing script-generated markdown files
# Part of Issue #1315 - Markdown compliance automation

set -euo pipefail

echo "Cleaning existing markdown compliance violations"
echo "Target: Remove emojis from legacy generated markdown files"
echo "Timestamp: $(date)"
echo ""

CLEANED=0
REPORTS_DIR="reports"
AAR_DIR=".aar"
LOGS_DIR="logs"
BACKUP_DIR="$LOGS_DIR/markdown_cleanup_backup_$(date %Y%m%d_%H%M%S)"

# Create backup and logs directories
mkdir -p "$BACKUP_DIR" "$LOGS_DIR"

# Function to clean emojis from a file
clean_file_emojis() {
    local file="$1"
    local backup_file
    backup_file="$BACKUP_DIR/$(basename "$file")"

    echo "Cleaning: $file"

    # Create backup
    cp "$file" "$backup_file"

    # Remove common emojis used in DevOnboarder markdown generation
    sed -i 's///g; s///g; s/🎯//g; s///g; s///g; s///g; s///g; s///g; s///g; s///g' "$file"

    CLEANED=$((CLEANED  1))
}

echo "Phase 1: Cleaning reports directory"
echo "==================================="

if [[ -d "$REPORTS_DIR" ]]; then
    echo "Processing $REPORTS_DIR..."
    while IFS= read -r -d '' file; do
        # Check if file contains emojis before cleaning
        if grep -q "\|\|🎯\|\|\|\|\|\|\|" "$file" 2>/dev/null; then
            clean_file_emojis "$file"
        fi
    done < <(find "$REPORTS_DIR" -name "*.md" -type f -print0)
fi

echo ""
echo "Phase 2: Cleaning AAR directory"
echo "================================"

if [[ -d "$AAR_DIR" ]]; then
    echo "Processing $AAR_DIR..."
    while IFS= read -r -d '' file; do
        # Check if file contains emojis before cleaning
        if grep -q "\|\|🎯\|\|\|\|\|\|\|" "$file" 2>/dev/null; then
            clean_file_emojis "$file"
        fi
    done < <(find "$AAR_DIR" -name "*.md" -type f -print0)
fi

echo ""
echo "Phase 3: Validation"
echo "==================="

# Run validation to confirm cleanup
if ./scripts/validate_markdown_compliance.sh; then
    echo ""
    echo " All markdown compliance violations cleaned"
    echo "Files cleaned: $CLEANED"
    echo "Backup location: $BACKUP_DIR"
else
    echo ""
    echo " Some violations may still exist"
    echo "Manual review may be needed"
fi

echo ""
echo "Cleanup Summary:"
echo "- Files processed: $CLEANED"
echo "- Backup directory: $BACKUP_DIR"
echo "- Next: Re-run validation to confirm compliance"
