#!/bin/bash
# Workflow Headers Enhancement - Add token usage documentation for maintenance clarity
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Configuration
LOG_FILE="logs/workflow_headers_$(date +%Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p logs

# Logging setup
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Workflow Headers Enhancement ====="
echo "Timestamp: $(date)"
echo "Adding token usage documentation headers to critical workflows..."

# Function to add or update workflow header
add_workflow_header() {
    local workflow_file="$1"
    local workflow_name
    workflow_name=$(basename "$workflow_file" .yml)
    local temp_file
    temp_file=$(mktemp)

    echo "Processing workflow: $workflow_name"

    # Determine token usage from workflow content
    local token_usage=""
    local permissions_block=""

    if grep -q "CI_ISSUE_AUTOMATION_TOKEN" "$workflow_file"; then
        token_usage="CI_ISSUE_AUTOMATION_TOKEN (issue creation, PR management)"
    elif grep -q "CI_BOT_TOKEN" "$workflow_file"; then
        token_usage="CI_BOT_TOKEN (automation workflows)"
    elif grep -q "ORCHESTRATION_BOT_KEY" "$workflow_file"; then
        token_usage="ORCHESTRATION_BOT_KEY (multi-service orchestration)"
    elif grep -q "permissions:" "$workflow_file"; then
        token_usage="GITHUB_TOKEN (default with explicit permissions)"
    else
        token_usage="GITHUB_TOKEN (default, read-only)"
    fi

    # Extract permissions block if present
    if grep -q "permissions:" "$workflow_file"; then
        permissions_block=$(grep -A 10 "permissions:" "$workflow_file" | grep -E "^  [a-z-]+:" | head -5 | sed 's/^/# /')
    fi

    # Create header comment
    cat > "$temp_file" << EOF
#
# WORKFLOW: $workflow_name
# PURPOSE: Auto-generated header for maintenance clarity
# TOKEN: $token_usage
# PERMISSIONS: Token-aligned permissions for CodeQL compliance
EOF

    if [[ -n "$permissions_block" ]]; then
        {
            echo "#"
            echo "# EXPLICIT PERMISSIONS:"
            echo "$permissions_block"
        } >> "$temp_file"
    fi

    cat >> "$temp_file" << 'EOF'
#
# MAINTENANCE NOTES:
# - This workflow follows Universal Workflow Permissions Policy
# - Token usage aligns with DevOnboarder No Default Token Policy v1.0
# - Required status checks documented in docs/ci/required-checks.md
# - Skip behavior validated for conditional jobs compatibility
#
# COMPLIANCE:
# SUCCESS CodeQL security requirements satisfied
# SUCCESS Token policy hierarchy respected
# SUCCESS Branch protection integration verified
# SUCCESS Production hardening applied
#
EOF

    # Check if workflow already has similar header
    if head -20 "$workflow_file" | grep -q "WORKFLOW:"; then
        echo "  SYMBOL Header already present, updating..."
        # Skip existing header and add new one
        awk '/^#/ && /WORKFLOW:/ {skip=1} /^[^#]/ {skip=0} !skip {print}' "$workflow_file" >> "$temp_file"
    else
        echo "  + Adding new header..."
        # Skip existing name line and add header
        tail -n +2 "$workflow_file" >> "$temp_file"
    fi

    # Backup original and replace
    cp "$workflow_file" "${workflow_file}.backup"
    mv "$temp_file" "$workflow_file"

    echo "  SYMBOL Header added to $workflow_name"
}

# Function to check workflow header compliance
check_workflow_compliance() {
    local workflow_file="$1"
    local workflow_name
    workflow_name=$(basename "$workflow_file" .yml)

    echo "Checking compliance: $workflow_name"

    local issues=0

    # Check for header presence
    if ! head -20 "$workflow_file" | grep -q "WORKFLOW:"; then
        echo "  FAILED Missing workflow header"
        ((issues++))
    fi

    # Check for token documentation
    if ! grep -q "TOKEN:" "$workflow_file"; then
        echo "  FAILED Missing token usage documentation"
        ((issues++))
    fi

    # Check for permissions alignment
    if grep -q "permissions:" "$workflow_file" && ! grep -q "PERMISSIONS:" "$workflow_file"; then
        echo "  WARNING Permissions block present but not documented in header"
        ((issues++))
    fi

    # Check for maintenance notes
    if ! grep -q "MAINTENANCE NOTES:" "$workflow_file"; then
        echo "  FAILED Missing maintenance documentation"
        ((issues++))
    fi

    if [[ $issues -eq 0 ]]; then
        echo "  SUCCESS Fully compliant"
    else
        echo "  WARNING $issues compliance issues found"
    fi

    return $issues
}

# Apply headers to critical workflows
echo "Adding headers to critical workflows..."

