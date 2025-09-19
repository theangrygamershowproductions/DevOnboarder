#!/bin/bash
# Validate template variable dependencies before cleanup

set -euo pipefail

echo "Validating template variable dependencies..."

# Find all template files
TEMPLATE_DIR="templates/issue-closure"
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "Template directory not found: $TEMPLATE_DIR"
    exit 1
fi

# Extract all variables used in templates
echo "Extracting variables from templates..."
USED_VARS=$(find "$TEMPLATE_DIR" -name "*.md" -exec grep -ho '{[A-Z_]*}' {} \; | sort -u | sed 's/[{}]//g')

echo "Variables used in templates:"
echo "$USED_VARS" | while read -r var; do
    echo "  - $var"
done

# Check if script declares these variables
SCRIPT_FILE="scripts/generate_issue_closure_comment.sh"
if [[ -f "$SCRIPT_FILE" ]]; then
    echo "Checking script variable declarations..."
    MISSING_VARS=""

    echo "$USED_VARS" | while read -r var; do
        if ! grep -q "$var=" "$SCRIPT_FILE"; then
            echo "WARNING: Variable $var used in templates but not declared in script"
            MISSING_VARS="$MISSING_VARS $var"
        fi
    done

    if [[ -n "$MISSING_VARS" ]]; then
        echo "VALIDATION FAILED: Missing variable declarations"
        exit 1
    else
        echo "✅ All template variables are declared in script"
    fi
fi

echo "Template variable validation complete"
