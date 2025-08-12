#!/bin/bash

# Enhanced validation targeting the final 4% of CI issues
# Focuses on known problem areas with specific fixes

set -euo pipefail

LOG_DIR="logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/final_4_percent_validation_$TIMESTAMP.log"

echo "TARGET Final 4% Validation - Targeting Remaining CI Issues"
echo "======================================================"
echo "Timestamp: $TIMESTAMP"
echo "Log file: $LOG_FILE"
echo

# Function to run individual validation with enhanced error reporting
run_validation() {
    local step_name="$1"
    local command="$2"
    local log_file="$LOG_DIR/step_${step_name,,}_$TIMESTAMP.log"

    echo "SEARCH Step: $step_name"
    echo "Command: $command"
    echo "Started: $(date)"

    if eval "$command" > "$log_file" 2>&1; then
        echo "SUCCESS $step_name: PASSED"
        return 0
    else
        echo "FAILED $step_name: FAILED"
        echo "Error details (last 10 lines):"
        tail -n 10 "$log_file" | sed 's/^/  /'
        echo "Full log: $log_file"
        return 1
    fi
}

# Ensure virtual environment is active
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo "WARNING  Activating virtual environment..."
    # shellcheck disable=SC1091 # Runtime source operation
    source .venv/bin/activate
fi

PASSED=0
FAILED=0

echo "=== 1. FRONTEND COVERAGE VALIDATION ==="
if run_validation "Frontend Dependencies" "cd frontend && npm ci"; then
    ((PASSED++))
else
    ((FAILED++))
fi

if run_validation "Frontend Coverage" "cd frontend && npm run coverage && npx nyc check-coverage --lines 95 --functions 95 --branches 95 --statements 95"; then
    ((PASSED++))
else
    ((FAILED++))
fi

echo
echo "=== 2. BOT ES MODULE TESTING ==="
if run_validation "Bot Dependencies" "cd bot && npm ci"; then
    ((PASSED++))
else
    ((FAILED++))
fi

if run_validation "Bot ES Module Tests" "cd bot && npm test -- --passWithNoTests --testTimeout=30000"; then
    ((PASSED++))
else
    ((FAILED++))
fi

echo
echo "=== 3. SERVICE INTEGRATION HEALTH ==="
if run_validation "Docker Environment Setup" "docker compose -f docker-compose.dev.yaml down || true"; then
    ((PASSED++))
else
    ((FAILED++))
fi

if run_validation "Service Health Checks" "docker compose -f docker-compose.dev.yaml up -d db auth-service && sleep 30 && curl -f http://localhost:8002/health --max-time 10"; then
    ((PASSED++))
else
    ((FAILED++))
fi

echo
echo "=== 4. ENVIRONMENT AUDIT ==="
if run_validation "Environment Sync Validation" "bash scripts/smart_env_sync.sh --validate-only"; then
    ((PASSED++))
else
    ((FAILED++))
fi

if run_validation "Security Audit" "bash scripts/env_security_audit.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

echo
echo "=== CLEANUP ==="
echo "Stopping Docker services..."
docker compose -f docker-compose.dev.yaml down || true

echo
echo "=== VALIDATION SUMMARY ==="
echo "Timestamp: $TIMESTAMP"
echo "Log directory: $LOG_DIR"
echo "Passed steps: $PASSED"
echo "Failed steps: $FAILED"
TOTAL=$((PASSED + FAILED))
if [[ $TOTAL -gt 0 ]]; then
    SUCCESS_RATE=$((PASSED * 100 / TOTAL))
    echo "Success rate: ${SUCCESS_RATE}%"

    if [[ $SUCCESS_RATE -ge 95 ]]; then
        echo "SYMBOL MISSION ACCOMPLISHED: 95%+ success rate achieved!"
    else
        echo "WARNING  Need to address remaining failures to reach 95%"
    fi
else
    echo "No tests executed"
fi

echo "Final 4% validation complete!"

# Exit with appropriate code
if [[ $FAILED -eq 0 ]]; then
    exit 0
else
    exit 1
fi
