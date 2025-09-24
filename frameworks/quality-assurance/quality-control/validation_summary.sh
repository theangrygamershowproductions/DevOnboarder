#!/usr/bin/env bash
set -euo pipefail

# Enhanced Validation Summary - Clean Error Reporting
# Provides clear, scannable output for all validation errors

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "=== DevOnboarder Validation Summary ==="
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo

# Initialize counters
TOTAL_ERRORS=0
MARKDOWN_ERRORS=0
TERMINAL_ERRORS=0
AGENT_ERRORS=0

# 1. Markdown Linting Summary
echo "MARKDOWN LINTING"
echo "-------------------"
if command -v npx >/dev/null 2>&1; then
    MARKDOWN_OUTPUT=$(npx markdownlint docs/ 2>&1 || true)
    if [ -n "$MARKDOWN_OUTPUT" ]; then
        # Parse and summarize markdown errors
        MARKDOWN_ERRORS=$(echo "$MARKDOWN_OUTPUT" | grep -c "MD[0-9]" || echo "0")
        if [ "$MARKDOWN_ERRORS" -gt 0 ]; then
            echo "Found $MARKDOWN_ERRORS markdown violations:"
            echo "$MARKDOWN_OUTPUT" | grep -E "MD[0-9]{3}" | head -5
            if [ "$MARKDOWN_ERRORS" -gt 5 ]; then
                echo "... and $((MARKDOWN_ERRORS - 5)) more"
            fi
            TOTAL_ERRORS=$((TOTAL_ERRORS + MARKDOWN_ERRORS))
        else
            echo "No markdown violations found"
        fi
    else
        echo "No markdown violations found"
    fi
else
    echo "markdownlint not available - skipped"
fi
echo

# 2. Terminal Output Policy Summary
echo "TERMINAL OUTPUT POLICY"
echo "-------------------------"
if [ -f "$REPO_ROOT/scripts/validate_terminal_output_simple.sh" ]; then
    TERMINAL_OUTPUT=$(bash "$REPO_ROOT/scripts/validate_terminal_output_simple.sh" 2>&1 || true)
    TERMINAL_ERRORS=$(echo "$TERMINAL_OUTPUT" | grep "Total critical violations:" | sed 's/Total critical violations: //' || echo "0")
    if [ "$TERMINAL_ERRORS" -gt 0 ]; then
        echo "Found $TERMINAL_ERRORS terminal policy violations:"
        echo "$TERMINAL_OUTPUT" | grep "CRITICAL VIOLATION" | head -5
        if [ "$TERMINAL_ERRORS" -gt 5 ]; then
            echo "... and $((TERMINAL_ERRORS - 5)) more"
        fi
        TOTAL_ERRORS=$((TOTAL_ERRORS + TERMINAL_ERRORS))
    else
        echo "No terminal policy violations found"
    fi
else
    echo "Terminal validation script not found - skipped"
fi
echo

# 3. Agent Certification Summary
echo "AGENT CERTIFICATION"
echo "----------------------"
if [ -f "$REPO_ROOT/scripts/validate_agent_certification.sh" ]; then
    AGENT_OUTPUT=$(bash "$REPO_ROOT/scripts/validate_agent_certification.sh" 2>&1 || true)
    if echo "$AGENT_OUTPUT" | grep -q "CERTIFICATION INCOMPLETE"; then
        AGENT_ERRORS=$(echo "$AGENT_OUTPUT" | grep -c "ERROR:" || echo "0")
        echo "Found $AGENT_ERRORS agent certification issues:"
        echo "$AGENT_OUTPUT" | grep "ERROR:" | head -3
        TOTAL_ERRORS=$((TOTAL_ERRORS + AGENT_ERRORS))
    else
        echo "All agents certified"
    fi
else
    echo "Agent validation script not found - skipped"
fi
echo

# 4. Summary Report
echo "VALIDATION SUMMARY"
echo "====================="
echo "Markdown violations: $MARKDOWN_ERRORS"
echo "Terminal violations: $TERMINAL_ERRORS"
echo "Agent cert issues:   $AGENT_ERRORS"
echo "                   --------"
echo "Total errors:        $TOTAL_ERRORS"
echo

if [ "$TOTAL_ERRORS" -eq 0 ]; then
    echo "ALL VALIDATIONS PASSED"
    exit 0
else
    echo "VALIDATION FAILURES DETECTED"
    echo
    echo "Quick Fix Commands:"
    [ "$MARKDOWN_ERRORS" -gt 0 ] && echo "  npx markdownlint --fix docs/"
    [ "$TERMINAL_ERRORS" -gt 0 ] && echo "  # Fix terminal output violations manually"
    [ "$AGENT_ERRORS" -gt 0 ] && echo "  # Update agent frontmatter manually"
    exit 1
fi
