#!/usr/bin/env bash
# Phase 2 Progress Tracker
# Tracks progress toward Phase 2 completion criteria

set -euo pipefail

# Centralized logging
mkdir -p logs
LOG_FILE="logs/phase2_progress_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== PHASE 2 PROGRESS TRACKER ==="
echo "Date: $(date)"
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo ""

# Phase 2 baseline metrics
BASELINE_VIOLATIONS=32
TARGET_VIOLATIONS=10
STRETCH_TARGET=0

# Get current violation count
echo "1. TERMINAL OUTPUT POLICY COMPLIANCE"
echo "===================================="

VIOLATION_OUTPUT=$(bash scripts/validate_terminal_output.sh 2>&1 || true)
CURRENT_VIOLATIONS=$(echo "$VIOLATION_OUTPUT" | grep -c "CRITICAL VIOLATION" || echo "0")

echo "Baseline violations: $BASELINE_VIOLATIONS"
echo "Current violations: $CURRENT_VIOLATIONS"
echo "Target violations: $TARGET_VIOLATIONS"
echo "Stretch target: $STRETCH_TARGET"

# Calculate progress
if [ "$CURRENT_VIOLATIONS" -le "$BASELINE_VIOLATIONS" ]; then
    PROGRESS=$(( (BASELINE_VIOLATIONS - CURRENT_VIOLATIONS) * 100 / BASELINE_VIOLATIONS ))
    REMAINING=$(( CURRENT_VIOLATIONS - TARGET_VIOLATIONS ))
    echo "Progress: $PROGRESS% reduction achieved"

    if [ "$REMAINING" -gt 0 ]; then
        echo "Remaining to target: $REMAINING violations"
    else
        echo "TARGET ACHIEVED: Under target threshold"
    fi
else
    echo "WARNING: Violations increased since baseline"
fi

echo ""

# Root Artifact Guard status
echo "2. ROOT ARTIFACT GUARD COMPLIANCE"
echo "================================="

if bash scripts/enforce_output_location.sh >/dev/null 2>&1; then
    echo "Status: PASSING"
    echo "Repository root: Clean"
else
    echo "Status: FAILING"
    echo "Repository root: Artifacts detected"
fi

echo ""

# Smart Log Cleanup System status
echo "3. SMART LOG CLEANUP SYSTEM STATUS"
echo "=================================="

if [ -f "scripts/smart_cleanup.sh" ]; then
    echo "Core script: PRESENT"
else
    echo "Core script: MISSING"
fi

if grep -q "smart-cleanup" .github/workflows/post-merge-cleanup.yml 2>/dev/null; then
    echo "CI integration: PRESENT"
else
    echo "CI integration: MISSING"
fi

echo ""

# CI workflow compliance
echo "4. CI WORKFLOW COMPLIANCE"
echo "========================"

TOTAL_WORKFLOWS=$(find .github/workflows -name "*.yml" | wc -l)
echo "Total workflows: $TOTAL_WORKFLOWS"

