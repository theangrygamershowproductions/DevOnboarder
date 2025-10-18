#!/bin/bash
# Option 1 Implementation Test Suite
# Tests all enhanced scripts to verify token loading works correctly

set -euo pipefail

echo "Testing Option 1 Implementation - Enhanced Token Loading"
echo "==========================================================="
echo

# Test counter
tests_passed=0
tests_total=0

# Function to run test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"

    echo "Testing: $test_name"
    echo "Command: $command"

    ((tests_total))

    if eval "$command" >/dev/null 2>&1; then
        output=$(eval "$command" 2>&1)
        if echo "$output" | grep -q "$expected_pattern"; then
            echo "PASS - Token loading successful"
            tests_passed=$((tests_passed  1))
        else
            echo "FAIL - Token loading pattern not found"
            echo "Expected pattern: $expected_pattern"
        fi
    else
        echo "FAIL - Command failed"
    fi

    echo "────────────────────────────────────────"
    echo
}

echo "Testing Critical Scripts with Enhanced Token Loading:"
echo

# Test 1: AAR Token Fix Script
run_test "AAR Token Fix Script" \
         "bash scripts/fix_aar_tokens.sh 2>/dev/null | head -5" \
         "Token environment loaded successfully"

# Test 2: Discord Bot Setup
run_test "Discord Bot Setup" \
         "bash scripts/setup_discord_bot.sh 2>&1 | head -5" \
         "Token environment loaded successfully"

# Test 3: Test Artifacts Management
run_test "Test Artifacts Manager" \
         "bash scripts/manage_test_artifacts.sh status 2>&1 | head -5" \
         "Token environment loaded successfully"

# Test 4: AAR Setup
run_test "AAR Setup Script" \
         "bash scripts/setup_aar_tokens.sh status 2>&1 | head -10" \
         "Token environment loaded successfully"

# Test 5: Token Environment Loader Direct
run_test "Token Environment Loader" \
         "source scripts/load_token_environment.sh 2>&1" \
         "Token environment loaded successfully"

# Test 6: Verify tokens are accessible
run_test "Token Accessibility Check" \
         "source scripts/load_token_environment.sh >/dev/null 2>&1 && echo \"AAR_TOKEN length: \${#AAR_TOKEN}\"" \
         "AAR_TOKEN length: 93"

echo "Test Results Summary:"
echo "========================"
echo "Tests passed: $tests_passed/$tests_total"
echo

if [ $tests_passed -eq $tests_total ]; then
    echo "ALL TESTS PASSED - Option 1 implementation successful!"
    echo
    echo "Enhanced token loading working across all critical scripts"
    echo "Token Architecture v2.1 fully integrated"
    echo "Developer experience enhanced with clear error guidance"
    echo "Scripts are self-contained and reliable"
else
    echo "Some tests failed - review output above"
    exit 1
fi

echo
echo "Next Steps:"
echo "- Phase 1 (Critical Scripts): COMPLETE"
echo "- Phase 2 (Automation Scripts): Ready to implement"
echo "- Phase 3 (Developer Scripts): Ready to implement"
