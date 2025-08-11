#!/bin/bash
# DevOnboarder CI Triage Action Plan - PR #1125
# Execute these commands in order to systematically resolve CI failures

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Ensure virtual environment
# shellcheck disable=SC1091 # Runtime source operation
source .venv/bin/activate

LOG_FILE="logs/ci_triage_execution_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "====== DevOnboarder CI Triage Execution - PR #1125 ======"
echo "Timestamp: $(date)"
echo "Log file: $LOG_FILE"
echo "Analysis: logs/ci_triage_analysis_pr1125.md"
echo ""

# Phase 1: Security Resolution (CRITICAL BLOCKING)
echo "=== PHASE 1: SECURITY RESOLUTION (CRITICAL) ==="
echo "CRITICAL: CodeQL found 4 high-severity security vulnerabilities"
echo "Manual review required for: app/aar-core/src/server.ts"
echo ""
echo "Security Issues Detected:"
echo "- Uncontrolled data used in path expression (2 instances)"
echo "- Missing rate limiting (2 instances)"
echo ""
echo "MANUAL ACTION REQUIRED:"
echo "1. Review app/aar-core/src/server.ts lines identified by CodeQL"
echo "2. Add input validation for user-provided paths"
echo "3. Implement rate limiting for file system operations"
echo "4. Re-run CodeQL scan after fixes"
echo ""
echo "Security fix commands to run after manual review:"
echo "  cd app/aar-core && npm run lint:security"
echo "  cd app/aar-core && npm run test:security"
echo ""

# Phase 2: Component Test Stabilization (CRITICAL BLOCKING)
echo "=== PHASE 2: COMPONENT TEST STABILIZATION (CRITICAL) ==="
echo "Running systematic test validation across all components..."
echo ""

echo "Testing Backend (Python 3.12)..."
if python -m pytest tests/ -v --tb=short --cov=src --cov-fail-under=95; then
    echo "SUCCESS Backend tests passing"
else
    echo "FAILED Backend tests require attention"
    echo "Common emoji policy impact: Test assertions expecting emoji content"
    echo "Manual review needed for test failures"
fi
echo ""

echo "Testing Frontend (React)..."
if npm run test --prefix frontend; then
    echo "SUCCESS Frontend tests passing"
else
    echo "FAILED Frontend tests require attention"
    echo "Common emoji policy impact: UI status indicators changed from emoji to text"
    echo "Update test selectors to use data-testid instead of emoji matching"
fi
echo ""

echo "Testing Bot (Discord.js)..."
if npm run test --prefix bot; then
    echo "SUCCESS Bot tests passing"
else
    echo "FAILED Bot tests require attention"
    echo "Common emoji policy impact: Message content assertions changed"
    echo "Update test expectations for ASCII-only message format"
fi
echo ""

echo "Testing AAR UI..."
if npm run test --prefix app/aar-core; then
    echo "SUCCESS AAR UI tests passing"
else
    echo "FAILED AAR UI tests require attention"
    echo "Common issue: Build process affected by policy changes"
    echo "Check for emoji content in templates or markdown processing"
fi
echo ""

# Phase 3: Policy Compliance Validation (CRITICAL BLOCKING)
echo "=== PHASE 3: POLICY COMPLIANCE VALIDATION (CRITICAL) ==="
echo "Running DevOnboarder quality control validation..."
echo ""

if ./scripts/qc_pre_push.sh; then
    echo "SUCCESS QC validation passing (95% threshold met)"
else
    echo "FAILED QC validation below 95% threshold"
    echo "Quality gates not met - manual remediation required"
    echo ""
    echo "Common QC failures from emoji policy:"
    echo "- Python linting: Print statements or format changes"
    echo "- TypeScript linting: Template literal content changes"
    echo "- Coverage: Test files affected by emoji removal"
    echo "- Documentation: Markdown format changes"
fi
echo ""

# Phase 4: Build and Documentation Validation (HIGH PRIORITY)
echo "=== PHASE 4: BUILD & DOCUMENTATION VALIDATION (HIGH PRIORITY) ==="
echo "Validating build processes and documentation compliance..."
echo ""

echo "Checking markdown compliance..."
if markdownlint-cli2 docs/ aar/ README.md; then
    echo "SUCCESS Markdown validation passing"
else
    echo "FAILED Markdown validation issues found"
    echo "Common issue: Emoji removal affected markdown structure"
    echo "Run: markdownlint-cli2 --fix docs/ aar/ README.md"
fi
echo ""

echo "Validating AAR system..."
if node scripts/render_aar.js docs/AAR/data/ docs/AAR/reports/; then
    echo "SUCCESS AAR system functional"
else
    echo "FAILED AAR system issues found"
    echo "Common issue: Template processing affected by emoji policy"
fi
echo ""

# Summary and Next Steps
echo "=== CI TRIAGE EXECUTION SUMMARY ==="
echo "Timestamp: $(date)"
echo ""
echo "CRITICAL ACTIONS REQUIRED:"
echo "1. Security Review: Manual fix required for CodeQL violations"
echo "2. Test Updates: Update assertions for emoji-to-ASCII changes"
echo "3. QC Compliance: Address specific quality gate failures"
echo ""
echo "BEFORE MERGE CHECKLIST:"
echo "[ ] CodeQL security issues resolved"
echo "[ ] All 4 component test suites passing"
echo "[ ] QC validation achieving 95% threshold"
echo "[ ] Build processes functional"
echo "[ ] Documentation validation passing"
echo ""
echo "Log saved: $LOG_FILE"
echo "Analysis: logs/ci_triage_analysis_pr1125.md"
echo "Next: Address security issues first, then run test stabilization"
