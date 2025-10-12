#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# validate_workflow_permissions.sh - Validate GitHub Actions workflows have explicit permissions

set -euo pipefail

WORKFLOW_DIR=".github/workflows"
EXIT_CODE=0
VIOLATIONS=()

echo "DevOnboarder Workflow Permissions Validator"
echo "==========================================="

if [[ ! -d "$WORKFLOW_DIR" ]]; then
    error "No workflows directory found at $WORKFLOW_DIR"
    exit 1
fi

# Simple validation: check if workflows have permissions blocks
echo "Scanning for workflows missing permissions..."
echo

for workflow in "$WORKFLOW_DIR"/*.yml "$WORKFLOW_DIR"/*.yaml; do
    if [[ ! -f "$workflow" ]]; then
        continue
    fi

    workflow_name=$(basename "$workflow")

    # Check if workflow has permissions at any level
    if grep -q "permissions:" "$workflow"; then
        success "$workflow_name - Has permissions"
    else
        error "$workflow_name - MISSING permissions (security risk)"
        VIOLATIONS+=("$workflow_name")
        EXIT_CODE=1
    fi
done

echo
echo "Summary:"
echo "========"

if [[ ${#VIOLATIONS[@]} -eq 0 ]]; then
    echo "🎉 All workflows have permissions blocks"
else
    echo "🚨 Found ${#VIOLATIONS[@]} workflows missing permissions:"
    printf '   • %s\n' "${VIOLATIONS[@]}"
    echo
    echo "SECURITY ISSUE: These workflows use overly broad default permissions"
    echo
    echo "FIX: Add explicit permissions to each job or workflow:"
    echo "permissions:"
    echo "  contents: read"
    echo "  # Add other minimal permissions as needed"
    echo
    echo "See: docs/WORKFLOW_SECURITY_STANDARDS.md"
fi

exit $EXIT_CODE
