#!/usr/bin/env bash
# Enable Branch Protection for DevOnboarder
# 
# Enforces DevOnboarder QC as a required CI check before merge
# Part of Q1 failure rate reduction initiative (Checkbox 2)

set -e

REPO="theangrygamershowproductions/DevOnboarder"
BRANCH="main"

echo "🔒 Enabling Branch Protection for $REPO"
echo "   Branch: $BRANCH"
echo "   Required Check: qc-check (DevOnboarder QC)"
echo ""

# Apply branch protection via GitHub API
# Requires: qc-check job from devonboarder-qc.yml workflow
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO/branches/$BRANCH/protection" \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["qc-check"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": false
}
EOF

echo ""
echo "✅ Branch protection enabled"
echo ""

# Verify configuration
echo "🔍 Verifying branch protection settings:"
gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO/branches/$BRANCH/protection" \
  --jq '{
    "Required Checks": .required_status_checks.contexts,
    "Strict": .required_status_checks.strict,
    "Enforce Admins": .enforce_admins,
    "Required Reviews": .required_pull_request_reviews.required_approving_review_count,
    "Require Conversation Resolution": .required_conversation_resolution
  }'

echo ""
echo "✅ GATE INSTALLED: DevOnboarder QC is now enforced on all PRs"
echo ""
echo "Log this achievement in ~/TAGS/Q1_FAILURE_RATE_REDUCTION.md:"
echo "  ✅ Checkbox 2: DevOnboarder QC workflow created and enforced"
echo "  - Job: qc-check (95%+ coverage, all tests pass)"
echo "  - Branch protection: Enabled on DevOnboarder main"
echo "  - No bypass allowed (enforce_admins: true)"
