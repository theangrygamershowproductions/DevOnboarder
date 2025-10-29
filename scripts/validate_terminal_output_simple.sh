#!/bin/bash
# Terminal Output Policy Enforcement Script - Simplified
# ZERO TOLERANCE for violations that cause terminal hanging

set -euo pipefail

echo "Starting Terminal Output Policy Validation (Simplified)"
echo "Target: GitHub Actions workflows"
echo "Policy: ZERO TOLERANCE for actual terminal-hanging patterns"

total_violations=0
WORKFLOW_DIR=".github/workflows"

# Check if workflow directory exists
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "No workflow directory found - skipping validation"
    exit 0
fi

echo "Scanning workflows in $WORKFLOW_DIR"

# Process each workflow file
for file in "$WORKFLOW_DIR"/*.yml "$WORKFLOW_DIR"/*.yaml; do
    # Skip if no files match the pattern
    [ -f "$file" ] || continue

    echo "Validating file: $file"

    # 1. Check for emojis and Unicode characters (CRITICAL)
    if grep -l '\|\|TARGET:\|\|\|\|\|\|\|\|\|GROW:\|📥\|LINK:\|🐛' "$file" 2>/dev/null; then
        echo "   CRITICAL: Emoji/Unicode characters found"
        ((total_violations))
    fi

    # 2. Check for variable expansion in echo (CRITICAL - causes hanging)
    # Exclude safe GitHub Actions patterns and variable assignments
    violations_found=$(grep -n '^\s*echo\s.*\$[A-Z_]' "$file" 2>/dev/null | grep -v 'GITHUB_OUTPUT\|GITHUB_ENV\|GITHUB_PATH' || true)
    if [ -n "$violations_found" ]; then
        echo "   CRITICAL: Variable expansion in echo found"
        echo "$violations_found" | head -3 | while read -r line; do
            echo "    Line: $line"
        done
        ((total_violations))
    fi

    # 3. Check for command substitution in echo (CRITICAL)
    violations_found=$(grep -n "echo.*\\\$(" "$file" 2>/dev/null | grep -v 'GITHUB_OUTPUT\|GITHUB_ENV' || true)
    if [ -n "$violations_found" ]; then
        echo "   CRITICAL: Command substitution in echo found"
        echo "$violations_found" | head -3 | while read -r line; do
            echo "    Line: $line"
        done
        ((total_violations))
    fi

    # 4. Check for multi-line echo with escape sequences (CRITICAL)
    if grep -n 'echo.*\\n\|echo.*\\t' "$file" 2>/dev/null | head -1 >/dev/null; then
        echo "   CRITICAL: Multi-line echo with escape sequences found"
        ((total_violations))
    fi

    # 5. Check for here-doc patterns (WARNING - context dependent)
    if grep -A3 -B3 'EOF' "$file" 2>/dev/null | grep 'echo\|comment.*body' | head -1 >/dev/null; then
        echo "   Here-doc near echo context - verify safety"
    fi

done

echo ""
echo "Validation complete"
echo "Total critical violations: $total_violations"

# Check if any violations were found
if [ "$total_violations" -gt 0 ]; then
    echo ""
    echo " ENFORCEMENT FAILURE: $total_violations critical violations found"
    echo "These violations WILL cause terminal hanging in DevOnboarder environment"
    echo ""
    echo "Required fixes:"
    printf "  • Replace echo with variable expansion: echo \"\\$VAR\"  printf '%%s\\n' \"\\$VAR\"\n"
    echo "  • Replace echo with command substitution: echo \"\$(cmd)\"  cmd"
    echo "  • Remove emojis/Unicode: [OK]  [OK]"
    printf "  • Replace multi-line echo: echo -e \"line1\\nline2\"  individual echo commands\n"
    echo ""
    exit 1
else
    echo ""
    echo "ENFORCEMENT  No critical terminal output violations found"
    echo "All workflows comply with ZERO TOLERANCE policy"
    exit 0
fi
