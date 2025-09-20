#!/usr/bin/env bash
set -euo pipefail

# DevOnboarder Centralized Logging Policy Enforcement
# CRITICAL: Validates that ALL logs use centralized logs/ directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Ensure logs directory exists
mkdir -p "$PROJECT_ROOT/logs"

# Log validation results
LOG_FILE="$PROJECT_ROOT/logs/log_centralization_validation_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Centralized Logging Policy Validation"
echo "Started at: $(date -Iseconds)"
echo "Project root: $PROJECT_ROOT"
echo "Validation log: $LOG_FILE"
echo ""

# Track violations
VIOLATIONS=0
VIOLATION_FILES=()

echo "Scanning for logging policy violations..."
echo ""

# Check for log files outside logs/ directory
echo "1. Checking for scattered log files..."
SCATTERED_LOGS=$(find "$PROJECT_ROOT" -name "*.log" \
    -not -path "$PROJECT_ROOT/logs/*" \
    -not -path "$PROJECT_ROOT/.git/*" \
    -not -path "$PROJECT_ROOT/.venv/*" \
    -not -path "$PROJECT_ROOT/venv/*" \
    -not -path "$PROJECT_ROOT/node_modules/*" \
    -not -path "$PROJECT_ROOT/*/node_modules/*" \
    -not -path "$PROJECT_ROOT/.pytest_cache/*" \
    -not -path "$PROJECT_ROOT/__pycache__/*" \
    -not -path "$PROJECT_ROOT/.codex/state/*" \
    -not -path "$PROJECT_ROOT/docs/*sample*.log" \
    -not -path "$PROJECT_ROOT/docs/diagnostics-sample.log" \
    2>/dev/null || true)

if [ -n "$SCATTERED_LOGS" ]; then
    echo "VIOLATION: Log files found outside logs/ directory:"
    echo "$SCATTERED_LOGS" | while read -r file; do
        echo "   - $file"
        VIOLATION_FILES+=("$file")
    done
    VIOLATIONS=$((VIOLATIONS + 1))
    echo ""
else
    echo "SUCCESS: No scattered log files found"
    echo ""
fi

# Check for prohibited log directories
echo "2. Checking for prohibited log directories..."
PROHIBITED_DIRS=$(find "$PROJECT_ROOT" -type d -name "*log*" \
    -not -path "$PROJECT_ROOT/logs" \
    -not -path "$PROJECT_ROOT/.git/*" \
    -not -path "$PROJECT_ROOT/.venv/*" \
    -not -path "$PROJECT_ROOT/venv/*" \
    -not -path "$PROJECT_ROOT/node_modules/*" \
    -not -path "$PROJECT_ROOT/*/node_modules/*" \
    -not -path "$PROJECT_ROOT/.mypy_cache/*" \
    -not -path "$PROJECT_ROOT/logs/.mypy_cache/*" \
    -not -path "$PROJECT_ROOT/*/.mypy_cache/*" \
    -not -path "$PROJECT_ROOT/.codex/logs" \
    2>/dev/null || true)

if [ -n "$PROHIBITED_DIRS" ]; then
    echo "VIOLATION: Prohibited log directories found:"
    echo "$PROHIBITED_DIRS" | while read -r dir; do
        echo "   - $dir"
    done
    VIOLATIONS=$((VIOLATIONS + 1))
    echo ""
else
    echo "SUCCESS: No prohibited log directories found"
    echo ""
fi

# Check scripts for hardcoded log paths
echo "3. Checking scripts for hardcoded non-centralized log paths..."
SCRIPT_VIOLATIONS=$(grep -r "/tmp.*\.log\|ci-logs/" "$PROJECT_ROOT/scripts/" \
    --include="*.sh" --include="*.py" \
    | grep -v "logs/" \
    | grep -v "# OK:" \
    | grep -v "$LOG_FILE" \
    | grep -v "validate_log_centralization.sh" \
    | grep -v "\.log.*pattern" \
    | grep -v "find.*\.log" \
    | grep -v "grep.*\.log" \
    || true)

if [ -n "$SCRIPT_VIOLATIONS" ]; then
    echo "VIOLATION: Scripts with non-centralized logging found:"
    echo "$SCRIPT_VIOLATIONS"
    VIOLATIONS=$((VIOLATIONS + 1))
    echo ""
else
    echo "SUCCESS: All scripts use centralized logging"
    echo ""
fi

# Check GitHub workflows for hardcoded log paths
echo "4. Checking GitHub workflows for non-centralized logging..."
WORKFLOW_VIOLATIONS=$(grep -r "/tmp.*\.log\|ci-logs/" "$PROJECT_ROOT/.github/workflows/" \
    --include="*.yml" --include="*.yaml" \
    | grep -v "path: logs" \
    | grep -v "name: ci-logs" \
    | grep -v "# OK:" \
    || true)

if [ -n "$WORKFLOW_VIOLATIONS" ]; then
    echo "VIOLATION: Workflows with non-centralized logging found:"
    echo "$WORKFLOW_VIOLATIONS"
    VIOLATIONS=$((VIOLATIONS + 1))
    echo ""
else
    echo "SUCCESS: All workflows use centralized logging"
    echo ""
fi

# Check for legacy ci-logs references in documentation
echo "5. Checking documentation for legacy log references..."
DOC_VIOLATIONS=$(grep -r "ci-logs" "$PROJECT_ROOT/docs/" \
    --include="*.md" \
    | grep -v "logs/" \
    | grep -v "Legacy:" \
    | grep -v "DEPRECATED:" \
    || true)

if [ -n "$DOC_VIOLATIONS" ]; then
    echo "WARNING: Documentation with legacy log references found:"
    echo "$DOC_VIOLATIONS"
    echo "   (Not blocking, but should be updated)"
    echo ""
else
    echo "SUCCESS: Documentation uses correct log references"
    echo ""
fi

# Validate logs/ directory structure
echo "6. Validating logs/ directory structure..."
if [ -d "$PROJECT_ROOT/logs" ]; then
    echo "SUCCESS: Centralized logs/ directory exists"

    # Check if logs/ is in .gitignore
    if grep -q "^logs/$" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
        echo "SUCCESS: logs/ directory properly ignored in .gitignore"
    else
        echo "VIOLATION: logs/ directory not found in .gitignore"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
else
    echo "VIOLATION: Centralized logs/ directory does not exist"
    VIOLATIONS=$((VIOLATIONS + 1))
fi

echo ""
echo "VALIDATION SUMMARY"
echo "====================="
echo "Total violations: $VIOLATIONS"
echo "Validation log: $LOG_FILE"
echo ""

if [ $VIOLATIONS -eq 0 ]; then
    echo "SUCCESS: Centralized Logging Policy COMPLIANT"
    echo "All logging properly uses centralized logs/ directory"
    echo ""
    echo "COMPLIANCE STATUS: PASSED"
    exit 0
else
    echo "FAILURE: Centralized Logging Policy VIOLATIONS DETECTED"
    echo "$VIOLATIONS violation(s) must be fixed before proceeding"
    echo ""
    echo "REQUIRED ACTIONS:"
    echo "   1. Move all scattered log files to logs/ directory"
    echo "   2. Remove prohibited log directories"
    echo "   3. Update scripts to use centralized logging pattern"
    echo "   4. Update workflows to use logs/ for all output"
    echo "   5. Ensure logs/ is in .gitignore"
    echo ""
    echo "POLICY REFERENCE: docs/standards/centralized-logging-policy.md"
    echo "COMPLIANCE STATUS: FAILED"
    exit 1
fi
