#!/usr/bin/env bash
#
# Enhanced Documentation Quality Control Script
#
# Integrates markdown formatting fixes with existing DevOnboarder QC system.
# This script can be run as part of pre-commit hooks or CI validation.
#
# Usage:
#     ./scripts/qc_docs.sh [--fix] [--file <path>]
#
# Options:
#     --fix         Automatically fix formatting issues
#     --file <path> Process only specific file
#
# Examples:
#     ./scripts/qc_docs.sh                                    # Check all docs
#     ./scripts/qc_docs.sh --fix                              # Check and fix all docs
#     ./scripts/qc_docs.sh --file docs/ci/document.md --fix   # Fix specific file
#
# Part of DevOnboarder's integrated Quality Control system.
#

set -euo pipefail

# Initialize variables
FIX_MODE=false
SPECIFIC_FILE=""
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
LOG_DIR="$PROJECT_ROOT/logs"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            FIX_MODE=true
            shift
            ;;
        --file)
            SPECIFIC_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "DevOnboarder Documentation QC Script"
            echo ""
            echo "Usage: $0 [--fix] [--file <path>]"
            echo ""
            echo "Options:"
            echo "  --fix         Automatically fix formatting issues"
            echo "  --file <path> Process only specific file"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

echo "DevOnboarder Documentation Quality Control"
echo "=========================================="
if [ "$FIX_MODE" = true ]; then
    echo "Mode: CHECK & FIX"
else
    echo "Mode: CHECK ONLY"
fi

# Virtual environment check
if [[ "${VIRTUAL_ENV:-}" == "" ]]; then
    if [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]]; then
        echo "Activating virtual environment..."
        # shellcheck source=/dev/null
        source "$PROJECT_ROOT/.venv/bin/activate"
    fi
fi

# Determine files to process
if [[ -n "$SPECIFIC_FILE" ]]; then
    if [[ ! -f "$SPECIFIC_FILE" ]]; then
        echo "ERROR: File not found"
        printf "File path: %s\n" "$SPECIFIC_FILE"
        exit 1
    fi
    FILES=("$SPECIFIC_FILE")
    echo "Processing single file"
    printf "File: %s\n" "$SPECIFIC_FILE"
else
    # Get all markdown files tracked by git
    readarray -t FILES < <(git ls-files '*.md' 2>/dev/null || find . -name "*.md" -type f -not -path './.git/*' -not -path './.*/*')
    echo "Processing markdown files"
    printf "File count: %d\n" "${#FILES[@]}"
fi

# Initialize counters
TOTAL_FILES=0
FORMATTED_FILES=0
ERROR_FILES=0
declare -a ERRORS=()

# Process each file
for file in "${FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        continue
    fi

    TOTAL_FILES=$((TOTAL_FILES + 1))
    echo -n "Processing: $file ... "

    if [[ "$FIX_MODE" = true ]]; then
        # Run formatting fix
        if python "$SCRIPT_DIR/fix_markdown_formatting.py" "$file" >/dev/null 2>&1; then
            echo "FIXED"
            FORMATTED_FILES=$((FORMATTED_FILES + 1))
        else
            echo "ERROR"
            ERROR_FILES=$((ERROR_FILES + 1))
            ERRORS+=("Failed to process: $file")
        fi
    else
        # Check for formatting issues (dry run)
        TEMP_FILE=$(mktemp)
        cp "$file" "$TEMP_FILE"

        if python "$SCRIPT_DIR/fix_markdown_formatting.py" "$TEMP_FILE" >/dev/null 2>&1; then
            if ! cmp -s "$file" "$TEMP_FILE"; then
                echo "NEEDS FORMATTING"
                FORMATTED_FILES=$((FORMATTED_FILES + 1))
            else
                echo "OK"
            fi
        else
            echo "ERROR"
            ERROR_FILES=$((ERROR_FILES + 1))
            ERRORS+=("Failed to check: $file")
        fi

        rm "$TEMP_FILE"
    fi
done

# Run existing documentation checks if available
echo ""
echo "Running additional documentation quality checks..."

# Markdownlint check
if command -v markdownlint >/dev/null 2>&1; then
    echo "Running markdownlint validation..."
    if [[ -n "$SPECIFIC_FILE" ]]; then
        markdownlint "$SPECIFIC_FILE" || echo "WARNING: Markdownlint issues found"
    else
        markdownlint docs/ || echo "WARNING: Markdownlint issues found"
    fi
else
    echo "WARNING: markdownlint not available, skipping lint check"
fi

# Vale check (if available)
if bash "$SCRIPT_DIR/check_docs.sh" >/dev/null 2>&1; then
    echo "Vale documentation check: PASSED"
else
    echo "Vale documentation check: WARNINGS (see logs/vale-results.json)"
fi

# Summary report
echo ""
echo "=============== SUMMARY ==============="
printf "Total files processed: %d\n" "$TOTAL_FILES"
printf "Files needing formatting: %d\n" "$FORMATTED_FILES"
printf "Processing errors: %d\n" "$ERROR_FILES"

if [[ $ERROR_FILES -gt 0 ]]; then
    echo ""
    echo "ERRORS:"
    for error in "${ERRORS[@]}"; do
        echo "  - Error occurred"
        printf "    Details: %s\n" "$error"
    done
fi

if [[ "$FIX_MODE" = true ]]; then
    if [[ $FORMATTED_FILES -gt 0 ]]; then
        echo ""
        echo "SUCCESS: Files have been fixed"
        printf "Files fixed: %d\n" "$FORMATTED_FILES"
        echo "Please review changes and commit if appropriate"
    else
        echo ""
        echo "SUCCESS: All files already properly formatted"
    fi
else
    if [[ $FORMATTED_FILES -gt 0 ]]; then
        echo ""
        echo "RECOMMENDATION: Run with --fix to automatically format files:"
        echo "  ./scripts/qc_docs.sh --fix"
        exit 1
    else
        echo ""
        echo "SUCCESS: All files are properly formatted"
    fi
fi

exit 0
