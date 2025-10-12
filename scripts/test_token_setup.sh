#!/bin/bash
# Test script to validate token setup and monitoring system

echo "🧪 TAGS Ecosystem Token Setup Validation"
echo "========================================"

# Test 1: Token loading
echo ""
echo "1️⃣ Testing Token Loading..."
if python3 scripts/token_loader.py load > /dev/null 2>&1; then
    echo "✅ Token loading: SUCCESS"
else
    echo "❌ Token loading: FAILED"
    exit 1
fi

# Test 2: Token monitoring
echo ""
echo "2️⃣ Testing Token Monitoring..."
if ./scripts/token_expiry_monitor.sh monitor-all > /dev/null 2>&1; then
    echo "✅ Token monitoring: SUCCESS"
else
    echo "❌ Token monitoring: FAILED"
    exit 1
fi

# Test 3: Check for real tokens (not placeholders)
echo ""
echo "3️⃣ Checking for Real Tokens..."
placeholder_count=$(grep -c "CHANGE_ME_" .tokens || echo "0")
if [[ $placeholder_count -eq 0 ]]; then
    echo "✅ All tokens configured: SUCCESS"
else
    echo "⚠️  $placeholder_count placeholder tokens remaining"
fi

# Test 4: Integration test
echo ""
echo "4️⃣ Testing Integration..."
if python3 scripts/token_expiry_integrator.py monitor > /dev/null 2>&1; then
    echo "✅ Token integration: SUCCESS"
else
    echo "❌ Token integration: FAILED"
    exit 1
fi

echo ""
echo "🎉 Token Setup Validation Complete!"
echo "==================================="
echo ""
echo "If all tests passed, your TAGS ecosystem token monitoring is ready!"
echo "Run: ./scripts/token_expiry_monitor.sh monitor-all  # To see current status"
