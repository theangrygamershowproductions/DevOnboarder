#!/bin/bash

# Quick validation of the final 4% issues
# Optimized for speed and focused problem detection

set -euo pipefail

echo "🎯 Quick Final 4% Check"
echo "======================"
echo "Checking the 4 main CI failure points..."
echo

ISSUES=0

# 1. Frontend coverage quick check
echo "1. Frontend coverage..."
if cd frontend && npm run test --silent > /dev/null 2>&1; then
    echo "   ✅ Frontend tests passing"
else
    echo "   ❌ Frontend tests failing"
    ((ISSUES++))
fi
cd ..

# 2. Bot ES module quick check
echo "2. Bot ES modules..."
if cd bot && npm test --silent --passWithNoTests > /dev/null 2>&1; then
    echo "   ✅ Bot tests passing"
else
    echo "   ❌ Bot tests need attention"
    ((ISSUES++))
fi
cd ..

# 3. Service health quick check
echo "3. Service health..."
if curl -f http://localhost:8002/health --silent --max-time 5 > /dev/null 2>&1; then
    echo "   ✅ Auth service healthy"
else
    echo "   ❌ Service needs startup or configuration"
    ((ISSUES++))
fi

# 4. Environment sync quick check
echo "4. Environment sync..."
if bash scripts/smart_env_sync.sh --validate-only --quiet > /dev/null 2>&1; then
    echo "   ✅ Environment synced"
else
    echo "   ❌ Environment needs sync"
    ((ISSUES++))
fi

echo
echo "=== QUICK CHECK SUMMARY ==="
if [[ $ISSUES -eq 0 ]]; then
    echo "🎉 All 4 areas look good! Ready for full validation."
    echo "Run: bash scripts/validate_final_4_percent.sh"
else
    echo "⚠️  Found $ISSUES issue(s) that need attention."
    echo "Run: bash scripts/validate_final_4_percent.sh for detailed analysis"
fi

echo "Quick check complete!"
exit $ISSUES
