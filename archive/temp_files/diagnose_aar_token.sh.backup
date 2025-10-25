#!/bin/bash
# AAR Token Diagnostic Script
# Helps diagnose token loading and permission issues

set -euo pipefail

echo "🔍 AAR Token Diagnostic Report"
echo "============================="
echo ""

# Change to project root
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Activate virtual environment
echo "1. Virtual Environment Check:"
if [ -f .venv/bin/activate ]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
    echo "   ✅ Virtual environment activated"
else
    echo "   ❌ Virtual environment not found"
    exit 1
fi

echo ""
echo "2. Token File Check:"
if [ -f .tokens ]; then
    echo "   ✅ .tokens file exists"
    if grep -q "AAR_TOKEN=" .tokens; then
        AAR_TOKEN_LENGTH=$(grep 'AAR_TOKEN=' .tokens | cut -d= -f2 | wc -c)
        echo "   ✅ AAR_TOKEN found (length: $((AAR_TOKEN_LENGTH - 1)))"
    else
        echo "   ❌ AAR_TOKEN not found in .tokens file"
        exit 1
    fi
else
    echo "   ❌ .tokens file not found"
    exit 1
fi

echo ""
echo "3. Loading Token Environment:"
if [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
    echo "   ✅ Token environment loaded"
else
    echo "   ❌ Token loader not found"
    exit 1
fi

echo ""
echo "4. Environment Variable Check:"
if [ -n "${AAR_TOKEN:-}" ]; then
    echo "   ✅ AAR_TOKEN loaded in environment"
    echo "   📏 Token length: ${#AAR_TOKEN}"
    echo "   🔢 Token prefix: ${AAR_TOKEN:0:20}..."
else
    echo "   ❌ AAR_TOKEN not found in environment"
    exit 1
fi

echo ""
echo "5. GitHub CLI Availability:"
if command -v gh >/dev/null 2>&1; then
    echo "   ✅ GitHub CLI available"
    echo "   📋 Version: $(gh --version | head -1)"
else
    echo "   ❌ GitHub CLI not available"
    exit 1
fi

echo ""
echo "6. Direct API Permission Tests:"
echo "   Testing with fresh environment..."

# Test actions API
echo -n "   🧪 Actions API: "
if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions >/dev/null 2>&1; then
    echo "✅ SUCCESS"
else
    echo "❌ FAILED"
    echo "      Error details:"
    GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions 2>&1 | head -3 | sed 's/^/      /'
fi

# Test issues API
echo -n "   🧪 Issues API: "
if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/issues?per_page=1 >/dev/null 2>&1; then
    echo "✅ SUCCESS"
else
    echo "❌ FAILED"
    echo "      Error details:"
    GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/issues?per_page=1 2>&1 | head -3 | sed 's/^/      /'
fi

# Test workflow runs
echo -n "   🧪 Workflow Runs API: "
if GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions/runs?per_page=1 >/dev/null 2>&1; then
    echo "✅ SUCCESS"
else
    echo "❌ FAILED"
    echo "      Error details:"
    GH_TOKEN="$AAR_TOKEN" gh api repos/theangrygamershowproductions/DevOnboarder/actions/runs?per_page=1 2>&1 | head -3 | sed 's/^/      /'
fi

echo ""
echo "7. Token Information:"
echo -n "   🔍 Token type check: "
if GH_TOKEN="$AAR_TOKEN" gh api user >/dev/null 2>&1; then
    echo "✅ Valid token"
else
    echo "❌ Invalid token"
fi

echo ""
echo "📊 Diagnosis Complete!"
echo "====================="
echo ""
echo "If permissions show as FAILED above but you just updated them:"
echo "• GitHub API permissions can take 2-5 minutes to propagate"
echo "• Try running this script again in a few minutes"
echo "• Verify token permissions at: https://github.com/settings/personal-access-tokens/fine-grained"
echo ""
echo "Required permissions for AAR system:"
echo "• Actions: Read & Write"
echo "• Issues: Read & Write"
echo "• Contents: Read"
echo "• Metadata: Read"
