#!/bin/bash
# DevOnboarder Universal Workflow Permissions Validator
# Ensures all workflows have explicit permissions per security policy

set -euo pipefail

echo "SYMBOL WORKFLOW PERMISSIONS VALIDATOR"
echo "================================="
echo ""

VIOLATIONS=0
WORKFLOWS_DIR=".github/workflows"

# Check if workflows directory exists
if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    echo "ERROR: Workflows directory not found: $WORKFLOWS_DIR"
    exit 1
fi

echo "SEARCH Scanning workflows for permissions compliance..."
echo ""

# Find all workflow files
for workflow in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    # Skip if no files match pattern
    [[ -f "$workflow" ]] || continue

    filename=$(basename "$workflow")

    # Check if workflow has permissions block
    if ! grep -q "^permissions:" "$workflow"; then
        echo "FAILED VIOLATION: $filename"
        echo "   Missing explicit permissions block"
        echo "   Required: Add 'permissions:' with minimal 'contents: read'"
        echo ""
        ((VIOLATIONS++))
    else
        # Check if it has contents: read at minimum
        if grep -A 5 "^permissions:" "$workflow" | grep -q "contents:.*read"; then
            echo "SUCCESS COMPLIANT: $filename"
        else
            echo "WARNING  WARNING: $filename"
            echo "   Has permissions block but missing 'contents: read'"
            echo "   Review permissions for principle of least privilege"
            echo ""
        fi
    fi
done

echo ""
echo "STATS SUMMARY:"
echo "==========="

if [[ $VIOLATIONS -eq 0 ]]; then
    echo "SUCCESS All workflows have explicit permissions"
    echo "SYMBOL Security compliance: PASS"
    exit 0
else
    echo "FAILED Found $VIOLATIONS workflows missing permissions"
    echo "SYMBOL Security compliance: FAIL"
    echo ""
    echo "IDEA REMEDIATION:"
    echo "Add to affected workflows:"
    echo ""
    echo "permissions:"
    echo "  contents: read"
    echo ""
    echo "SYMBOL Policy: DevOnboarder Universal Workflow Permissions Policy v1.0"
    echo "TARGET Goal: Explicit permissions prevent CodeQL security warnings"
    exit 1
fi
