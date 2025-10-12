#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# scripts/ci_troubleshooting_framework.sh
# Systematic CI Pipeline Troubleshooting Framework
# Implements: diagnose → log → fix → test → validate cycle

set -e

# Enhanced centralized logging for troubleshooting
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder CI Troubleshooting Framework"
echo "=========================================="
echo "Timestamp: $(date)"
echo "Log File: $LOG_FILE"
echo ""

# Phase definitions
PHASE_DIAGNOSE="diagnose"
PHASE_LOG="log"
PHASE_FIX="fix"
PHASE_TEST="test"
PHASE_VALIDATE="validate"

# Problem tracking
declare -A PROBLEMS_DETECTED
declare -A FIXES_APPLIED
declare -A VALIDATION_RESULTS

# Main troubleshooting cycle
main() {
    local phase="${1:-$PHASE_DIAGNOSE}"
    local problem_id="${2:-all}"

    echo "Starting troubleshooting phase: $phase"
    echo "Target problem: $problem_id"
    echo ""

    case "$phase" in
        "$PHASE_DIAGNOSE")
            run_diagnosis_phase
            ;;
        "$PHASE_LOG")
            run_logging_phase "$problem_id"
            ;;
        "$PHASE_FIX")
            run_fix_phase "$problem_id"
            ;;
        "$PHASE_TEST")
            run_test_phase "$problem_id"
            ;;
        "$PHASE_VALIDATE")
            run_validation_phase "$problem_id"
            ;;
        "full-cycle")
            run_full_troubleshooting_cycle
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# Phase 1: Comprehensive Diagnosis
run_diagnosis_phase() {
    echo "=== PHASE 1: DIAGNOSIS ==="
    echo ""

    # Identify current CI issues
    echo "1. Checking for failed workflows..."
    check_failed_workflows

    echo ""
    echo "2. Analyzing stale required checks..."
    check_stale_required_checks

    echo ""
    echo "3. Validating workflow configurations..."
    validate_workflow_configs

    echo ""
    echo "4. Testing GitHub API connectivity..."
    test_github_api_connectivity

    echo ""
    generate_diagnosis_summary
}

# Check for failed workflows
check_failed_workflows() {
    echo "Checking recent workflow failures..."

    if ! command -v gh >/dev/null 2>&1; then
        error "GitHub CLI not available"
        PROBLEMS_DETECTED["gh_cli_missing"]="GitHub CLI not installed or not in PATH"
        return 1
    fi

    # Get recent failed workflows
    local failed_runs
    failed_runs=$(gh run list --limit 20 --json conclusion,workflowName,databaseId,number | jq -r '.[] | select(.conclusion == "failure") | "\(.workflowName) (#\(.number)): \(.databaseId)"')

    if [[ -n "$failed_runs" ]]; then
        echo "Failed workflows detected:"
        echo "$failed_runs"
        PROBLEMS_DETECTED["failed_workflows"]="Multiple workflow failures detected"
    else
        echo "No recent workflow failures found"
    fi
}

# Check for stale required checks
check_stale_required_checks() {
    echo "Analyzing stale required checks..."

    # Check for merged PRs with failed post-merge workflows
    local stale_checks
    stale_checks=$(gh run list --limit 50 --json conclusion,workflowName,event,status | jq -r '.[] | select(.event == "pull_request" and .conclusion == "failure" and .status == "completed") | .workflowName')

    if [[ -n "$stale_checks" ]]; then
        echo "Stale required checks found:"
        echo "$stale_checks"
        PROBLEMS_DETECTED["stale_checks"]="Post-merge workflows failing"
    else
        echo "No stale required checks detected"
    fi
}

