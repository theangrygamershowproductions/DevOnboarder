#!/usr/bin/env bash
set -euo pipefail

# Enhanced Smart Pre-commit Hook for Proactive CI
# Integrates with existing emoji policy enforcement framework

echo "SYMBOL Enhanced Smart Pre-commit Validation"

# Source existing QC system for consistency
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QC_SCRIPT="$SCRIPT_DIR/qc_pre_push.sh"

# Function to run targeted validation on changed files
run_targeted_validation() {
    local changed_files
    changed_files=$(git diff --cached --name-only)

    if [ -z "$changed_files" ]; then
        echo "   No staged files found"
        return 0
    fi

    echo "   Validating $(echo "$changed_files" | wc -l) staged files..."

    local validation_failed=false
    local auto_fixes_applied=false

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Skip binary files and non-text files
            if file --mime-type "$file" | grep -q "text/"; then
                echo "   SYMBOL Checking: $file"

                # 1. Emoji policy enforcement (existing tool)
                if [[ "$file" =~ \.(md|py|sh|yml|yaml)$ ]]; then
                    if [ -x "$SCRIPT_DIR/comprehensive_emoji_scrub.py" ]; then
                        if python "$SCRIPT_DIR/comprehensive_emoji_scrub.py" "$file" --auto-fix; then
                            echo "   SYMBOL Auto-fixed emoji violations in $file"
                            git add "$file"  # Re-stage fixed file
                            auto_fixes_applied=true
                        fi
                    fi
                fi

                # 2. Terminal output validation for shell scripts
                if [[ "$file" =~ \.sh$ ]]; then
                    if [ -x "$SCRIPT_DIR/validate_terminal_output_simple.sh" ]; then
                        if ! bash "$SCRIPT_DIR/validate_terminal_output_simple.sh" "$file"; then
                            echo "   SYMBOL Terminal output violation in $file"
                            validation_failed=true
                        fi
                    fi
                fi

                # 3. Policy violation detection
                if [[ "$file" =~ \.(py|sh|yml|yaml|md)$ ]]; then
                    if [ -x "$SCRIPT_DIR/agent_policy_enforcer.py" ]; then
                        if ! python "$SCRIPT_DIR/agent_policy_enforcer.py" "$file" --check-only; then
                            echo "   SYMBOL Policy violations detected in $file"
                            validation_failed=true
                        fi
                    fi
                fi
            fi
        fi
    done <<< "$changed_files"

    # If auto-fixes were applied, suggest re-running commit
    if [ "$auto_fixes_applied" = true ]; then
        echo ""
        echo "SYMBOL Auto-fixes applied to staged files"
        echo "   Files have been re-staged automatically"
        echo "   You can now commit again"
        return 0
    fi

    # If validation failed, provide guidance
    if [ "$validation_failed" = true ]; then
        echo ""
        echo "SYMBOL Pre-commit validation failed"
        echo "   Fix the violations above and try again"
        echo "   Or run: $QC_SCRIPT for comprehensive validation"
        return 1
    fi

    echo "SYMBOL Pre-commit validation passed"
    return 0
}

# Function to run smart QC based on change type
run_smart_qc() {
    local changed_files
    changed_files=$(git diff --cached --name-only)

    # Determine if full QC is needed based on changed files
    local needs_full_qc=false

    while IFS= read -r file; do
        # Trigger full QC for critical files
        if [[ "$file" =~ ^(pyproject\.toml|package\.json|\.github/workflows/|scripts/qc_|scripts/validate_) ]]; then
            needs_full_qc=true
            break
        fi

        # Trigger full QC for many changes
        if [ "$(echo "$changed_files" | wc -l)" -gt 10 ]; then
            needs_full_qc=true
            break
        fi
    done <<< "$changed_files"

    if [ "$needs_full_qc" = true ]; then
        echo "SYMBOL Running comprehensive QC validation..."
        if [ -x "$QC_SCRIPT" ]; then
            if ! "$QC_SCRIPT"; then
                echo "SYMBOL Comprehensive QC validation failed"
                echo "   Address the issues above before committing"
                return 1
            fi
        else
            echo "SYMBOL QC script not found at: $QC_SCRIPT"
        fi
    else
        echo "SYMBOL Targeted validation sufficient for this commit"
    fi

    return 0
}

# Main execution
main() {
    echo "   Integration with emoji policy enforcement framework"
    echo ""

    # 1. Run targeted validation first (fast)
    if ! run_targeted_validation; then
        exit 1
    fi

    echo ""

    # 2. Run smart QC if needed (comprehensive)
    if ! run_smart_qc; then
        exit 1
    fi

    echo ""
    echo "SYMBOL Enhanced pre-commit validation complete!"
    echo "   Ready to commit with proactive CI integration"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "SYMBOL Not in a git repository"
    exit 1
fi

# Check for virtual environment (DevOnboarder requirement)
if [ -z "${VIRTUAL_ENV:-}" ]; then
    echo "SYMBOL Virtual environment required"
    echo "   Run: source .venv/bin/activate"
    exit 1
fi

main "$@"
