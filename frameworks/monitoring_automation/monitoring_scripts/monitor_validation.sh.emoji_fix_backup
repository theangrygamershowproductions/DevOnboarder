#!/usr/bin/env bash
set -eo pipefail

echo "VIEW: DevOnboarder CI Validation Monitor"
echo "Real-time monitoring of comprehensive validation progress"
echo

# Find the most recent validation log
LATEST_LOG=$(find logs -name "comprehensive_ci_validation_*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)

if [ -z "$LATEST_LOG" ]; then
    echo "ERROR: No validation logs found in logs/"
    echo "TIP: Start validation first: bash scripts/validate_ci_locally.sh"
    exit 1
fi

echo "DOC: Monitoring: $LATEST_LOG"
echo "INFO: Use Ctrl+C to exit monitoring"
echo
echo "════════════════════════════════════════"

# Show current progress if validation is running
if pgrep -f "validate_ci_locally.sh" >/dev/null; then
    echo "🟢 Validation is currently RUNNING"
    echo "STATS: Real-time progress:"
    echo
    tail -f "$LATEST_LOG"
else
    echo "[NOT RUNNING] Validation is NOT running"
    echo "STATS: Final results from last run:"
    echo

    # Show summary
    if grep -q "FINAL SUMMARY" "$LATEST_LOG"; then
        echo "=== SUMMARY ==="
        sed -n '/=== FINAL SUMMARY ===/,/^$/p' "$LATEST_LOG"
        echo
    fi

    # Show any failures
    if grep -q "Status: FAILED" "$LATEST_LOG"; then
        echo "ERROR: FAILED STEPS:"
        grep -B1 -A5 "Status: FAILED" "$LATEST_LOG"
        echo
        echo "TIP: TROUBLESHOOTING:"
        echo "   • View specific step log: cat logs/step_N_stepname.log"
        echo "   • View all failures: grep -A10 'FAILED' $LATEST_LOG"
    else
        echo "SUCCESS: ALL STEPS PASSED"
    fi

    echo
    echo "TIP: TIP: Run 'bash scripts/validate_ci_locally.sh' to start new validation"
fi
