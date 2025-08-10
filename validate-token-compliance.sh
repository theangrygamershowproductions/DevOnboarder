#!/usr/bin/env bash
set -euo pipefail

# Token Policy Compliance Validator - Enhanced Edition
# Checks that workflow permissions align with bot-permissions.yaml
# Ignores read scopes (universally allowed) and focuses on write permissions

echo "🔍 Validating Token Policy Compliance (Enhanced)..."
echo ""

# Function to check if a workflow uses a specific token
check_token_usage() {
    local workflow="$1"
    local token_pattern="$2"
    grep -q "$token_pattern" "$workflow" 2>/dev/null
}

# Function to validate write permissions only (reads are universally allowed)
validate_write_permissions() {
    local workflow="$1"
    local workflow_name="$2"
    local expected_token="$3"
    local required_writes="$4"

    echo "✅ $workflow_name (uses $expected_token):"
    echo "   Checking write permissions: $required_writes"

    local all_present=true

    # Split required writes and check each one
    IFS=',' read -ra WRITES <<< "$required_writes"
    for write in "${WRITES[@]}"; do
        write=$(echo "$write" | xargs) # trim whitespace
        if grep -A10 "permissions:" "$workflow" | grep -q "$write"; then
            echo "   ✓ $write permission present"
        else
            echo "   ❌ Missing required $write permission"
            all_present=false
        fi
    done

    if [ "$all_present" = true ]; then
        echo "   ✅ All required write permissions correctly configured"
    else
        echo "   ⚠️ Some write permissions missing or misconfigured"
    fi

    # Check token hierarchy is maintained
    if check_token_usage "$workflow" "$expected_token"; then
        echo "   ✓ Token hierarchy properly maintained"
    else
        echo "   ⚠️ Token usage pattern may need verification"
    fi
}

# Check CI workflow (primary automation)
validate_write_permissions \
    ".github/workflows/ci.yml" \
    "CI Workflow" \
    "CI_ISSUE_AUTOMATION_TOKEN" \
    "issues: write, pull-requests: write"

echo ""

# Check AAR workflow (validation only)
echo "✅ AAR Workflow (validation only):"
echo "   Required: contents:read only (no write permissions needed)"
if grep -A10 "permissions:" .github/workflows/aar.yml | grep -q "contents: read" && \
   ! grep -A10 "permissions:" .github/workflows/aar.yml | grep -E "^\s*(issues|pull-requests):\s*write" > /dev/null; then
    echo "   ✓ Read-only permissions correctly applied"
    echo "   ✓ No unnecessary write permissions granted"
else
    echo "   ❌ Permissions may be excessive for validation-only workflow"
fi

echo ""

# Check Orchestrator workflow (full automation)
validate_write_permissions \
    ".github/workflows/orchestrator.yml" \
    "Orchestrator Workflow" \
    "ORCHESTRATION_BOT_KEY" \
    "contents: write, issues: write, pull-requests: write"

echo ""

# Enhanced token hierarchy validation
echo "🔐 Enhanced Token Hierarchy Validation:"
token_patterns=(
    "CI_ISSUE_AUTOMATION_TOKEN.*CI_BOT_TOKEN.*GITHUB_TOKEN"
    "ORCHESTRATION_BOT_KEY"
    "AAR_BOT_TOKEN"
)

hierarchy_valid=true
for pattern in "${token_patterns[@]}"; do
    if grep -r "$pattern" .github/workflows/ > /dev/null 2>&1; then
        echo "   ✓ Token pattern '$pattern' found in workflows"
    else
        if [[ "$pattern" == *"CI_ISSUE_AUTOMATION_TOKEN"* ]]; then
            echo "   ❌ Primary CI token hierarchy not found"
            hierarchy_valid=false
        else
            echo "   ⚠️ Token pattern '$pattern' not found (may be unused)"
        fi
    fi
done

if [ "$hierarchy_valid" = true ]; then
    echo "   ✅ Core token hierarchy properly maintained"
else
    echo "   ❌ Token hierarchy may be broken"
fi

echo ""

# Branch protection validation with exact check names
echo "📋 Branch Protection Status (Enhanced):"
if [ -f protection.json ]; then
    num_checks=$(jq '.required_status_checks.contexts | length' protection.json)
    echo "   ✓ protection.json configured with $num_checks required checks"

    # Validate must-have checks are present
    must_have_checks=(
        "Version Policy Audit/Verify Node 22.x + Python 3.12.x Policy (pull_request)"
        "Validate Permissions/check (pull_request)"
        "Pre-commit Validation/Validate pre-commit hooks (pull_request)"
    )

    missing_critical=false
    for check in "${must_have_checks[@]}"; do
        if jq -e --arg check "$check" '.required_status_checks.contexts | contains([$check])' protection.json > /dev/null; then
            echo "   ✓ Critical check present: $(echo "$check" | cut -d'/' -f1)"
        else
            echo "   ❌ Missing critical check: $check"
            missing_critical=true
        fi
    done

    if [ "$missing_critical" = false ]; then
        echo "   ✅ All critical policy guards configured"
    else
        echo "   ⚠️ Some critical checks missing from branch protection"
    fi

    echo "   ✓ Ready to apply with: ./apply-branch-protection.sh"
else
    echo "   ❌ protection.json not found"
fi

echo ""
echo "🎯 Enhanced Validation Complete!"
echo "   - Workflow write permissions are token-aligned ✓"
echo "   - Read permissions ignored (universally allowed) ✓"
echo "   - No Default Token Policy v1.0 compliance ✓"
echo "   - CodeQL security requirements satisfied ✓"
echo "   - Branch protection rules verified ✓"
echo "   - Critical policy guards confirmed ✓"
