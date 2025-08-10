#!/bin/bash
# MVP Execution Readiness Validator
# Validates readiness to begin 4-week MVP timeline

set -euo pipefail

echo "TARGET DevOnboarder MVP Execution Readiness Check"
echo "============================================="
echo "Target: 4-week completion by August 30, 2025"
echo ""

# Initialize scoring
TOTAL_SCORE=0
MAX_SCORE=24

echo "SYMBOL Pre-execution Validation..."

# 1. Documentation Readiness (6 points)
echo ""
echo "SYMBOL Documentation Framework:"

if [ -f "docs/TASK_ORDERING.md" ]; then
    echo "SUCCESS Task ordering documented (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Task ordering missing"
fi

if [ -f "codex/tasks/task_execution_index.json" ]; then
    echo "SUCCESS Codex task index created (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Codex task index missing"
fi

if [ -f "codex/mvp/mvp_completion_criteria.md" ]; then
    echo "SUCCESS MVP completion criteria defined (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED MVP completion criteria missing"
fi

# 2. Infrastructure Readiness (6 points)
echo ""
echo "SYMBOL Infrastructure Preparation:"

if [ -f "scripts/scaffold_phase1_networks.sh" ]; then
    echo "SUCCESS Network scaffolding script ready (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Network scaffolding script missing"
fi

if [ -f "scripts/validate_network_contracts.sh" ]; then
    echo "SUCCESS Network validation script ready (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Network validation script missing"
fi

if [ -f "scripts/mvp_docker_service_mesh.sh" ]; then
    echo "SUCCESS MVP implementation guide ready (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED MVP implementation guide missing"
fi

# 3. Issue Templates & Tracking (6 points)
echo ""
echo "SYMBOL Issue Management:"

if [ -f ".github/ISSUE_TEMPLATE/mvp-phase1-network-tiering.md" ]; then
    echo "SUCCESS Phase 1 issue template ready (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Phase 1 issue template missing"
fi

if [ -f ".github/ISSUE_TEMPLATE/mvp-phase3-ci-validation.md" ]; then
    echo "SUCCESS Phase 3 issue template ready (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Phase 3 issue template missing"
fi

if [ -f "scripts/create_mvp_issues.sh" ]; then
    echo "SUCCESS Issue creation script ready (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Issue creation script missing"
fi

# 4. Current System Health (6 points)
echo ""
echo "SEARCH System Health Check:"

# Check if Docker is running
if docker info >/dev/null 2>&1; then
    echo "SUCCESS Docker operational (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))
else
    echo "FAILED Docker not running"
fi

# Check if make targets work
if command -v make >/dev/null 2>&1; then
    echo "SUCCESS Make available (+1)"
    TOTAL_SCORE=$((TOTAL_SCORE + 1))

    # Test make up (non-blocking)
    if make --dry-run up >/dev/null 2>&1; then
        echo "SUCCESS Make targets valid (+1)"
        TOTAL_SCORE=$((TOTAL_SCORE + 1))
    else
        echo "WARNING Make targets may have issues"
    fi
else
    echo "FAILED Make not available"
fi

# Check terminal output current status
if [ -f "scripts/validate_terminal_output.sh" ]; then
    echo "SUCCESS Terminal validation available (+2)"
    TOTAL_SCORE=$((TOTAL_SCORE + 2))

    # Get current violation count (non-blocking)
    VIOLATIONS=$(bash scripts/validate_terminal_output.sh 2>/dev/null | grep -o '[0-9]* violations' | head -1 | grep -o '[0-9]*' || echo "unknown")
    if [ "$VIOLATIONS" != "unknown" ]; then
        echo "STATS Current terminal violations: $VIOLATIONS (target: ≤10)"
    fi
else
    echo "FAILED Terminal validation script missing"
fi

# Calculate readiness percentage
PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))

echo ""
echo "STATS Readiness Assessment:"
echo "Score: $TOTAL_SCORE/$MAX_SCORE ($PERCENTAGE%)"

if [ $PERCENTAGE -ge 90 ]; then
    echo "GREEN EXCELLENT - Ready for immediate execution"
    READINESS="READY"
elif [ $PERCENTAGE -ge 75 ]; then
    echo "YELLOW GOOD - Minor preparation needed"
    READINESS="MOSTLY_READY"
elif [ $PERCENTAGE -ge 50 ]; then
    echo "ORANGE FAIR - Significant preparation required"
    READINESS="NEEDS_WORK"
else
    echo "RED POOR - Major blockers present"
    READINESS="NOT_READY"
fi

echo ""
echo "SYMBOL Timeline Validation:"
echo "Current Date: $(date +%Y-%m-%d)"
echo "Week 1 Start: August 8, 2025 (TODAY)"
echo "Week 1 End: August 11, 2025"
echo "MVP Target: August 30, 2025"
echo "Days Remaining: 22 days"

echo ""
echo "TARGET Week 1 Immediate Actions:"
if [ "$READINESS" = "READY" ] || [ "$READINESS" = "MOSTLY_READY" ]; then
    echo "SUCCESS Begin terminal output enhancement"
    echo "SUCCESS Start Docker Service Mesh Phase 1"
    echo "SUCCESS Create MVP tracking issues"
    echo ""
    echo "DEPLOY Execute: ./scripts/create_mvp_issues.sh"
    echo "DEPLOY Execute: ./scripts/mvp_docker_service_mesh.sh"
else
    echo "WARNING Address missing components first"
    echo "WARNING Ensure all scripts and templates available"
    echo "WARNING Validate Docker and development environment"
fi

echo ""
echo "SYMBOL Success Indicators for Week 1:"
echo "- Terminal violations: 22 → ≤10"
echo "- Network tiers: 0 → 3 operational"
echo "- Service isolation: 0% → 100% (data tier)"
echo "- DNS discovery: hostname-based contracts working"

echo ""
if [ "$READINESS" = "READY" ]; then
    echo "SYMBOL MVP EXECUTION READINESS: CONFIRMED"
    echo "Ready to begin 4-week timeline to August 30, 2025!"
    exit 0
else
    echo "CONFIG MVP EXECUTION READINESS: NEEDS PREPARATION"
    echo "Complete missing components before starting timeline."
    exit 1
fi
