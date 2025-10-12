#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# shellcheck disable=SC2126,SC2012
# scripts/validate_split_readiness.sh
# Validates DevOnboarder's readiness for strategic repository split using comprehensive diagnostic data

set -euo pipefail

LOG_FILE="logs/split_readiness_validation_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Strategic Split Readiness Validation"
echo "================================================"
echo "Comprehensive assessment of repository split readiness using diagnostic data"
echo ""

# Check prerequisites
echo "=== Prerequisites Check ==="
echo "Validating required diagnostic tools and data..."

PREREQUISITES_MET=true

# Check if diagnostic scripts exist
if [ ! -f "scripts/analyze_service_dependencies.sh" ]; then
    error "Missing: scripts/analyze_service_dependencies.sh"
    PREREQUISITES_MET=false
else
    success "Found: Service dependency analysis script"
fi

if [ ! -f "scripts/extract_service_interfaces.py" ]; then
    error "Missing: scripts/extract_service_interfaces.py"
    PREREQUISITES_MET=false
else
    success "Found: Service interface extraction script"
fi

if [ ! -f "scripts/catalog_shared_resources.sh" ]; then
    error "Missing: scripts/catalog_shared_resources.sh"
    PREREQUISITES_MET=false
else
    success "Found: Shared resources catalog script"
fi

if [ ! -f "docs/strategic-split-assessment.md" ]; then
    error "Missing: docs/strategic-split-assessment.md"
    PREREQUISITES_MET=false
else
    success "Found: Strategic split assessment documentation"
fi

if [ "$PREREQUISITES_MET" = false ]; then
    echo ""
    error "Prerequisites not met. Please run the missing diagnostic tools first."
    echo "Recommended order:"
    echo "1. bash scripts/analyze_service_dependencies.sh"
    echo "2. python scripts/extract_service_interfaces.py"
    echo "3. bash scripts/catalog_shared_resources.sh"
    exit 1
fi

echo ""

# Run diagnostic tools if data is missing
echo "=== Running Diagnostic Analysis ==="
echo "Executing diagnostic tools to gather current data..."

echo "Running service dependency analysis..."
if ! bash scripts/analyze_service_dependencies.sh >/dev/null 2>&1; then
    warning "Warning: Service dependency analysis had issues, continuing..."
else
    success "Service dependency analysis complete"
fi

echo "Running service interface extraction..."
if ! python scripts/extract_service_interfaces.py >/dev/null 2>&1; then
    warning "Warning: Service interface extraction had issues, continuing..."
else
    success "Service interface extraction complete"
fi

echo "Running shared resources catalog..."
if ! bash scripts/catalog_shared_resources.sh >/dev/null 2>&1; then
    warning "Warning: Shared resources catalog had issues, continuing..."
else
    success "Shared resources catalog complete"
fi

echo ""

# Analyze collected data
echo "=== Split Readiness Analysis ==="
echo "Analyzing diagnostic data for split readiness assessment..."

# Service boundary analysis
echo "Service Boundary Maturity:"
SERVICE_DIRS=$(find src/ -maxdepth 1 -type d 2>/dev/null | grep -v "src/$" | wc -l)
echo "  Service directories identified: $SERVICE_DIRS"

if [ "$SERVICE_DIRS" -ge 4 ]; then
    echo "  SUCCESS: GOOD: Multiple services with clear directory boundaries"
    SERVICE_BOUNDARY_SCORE=3
elif [ "$SERVICE_DIRS" -ge 2 ]; then
    echo "  WARNING: MODERATE: Some service separation present"
    SERVICE_BOUNDARY_SCORE=2
else
    echo "  ERROR: POOR: Limited service boundary separation"
    SERVICE_BOUNDARY_SCORE=1
fi

echo ""

# Database coupling analysis
echo "Database Coupling Assessment:"
DB_MODEL_FILES=$(find src/ -name "*model*.py" -o -name "models.py" 2>/dev/null | wc -l)
SHARED_DB_REFS=$(grep -r "DATABASE_URL\|Session\|db\." src/ 2>/dev/null | wc -l)

