#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Terminal Output Policy Enforcement Script - FIXED VERSION
# ZERO TOLERANCE for violations that cause terminal hanging

set -euo pipefail

LOG_FILE="logs/terminal_output_validation_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting Terminal Output Policy Validation (Fixed Version)"
echo "Target: GitHub Actions workflows"
echo "Policy: ZERO TOLERANCE for emojis, command substitution, multi-line variables"

VIOLATIONS=0
WORKFLOW_DIR=".github/workflows"

# Check if workflow directory exists
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "No workflow directory found - skipping validation"
    exit 0
fi

echo "Scanning workflows in $WORKFLOW_DIR"

# Find all workflow files
find "$WORKFLOW_DIR" -name "*.yml" -o -name "*.yaml" | while IFS= read -r file; do
    echo "Validating file: $file"

    # Check for emojis and Unicode characters
    if grep -P '[\x{1F600}-\x{1F64F}]|[\x{1F300}-\x{1F5FF}]|[\x{1F680}-\x{1F6FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]|SUCCESS:|ERROR:|TOOL:|REPORT:|📈|📥|🔗|🐛|WARNING:|💡|TARGET:|DEPLOY:|CHECK:|🔍|NOTE:' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Emoji/Unicode characters found in $file"
        echo "These WILL cause immediate terminal hanging"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # Check for command substitution in echo statements (FIXED: more precise)
    if grep -E '^[[:space:]]*echo[[:space:]].*\$\(' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Command substitution in echo found in $file"
        echo "This WILL cause terminal hanging"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # Check for variable expansion in echo (FIXED: more precise)
    if grep -E '^[[:space:]]*echo[[:space:]].*\$[A-Z_][A-Z0-9_]*' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Variable expansion in echo found in $file"
        echo "This can cause terminal hanging"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # Check for actual multi-line string variables (FIXED: more precise pattern)
    if grep -Pzo '(?s)[A-Z_]+="[^"]*\n[^"]*"' "$file" 2>/dev/null | grep -q .; then
        echo "CRITICAL VIOLATION: Multi-line string variable found in $file"
        echo "This WILL cause terminal hanging"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # Check for here-doc syntax (cat > file << 'EOF')
    if grep -E 'cat[[:space:]]*>[[:space:]]*[^[:space:]]+[[:space:]]*<<[[:space:]]*['"'"']?EOF['"'"']?' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Here-doc syntax found in $file"
        echo "This WILL cause terminal hanging"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # Check for escape sequences in echo commands ONLY (FIXED: exclude printf)
    if grep -E '^[[:space:]]*echo[[:space:]].*\\[nt]' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Escape sequences in echo found in $file"
        echo "This WILL cause terminal hanging"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # NOTE: printf with \n is CORRECT and should NOT be flagged
done

# Check if any violations were found
if [ "$VIOLATIONS" -gt 0 ]; then
    echo "ENFORCEMENT FAILURE: $VIOLATIONS critical violations found"
    echo "These violations WILL cause terminal hanging in DevOnboarder environment"
    echo "ALL violations must be fixed before commit"
    echo "Use only individual echo commands with plain ASCII text"
    exit 1
else
    echo "ENFORCEMENT SUCCESS: No terminal output policy violations found"
    echo "All workflows comply with ZERO TOLERANCE policy"
    exit 0
fi
