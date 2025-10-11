#!/bin/bash

# Pre-commit hook to enforce AI context management standards
# Version: 1.0 | Created: 2025-01-10

# Note: Removed 'set -e' to allow script to continue and show all issues

echo "🤖 Running AI Context Management Quality Checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTRUCTION_EXTENSIONS=("md" "txt" "rst")
REQUIRED_SECTIONS=("Goal & Context" "Requirements & Constraints" "Use Cases" "Dependencies")
MAX_LINE_LENGTH=120
MIN_EXAMPLE_COUNT=1

# Counters
WARNINGS=0
ERRORS=0
FILES_CHECKED=0

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check if file is an instruction file
is_instruction_file() {
    local file="$1"
    
    # Check by directory (instructions, docs, .github)
    if [[ "$file" =~ (instructions|docs|\.github)/ ]]; then
        return 0
    fi
    
    # Check by filename pattern
    if [[ "$file" =~ (instruction|template|guide|setup|README) ]]; then
        return 0
    fi
    
    return 1
}

# Check for required metadata in header
check_metadata() {
    local file="$1"
    local has_version=false
    local has_updated=false
    
    # Look for metadata in first 10 lines
    head -10 "$file" | while read -r line; do
        if [[ "$line" =~ Version:|v[0-9] ]]; then
            has_version=true
        fi
        if [[ "$line" =~ (Updated:|Last.Modified:|Created:) ]]; then
            has_updated=true
        fi
    done
    
    if ! head -10 "$file" | grep -q "Version:\|v[0-9]"; then
        log_warning "$file: Missing version information in header"
    fi
    
    if ! head -10 "$file" | grep -q "Updated:\|Last.Modified:\|Created:"; then
        log_warning "$file: Missing timestamp information in header"
    fi
}

# Check for required sections
check_required_sections() {
    local file="$1"
    local missing_sections=()
    
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -qi "## $section\|# $section" "$file"; then
            missing_sections+=("$section")
        fi
    done
    
    if [ ${#missing_sections[@]} -gt 0 ]; then
        log_error "$file: Missing required sections: ${missing_sections[*]}"
    fi
}

# Check for examples and use cases
check_examples() {
    local file="$1"
    local example_count=0
    
    # Count code blocks, input/output examples, and use case sections
    example_count=$(grep -c '\`\`\`\|Input:\|Expected:\|Example:' "$file" 2>/dev/null || echo "0")
    
    if [ "$example_count" -lt "$MIN_EXAMPLE_COUNT" ]; then
        log_warning "$file: Insufficient examples (found: $example_count, minimum: $MIN_EXAMPLE_COUNT)"
    fi
}

# Check for vague language
check_vague_language() {
    local file="$1"
    local vague_patterns=(
        "should probably"
        "might want to"
        "could be"
        "sort of"
        "kind of"
        "maybe"
        "perhaps"
        "TODO"
        "FIXME"
        "\\[placeholder\\]"
        "\\[fill.in\\]"
        "\\[replace.with\\]"
    )
    
    for pattern in "${vague_patterns[@]}"; do
        if grep -qi "$pattern" "$file"; then
            log_warning "$file: Contains vague language: '$pattern'"
        fi
    done
}

# Check line length
check_line_length() {
    local file="$1"
    local line_num=0
    
    while IFS= read -r line; do
        ((line_num++))
        if [ ${#line} -gt $MAX_LINE_LENGTH ]; then
            log_warning "$file:$line_num: Line exceeds $MAX_LINE_LENGTH characters (${#line})"
        fi
    done < "$file"
}

# Check for acceptance criteria
check_acceptance_criteria() {
    local file="$1"
    
    if ! grep -qi "acceptance criteria\|success criteria\|done when\|complete when" "$file"; then
        log_warning "$file: Missing explicit acceptance criteria"
    fi
}

# Check specific file
check_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi
    
    log_info "Checking $file..."
    ((FILES_CHECKED++))
    
    # Run all checks
    check_metadata "$file"
    check_required_sections "$file"
    check_examples "$file"
    check_vague_language "$file"
    check_line_length "$file"
    check_acceptance_criteria "$file"
}

# Main execution
main() {
    local files_to_check=()
    
    # If arguments provided, check those files
    if [ $# -gt 0 ]; then
        files_to_check=("$@")
    else
        # Find all instruction files (try git first, fallback to find)
        if git rev-parse --git-dir >/dev/null 2>&1; then
            while IFS= read -r file; do
                if is_instruction_file "$file"; then
                    files_to_check+=("$file")
                fi
            done < <(git ls-files)
        else
            # Fallback to find command
            while IFS= read -r -d '' file; do
                if is_instruction_file "$file"; then
                    files_to_check+=("$file")
                fi
            done < <(find . -name "*.md" -o -name "*.txt" -o -name "*.rst" -print0 2>/dev/null)
        fi
    fi
    
    if [ ${#files_to_check[@]} -eq 0 ]; then
        log_info "No instruction files found to check"
        exit 0
    fi
    
    # Check each file
    for file in "${files_to_check[@]}"; do
        check_file "$file"
    done
    
    # Summary
    echo ""
    echo "🤖 AI Context Management Quality Check Summary:"
    echo "  Files checked: $FILES_CHECKED"
    echo "  Warnings: $WARNINGS"
    echo "  Errors: $ERRORS"
    
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}❌ Quality check failed with $ERRORS errors${NC}"
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Quality check passed with $WARNINGS warnings${NC}"
        exit 0
    else
        echo -e "${GREEN}✅ All quality checks passed!${NC}"
        exit 0
    fi
}

# Show help
show_help() {
    cat << EOF
AI Context Management Quality Checker

USAGE:
    $0 [OPTIONS] [FILES...]

OPTIONS:
    -h, --help     Show this help message
    --fix          Attempt to auto-fix common issues (not implemented yet)

EXAMPLES:
    $0                                  # Check all instruction files
    $0 README.md docs/setup.md         # Check specific files
    $0 --help                          # Show help

This script enforces AI context management standards including:
- Required metadata (version, timestamps)
- Structured sections (Goal & Context, Requirements, Use Cases, Dependencies)
- Sufficient examples and use cases
- Clear, unambiguous language
- Explicit acceptance criteria
- Reasonable line lengths

For more information, see .github/instruction-template.md
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --fix)
            log_info "Auto-fix mode not implemented yet"
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Run main function with remaining arguments
main "$@"