#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Documentation Structure Validation
# Prevents duplicate headings and enforces heading patterns

set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" ]]; then
    echo "Usage: $0 <markdown-file>"
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "File not found: $FILE"
    exit 1
fi

echo "🔍 Validating documentation structure: $FILE"

# Check for duplicate headings
check_duplicate_headings() {
    check "Checking for duplicate headings..."
    local duplicates
    duplicates=$(grep -h "^##\+ " "$FILE" | sort | uniq -d)
    if [[ -n "$duplicates" ]]; then
        error "Duplicate headings found:"
        echo "$duplicates" | while IFS= read -r line; do
            echo "   - $line"
        done
        return 1
    fi
    success "No duplicate headings found"
}

# Check for generic heading patterns that are likely to duplicate
check_generic_patterns() {
    check "Checking for generic heading patterns..."
    local generic_patterns=("Challenge Description" "Implementation Solutions" "Problem" "Solutions")
    local found_generic=false

    for pattern in "${generic_patterns[@]}"; do
        local count
        count=$(grep -c "^##\+ $pattern" "$FILE" || true)
        if [[ "$count" -gt 1 ]]; then
            warning " Generic pattern '$pattern' used $count times (likely to duplicate)"
            found_generic=true
        fi
    done

    if [[ "$found_generic" == "false" ]]; then
        success "No problematic generic patterns found"
    fi
}

# Suggest improvements for generic headings
suggest_improvements() {
    check "Checking for improvement opportunities..."
    local suggestions_made=false

    if grep -q "### Challenge Description" "$FILE"; then
        echo "💡 Consider domain-specific headings: '### [Domain]: Challenge Analysis'"
        suggestions_made=true
    fi

    if grep -q "### Implementation Solutions" "$FILE"; then
        echo "💡 Consider domain-specific headings: '### [Domain]: Solution Framework'"
        suggestions_made=true
    fi

    if [[ "$suggestions_made" == "false" ]]; then
        success "Heading structure looks good"
    fi
}

# Main validation
echo "======================================"
check_duplicate_headings
check_generic_patterns
suggest_improvements
echo "======================================"
report "Documentation structure validation complete"
