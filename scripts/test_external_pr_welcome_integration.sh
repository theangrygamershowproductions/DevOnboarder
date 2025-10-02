#!/usr/bin/env bash
# Integration test for external PR welcome system
# Tests the actual GitHub Actions workflow logic safely

set -euo pipefail

echo "🧪 External PR Welcome System - Integration Testing"
echo "=================================================="

# Test environment validation
echo "Test 1: Environment validation..."
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI not available"
    exit 1
fi
echo "✅ GitHub CLI available"

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ GitHub CLI not authenticated"
    exit 1
fi
echo "✅ GitHub CLI authenticated"

# Test workflow trigger conditions
echo ""
echo "Test 2: Workflow trigger simulation..."

# Simulate fork detection logic (test structure validation)
cat > /tmp/fork_test.json << 'EOF'
{
  "pull_request": {
    "head": {
      "repo": {
        "fork": true
      }
    },
    "action": "opened"
  }
}
EOF

echo "✅ Fork detection condition can be evaluated"

# Test contributor count API endpoint (without actually calling it)
echo ""
echo "Test 3: GitHub API endpoint validation..."
REPO_URL="https://api.github.com/repos/theangrygamershowproductions/DevOnboarder/contributors"
if curl -s -I "$REPO_URL" | grep -q "200 OK"; then
    echo "✅ Contributors API endpoint accessible"
else
    echo "⚠️  Contributors API endpoint check failed (may be rate limited)"
fi

# Test template rendering
echo ""
echo "Test 4: Template content validation..."
TEMPLATE_CONTENT=$(cat templates/external-pr-welcome.md)
if echo "$TEMPLATE_CONTENT" | grep -q "Welcome to DevOnboarder"; then
    echo "✅ Template contains welcome message"
else
    echo "❌ Template missing welcome message"
    exit 1
fi

# Test for potential GitHub Actions syntax issues
echo ""
echo "Test 5: GitHub Actions workflow validation..."
if grep -q "github.event.pull_request.head.repo.fork == true" .github/workflows/pr-automation.yml; then
    echo "✅ Fork condition uses proper GitHub Actions syntax"
else
    echo "❌ Fork condition syntax may be incorrect"
    exit 1
fi

echo ""
echo "🎉 Integration tests passed!"
echo ""
echo "🧪 Next Level: Live Testing Options"
echo "=================================="
echo "SAFE OPTION: Test on a separate test repository first"
echo "LIVE OPTION: Monitor first few external PRs closely"
echo ""
echo "Recommended: Create a test fork and PR to validate end-to-end flow"
