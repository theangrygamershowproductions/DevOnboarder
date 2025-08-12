#!/usr/bin/env bash
# Fix Workflow Headers - Add required header documentation to all workflows
set -eo pipefail

echo "===== Fix Workflow Headers ====="
echo "Adding required header documentation to all non-compliant workflows..."

# Function to add headers to a workflow file
add_workflow_headers() {
    local workflow_file="$1"
    local workflow_name
    workflow_name=$(basename "$workflow_file" .yml)

    echo "Processing: $workflow_name"

    # Check if headers already exist
    if head -n 5 "$workflow_file" | grep -q "# TOKEN:"; then
        echo "  SKIP: Headers already present"
        return 0
    fi

    # Determine appropriate headers based on workflow name and content
    local token_doc="# TOKEN: GITHUB_TOKEN (default with explicit permissions)"
    local permissions_doc="# PERMISSIONS: contents:read"
    local purpose_doc="# PURPOSE: DevOnboarder workflow automation"
    local compliance_doc="# COMPLIANCE: Universal Workflow Permissions Policy + No Default Token Policy v1.0"
    local scope_doc="# SCOPE: Automated workflow processing"

    # Customize based on workflow patterns
    if [[ "$workflow_name" == *"aar"* ]]; then
        token_doc="# TOKEN: CI_ISSUE_AUTOMATION_TOKEN (issue creation and management)"
        permissions_doc="# PERMISSIONS: contents:read, issues:write, pull-requests:write"
        purpose_doc="# PURPOSE: Generate After Action Reports for DevOnboarder automation"
        scope_doc="# SCOPE: CI failure analysis and documentation generation"
    elif [[ "$workflow_name" == *"ci"* ]] || [[ "$workflow_name" == *"test"* ]]; then
        permissions_doc="# PERMISSIONS: contents:read, pull-requests:write"
        purpose_doc="# PURPOSE: Continuous integration and testing for DevOnboarder"
        scope_doc="# SCOPE: Code quality validation and test execution"
    elif [[ "$workflow_name" == *"security"* ]] || [[ "$workflow_name" == *"audit"* ]]; then
        permissions_doc="# PERMISSIONS: contents:read, security-events:write"
        purpose_doc="# PURPOSE: Security and compliance auditing for DevOnboarder"
        scope_doc="# SCOPE: Security scanning and policy enforcement"
    elif [[ "$workflow_name" == *"bot"* ]] || [[ "$workflow_name" == *"discord"* ]]; then
        permissions_doc="# PERMISSIONS: contents:read, issues:write"
        purpose_doc="# PURPOSE: Discord bot automation and integration"
        scope_doc="# SCOPE: Bot deployment and Discord service management"
    elif [[ "$workflow_name" == *"deploy"* ]] || [[ "$workflow_name" == *"release"* ]]; then
        permissions_doc="# PERMISSIONS: contents:write, packages:write"
        purpose_doc="# PURPOSE: Deployment and release automation for DevOnboarder"
        scope_doc="# SCOPE: Service deployment and version management"
    elif [[ "$workflow_name" == *"docs"* ]] || [[ "$workflow_name" == *"documentation"* ]]; then
        permissions_doc="# PERMISSIONS: contents:read, pages:write"
        purpose_doc="# PURPOSE: Documentation generation and maintenance"
        scope_doc="# SCOPE: Documentation quality and publishing automation"
    fi

    # Create temporary file with headers
    local temp_file="/tmp/workflow_with_headers_$$.yml"
    {
        echo "$token_doc"
        echo "$permissions_doc"
        echo "$purpose_doc"
        echo "$compliance_doc"
        echo "$scope_doc"
        echo ""
        cat "$workflow_file"
    } > "$temp_file"

    # Replace original file
    mv "$temp_file" "$workflow_file"
    echo "  SUCCESS: Added compliant headers"
}

# Get list of all workflow files
echo "Scanning .github/workflows/ directory..."

total_fixed=0
for workflow_file in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [[ -f "$workflow_file" ]]; then
        add_workflow_headers "$workflow_file"
        total_fixed=$((total_fixed + 1))
    fi
done

echo ""
echo "===== Fix Summary ====="
echo "Total workflows processed: $total_fixed"
echo ""
echo "Running audit to verify fixes..."
bash scripts/audit-workflow-headers.sh

echo ""
echo "Workflow header fix complete!"
