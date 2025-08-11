#!/usr/bin/env bash
# Audit Workflow Headers - Ensures every workflow declares token usage and policy compliance
set -eo pipefail  # Removed -u (nounset) temporarily to debug

echo "===== Audit Workflow Headers ====="
echo "Checking all workflows for required header documentation..."

fail=0
total_workflows=0
compliant_workflows=0

# Function to check a single workflow file
check_workflow_headers() {
    local workflow_file="$1"
    local workflow_name
    workflow_name=$(basename "$workflow_file" .yml)

    echo ""
    echo "Checking: $workflow_name"

    local issues=0

    # Check for token documentation (flexible patterns)
    if ! head -n 10 "$workflow_file" | grep -qi 'token\|auth'; then
        echo "  FAILED Missing token usage documentation"
        ((issues++))
    else
        echo "  SUCCESS Token usage documented"
    fi

    # Check for permissions documentation (either explicit block or reference)
    if grep -q "permissions:" "$workflow_file"; then
        echo "  SUCCESS Explicit permissions block present"
    elif head -n 10 "$workflow_file" | grep -qi 'permission\|scope'; then
        echo "  SUCCESS Permissions referenced in header"
    else
        echo "  FAILED Missing permissions documentation"
        ((issues++))
    fi

    # Check for policy compliance reference
    if head -n 15 "$workflow_file" | grep -qi 'no default token policy\|universal.*policy\|compliance'; then
        echo "  SUCCESS Policy compliance referenced"
    else
        echo "  FAILED Missing policy compliance reference"
        ((issues++))
    fi

    # Check for maintenance notes (purpose/scope documentation)
    if head -n 15 "$workflow_file" | grep -qi 'purpose\|role\|maintenance\|scope'; then
        echo "  SUCCESS Purpose/maintenance documentation present"
    else
        echo "  FAILED Missing purpose/maintenance documentation"
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        echo "  TARGET FULLY COMPLIANT"
        # Use temporary variable to avoid set -u issues
        local temp_compliant=$((compliant_workflows + 1))
        compliant_workflows=$temp_compliant
    else
        echo "  WARNING $issues compliance issues found"
        # Use temporary variable to avoid set -u issues
        local temp_fail=$((fail + issues))
        fail=$temp_fail
    fi

    return $issues
}

# Check all workflow files
echo "Scanning .github/workflows/ directory..."

for workflow_file in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [[ -f "$workflow_file" ]]; then
        set +e  # Temporarily disable exit on error
        check_workflow_headers "$workflow_file"
        set -e  # Re-enable exit on error
        total_workflows=$((total_workflows + 1))
    fi
done

echo ""
echo "===== Audit Summary ====="
echo "Total workflows checked: $total_workflows"
echo "Fully compliant workflows: $compliant_workflows"
echo "Workflows with issues: $((total_workflows - compliant_workflows))"
echo "Total compliance issues: $fail"

if [[ $fail -eq 0 ]]; then
    echo ""
    echo "SYMBOL ALL WORKFLOWS COMPLIANT"
    echo "SUCCESS Token usage documented in all workflows"
    echo "SUCCESS Permissions properly declared or referenced"
    echo "SUCCESS Policy compliance verified across all workflows"
    echo "SUCCESS Purpose and maintenance documentation present"
    echo ""
    echo "Workflow headers audit: PASSED"
else
    echo ""
    echo "FAILED WORKFLOW HEADER ISSUES FOUND"
    echo ""
    echo "To fix compliance issues:"
    echo ""
    echo "1. Add token usage documentation to workflow headers:"
    echo "   # TOKEN: CI_ISSUE_AUTOMATION_TOKEN (issue creation, PR management)"
    echo "   # TOKEN: GITHUB_TOKEN (default with explicit permissions)"
    echo ""
    echo "2. Document permissions usage:"
    echo "   # PERMISSIONS: contents:read, issues:write, pull-requests:write"
    echo "   # Or reference: See .codex/bot-permissions.yaml for capabilities"
    echo ""
    echo "3. Reference policy compliance:"
    echo "   # COMPLIANCE: No Default Token Policy v1.0"
    echo "   # COMPLIANCE: Universal Workflow Permissions Policy"
    echo ""
    echo "4. Add purpose documentation:"
    echo "   # PURPOSE: Brief description of workflow purpose"
    echo "   # SCOPE: Files/triggers this workflow covers"
    echo ""
    echo "Example compliant header:"
    echo "# TOKEN: CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN"
    echo "# PERMISSIONS: contents:read, issues:write, pull-requests:write"
    echo "# PURPOSE: Run tests and linting for all pushes and pull requests"
    echo "# COMPLIANCE: Universal Workflow Permissions Policy + No Default Token Policy v1.0"
    echo ""
    exit 1
fi