# Count workflows with violations
VIOLATING_WORKFLOWS=0
for workflow in .github/workflows/*.yml; do
    if bash scripts/validate_terminal_output.sh "$workflow" 2>&1 | grep -q "CRITICAL VIOLATION"; then
        ((VIOLATING_WORKFLOWS++))
    fi
done 2>/dev/null || true

COMPLIANT_WORKFLOWS=$((TOTAL_WORKFLOWS - VIOLATING_WORKFLOWS))
COMPLIANCE_PERCENTAGE=$((COMPLIANT_WORKFLOWS * 100 / TOTAL_WORKFLOWS))

echo "Compliant workflows: $COMPLIANT_WORKFLOWS/$TOTAL_WORKFLOWS ($COMPLIANCE_PERCENTAGE%)"
echo "Violating workflows: $VIOLATING_WORKFLOWS"

echo ""

# Quality control status
echo "5. QUALITY CONTROL STATUS"
echo "========================="

if [ -f ".venv/bin/activate" ]; then
    echo "Virtual environment: PRESENT"

    # Activate venv and check QC
    # shellcheck source=/dev/null
    source .venv/bin/activate

    if command -v python >/dev/null 2>&1; then
        echo "Python environment: ACTIVE"

        # Run QC check if available
        if [ -f "scripts/qc_pre_push.sh" ]; then
            echo "Running QC validation..."
            if bash scripts/qc_pre_push.sh >/dev/null 2>&1; then
                echo "QC status: PASSING (95%+ threshold)"
            else
                echo "QC status: FAILING"
            fi
        else
            echo "QC script: NOT FOUND"
        fi
    else
        echo "Python environment: INACTIVE"
    fi
else
    echo "Virtual environment: MISSING"
fi

echo ""

# Phase 2 completion assessment
echo "6. PHASE 2 COMPLETION ASSESSMENT"
echo "================================"

COMPLETION_CRITERIA=0
TOTAL_CRITERIA=6

# Criterion 1: Terminal violations ≤10
if [ "$CURRENT_VIOLATIONS" -le "$TARGET_VIOLATIONS" ]; then
    echo "✅ Terminal violations ≤$TARGET_VIOLATIONS: ACHIEVED"
    ((COMPLETION_CRITERIA++))
else
    echo "❌ Terminal violations ≤$TARGET_VIOLATIONS: $CURRENT_VIOLATIONS violations remaining"
fi

# Criterion 2: Root Artifact Guard passes
if bash scripts/enforce_output_location.sh >/dev/null 2>&1; then
    echo "✅ Root Artifact Guard clean: ACHIEVED"
    ((COMPLETION_CRITERIA++))
else
    echo "❌ Root Artifact Guard clean: Artifacts detected"
fi

# Criterion 3: Smart Log Cleanup System functional
if [ -f "scripts/smart_cleanup.sh" ] && grep -q "smart-cleanup" .github/workflows/post-merge-cleanup.yml 2>/dev/null; then
    echo "✅ Smart Log Cleanup System: FUNCTIONAL"
    ((COMPLETION_CRITERIA++))
else
    echo "❌ Smart Log Cleanup System: Incomplete"
fi

# Criterion 4: All workflows compliant
if [ "$VIOLATING_WORKFLOWS" -eq 0 ]; then
    echo "✅ All workflows compliant: ACHIEVED"
    ((COMPLETION_CRITERIA++))
else
    echo "❌ All workflows compliant: $VIOLATING_WORKFLOWS workflows need fixes"
fi

# Criterion 5: Copilot instructions enforced
if grep -q "phase2_terminal_output_compliance" .github/copilot-instructions.md 2>/dev/null; then
    echo "✅ Copilot instructions enforced: ACHIEVED"
    ((COMPLETION_CRITERIA++))
else
    echo "❌ Copilot instructions enforced: Not configured"
fi

# Criterion 6: QC standards maintained
if [ -f "scripts/qc_pre_push.sh" ] && bash scripts/qc_pre_push.sh >/dev/null 2>&1; then
    echo "✅ QC standards maintained: ACHIEVED"
    ((COMPLETION_CRITERIA++))
else
    echo "❌ QC standards maintained: Failing"
fi

echo ""
echo "PHASE 2 COMPLETION: $COMPLETION_CRITERIA/$TOTAL_CRITERIA criteria met"

COMPLETION_PERCENTAGE=$((COMPLETION_CRITERIA * 100 / TOTAL_CRITERIA))
echo "Completion percentage: $COMPLETION_PERCENTAGE%"

if [ "$COMPLETION_CRITERIA" -eq "$TOTAL_CRITERIA" ]; then
    echo ""
    echo "🎉 PHASE 2 COMPLETE! Ready for Phase 3 transition."
elif [ "$COMPLETION_CRITERIA" -ge 4 ]; then
    echo ""
    echo "🟡 PHASE 2 NEARLY COMPLETE: $((TOTAL_CRITERIA - COMPLETION_CRITERIA)) criteria remaining"
else
    echo ""
    echo "🔴 PHASE 2 IN PROGRESS: $((TOTAL_CRITERIA - COMPLETION_CRITERIA)) criteria remaining"
fi

echo ""
echo "Next priority actions:"
if [ "$CURRENT_VIOLATIONS" -gt "$TARGET_VIOLATIONS" ]; then
    echo "  1. Fix terminal output violations (priority: CRITICAL)"
fi
if ! bash scripts/enforce_output_location.sh >/dev/null 2>&1; then
    echo "  2. Clean repository root artifacts (priority: HIGH)"
fi
if [ "$VIOLATING_WORKFLOWS" -gt 0 ]; then
    echo "  3. Fix violating workflows (priority: HIGH)"
fi

echo ""
echo "Progress log saved to: $LOG_FILE"
echo "Phase 2 plan: .codex/tasks/phase2_terminal_output_compliance.md"
echo "Baseline lock: .codex/BASELINE_LOCKED.md"
