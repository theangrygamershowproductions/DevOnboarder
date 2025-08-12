#!/bin/bash
# Skip Behavior Confirmation - Validate conditional jobs don't block required checks
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Configuration
LOG_FILE="logs/skip_behavior_$(date +%Y%m%d_%H%M%S).log"

# Ensure logs directory exists
mkdir -p logs

# Logging setup
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Skip Behavior Confirmation Check ====="
echo "Timestamp: $(date)"
echo "Validating conditional jobs and required check compatibility..."

# Function to check workflow for conditional jobs
check_workflow_conditionals() {
    local workflow_file="$1"
    local workflow_name
    workflow_name=$(basename "$workflow_file" .yml)

    echo "Analyzing workflow: $workflow_name"

    # Check for conditional syntax
    if grep -q "if:" "$workflow_file"; then
        echo "  SYMBOL Contains conditional jobs"

        # Extract conditional patterns
        echo "  Conditional patterns found:"
        grep -n "if:" "$workflow_file" | while read -r line; do
            echo "    Line $(echo "$line" | cut -d: -f1): $(echo "$line" | cut -d: -f2- | xargs)"
        done
    else
        echo "  SYMBOL No conditional jobs detected"
    fi

    # Check for skip patterns
    if grep -qE "(skip|only.*changes|paths.*ignore)" "$workflow_file"; then
        echo "  WARNING Contains skip/filter patterns"
        grep -nE "(skip|only.*changes|paths.*ignore)" "$workflow_file" | while read -r line; do
            echo "    $(echo "$line" | cut -d: -f1): $(echo "$line" | cut -d: -f2- | xargs)"
        done
    fi

    echo ""
}

# Analyze critical workflows
echo "Checking workflows that contribute to required status checks..."

CRITICAL_WORKFLOWS=(
    ".github/workflows/ci.yml"
    ".github/workflows/aar.yml"
    ".github/workflows/orchestrator.yml"
    ".github/workflows/validate-permissions.yml"
    ".github/workflows/pre-commit.yml"
    ".github/workflows/version-policy-audit.yml"
    ".github/workflows/root-artifact-monitor.yml"
    ".github/workflows/terminal-policy-enforcement.yml"
    ".github/workflows/potato-policy-focused.yml"
    ".github/workflows/documentation-quality.yml"
)

workflow_issues=false

for workflow in "${CRITICAL_WORKFLOWS[@]}"; do
    if [[ -f "$workflow" ]]; then
        check_workflow_conditionals "$workflow"
    else
        echo "WARNING Workflow not found: $workflow"
        workflow_issues=true
    fi
done

echo "===== Skip Behavior Analysis ====="

# Check for legitimate skip scenarios
echo "Legitimate skip scenarios to validate:"

echo "1. Path-based filtering (should skip when unrelated files change)"
echo "   - Frontend-only changes shouldn't trigger backend tests"
echo "   - Documentation-only changes may skip some validations"
echo "   - Configuration changes should trigger all validations"

echo "2. Conditional matrix jobs (should skip gracefully)"
echo "   - OS-specific jobs on incompatible platforms"
echo "   - Language version matrix with availability constraints"
echo "   - Feature flag dependent tests"

echo "3. Environment-based conditionals (should respect context)"
echo "   - Production-only validations"
echo "   - PR vs push behavior differences"
echo "   - Fork vs origin repository handling"

echo "===== Required Check Compatibility ====="

echo "Analyzing GitHub required check behavior with skipped jobs..."

# Check if any workflows might create status check confusion
echo "Critical validation points:"

echo "SYMBOL Required checks MUST complete with success or failure"
echo "SYMBOL Skipped jobs should not be listed as required checks"
echo "SYMBOL Conditional jobs that skip should provide alternative success path"

# Provide validation commands
echo "===== Validation Commands ====="

cat << 'EOF'
# Test skip behavior in development:

1. Create test PR with different change types:
   - docs-only: echo "test" >> README.md
   - frontend-only: touch frontend/test-file.txt
   - backend-only: touch src/test-file.py
   - config-only: echo "test: true" >> config/test.yml

2. Monitor check results:
   gh pr checks --watch

3. Verify required checks still pass:
   gh pr view --json statusCheckRollup

4. Test conditional job behavior:
   - Create PR from fork (external contributor simulation)
   - Create PR with specific file patterns
   - Verify no required checks are permanently pending

5. Emergency scenarios:
   - All CI infrastructure down: Should require manual admin override
   - Specific check consistently failing: May need temporary removal from required list
   - New check deployment: Should not be immediately required
EOF

echo "===== Recommendations ====="

echo "1. **Never make conditional jobs required checks**"
echo "   - If job might skip, it shouldn't block merges"
echo "   - Use alternative success criteria for conditional logic"

echo "2. **Design skip-safe required checks**"
echo "   - Always-run validation steps"
echo "   - Comprehensive but minimal required set"
echo "   - Clear pass/fail criteria independent of matrix variations"

echo "3. **Monitor check completion rates**"
echo "   - Track which checks frequently skip vs fail"
echo "   - Ensure required checks have high completion rates"
echo "   - Alert on required checks stuck in 'pending' state"

echo "4. **Documentation for edge cases**"
echo "   - Document legitimate override scenarios"
echo "   - Maintain troubleshooting guide for stuck checks"
echo "   - Clear escalation path for persistent issues"

# Check current protection status
echo "===== Current Protection Status ====="

if command -v gh >/dev/null 2>&1; then
    echo "Checking current required status checks from GitHub..."
    if gh api repos/:owner/:repo/branches/main/protection 2>/dev/null | jq -r '.required_status_checks.contexts[]?' 2>/dev/null; then
        echo "Required checks confirmed active"
    else
        echo "WARNING Unable to retrieve protection status (may need authentication)"
    fi
else
    echo "WARNING GitHub CLI not available for live status check"
fi

if [[ "$workflow_issues" == "true" ]]; then
    echo "FAILED ISSUES DETECTED: Some critical workflows are missing"
    echo "Manual review required for complete skip behavior validation"
    exit 1
else
    echo "SUCCESS VALIDATION COMPLETE: Workflows analyzed for skip behavior"
    echo "Review conditional logic and ensure required checks remain reliable"
fi

echo "Skip behavior confirmation completed"
echo "Log saved to: $LOG_FILE"
