#!/bin/bash
# Test script to validate per-service coverage implementation.

set -euo pipefail

echo "🧪 Testing Per-Service Coverage Implementation"
echo "=============================================="
echo

# Check that our script is executable and has correct permissions
if [[ -x "scripts/generate_service_coverage_report.py" ]]; then
    echo "✅ Coverage report script is executable"
else
    echo "❌ Coverage report script permissions issue"
    exit 1
fi

# Validate script syntax
if python -m py_compile scripts/generate_service_coverage_report.py; then
    echo "✅ Coverage report script syntax is valid"
else
    echo "❌ Coverage report script has syntax errors"
    exit 1
fi

# Check that CI workflow has the new per-service structure
if grep -q "per-service coverage tests" .github/workflows/ci.yml; then
    echo "✅ CI workflow updated with per-service testing"
else
    echo "❌ CI workflow missing per-service testing"
    exit 1
fi

# Validate service thresholds are properly configured
if grep -q "devonboarder.*95" .github/workflows/ci.yml && \
   grep -q "xp.*90" .github/workflows/ci.yml && \
   grep -q "feedback.*85" .github/workflows/ci.yml; then
    echo "✅ Service thresholds properly configured"
else
    echo "❌ Service thresholds not properly configured"
    exit 1
fi

# Check artifact upload configuration
if grep -q "pytest-.*\.xml" .github/workflows/ci.yml && \
   grep -q "coverage.*\.xml" .github/workflows/ci.yml; then
    echo "✅ Per-service artifacts properly configured"
else
    echo "❌ Per-service artifacts not properly configured"
    exit 1
fi

echo
echo "🎯 IMPLEMENTATION VALIDATION SUMMARY"
echo "==================================="
echo "✅ Script executable and syntax valid"
echo "✅ CI workflow updated with per-service logic"
echo "✅ Strategic service thresholds configured"
echo "✅ Comprehensive artifact collection enabled"
echo
echo "🚀 Per-service coverage implementation is READY!"
echo "   Run the CI pipeline to see strategic testing in action."
