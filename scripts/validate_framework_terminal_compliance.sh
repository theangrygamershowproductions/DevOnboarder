#!/bin/bash
# Framework Terminal Output Compliance Validator
# Validates framework files for DevOnboarder terminal output policy
# Excludes backup files and focuses on actual source files

set -euo pipefail

LOG_FILE="logs/framework_terminal_validation_$(date %Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Framework Terminal Output Compliance Validation"
echo "Policy: ZERO TOLERANCE for emojis in framework source files"
echo "Target: frameworks/ directory (excluding backup files)"
echo "Scope: .py, .sh, .md files only"

FRAMEWORK_DIR="frameworks"
total_violations=0

# Check if framework directory exists
if [ ! -d "$FRAMEWORK_DIR" ]; then
    echo "No framework directory found - skipping validation"
    exit 0
fi

echo "Scanning framework files in $FRAMEWORK_DIR"

# Find source files, excluding backups
while IFS= read -r -d '' file; do
    echo "Validating: $file"
    file_violations=0

    # Check for emojis and problematic Unicode characters
    if grep -P '[\x{1F600}-\x{1F64F}]|[\x{1F300}-\x{1F5FF}]|[\x{1F680}-\x{1F6FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]|||||GROW:|📥|LINK:|🐛|||🎯|||||🤖' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Terminal-hanging characters found in $file"
        echo "DevOnboarder policy: Use ASCII equivalents (, , etc.)"
        ((file_violations))
    fi

    # For shell/Python files, check for problematic echo patterns
    if [[ "$file" =~ \.(sh|py)$ ]]; then
        # Check for command substitution in echo
        if grep -E '^\s*echo.*\$\(' "$file" 2>/dev/null; then
            echo "CRITICAL VIOLATION: Command substitution in echo found in $file"
            echo "DevOnboarder policy: Use printf or separate command assignment"
            ((file_violations))
        fi

        # Check for variable expansion in echo (Python f-strings are OK)
        if [[ "$file" =~ \.sh$ ]] && grep -E '^\s*echo.*\$[A-Z_]' "$file" 2>/dev/null; then
            echo "CRITICAL VIOLATION: Variable expansion in echo found in $file"
            echo "DevOnboarder policy: Use printf for variable output"
            ((file_violations))
        fi
    fi

    ((total_violations = file_violations))

done < <(find "$FRAMEWORK_DIR" -type f \( -name "*.py" -o -name "*.sh" -o -name "*.md" \) \
    ! -name "*.emoji_fix_backup" \
    ! -name "*.bak" \
    ! -name "*.backup" \
    -print0)

# Summary
if [ "$total_violations" -gt 0 ]; then
    echo "FRAMEWORK COMPLIANCE FAILURE: $total_violations violations found"
    echo "All framework files must use ASCII terminal output only"
    echo "Run scripts/comprehensive_emoji_fix.py to resolve violations"
    exit 1
else
    echo "FRAMEWORK COMPLIANCE  No violations found"
    echo "All framework files comply with terminal output policy"
    exit 0
fi
