#!/bin/bash
# Terminal Output Policy Enforcement Script - Refined Edition
# ZERO TOLERANCE for violations that cause terminal hanging
# Excludes false positives from GitHub Actions file operations

set -euo pipefail

LOG_FILE="logs/terminal_output_validation_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

# Safety: guard potentially slow external commands with a short timeout
TIMEOUT=5

# Ensure child processes are cleaned up on exit (prevents stray greps/tee hanging)
trap 'pkill -P $$ >/dev/null 2>&1 || true' EXIT

echo "Starting Terminal Output Policy Validation (Refined)"
echo "Target: GitHub Actions workflows"
echo "Policy: ZERO TOLERANCE for emojis, command substitution, multi-line variables"
echo "Excluding: GitHub Actions file operations (GITHUB_OUTPUT, GITHUB_ENV)"

# Removed unused VIOLATIONS variable per shellcheck
# Main violation detection happens in detailed pattern checks below
WORKFLOW_DIR=".github/workflows"

# Helper function to check if a line is a safe GitHub Actions operation
is_github_actions_safe() {
    local line="$1"

    # Exclude safe GitHub Actions patterns
    if echo "$line" | grep -qE '(GITHUB_OUTPUT|GITHUB_ENV|GITHUB_STEP_SUMMARY)'; then
        return 0  # Safe
    fi

    # Exclude date command assignments (safe single commands)
    if echo "$line" | grep -qE '[A-Z_]+=\$\(date\s+[^)]*\)[[:space:]]*$'; then
        return 0  # Safe
    fi

    # Exclude simple command substitutions that are safe
    if echo "$line" | grep -qE '[A-Z_]+=\$\([^)]+\)[[:space:]]*$'; then
        return 0  # Safe single command
    fi

    # Exclude wc -l and find commands (safe)
    if echo "$line" | grep -qE '\$\((wc|find|grep -c)'; then
        return 0  # Safe
    fi

    return 1  # Potentially unsafe
}

# Check if workflow directory exists
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "No workflow directory found - skipping validation"
    exit 0
fi

echo "Scanning workflows in $WORKFLOW_DIR"

# Find all workflow files and validate them
total_violations=0