echo "  Database model files: $DB_MODEL_FILES"
echo "  Shared database references: $SHARED_DB_REFS"

if [ "$SHARED_DB_REFS" -lt 20 ]; then
    echo "  SUCCESS: LOW: Manageable database coupling"
    DB_COUPLING_SCORE=3
elif [ "$SHARED_DB_REFS" -lt 50 ]; then
    echo "  WARNING: MEDIUM: Moderate database coupling"
    DB_COUPLING_SCORE=2
else
    echo "  ERROR: HIGH: Significant database coupling"
    DB_COUPLING_SCORE=1
fi

echo ""

# API interface maturity
echo "API Interface Maturity:"
if [ -f "docs/service-api-contracts.md" ]; then
    API_ENDPOINTS=$(grep -c "^- \*\*[A-Z]" docs/service-api-contracts.md 2>/dev/null || echo "0")
    echo "  Documented API endpoints: $API_ENDPOINTS"

    if [ "$API_ENDPOINTS" -gt 20 ]; then
        echo "  SUCCESS: MATURE: Comprehensive API documentation"
        API_MATURITY_SCORE=3
    elif [ "$API_ENDPOINTS" -gt 10 ]; then
        echo "  WARNING: DEVELOPING: Moderate API documentation"
        API_MATURITY_SCORE=2
    else
        echo "  ERROR: IMMATURE: Limited API documentation"
        API_MATURITY_SCORE=1
    fi
else
    echo "  ERROR: No API contract documentation found"
    API_MATURITY_SCORE=1
fi

echo ""

