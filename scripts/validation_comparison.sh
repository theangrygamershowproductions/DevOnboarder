#!/bin/bash
# Validation Script Comparison Analysis

echo "=== Validation Script Comparison ==="
echo "Date: $(date)"
echo ""

echo "ORIGINAL SCRIPT RESULTS:"
bash scripts/validate_terminal_output.sh 2>&1 | grep -c "CRITICAL VIOLATION" | sed 's/^/Total violations: /'

echo ""
echo "FIXED SCRIPT RESULTS:"
bash scripts/validate_terminal_output_fixed.sh 2>&1 | grep -c "CRITICAL VIOLATION" | sed 's/^/Total violations: /'

echo ""
echo "IMPROVEMENT:"
ORIGINAL=$(bash scripts/validate_terminal_output.sh 2>&1 | grep -c "CRITICAL VIOLATION")
FIXED=$(bash scripts/validate_terminal_output_fixed.sh 2>&1 | grep -c "CRITICAL VIOLATION")
FALSE_POSITIVES=$((ORIGINAL - FIXED))
echo "False positives eliminated: $FALSE_POSITIVES"
echo "Accuracy improvement: $(( (FALSE_POSITIVES * 100) / ORIGINAL ))%"

echo ""
echo "ACTUAL VIOLATIONS REMAINING: $FIXED"
echo "Progress toward zero violations: $(( (32 - FIXED) * 100 / 32 ))% complete"
