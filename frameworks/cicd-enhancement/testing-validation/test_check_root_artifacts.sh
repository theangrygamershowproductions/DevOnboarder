#!/usr/bin/env bash
set -euo pipefail

# Test harness for root artifact detection scripts
echo "Testing root artifact detection scripts"

# Create test artifacts
echo "Creating test artifacts for validation"
mkdir -p test_artifacts_temp
touch test_artifacts_temp/.coverage.test
touch test_artifacts_temp/pytest_cache
mkdir -p test_artifacts_temp/__pycache__

# Move to temp location to avoid false positives
cd test_artifacts_temp

# Test 1: check_root_artifacts.sh should detect violations
echo "Test 1: Checking violation detection"
if bash ../scripts/check_root_artifacts.sh; then
    echo "FAIL: Should have detected violations"
    exit 1
else
    echo "PASS: Correctly detected violations"
fi

# Test 2: list_root_violations.sh should list artifacts
echo "Test 2: Checking violation listing"
violations=$(bash ../scripts/list_root_violations.sh)
if [ -n "$violations" ]; then
    echo "PASS: Listed violations:"
    echo "$violations"
else
    echo "FAIL: Should have listed violations"
    exit 1
fi

# Test 3: clean_root_artifacts.sh should remove artifacts
echo "Test 3: Checking cleanup functionality"
bash ../scripts/clean_root_artifacts.sh

# Test 4: check_root_artifacts.sh should be clean after cleanup
echo "Test 4: Verifying cleanup success"
if bash ../scripts/check_root_artifacts.sh; then
    echo "PASS: Clean after artifact removal"
else
    echo "FAIL: Should be clean after cleanup"
    exit 1
fi

# Cleanup test environment
cd ..
rm -rf test_artifacts_temp

echo "All tests passed successfully"