# Test coverage analysis
echo "Test Coverage Assessment:"
if command -v python >/dev/null 2>&1; then
    PYTHON_COVERAGE=$(python -c "
import json
import os
try:
    with open('.coverage', 'r') as f: pass
    print('Coverage file found')
except:
    print('No coverage data')
" 2>/dev/null || echo "No coverage data")
    echo "  Python test coverage: $PYTHON_COVERAGE"
fi

# Check if Jest is configured properly (our recent fix)
if [ -f "bot/package.json" ] && grep -q "testTimeout" bot/package.json; then
    echo "  SUCCESS: Jest timeout configured (CI stability)"
    TEST_CONFIG_SCORE=3
else
    echo "  WARNING: Jest timeout missing (potential CI issues)"
    TEST_CONFIG_SCORE=2
fi

echo ""

# CI/CD complexity analysis
echo "CI/CD Infrastructure Assessment:"
WORKFLOW_COUNT=$(ls .github/workflows/ 2>/dev/null | wc -l)
MULTI_SERVICE_WORKFLOWS=$(grep -l "frontend\|bot\|auth\|xp" .github/workflows/*.yml 2>/dev/null | wc -l)

echo "  Total workflows: $WORKFLOW_COUNT"
echo "  Multi-service workflows: $MULTI_SERVICE_WORKFLOWS"

if [ "$WORKFLOW_COUNT" -lt 10 ]; then
    echo "  SUCCESS: SIMPLE: Manageable CI/CD complexity"
    CI_COMPLEXITY_SCORE=3
elif [ "$WORKFLOW_COUNT" -lt 20 ]; then
    echo "  WARNING: MODERATE: Some CI/CD complexity"
    CI_COMPLEXITY_SCORE=2
else
    echo "  ERROR: COMPLEX: High CI/CD coordination needed"
    CI_COMPLEXITY_SCORE=1
fi

echo ""

# Calculate overall readiness score
TOTAL_SCORE=$((SERVICE_BOUNDARY_SCORE + DB_COUPLING_SCORE + API_MATURITY_SCORE + TEST_CONFIG_SCORE + CI_COMPLEXITY_SCORE))
MAX_SCORE=15

echo "=== Overall Split Readiness Assessment ==="
echo "Calculating readiness score based on diagnostic analysis..."
echo ""

echo "Component Scores:"
echo "  Service Boundaries: $SERVICE_BOUNDARY_SCORE/3"
echo "  Database Coupling: $DB_COUPLING_SCORE/3"
echo "  API Maturity: $API_MATURITY_SCORE/3"
echo "  Test Configuration: $TEST_CONFIG_SCORE/3"
echo "  CI/CD Complexity: $CI_COMPLEXITY_SCORE/3"
echo ""

echo "Overall Readiness Score: $TOTAL_SCORE/$MAX_SCORE"

READINESS_PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))
echo "Readiness Percentage: $READINESS_PERCENTAGE%"

echo ""

# Generate recommendations based on score
if [ "$READINESS_PERCENTAGE" -ge 80 ]; then
    target "RECOMMENDATION: READY FOR STRATEGIC SPLIT"
    echo ""
    success "High readiness score indicates successful split probability"
    success "Service boundaries are well-defined"
    success "Technical infrastructure supports split"
    echo ""
    echo "Suggested Split Order:"
    echo "1. Discord Bot (Independent, lowest risk)"
    echo "2. Frontend (Clear API boundaries)"
    echo "3. Auth Service (Stable API, coordinate database)"
    echo "4. Remaining services (Based on API maturity)"

elif [ "$READINESS_PERCENTAGE" -ge 60 ]; then
    warning "RECOMMENDATION: PARTIALLY READY - ADDRESS KEY ISSUES"
    echo ""
    warning "Moderate readiness - address key issues before split"
    warning "Focus on improving lowest-scoring components"
    echo ""
    echo "Priority Improvements Needed:"
    if [ "$DB_COUPLING_SCORE" -lt 3 ]; then
        echo "- Reduce database coupling complexity"
    fi
    if [ "$API_MATURITY_SCORE" -lt 3 ]; then
        echo "- Improve API documentation and contracts"
    fi
    if [ "$CI_COMPLEXITY_SCORE" -lt 3 ]; then
        echo "- Simplify CI/CD workflow coordination"
    fi

else
    error "RECOMMENDATION: NOT READY - SIGNIFICANT PREPARATION NEEDED"
    echo ""
    error "Low readiness score indicates high split failure risk"
    error "Multiple components need improvement"
    echo ""
    echo "Required Preparation Before Split:"
    echo "- Establish clearer service boundaries"
    echo "- Reduce database coupling"
    echo "- Mature API contracts"
    echo "- Simplify CI/CD infrastructure"
    echo "- Improve test coverage and configuration"
fi

echo ""

# Generate specific next steps
echo "=== Recommended Next Steps ==="
echo ""

if [ "$READINESS_PERCENTAGE" -ge 80 ]; then
    echo "Immediate Actions (1-2 weeks):"
    echo "1. Create repository templates using existing patterns"
    echo "2. Start with Discord Bot split (lowest risk)"
    echo "3. Test split process with comprehensive validation"
    echo "4. Document lessons learned for subsequent splits"

elif [ "$READINESS_PERCENTAGE" -ge 60 ]; then
    echo "Preparation Actions (2-4 weeks):"
    echo "1. Address identified weak points in lowest-scoring areas"
    echo "2. Improve API documentation and service contracts"
    echo "3. Plan database migration strategy"
    echo "4. Re-run validation after improvements"

else
    echo "Foundation Building (4-8 weeks):"
    echo "1. Establish clear service boundary patterns"
    echo "2. Create comprehensive API documentation"
    echo "3. Reduce database coupling through refactoring"
    echo "4. Simplify CI/CD workflow structure"
    echo "5. Re-assess readiness after foundational improvements"
fi

echo ""
echo "Monitoring and Validation:"
echo "- Re-run this validation monthly during preparation"
echo "- Track readiness score improvements over time"
echo "- Use diagnostic data to validate split success"
echo "- Monitor service health metrics post-split"

echo ""
echo "Split readiness validation complete"
echo "Results saved to: $LOG_FILE"
echo ""
echo "Summary: $READINESS_PERCENTAGE% ready for strategic repository split"

# Exit with appropriate code based on readiness
if [ "$READINESS_PERCENTAGE" -ge 80 ]; then
    exit 0  # Ready
elif [ "$READINESS_PERCENTAGE" -ge 60 ]; then
    exit 1  # Partially ready
else
    exit 2  # Not ready
fi
