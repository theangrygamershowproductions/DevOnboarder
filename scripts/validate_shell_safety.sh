#!/usr/bin/env bash
# Shell Command Safety Validator
# Detects potentially unsafe shell command patterns to prevent terminal hanging
# Created in response to Shell Interpretation Incident - September 19, 2025

set -euo pipefail

# Script configuration
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
LOG_DIR="$PROJECT_ROOT/logs"

# Initialize variables
VIOLATIONS_FOUND=0
VALIDATION_LOG="$LOG_DIR/shell_safety_validation_$(date %Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"

echo "DevOnboarder Shell Command Safety Validator"
echo "=========================================="
echo "Incident Reference: shell-interpretation-incident-20250919.md"
echo "Log: $VALIDATION_LOG"
echo ""

# Function to log violations
log_violation() {
    local severity="$1"
    local pattern="$2"
    local file="$3"
    local line="$4"
    local content="$5"

    echo "[$severity] $pattern in $file:$line" | tee -a "$VALIDATION_LOG"
    echo "  Content: $content" | tee -a "$VALIDATION_LOG"
    echo "" | tee -a "$VALIDATION_LOG"
    ((VIOLATIONS_FOUND))
}

# Pattern detection functions
check_unsafe_gh_commands() {
    echo "Checking for unsafe GitHub CLI commands..."

    # Pattern 1: gh pr create with inline --body containing metacharacters
    if grep -n "gh pr create.*--body.*[*\[\]\$\`]" scripts/*.sh 2>/dev/null; then
        while IFS: read -r file line content; do
            log_violation "HIGH" "Unsafe gh pr create with metacharacters" "$file" "$line" "$content"
        done < <(grep -n "gh pr create.*--body.*[*\[\]\$\`]" scripts/*.sh 2>/dev/null)
    fi

    # Pattern 2: gh issue create with inline --body containing metacharacters
    if grep -n "gh issue create.*--body.*[*\[\]\$\`]" scripts/*.sh 2>/dev/null; then
        while IFS: read -r file line content; do
            log_violation "HIGH" "Unsafe gh issue create with metacharacters" "$file" "$line" "$content"
        done < <(grep -n "gh issue create.*--body.*[*\[\]\$\`]" scripts/*.sh 2>/dev/null)
    fi

    # Pattern 3: Multi-line content in shell variables
    if grep -n "BODY=.*\\\$" scripts/*.sh 2>/dev/null; then
        while IFS=':' read -r file line content; do
            log_violation "MEDIUM" "Multi-line content in shell variable" "$file" "$line" "$content"
        done < <(grep -n "BODY=.*\\\$" scripts/*.sh 2>/dev/null)
    fi
}

check_unsafe_echo_patterns() {
    echo "Checking for unsafe echo patterns..."

    # Pattern 1: Echo with emojis (from Terminal Output Policy)
    if grep -n "echo.*[TARGET:🥔]" scripts/*.sh 2>/dev/null; then
        while IFS: read -r file line content; do
            log_violation "CRITICAL" "Echo with emoji characters (terminal hanging risk)" "$file" "$line" "$content"
        done < <(grep -n "echo.*[TARGET:🥔]" scripts/*.sh 2>/dev/null)
    fi

    # Pattern 2: Echo with command substitution
    if grep -n "echo.*\\\$(" scripts/*.sh 2>/dev/null; then
        while IFS: read -r file line content; do
            log_violation "HIGH" "Echo with command substitution" "$file" "$line" "$content"
        done < <(grep -n "echo.*\\\$(" scripts/*.sh 2>/dev/null)
    fi

    # Pattern 3: Echo with variable expansion
    if grep -n "echo.*\\\$[a-zA-Z_]" scripts/*.sh 2>/dev/null; then
        while IFS: read -r file line content; do
            log_violation "MEDIUM" "Echo with variable expansion" "$file" "$line" "$content"
        done < <(grep -n "echo.*\\\$[a-zA-Z_]" scripts/*.sh 2>/dev/null)
    fi
}

check_unquoted_variables() {
    echo "Checking for unquoted variables in commands..."

    # Pattern: Unquoted variables with metacharacters
    if grep -n "[a-zA-Z_]*=.*[*\[\]].*" scripts/*.sh 2>/dev/null; then
        while IFS=':' read -r file line content; do
            if [[ ! "$content" =~ ^\# ]]; then  # Skip comments
                log_violation "MEDIUM" "Unquoted variable with metacharacters" "$file" "$line" "$content"
            fi
        done < <(grep -n "[a-zA-Z_]*=.*[*\[\]].*" scripts/*.sh 2>/dev/null)
    fi
}

check_unsafe_command_patterns() {
    echo "Checking for other unsafe command patterns..."

    # Pattern 1: eval with complex content
    if grep -n "eval.*[*\[\]\$]" scripts/*.sh 2>/dev/null; then
        while IFS=':' read -r file line content; do
            log_violation "CRITICAL" "Eval with metacharacters" "$file" "$line" "$content"
        done < <(grep -n "eval.*[*\[\]\$]" scripts/*.sh 2>/dev/null)
    fi

    # Pattern 2: Complex content in function calls
    if grep -n "gh.*--.*\".*[*\[\]].*\"" scripts/*.sh 2>/dev/null; then
        while IFS=':' read -r file line content; do
            log_violation "HIGH" "GitHub CLI with quoted metacharacters" "$file" "$line" "$content"
        done < <(grep -n "gh.*--.*\".*[*\[\]].*\"" scripts/*.sh 2>/dev/null)
    fi
}

# Run all checks
echo "Starting shell safety validation..."
echo "=================================" | tee -a "$VALIDATION_LOG"
echo "Date: $(date)" | tee -a "$VALIDATION_LOG"
echo "Incident: shell-interpretation-incident-20250919.md" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

check_unsafe_gh_commands
check_unsafe_echo_patterns
check_unquoted_variables
check_unsafe_command_patterns

echo "Shell safety validation complete"
echo "================================"

if [ "$VIOLATIONS_FOUND" -eq 0 ]; then
    echo " No shell safety violations detected"
    echo "All commands follow DevOnboarder terminal safety standards"
    exit 0
else
    echo " $VIOLATIONS_FOUND shell safety violations detected"
    echo "Review log: $VALIDATION_LOG"
    echo ""
    echo "Recommended actions:"
    echo "1. Use --body-file instead of --body for GitHub CLI commands"
    echo "2. Use printf instead of echo for variable content"
    echo "3. Quote all variables and escape metacharacters"
    echo "4. Follow DevOnboarder Terminal Output Policy guidelines"
    echo ""
    echo "See: docs/incidents/shell-interpretation-incident-20250919.md"
    exit 1
fi