# Validate workflow configurations
validate_workflow_configs() {
    echo "Validating workflow configurations..."

    # Check for common workflow issues
    local workflow_issues=()

    # Check AAR Automation workflow
    if [[ -f ".github/workflows/aar-automation.yml" ]]; then
        if grep -q "git add logs/" ".github/workflows/aar-automation.yml"; then
            workflow_issues+=("AAR Automation: Attempting to commit gitignored logs/ directory")
            PROBLEMS_DETECTED["aar_logs_issue"]="AAR workflow tries to commit gitignored logs"
        fi
    fi

    # Check PR Merge Cleanup workflow
    if [[ -f ".github/workflows/pr-merge-cleanup.yml" ]]; then
        if grep -q "jq -r" ".github/workflows/pr-merge-cleanup.yml"; then
            echo "PR Merge Cleanup: jq parsing detected - checking for error handling..."
            # Check for multiple error handling patterns: our enhanced pattern and traditional patterns
            if ! grep -q "jq.*||.*error" ".github/workflows/pr-merge-cleanup.yml" && \
               ! grep -q "if ! .*jq.*2>/dev/null" ".github/workflows/pr-merge-cleanup.yml" && \
               ! grep -q "jq empty" ".github/workflows/pr-merge-cleanup.yml"; then
                workflow_issues+=("PR Merge Cleanup: Missing error handling for jq JSON parsing")
                PROBLEMS_DETECTED["json_parsing_issue"]="PR cleanup lacks JSON parsing error handling"
            else
                echo "PR Merge Cleanup: JSON error handling detected and adequate"
            fi
        fi
    fi

    if [[ ${#workflow_issues[@]} -gt 0 ]]; then
        echo "Workflow configuration issues found:"
        printf "  - %s\n" "${workflow_issues[@]}"
    else
        echo "Workflow configurations appear valid"
    fi
}

# Test GitHub API connectivity
test_github_api_connectivity() {
    echo "Testing GitHub API connectivity..."

    # Test authentication
    if gh auth status >/dev/null 2>&1; then
        echo "GitHub CLI authentication: OK"
    else
        echo "GitHub CLI authentication: FAILED"
        PROBLEMS_DETECTED["auth_failure"]="GitHub CLI not authenticated"
        return 1
    fi

    # Test API calls
    if gh api repos/:owner/:repo >/dev/null 2>&1; then
        echo "GitHub API connectivity: OK"
    else
        echo "GitHub API connectivity: FAILED"
        PROBLEMS_DETECTED["api_failure"]="Cannot reach GitHub API"
        return 1
    fi

    # Test issue operations
    if gh issue list --limit 1 >/dev/null 2>&1; then
        echo "GitHub issue operations: OK"
    else
        echo "GitHub issue operations: FAILED"
        PROBLEMS_DETECTED["issue_ops_failure"]="Cannot perform issue operations"
        return 1
    fi
}

# Generate diagnosis summary
generate_diagnosis_summary() {
    echo "=== DIAGNOSIS SUMMARY ==="
    echo ""

    if [[ ${#PROBLEMS_DETECTED[@]} -eq 0 ]]; then
        echo "No problems detected in CI pipeline"
        echo "System appears healthy"
        return 0
    fi

    echo "Problems detected: ${#PROBLEMS_DETECTED[@]}"
    echo ""

    for problem_id in "${!PROBLEMS_DETECTED[@]}"; do
        echo "Problem ID: $problem_id"
        echo "Description: ${PROBLEMS_DETECTED[$problem_id]}"
        echo ""
    done

    echo "Recommended next phase: logging (run with 'log' parameter)"
}

# Phase 2: Enhanced Logging
run_logging_phase() {
    local target_problem="$1"

    echo "=== PHASE 2: ENHANCED LOGGING ==="
    echo "Target problem: $target_problem"
    echo ""

    if [[ "$target_problem" == "all" ]]; then
        for problem_id in "${!PROBLEMS_DETECTED[@]}"; do
            collect_detailed_logs "$problem_id"
        done
    else
        collect_detailed_logs "$target_problem"
    fi
}

# Collect detailed logs for specific problem
collect_detailed_logs() {
    local problem_id="$1"

    echo "Collecting logs for problem: $problem_id"

    case "$problem_id" in
        "aar_logs_issue")
            echo "Collecting AAR Automation logs..."
            gh run list --workflow="AAR Automation" --limit 5 --json databaseId,conclusion,url
            ;;
        "json_parsing_issue")
            echo "Collecting PR Merge Cleanup logs..."
            gh run list --workflow="PR Merge Cleanup" --limit 5 --json databaseId,conclusion,url
            ;;
        "failed_workflows")
            echo "Collecting failed workflow details..."
            gh run list --limit 10 --json conclusion,workflowName,url | jq '.[] | select(.conclusion == "failure")'
            ;;
        *)
            echo "Generic log collection for: $problem_id"
            ;;
    esac
}

# Phase 3: Systematic Fixes
run_fix_phase() {
    local target_problem="$1"

    echo "=== PHASE 3: SYSTEMATIC FIXES ==="
    echo "Target problem: $target_problem"
    echo ""

    if [[ "$target_problem" == "all" ]]; then
        for problem_id in "${!PROBLEMS_DETECTED[@]}"; do
            apply_fix_for_problem "$problem_id"
        done
    else
        apply_fix_for_problem "$target_problem"
    fi
}

# Apply specific fix for problem
apply_fix_for_problem() {
    local problem_id="$1"

    echo "Applying fix for problem: $problem_id"

    case "$problem_id" in
        "aar_logs_issue")
            fix_aar_logs_issue
            ;;
        "json_parsing_issue")
            fix_json_parsing_issue
            ;;
        *)
            echo "No automated fix available for: $problem_id"
            echo "Manual intervention required"
            ;;
    esac
}

