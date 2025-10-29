#!/bin/bash
# scripts/terminal_zero_tolerance_validator.sh
# Comprehensive terminal output violation detection

set -e

echo "DevOnboarder Terminal Zero Tolerance Validator"
echo "=============================================="
echo "Timestamp: $(date)"
echo

# Critical violation patterns that cause hanging
declare -a CRITICAL_PATTERNS=(
    "echo.*[TARGET:]"     # Emojis cause immediate hanging
    "echo.*[≥≤]"                    # Unicode characters cause hanging
    "echo.*\\$\\("                      # Command substitution in echo
    "echo.*\\$\\{"                      # Variable expansion in echo
    "echo -e.*\\\\n"                    # Multi-line escape sequences
    "cat << ['\"]?EOF"                  # Here-doc patterns
    "echo.*\\\\n.*\\\\n"                # Multi-line echo patterns
)

VIOLATION_COUNT=0
TOTAL_FILES=0

# Function to check file for violations
check_file_violations() {
    local file="$1"
    local file_violations=0

    TOTAL_FILES=$((TOTAL_FILES  1))

    echo "Checking: $file"

    # Check for critical violations
    for pattern in "${CRITICAL_PATTERNS[@]}"; do
        if grep -n -E "$pattern" "$file" >/dev/null 2>&1; then
            violations=$(grep -n -E "$pattern" "$file")
            echo "  VIOLATION: $pattern"
            echo "$violations" | while read -r line; do
                echo "    Line: $line"
            done
            file_violations=$((file_violations  1))
        fi
    done

    VIOLATION_COUNT=$((VIOLATION_COUNT  file_violations))

    if [[ $file_violations -eq 0 ]]; then
        echo "  CLEAN: No violations found"
    else
        echo "  VIOLATIONS: $file_violations found"
    fi

    echo
}

# Scan all shell scripts and markdown files
echo "Scanning for terminal output violations..."
echo

# Check shell scripts
find . -name "*.sh" -not -path "./.venv/*" -not -path "./node_modules/*" | while read -r file; do
    check_file_violations "$file"
done

# Check markdown files for code blocks
find . -name "*.md" -not -path "./.venv/*" -not -path "./node_modules/*" | while read -r file; do
    if grep -q '```bash' "$file" || grep -q '```sh' "$file"; then
        check_file_violations "$file"
    fi
done

echo "Terminal Zero Tolerance Validation Complete"
echo "=========================================="
echo "Files scanned: $TOTAL_FILES"
echo "Total violations: $VIOLATION_COUNT"
echo

if [[ $VIOLATION_COUNT -eq 0 ]]; then
    echo " Zero violations found - terminal output policy compliant"
    exit 0
elif [[ $VIOLATION_COUNT -le 10 ]]; then
    echo " $VIOLATION_COUNT violations found - within Phase 1 target"
    exit 1
else
    echo "CRITICAL: $VIOLATION_COUNT violations found - exceeds acceptable threshold"
    exit 2
fi