for file in "$WORKFLOW_DIR"/*.yml "$WORKFLOW_DIR"/*.yaml; do
    # Skip if no files match the pattern
    [ -f "$file" ] || continue

    echo "Validating file: $file"
    file_violations=0

    # 1. Check for emojis and Unicode characters (keep this check)
    if timeout "$TIMEOUT" grep -P '[\x{1F600}-\x{1F64F}]|[\x{1F300}-\x{1F5FF}]|[\x{1F680}-\x{1F6FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]|✅|❌|🛠️|📊|📈|📥|🔗|🐛|⚠️|💡|🎯|🚀|📋|🔍|📝' "$file" 2>/dev/null; then
        echo "CRITICAL VIOLATION: Emoji/Unicode characters found in $file"
        echo "These WILL cause immediate terminal hanging"
        ((file_violations++))
    fi

    # 2. Check for command substitution in echo statements (refined)
    while IFS= read -r line_with_num; do
        line_content=$(echo "$line_with_num" | cut -d: -f2-)

        # Skip if it's a safe GitHub Actions operation
        if is_github_actions_safe "$line_content"; then
            continue
        fi

        # Only flag actual problematic echo with command substitution
        if echo "$line_content" | grep -qE '^\s*echo\s+.*\$\('; then
            echo "CRITICAL VIOLATION: Command substitution in echo found in $file"
            echo "Line: $line_content"
            echo "This WILL cause terminal hanging"
            ((file_violations++))
        fi
    done < <(timeout "$TIMEOUT" grep -n -E 'echo.*\$\(' "$file" 2>/dev/null || true)

    # 3. Check for variable expansion in echo (refined)
    while IFS= read -r line_with_num; do
        line_num=$(echo "$line_with_num" | cut -d: -f1)
        line_content=$(echo "$line_with_num" | cut -d: -f2-)

        # Skip GitHub Actions file operations
        if echo "$line_content" | grep -qE '>>\s*\$\{?(GITHUB_OUTPUT|GITHUB_ENV|GITHUB_STEP_SUMMARY)'; then
            continue
        fi

        # Skip safe variable assignments
        if is_github_actions_safe "$line_content"; then
            continue
        fi

        # Only flag actual terminal output with variable expansion
        if echo "$line_content" | grep -qE '^\s*(echo)\s+.*\$[A-Z_][A-Z0-9_]*'; then
            echo "CRITICAL VIOLATION: Variable expansion in echo found in $file"
            echo "Line $line_num: $line_content"
            echo "This can cause terminal hanging"
            ((file_violations++))
        fi
    done < <(timeout "$TIMEOUT" grep -n -E '^\s*echo.*\$[A-Z_][A-Z0-9_]*' "$file" 2>/dev/null || true)

    # 4. Check for actual multi-line string variables (refined)
    # Look for assignments that span multiple lines, not single-line commands
    in_multiline=false
    multiline_var=""
    line_num=0

    while IFS= read -r line; do
        ((line_num++))

        # Check if line starts a potentially problematic multi-line assignment
        if echo "$line" | grep -qE '^\s*[A-Z_]+="[^"]*$' && ! is_github_actions_safe "$line"; then
            in_multiline=true
            multiline_var="$line"
            continue
        fi

        # If we're in a multi-line context, check if it continues
        if [ "$in_multiline" = true ]; then
            if echo "$line" | grep -qE '^[^"]*"[[:space:]]*$'; then
                echo "CRITICAL VIOLATION: Multi-line string variable found in $file"
                echo "Starting line $line_num: $multiline_var"
                echo "This WILL cause terminal hanging"
                ((file_violations++))
                in_multiline=false
                multiline_var=""
            elif echo "$line" | grep -qE '^\s*$'; then
                # Empty line - continue checking
                continue
            else
                # Line doesn't continue the string - reset
                in_multiline=false
                multiline_var=""
            fi
        fi
    done < <(timeout "$TIMEOUT" cat "$file")

    # 5. Check for here-doc syntax near echo (keep this check)
    if timeout "$TIMEOUT" grep -B3 -A3 'EOF' "$file" | timeout "$TIMEOUT" grep -E 'echo|comment.*body' 2>/dev/null; then
        # Only warn, don't count as violation unless it's clearly problematic
        echo "WARNING: Here-doc near echo/comment context in $file"
        echo "Verify this does not cause terminal hanging"
    fi

    # 6. Check for escape sequences in echo (keep this check)
    while IFS= read -r line_with_num; do
        line_content=$(echo "$line_with_num" | cut -d: -f2-)

        # Only flag actual echo with escape sequences, not printf
        if echo "$line_content" | grep -qE '^\s*echo\s+.*\\[nt]'; then
            echo "CRITICAL VIOLATION: Escape sequences in echo found in $file"
            echo "Line: $line_content"
            echo "This WILL cause terminal hanging"
            ((file_violations++))
        fi
    done < <(timeout "$TIMEOUT" grep -n -E 'echo.*\\[nt]' "$file" 2>/dev/null || true)

    # Add file violations to total
    ((total_violations += file_violations))

done

# Check if any violations were found
if [ "$total_violations" -gt 0 ]; then
    echo "ENFORCEMENT FAILURE: $total_violations critical violations found"
    echo "These violations WILL cause terminal hanging in DevOnboarder environment"
    echo "ALL violations must be fixed before commit"
    echo "Use only individual echo commands with plain ASCII text"
    printf "Use printf for variable output: printf '%%s\\n' \"\\$VAR\"\n"
    exit 1
else
    echo "ENFORCEMENT SUCCESS: No terminal output policy violations found"
    echo "All workflows comply with ZERO TOLERANCE policy"
    exit 0
fi
