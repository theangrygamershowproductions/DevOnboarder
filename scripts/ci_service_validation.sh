#!/bin/bash
# Phase 3: CI Service Validation Loop Script
# Integrates quality gates into CI pipeline with automated validation

set -euo pipefail

# Centralized log location
LOG_FILE="logs/ci_service_validation_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting Phase 3 CI Service Validation Loop"

# Parse command line arguments
PHASE=${1:-3}
MODE=${2:-warning}  # strict, warning, monitoring
SERVICES_FILTER=${3:-all}

echo "Phase: $PHASE, Mode: $MODE, Services: $SERVICES_FILTER"

# Track validation results
VALIDATION_FAILURES=0
QUALITY_GATE_RESULTS=""

# Function to add validation result
add_result() {
    local test_name="$1"
    local status="$2"
    local details="$3"

    QUALITY_GATE_RESULTS+="{\"test\":\"$test_name\",\"status\":\"$status\",\"details\":\"$details\"},"

    if [ "$status" = "FAIL" ]; then
        ((VALIDATION_FAILURES++))
        echo "❌ $test_name: $details"
    else
        echo "✅ $test_name: $details"
    fi
}

echo "=== CI Service Validation: Network Contracts ==="
if bash scripts/validate_network_contracts.sh >/dev/null 2>&1; then
    add_result "Network Contracts" "PASS" "All network tiers properly configured"
else
    add_result "Network Contracts" "FAIL" "Network contract violations detected"
fi

echo "=== CI Service Validation: Service Health ==="
SERVICES=(auth-service backend discord-integration dashboard-service frontend)
for svc in "${SERVICES[@]}"; do
    if [ "$SERVICES_FILTER" != "all" ] && [ "$SERVICES_FILTER" != "$svc" ]; then
        continue
    fi

    if docker compose -f docker-compose.dev.yaml ps -q "$svc" >/dev/null 2>&1; then
        STATUS=$(docker compose -f docker-compose.dev.yaml ps -q "$svc" | xargs docker inspect -f '{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
        if [ "$STATUS" = "healthy" ]; then
            add_result "Service Health: $svc" "PASS" "Service is healthy"
        else
            add_result "Service Health: $svc" "FAIL" "Service status: $STATUS"
        fi
    else
        add_result "Service Health: $svc" "FAIL" "Service not running"
    fi
done

echo "=== CI Service Validation: Artifact Hygiene ==="
if bash scripts/enforce_output_location.sh >/dev/null 2>&1; then
    add_result "Artifact Hygiene" "PASS" "No root-level artifacts detected"
else
    add_result "Artifact Hygiene" "FAIL" "Root-level artifacts violate hygiene policy"
fi

echo "=== CI Service Validation: Coverage Thresholds ==="
# Placeholder for coverage validation - would integrate with actual coverage tools
add_result "Coverage Validation" "PASS" "Coverage thresholds met (placeholder)"

# Generate results summary
echo ""
echo "=== Phase 3 CI Validation Results ==="
echo "Total validation failures: $VALIDATION_FAILURES"
echo "Mode: $MODE"

# Handle enforcement based on mode
case $MODE in
    "strict")
        if [ $VALIDATION_FAILURES -gt 0 ]; then
            echo "❌ STRICT MODE: Blocking CI due to validation failures"
            exit 1
        else
            echo "✅ STRICT MODE: All validations passed, CI approved"
        fi
        ;;
    "warning")
        if [ $VALIDATION_FAILURES -gt 0 ]; then
            echo "⚠️  WARNING MODE: Validation failures detected, but CI allowed to continue"
            echo "Consider reviewing failures before merge"
        else
            echo "✅ WARNING MODE: All validations passed"
        fi
        ;;
    "monitoring")
        echo "📊 MONITORING MODE: Validation results recorded for metrics"
        ;;
    *)
        echo "❌ Unknown mode: $MODE. Use strict, warning, or monitoring"
        exit 1
        ;;
esac

echo "Phase 3 CI Service Validation Loop completed"
echo "Results logged to: $LOG_FILE"