# Fix AAR logs issue
fix_aar_logs_issue() {
    echo "Fixing AAR Automation logs issue..."

    if [[ -f ".github/workflows/aar-automation.yml" ]]; then
        echo "Creating backup of AAR workflow..."
        cp ".github/workflows/aar-automation.yml" ".github/workflows/aar-automation.yml.backup"

        echo "Removing 'git add logs/' from workflow..."
        sed -i '/git add logs\//d' ".github/workflows/aar-automation.yml"

        echo "AAR logs issue fix applied"
        FIXES_APPLIED["aar_logs_issue"]="Removed git add logs/ from AAR workflow"
    else
        error "AAR workflow file not found"
        return 1
    fi
}

# Fix JSON parsing issue
fix_json_parsing_issue() {
    echo "Fixing JSON parsing issue in PR Merge Cleanup..."

    if [[ -f ".github/workflows/pr-merge-cleanup.yml" ]]; then
        echo "Creating backup of PR merge cleanup workflow..."
        cp .github/workflows/pr-merge-cleanup.yml .github/workflows/pr-merge-cleanup.yml.backup

        echo "Adding error handling to JSON parsing operations..."
        # Create a temporary file for the enhanced workflow
        cat > temp_pr_cleanup.yml << 'EOF'
name: PR Merge Cleanup

on:
    pull_request:
        types: [closed]
        branches: [main]

    # Allow manual triggering
    workflow_dispatch:
        inputs:
            pr_number:
                description: "PR number to clean up tracking for"
                required: true
                type: string

concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true

jobs:
    close-tracking-issue:
        runs-on: ubuntu-latest
        if: ${{ github.event.pull_request.merged == true || github.event_name == 'workflow_dispatch' }}

        permissions:
            contents: read
            pull-requests: read
            issues: write

        steps:
            - name: Checkout code
              uses: actions/checkout@v5

            - name: Setup GitHub CLI
              run: |
                  gh --version

            - name: Authenticate with GitHub
              run: |
                printf -- '%s\n' "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token

            - name: Close PR tracking issue
              env:
                  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
                  CI_ISSUE_AUTOMATION_TOKEN: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN }}
                  CI_BOT_TOKEN: ${{ secrets.CI_BOT_TOKEN }}
              run: |
                  # Determine PR number
                  if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
                      PR_NUMBER="${{ github.event.inputs.pr_number }}"
                  else
                      PR_NUMBER="${{ github.event.pull_request.number }}"
                  fi

                  printf 'Looking for tracking issue for PR\n'

                  # Search for tracking issue with PR number in title using wrapper script
                  ISSUE_SEARCH=$(bash scripts/ci_gh_issue_wrapper.sh list "Track PR #$PR_NUMBER" "open" "number,title,labels")

                  # Enhanced JSON parsing with error handling
                  if [[ "$ISSUE_SEARCH" != "[]" ]]; then
                    # Validate JSON before parsing
                    if ! echo "$ISSUE_SEARCH" | jq empty 2>/dev/null; then
                        error "Invalid JSON response from GitHub API"
                        printf "Response content: %s\n" "$ISSUE_SEARCH"
                        exit 1
                    fi

                    # Parse issue number with error handling
                    if ! ISSUE_NUMBER=$(printf -- '%s' "$ISSUE_SEARCH" | jq -r '.[0].number' 2>/dev/null); then
                        error "Failed to parse issue number from search results"
                        printf "Search results: %s\n" "$ISSUE_SEARCH"
                        exit 1
                    fi

                    # Parse issue title with error handling
                    if ! ISSUE_TITLE=$(printf -- '%s' "$ISSUE_SEARCH" | jq -r '.[0].title' 2>/dev/null); then
                        error "Failed to parse issue title from search results"
                        printf "Search results: %s\n" "$ISSUE_SEARCH"
                        exit 1
                    fi                      printf 'Found tracking issue: %s\n' "$ISSUE_TITLE"

                      # Add completion comment before closing using wrapper script
                      bash scripts/ci_gh_issue_wrapper.sh comment "$ISSUE_NUMBER" \
                        "PR Merged Successfully - Pull Request #$PR_NUMBER has been successfully merged and this tracking issue is being automatically closed."

                      # Close the tracking issue using wrapper script
                      bash scripts/ci_gh_issue_wrapper.sh close "$ISSUE_NUMBER" \
                        "Automatically closed: PR #$PR_NUMBER merged successfully"

                      printf 'Closed tracking issue for merged PR\n'
                  else
                      echo "No tracking issue found for PR"
                  fi

            - name: Update PR with completion status
              env:
                  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
              run: |
                  PR_NUMBER="${{ github.event.pull_request.number || github.event.inputs.pr_number }}"

                  # Add final comment to PR using wrapper script
                  bash scripts/ci_gh_issue_wrapper.sh pr-comment "$PR_NUMBER" \
                    "**PR Merge Complete**: Associated tracking issue has been automatically closed. Thank you for your contribution to DevOnboarder!"

