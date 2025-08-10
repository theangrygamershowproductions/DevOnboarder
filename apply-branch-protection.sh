#!/usr/bin/env bash
set -euo pipefail

# Apply DevOnboarder Branch Protection
# Token Policy Compliant Implementation

OWNER="theangrygamershowproductions"
REPO="DevOnboarder"

echo "Applying comprehensive branch protection to main branch..."

# Apply the protection rules
gh api -X PUT \
  "repos/$OWNER/$REPO/branches/main/protection" \
  -H "Accept: application/vnd.github+json" \
  --input protection.json

echo "Branch protection applied successfully!"

echo ""
echo "Required status checks now enforced:"
echo "  ✅ Must-Have Policy Guards:"
echo "    - Version Policy Audit"
echo "    - Validate Permissions"
echo "    - Pre-commit Validation"
echo ""
echo "  🔒 Quality & Security Checks:"
echo "    - CI/test (3.12, 22)"
echo "    - AAR System Validation"
echo "    - Orchestrator"
echo "    - CodeQL (python & typescript)"
echo ""
echo "  🛡️ Safety Rails:"
echo "    - Root Artifact Monitor"
echo "    - Terminal Output Policy"
echo "    - Enhanced Potato Policy"
echo "    - Documentation Quality"
echo ""
echo "🎯 All PRs must pass these checks before merge!"
