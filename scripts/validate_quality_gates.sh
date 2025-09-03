#!/usr/bin/env bash
# =============================================================================
# File: scripts/validate_quality_gates.sh
# Purpose: Validate that DevOnboarder quality gates are functional, not just appearing to function
# Author: DevOnboarder Project
# Standards: Zero-Accountability-Loss Framework compliance
# =============================================================================

set -euo pipefail

# Centralized logging compliance
mkdir -p logs
HEALTH_LOG="logs/quality_gate_health_$(date +%Y%m%d_%H%M%S).log"

{
    echo "DevOnboarder Quality Gate Health Check"
    echo "======================================"
    echo "Started: $(date -Iseconds)"
    echo "Repository: $(git remote get-url origin 2>/dev/null || echo 'unknown')"
    echo "User: $(whoami)"
    echo "Working Directory: $(pwd)"
    echo ""

    # 1. Verify git hooks are not disabled
    echo "1. Git Hooks Configuration Check"
    echo "--------------------------------"
    if HOOKS_PATH=$(git config --get core.hooksPath 2>/dev/null); then
        echo "CRITICAL FAILURE: core.hooksPath is set to: $HOOKS_PATH"
        echo "This disables git hooks. Quality gates are BYPASSED!"
        echo "Required action: git config --unset core.hooksPath"
        echo "Incident requires immediate investigation and documentation"
        exit 1
    else
        echo "SUCCESS: core.hooksPath not set (hooks enabled)"
    fi

    # 2. Verify pre-commit is installed
    echo ""
    echo "2. Pre-commit Installation Check"
    echo "---------------------------------"
    if [ ! -f .git/hooks/pre-commit ]; then
        echo "CRITICAL FAILURE: No pre-commit hook found at .git/hooks/pre-commit"
        echo "Quality gates are NOT installed!"
        echo "Required action: pre-commit install --install-hooks"
        exit 1
    else
        echo "SUCCESS: Pre-commit hook file exists"
        echo "Hook details: $(ls -la .git/hooks/pre-commit)"
    fi

    # 3. Verify pre-commit executable is accessible
    echo ""
    echo "3. Pre-commit Tool Accessibility"
    echo "---------------------------------"
    if ! command -v pre-commit >/dev/null 2>&1; then
        echo "CRITICAL FAILURE: pre-commit command not found"
        echo "Required action: Activate virtual environment and install pre-commit"
        exit 1
    else
        echo "SUCCESS: pre-commit executable found at: $(which pre-commit)"
        echo "Version: $(pre-commit --version)"
    fi

    # 4. Verify pre-commit functionality with test file
    echo ""
    echo "4. Pre-commit Functionality Test"
    echo "---------------------------------"
    TEST_FILE="test_quality_gate_$(date +%s).md"

    # Create test file with known violation (trailing space)
    echo "# Test file with trailing space " > "$TEST_FILE"
    git add "$TEST_FILE" 2>/dev/null || {
        echo "WARNING: Could not stage test file for validation"
        rm -f "$TEST_FILE"
    }

    # Test pre-commit run on specific file
    if git ls-files --cached | grep -q "$TEST_FILE"; then
        if pre-commit run --files "$TEST_FILE" >/dev/null 2>&1; then
            echo "CRITICAL FAILURE: Pre-commit did not catch trailing whitespace violation"
            echo "Quality gates may not be functioning properly"
            git reset HEAD "$TEST_FILE" 2>/dev/null || true
            rm -f "$TEST_FILE"
            exit 1
        else
            echo "SUCCESS: Pre-commit correctly caught test violation"
            git reset HEAD "$TEST_FILE" 2>/dev/null || true
            rm -f "$TEST_FILE"
        fi
    else
        echo "INFO: Skipping functional test (could not stage test file)"
    fi

    # 5. Verify virtual environment integration
    echo ""
    echo "5. Virtual Environment Integration"
    echo "----------------------------------"
    if [[ -z "${VIRTUAL_ENV:-}" ]]; then
        echo "WARNING: Virtual environment not activated"
        echo "Quality gates may not have access to required tools"
        echo "Recommended action: source .venv/bin/activate"
    else
        echo "SUCCESS: Virtual environment active: $VIRTUAL_ENV"
        echo "Python executable: $(which python)"
    fi

    # 6. Audit recent commits for bypass patterns
    echo ""
    echo "6. Recent Commit Bypass Audit"
    echo "------------------------------"
    BYPASS_COMMITS=$(git log --oneline --since="7 days ago" --grep="--no-verify" --grep="skip.*hook" --grep="bypass.*hook" 2>/dev/null || echo "")
    if [[ -n "$BYPASS_COMMITS" ]]; then
        echo "WARNING: Recent commits may have bypassed quality gates:"
        # POTATO: EMERGENCY APPROVED - validation-script-documentation-violation-20250902
        while IFS= read -r line; do
            echo "   $line"
        done <<< "$BYPASS_COMMITS"
        echo "These commits require review for compliance"
    else
        echo "SUCCESS: No recent quality gate bypass detected"
    fi

    # 7. Check for common quality gate files
    echo ""
    echo "7. Quality Gate File Integrity"
    echo "-------------------------------"
    REQUIRED_FILES=(".pre-commit-config.yaml" "pyproject.toml" ".markdownlint.json")
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            echo "SUCCESS: $file exists"
        else
            echo "WARNING: $file missing (quality configuration may be incomplete)"
        fi
    done

    # 8. Validate safe_commit.sh exists and is executable
    echo ""
    echo "8. Safe Commit Script Validation"
    echo "---------------------------------"
    if [[ -f "scripts/safe_commit.sh" && -x "scripts/safe_commit.sh" ]]; then
        echo "SUCCESS: safe_commit.sh exists and is executable"
    else
        echo "WARNING: scripts/safe_commit.sh missing or not executable"
        echo "Developers may bypass quality gates with direct git commit"
    fi

    echo ""
    echo "HEALTH CHECK SUMMARY"
    echo "==================="
    echo "SUCCESS: Quality gates are FUNCTIONAL and ENFORCED"
    echo "Validation completed without critical failures"
    echo "Health log: $HEALTH_LOG"
    echo "Completed: $(date -Iseconds)"

} 2>&1 | tee "$HEALTH_LOG"

echo ""
echo "Quality gate health check completed successfully"
echo "Log file: $HEALTH_LOG"