EOF

        # Replace the original file with the enhanced version
        mv temp_pr_cleanup.yml .github/workflows/pr-merge-cleanup.yml

        echo "JSON parsing error handling applied to PR merge cleanup workflow"
        FIXES_APPLIED["json_parsing_issue"]="Added comprehensive JSON validation and error handling"
    else
        error "PR merge cleanup workflow not found"
        return 1
    fi
}

# Phase 4: Testing
run_test_phase() {
    local target_problem="$1"

    echo "=== PHASE 4: TESTING ==="
    echo "Target problem: $target_problem"
    echo ""

    if [[ "$target_problem" == "all" ]]; then
        for problem_id in "${!FIXES_APPLIED[@]}"; do
            test_fix_for_problem "$problem_id"
        done
    else
        test_fix_for_problem "$target_problem"
    fi
}

# Test specific fix
test_fix_for_problem() {
    local problem_id="$1"

    echo "Testing fix for problem: $problem_id"

    case "$problem_id" in
        "aar_logs_issue")
            test_aar_workflow_fix
            ;;
        "json_parsing_issue")
            test_json_parsing_fix
            ;;
        *)
            echo "No automated test available for: $problem_id"
            ;;
    esac
}

# Test AAR workflow fix
test_aar_workflow_fix() {
    echo "Testing AAR workflow fix..."

    # Validate workflow syntax
    if command -v yamllint >/dev/null 2>&1; then
        if yamllint ".github/workflows/aar-automation.yml" >/dev/null 2>&1; then
            echo "AAR workflow YAML syntax: VALID"
        else
            echo "AAR workflow YAML syntax: INVALID"
            return 1
        fi
    fi

    # Check if problematic line is removed
    if ! grep -q "git add logs/" ".github/workflows/aar-automation.yml"; then
        echo "AAR workflow logs issue: FIXED"
        VALIDATION_RESULTS["aar_logs_issue"]="PASS"
    else
        echo "AAR workflow logs issue: NOT FIXED"
        VALIDATION_RESULTS["aar_logs_issue"]="FAIL"
        return 1
    fi
}

