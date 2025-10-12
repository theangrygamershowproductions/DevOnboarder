#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Test script to validate per-service coverage implementation.

set -euo pipefail

echo "🧪 Testing Per-Service Coverage Implementation"
echo "=============================================="
echo

# Check that our script is executable and has correct permissions
if [[ -x "scripts/generate_service_coverage_report.py" ]]; then
    success "Coverage report script is executable"
else
    error "Coverage report script permissions issue"
    exit 1
fi

# Validate script syntax
if python -m py_compile scripts/generate_service_coverage_report.py; then
    success "Coverage report script syntax is valid"
else
    error "Coverage report script has syntax errors"
    exit 1
fi

# Check that CI workflow has the new per-service structure
if grep -q "per-service coverage tests" .github/workflows/ci.yml; then
    success "CI workflow updated with per-service testing"
else
    error "CI workflow missing per-service testing"
    exit 1
fi

# Validate service thresholds are properly configured
if grep -q "devonboarder.*95" .github/workflows/ci.yml && \
   grep -q "xp.*90" .github/workflows/ci.yml && \
   grep -q "feedback.*85" .github/workflows/ci.yml; then
    success "Service thresholds properly configured"
else
    error "Service thresholds not properly configured"
    exit 1
fi

# Check artifact upload configuration
if grep -q "pytest-.*\.xml" .github/workflows/ci.yml && \
   grep -q "coverage.*\.xml" .github/workflows/ci.yml; then
    success "Per-service artifacts properly configured"
else
    error "Per-service artifacts not properly configured"
    exit 1
fi

echo
target "IMPLEMENTATION VALIDATION SUMMARY"
echo "==================================="
success "Script executable and syntax valid"
success "CI workflow updated with per-service logic"
success "Strategic service thresholds configured"
success "Comprehensive artifact collection enabled"
echo
deploy "Per-service coverage implementation is READY!"
echo "   Run the CI pipeline to see strategic testing in action."
