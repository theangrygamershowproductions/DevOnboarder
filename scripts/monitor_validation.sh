#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -eo pipefail

echo "📺 DevOnboarder CI Validation Monitor"
echo "Real-time monitoring of comprehensive validation progress"
echo

# Find the most recent validation log
LATEST_LOG=$(find logs -name "comprehensive_ci_validation_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)

if [ -z "$LATEST_LOG" ]; then
    error "No validation logs found in logs/"
    echo "💡 Start validation first: bash scripts/validate_ci_locally.sh"
    exit 1
fi

echo "📄 Monitoring: $LATEST_LOG"
echo "🔍 Use Ctrl+C to exit monitoring"
echo
echo "════════════════════════════════════════"

# Show current progress if validation is running
if pgrep -f "validate_ci_locally.sh" >/dev/null; then
    echo "🟢 Validation is currently RUNNING"
    report "Real-time progress:"
    echo
    tail -f "$LATEST_LOG"
else
    echo "🔴 Validation is NOT running"
    report "Final results from last run:"
    echo

    # Show summary
    if grep -q "FINAL SUMMARY" "$LATEST_LOG"; then
        echo "=== SUMMARY ==="
        sed -n '/=== FINAL SUMMARY ===/,/^$/p' "$LATEST_LOG"
        echo
    fi

    # Show any failures
    if grep -q "Status: FAILED" "$LATEST_LOG"; then
        error "FAILED STEPS:"
        grep -B1 -A5 "Status: FAILED" "$LATEST_LOG"
        echo
        echo "💡 TROUBLESHOOTING:"
        echo "   • View specific step log: cat logs/step_N_stepname.log"
        echo "   • View all failures: grep -A10 'FAILED' $LATEST_LOG"
    else
        success "ALL STEPS PASSED"
    fi

    echo
    echo "💡 TIP: Run 'bash scripts/validate_ci_locally.sh' to start new validation"
fi