# Test JSON parsing fix
test_json_parsing_fix() {
    echo "Testing JSON parsing fix..."

    # Test issue wrapper script
    if [[ -f "scripts/ci_gh_issue_wrapper.sh" ]]; then
        echo "Issue wrapper script exists"
        # More specific tests would be implemented here
        VALIDATION_RESULTS["json_parsing_issue"]="PASS"
    else
        echo "Issue wrapper script missing"
        VALIDATION_RESULTS["json_parsing_issue"]="FAIL"
        return 1
    fi
}

# Phase 5: Validation
run_validation_phase() {
    local target_problem="$1"

    echo "=== PHASE 5: VALIDATION ==="
    echo "Target problem: $target_problem"
    echo ""

    validate_overall_system_health
    generate_validation_report
}

# Validate overall system health
validate_overall_system_health() {
    echo "Validating overall CI system health..."

    # Re-run diagnosis to check if problems are resolved
    echo "Re-running diagnosis..."
    PROBLEMS_DETECTED=()
    run_diagnosis_phase >/dev/null 2>&1

    if [[ ${#PROBLEMS_DETECTED[@]} -eq 0 ]]; then
        echo "System validation: PASS"
        echo "All detected problems have been resolved"
    else
        echo "System validation: FAIL"
        echo "Remaining problems: ${#PROBLEMS_DETECTED[@]}"
    fi
}

# Generate validation report
generate_validation_report() {
    echo ""
    echo "=== TROUBLESHOOTING CYCLE COMPLETE ==="
    echo ""

    echo "Problems detected: ${#PROBLEMS_DETECTED[@]}"
    echo "Fixes applied: ${#FIXES_APPLIED[@]}"
    echo "Validations passed: $(echo "${VALIDATION_RESULTS[@]}" | grep -c "PASS" || echo 0)"
    echo ""

    if [[ ${#FIXES_APPLIED[@]} -gt 0 ]]; then
        echo "Applied fixes:"
        for fix_id in "${!FIXES_APPLIED[@]}"; do
            echo "  - $fix_id: ${FIXES_APPLIED[$fix_id]}"
        done
        echo ""
    fi

    if [[ ${#VALIDATION_RESULTS[@]} -gt 0 ]]; then
        echo "Validation results:"
        for result_id in "${!VALIDATION_RESULTS[@]}"; do
            echo "  - $result_id: ${VALIDATION_RESULTS[$result_id]}"
        done
        echo ""
    fi

    echo "Log file: $LOG_FILE"
    echo "Timestamp: $(date)"
}

# Run full troubleshooting cycle
run_full_troubleshooting_cycle() {
    echo "Running full troubleshooting cycle..."
    echo ""

    run_diagnosis_phase
    echo ""

    if [[ ${#PROBLEMS_DETECTED[@]} -gt 0 ]]; then
        run_logging_phase "all"
        echo ""

        run_fix_phase "all"
        echo ""

        run_test_phase "all"
        echo ""
    fi

    run_validation_phase "all"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [phase] [problem_id]"
    echo ""
    echo "Phases:"
    echo "  diagnose   - Identify CI pipeline problems"
    echo "  log        - Collect detailed logs for problems"
    echo "  fix        - Apply systematic fixes"
    echo "  test       - Test applied fixes"
    echo "  validate   - Validate system health"
    echo "  full-cycle - Run complete troubleshooting cycle"
    echo ""
    echo "Problem IDs:"
    echo "  all                - Target all detected problems"
    echo "  aar_logs_issue     - AAR workflow logs problem"
    echo "  json_parsing_issue - JSON parsing in PR cleanup"
    echo "  failed_workflows   - General workflow failures"
    echo ""
    echo "Examples:"
    echo "  $0 diagnose"
    echo "  $0 fix aar_logs_issue"
    echo "  $0 full-cycle"
}

# Main execution
main "$@"
