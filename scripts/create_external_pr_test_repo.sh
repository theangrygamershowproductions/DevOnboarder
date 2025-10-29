#!/usr/bin/env bash
# Create a test repository to validate external PR welcome system
# POTATO APPROVAL: create-test-repo-20251002

set -euo pipefail

echo "🧪 Creating Test Repository for External PR Welcome System"
echo "=========================================================="

# Create minimal test repository
TEST_REPO_NAME="devonboarder-external-pr-test"

echo "Creating test repository: $TEST_REPO_NAME"

# Create test repo with minimal PR automation workflow
gh repo create "$TEST_REPO_NAME" \
    --description "Test repository for DevOnboarder external PR welcome system validation" \
    --public \
    --clone

cd "$TEST_REPO_NAME" || exit 1

# Copy essential files for testing
mkdir -p .github/workflows templates

# Create minimal PR automation workflow (just the welcome part)
cat > .github/workflows/test-pr-welcome.yml << 'EOF'
name: Test External PR Welcome

on:
  pull_request:
    types: [opened]

jobs:
  welcome-external-contributors:
    if: github.event.pull_request.head.repo.fork == true
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Welcome external contributors
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          echo "External fork PR detected - testing welcome system"

          # Simple test message instead of full logic
          gh pr comment ${{ github.event.number }} --body "🎉 **Test Welcome Message**

Thank you for your external contribution to DevOnboarder test repository!

This is a test of our external PR welcome system.

**Test Status:**  System Working
**Fork Detection:**  Confirmed
**Automation:**  Active

The actual system includes comprehensive security guidance and onboarding resources."
EOF

# Copy the welcome template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_SRC="$SCRIPT_DIR/../templates/external-pr-welcome.md"
if [[ ! -f "$TEMPLATE_SRC" ]]; then
  echo " Template file not found: $TEMPLATE_SRC"
  exit 1
fi
cp "$TEMPLATE_SRC" "templates/"

# Create basic README
cat > README.md << 'EOF'
# DevOnboarder External PR Test Repository

This is a test repository for validating DevOnboarder's external PR welcome system.

## Testing Process

1. Fork this repository
2. Create a branch with changes
3. Open a pull request
4. Verify the welcome automation triggers

## Expected Behavior

- First-time external contributors should receive a welcome message
- The message should appear automatically on PR open
- Subsequent PRs from the same contributor should not trigger welcomes
EOF

# Initial commit
git add .
git commit -m "INIT: Test repository for external PR welcome system validation"
git push -u origin main

echo ""
echo " Test repository created: https://github.com/$(gh api user --jq .login)/$TEST_REPO_NAME"
echo ""
echo "🧪 Testing Steps:"
echo "1. Fork the test repository from a different account"
echo "2. Make a small change and open a PR"
echo "3. Verify the welcome message appears"
echo "4. Test with subsequent PRs to ensure no duplicate messages"
echo ""
echo "TARGET: Once validated, delete the test repository and deploy to production"