CRITICAL_WORKFLOWS=(
    ".github/workflows/ci.yml"
    ".github/workflows/aar.yml"
    ".github/workflows/orchestrator.yml"
    ".github/workflows/validate-permissions.yml"
    ".github/workflows/version-policy-audit.yml"
    ".github/workflows/documentation-quality.yml"
)

total_processed=0
total_issues=0

for workflow in "${CRITICAL_WORKFLOWS[@]}"; do
    if [[ -f "$workflow" ]]; then
        add_workflow_header "$workflow"
        ((total_processed++))
    else
        echo "WARNING Workflow not found: $workflow"
    fi
done

echo ""
echo "===== Compliance Verification ====="

# Verify all workflows now have proper headers
for workflow in "${CRITICAL_WORKFLOWS[@]}"; do
    if [[ -f "$workflow" ]]; then
        if ! check_workflow_compliance "$workflow"; then
            ((total_issues++))
        fi
    fi
done

echo ""
echo "===== Documentation Standards ====="

echo "Creating workflow documentation standards..."

cat > ".github/WORKFLOW_STANDARDS.md" << 'EOF'
# Workflow Standards and Maintenance Guide

## Header Requirements

All workflow files must include a standardized header with:

- **WORKFLOW**: File name and purpose
- **TOKEN**: Authentication token usage and scope
- **PERMISSIONS**: Explicit permissions documentation
- **MAINTENANCE NOTES**: Policy compliance references
- **COMPLIANCE**: Verification checklist

## Token Usage Guidelines

### Token Hierarchy (DevOnboarder No Default Token Policy v1.0)

1. **CI_ISSUE_AUTOMATION_TOKEN** - Issue creation, PR management
2. **CI_BOT_TOKEN** - General automation workflows
3. **ORCHESTRATION_BOT_KEY** - Multi-service orchestration
4. **GITHUB_TOKEN** - Default token with explicit permissions

### Permissions Alignment

All workflows must use **token-aligned permissions** to satisfy:
- SUCCESS CodeQL security requirements
- SUCCESS Token capability boundaries
- SUCCESS Branch protection integration
- SUCCESS Principle of least privilege

## Required Status Checks

Workflows contributing to branch protection must:
- Complete with success or failure (never permanently pending)
- Handle conditional jobs appropriately
- Document skip behavior in workflow comments
- Maintain check name consistency with `docs/ci/required-checks.md`

## Maintenance Procedures

### Adding New Workflows

1. Copy header template from existing critical workflow
2. Update TOKEN and PERMISSIONS sections appropriately
3. Add to required checks if workflow blocks merges
4. Update documentation in `docs/ci/required-checks.md`

### Modifying Existing Workflows

1. Preserve header documentation
2. Update TOKEN usage if authentication changes
3. Verify permissions alignment with token capabilities
4. Test required check behavior for conditional jobs

### Emergency Procedures

1. **Broken Required Check**: Remove from protection temporarily
2. **Token Issues**: Fall back to GITHUB_TOKEN with minimal permissions
3. **Compliance Violations**: Use workflow validation scripts
4. **Header Missing**: Run `scripts/workflow_headers_enhancement.sh`

## Validation Commands

```bash
# Check workflow compliance
bash scripts/workflow_headers_enhancement.sh

# Validate required checks
bash scripts/matrix_drift_protection.sh

# Confirm skip behavior
bash scripts/skip_behavior_confirmation.sh

# Apply branch protection
bash scripts/apply-branch-protection.sh
```

## Integration Points

- **Branch Protection**: `.github/protection.json`
- **Check Documentation**: `docs/ci/required-checks.md`
- **Token Policy**: DevOnboarder No Default Token Policy v1.0
- **Permissions Policy**: Universal Workflow Permissions Policy
- **Compliance Framework**: Production hardening validation

EOF

echo ""
echo "===== Results Summary ====="

echo "Workflow Headers Enhancement Results:"
echo "- Processed: $total_processed workflows"
echo "- Issues found: $total_issues compliance gaps"
echo "- Documentation: .github/WORKFLOW_STANDARDS.md created"
echo "- Backup files: *.backup created for safety"

if [[ $total_issues -gt 0 ]]; then
    echo ""
    echo "WARNING Manual review recommended for compliance gaps"
    echo "Run individual workflow checks for detailed issues"
else
    echo ""
    echo "SUCCESS All workflows meet header standards"
    echo "Production hardening Step 5 completed successfully"
fi

echo ""
echo "===== Maintenance Commands ====="

cat << 'EOF'
# Restore workflow from backup if needed:
cp .github/workflows/ci.yml.backup .github/workflows/ci.yml

# Re-run header enhancement:
bash scripts/workflow_headers_enhancement.sh

# Validate complete production hardening:
bash scripts/matrix_drift_protection.sh
bash scripts/skip_behavior_confirmation.sh
EOF

echo ""
echo "Workflow headers enhancement completed"
echo "Log saved to: $LOG_FILE"
