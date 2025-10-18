#!/bin/bash
# AAR System Token Diagnostic - GitHub Actions API Compliant
# Based on official GitHub Actions REST API documentation
# https://docs.github.com/en/rest/actions

set -euo pipefail

# Source virtual environment and load environment
cd "$(dirname "${BASH_SOURCE[0]}")/.."
source .venv/bin/activate

# Load tokens using Token Architecture v2.1
if [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh > /dev/null 2>&1
fi

printf "Target: AAR System Token Diagnostic (GitHub Actions API Compliant)\n"
printf "==============================================================\n"
printf "\n"

# Check if AAR_TOKEN exists
if [ -z "${AAR_TOKEN:-}" ]; then
    printf "Error: AAR_TOKEN not found in environment\n"
    printf "   Please ensure Token Architecture v2.1 is properly configured\n"
    exit 1
fi

printf "Length: %d\n" "${#AAR_TOKEN}"
echo ""

# GitHub Actions API Testing
# Based on https://docs.github.com/en/rest/actions
printf "Testing GitHub Actions API Permissions...\n"
printf "   Using official GitHub Actions REST API endpoints\n"
printf "\n"

REPO="repos/theangrygamershowproductions/DevOnboarder"

# Test 1: Repository access (foundational requirement)
printf "List: Test 1: Repository Access\n"
if GH_TOKEN="$AAR_TOKEN" gh api "$REPO" >/dev/null 2>&1; then
    printf "   Success:  Basic repository access working\n"
    export REPO_ACCESS=true
else
    printf "   Error: FAILED: Cannot access repository\n"
    printf "   This indicates a fundamental token configuration issue\n"
    exit 1
fi

# Test 2: Workflows API (/repos/{owner}/{repo}/actions/workflows)
printf "\n"
printf "List: Test 2: Actions Workflows API\n"
printf "Value: %s\n" "$REPO"
if GH_TOKEN="$AAR_TOKEN" gh api "$REPO/actions/workflows" >/dev/null 2>&1; then
    printf "   Success:  Can list repository workflows\n"
    export WORKFLOWS_OK=true
else
    printf "   Error: FAILED: Cannot access workflows\n"
    printf "   Required permission: actions: read\n"
    export WORKFLOWS_OK=false
fi

# Test 3: Workflow Runs API (/repos/{owner}/{repo}/actions/runs)
printf "\n"
printf "List: Test 3: Actions Workflow Runs API\n"
printf "Value: %s\n" "$REPO"
if GH_TOKEN="$AAR_TOKEN" gh api "$REPO/actions/runs?per_page=1" >/dev/null 2>&1; then
    printf "   Success:  Can access workflow runs\n"
    export RUNS_OK=true
else
    printf "   Error: FAILED: Cannot access workflow runs\n"
    printf "   Required permission: actions: read\n"
    export RUNS_OK=false
fi

# Test 4: Issues API (for AAR issue creation)
printf "\n"
printf "List: Test 4: Issues API\n"
printf "Value: %s\n" "$REPO"
if GH_TOKEN="$AAR_TOKEN" gh api "$REPO/issues?per_page=1" >/dev/null 2>&1; then
    printf "   Success:  Can access issues\n"
    export ISSUES_OK=true
else
    printf "   Error: FAILED: Cannot access issues\n"
    printf "   Required permission: issues: read & write\n"
    export ISSUES_OK=false
fi

# Test 5: Specific workflow run details (AAR system requirement)
printf "\n"
printf "List: Test 5: Workflow Run Details\n"
printf "   Getting latest workflow run for detailed testing...\n"
if latest_run=$(GH_TOKEN="$AAR_TOKEN" gh api "$REPO/actions/runs?per_page=1" 2>/dev/null | jq -r '.workflow_runs[0].id // empty' 2>/dev/null); then
    if [ -n "$latest_run" ]; then
        printf "Value: %s\n" "$latest_run"
        if GH_TOKEN="$AAR_TOKEN" gh api "$REPO/actions/runs/$latest_run" >/dev/null 2>&1; then
            printf "   Success:  Can access specific workflow run details\n"
            export RUN_DETAILS_OK=true
        else
            printf "   Error: FAILED: Cannot access workflow run details\n"
            export RUN_DETAILS_OK=false
        fi
    else
        printf "   Warning: No workflow runs found to test\n"
        export RUN_DETAILS_OK=true  # Not a failure, just no data
    fi
else
    printf "   Error: FAILED: Cannot retrieve workflow runs for testing\n"
    export RUN_DETAILS_OK=false
fi

printf "\n"
printf "Diagnostic Results:\n"
printf "===================\n"

# Calculate overall success
TOTAL_TESTS=4
PASSED_TESTS=0

if [ "$WORKFLOWS_OK" = true ]; then
    PASSED_TESTS=$((PASSED_TESTS  1))
fi
if [ "$RUNS_OK" = true ]; then
    PASSED_TESTS=$((PASSED_TESTS  1))
fi
if [ "$ISSUES_OK" = true ]; then
    PASSED_TESTS=$((PASSED_TESTS  1))
fi
if [ "$RUN_DETAILS_OK" = true ]; then
    PASSED_TESTS=$((PASSED_TESTS  1))
fi

printf "Value: %s\n" "$TOTAL_TESTS"
printf "\n"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    printf "EXCELLENT: All AAR_TOKEN permissions are working!\n"
    printf "\n"
    printf "Success: Your Fine-Grained token has successfully completed propagation\n"
    printf "Success: All required GitHub Actions API endpoints are accessible\n"
    printf "Success: AAR system should now function properly\n"
    printf "\n"
    printf "Ready: Next steps:\n"
    printf "   • AAR system is ready for use\n"
    printf "   • Run: make aar-generate WORKFLOW_ID=<workflow_id>\n"
    printf "   • All diagnostic checks passed\n"

elif [ $PASSED_TESTS -ge 2 ]; then
    printf "PARTIAL  Fine-Grained Token Propagation in Progress\n"
    printf "\n"
    printf "Success: Repository access working (permissions correctly configured)\n"
    printf "Some Actions API endpoints still propagating\n"
    printf "\n"
    printf "This is normal behavior for Fine-Grained tokens on organization repositories.\n"
    printf "\n"
    printf "Expected timeline: 2-5 more minutes for complete propagation\n"
    printf "Re-run this script: bash scripts/fix_aar_tokens.sh\n"
    printf "\n"
    printf "List: Working endpoints:\n"
    if [ "$WORKFLOWS_OK" = true ]; then printf "   Success: Workflows API\n"; fi
    if [ "$RUNS_OK" = true ]; then printf "   Success: Workflow runs API\n"; fi
    if [ "$ISSUES_OK" = true ]; then printf "   Success: Issues API\n"; fi
    if [ "$RUN_DETAILS_OK" = true ]; then printf "   Success: Run details API\n"; fi

else
    printf "Warning: PERMISSION CONFIGURATION NEEDED\n"
    printf "\n"
    printf "Your token may need permission updates in GitHub settings.\n"
    printf "\n"
    printf "Required Fine-Grained Token Permissions:\n"
    printf "   1. Go to: https://github.com/settings/personal-access-tokens/fine-grained\n"
    printf "   2. Find your AAR_TOKEN and click 'Edit'\n"
    printf "   3. Ensure these Repository permissions:\n"
    printf "      • Actions: Read (minimum) or Read & Write\n"
    printf "      • Issues: Read & Write\n"
    printf "      • Metadata: Read\n"
    printf "      • Contents: Read\n"
    printf "\n"
    printf "   4. Ensure Repository access includes:\n"
    printf "      • theangrygamershowproductions/DevOnboarder\n"
    printf "\n"
    printf "   5. Save and wait 2-5 minutes for propagation\n"
fi

printf "\n"
printf "Documentation: GitHub Actions REST API\n"
printf "   https://docs.github.com/en/rest/actions\n"
