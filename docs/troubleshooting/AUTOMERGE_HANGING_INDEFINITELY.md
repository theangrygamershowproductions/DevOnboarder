---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
---

# Automerge Hanging Indefinitely - Critical Infrastructure Troubleshooting

**Symptom Category:** CI/CD Infrastructure

**Severity:** CRITICAL - Blocks all PR merges repository-wide

**First Documented:** 2025-09-02 (PR #1212)

**Resolution Time:** ~2 hours

## 🚨 Problem Symptoms

### Primary Indicators

- ✅ All required status checks show as "SUCCESS" and "COMPLETED"

- ✅ Automerge is enabled on pull request

- ❌ PR shows "BLOCKED" merge state indefinitely

- ❌ GitHub shows "7 Required checks that are still waiting for status to be reported"

- ❌ Status checks appear as "Expected — Waiting for status to be reported" despite completing

### Secondary Indicators

- Pull requests hang in "BLOCKED" state for hours/days

- Manual merge attempts may also be blocked

- Issue affects multiple PRs simultaneously

- CI workflows complete successfully but merge eligibility not recognized

## 🔍 Root Cause Analysis

### Critical Infrastructure Misconfigurations

This issue stems from **two interconnected repository configuration problems**:

#### 1. Default Branch Misconfiguration

**Problem:** Repository default branch set incorrectly

```bash

# Symptom: Default branch points to wrong branch

gh api repos/OWNER/REPO --jq '.default_branch'

# Returns: "ci-recovery" (or other incorrect branch)

# Expected: "main"

```

**Impact:** GitHub's merge system becomes confused when PR targets `main` but repository default is different.

#### 2. Branch Protection Rule Mismatch

**Problem:** Required status check names don't match actual check run names

```bash

# Branch protection requires (INCORRECT)

"CodeQL/Analyze (javascript-typescript) (dynamic)"
"Documentation Quality/validate-docs (pull_request)"
"Enhanced Potato Policy Enforcement/enhanced-potato-policy (pull_request)"

# Actual check runs provide (CORRECT)

"CodeQL"
"validate-docs"
"enhanced-potato-policy"

```

**Impact:** GitHub waits for status checks that will never report because the names don't match.

## 🛠️ Step-by-Step Resolution

### Phase 1: Diagnostic Commands

**1. Verify repository default branch:**

```bash

cd /path/to/repo
gh api repos/OWNER/REPO --jq '.default_branch'

```

**2. Check PR target vs repository default:**

```bash

gh pr view ISSUE_NUMBER --json baseRefName,headRefName

```

**3. Compare required vs actual status check names:**

```bash

# Required checks

gh api repos/OWNER/REPO/branches/BRANCH/protection --jq '.required_status_checks.contexts[]' | sort

# Actual check runs

gh pr view ISSUE_NUMBER --json statusCheckRollup --jq '.statusCheckRollup[].name' | sort

```

**4. Verify commit status state:**

```bash

gh api repos/OWNER/REPO/commits/$(git rev-parse HEAD)/status --jq '.state'

# If "pending" despite completed checks → Configuration mismatch confirmed

```

### Phase 2: Fix Repository Default Branch

```bash

# Update repository default branch to correct branch (usually "main")

gh api repos/OWNER/REPO -X PATCH --field default_branch=main

```

**Verification:**

```bash

gh api repos/OWNER/REPO --jq '.default_branch'

# Should return: "main"

```

### Phase 3: Fix Branch Protection Rules

**1. Get actual check run names:**

```bash

gh api repos/OWNER/REPO/commits/$(git rev-parse HEAD)/check-runs \
  --jq '.check_runs[] | select(.conclusion == "success") | .name' | sort | uniq

```

**2. Update branch protection with correct names:**

```bash

echo '{
  "contexts": [
    "CodeQL",
    "enhanced-potato-policy",
    "Root Artifact Guard",
    "Enforce Terminal Output Policy",
    "validate-docs",
    "check"
  ],
  "strict": true
}' | gh api repos/OWNER/REPO/branches/main/protection/required_status_checks -X PATCH --input -

```

### Phase 4: Refresh Automerge

```bash

# Re-enable automerge to trigger status recalculation

gh pr merge ISSUE_NUMBER --auto --merge

```

### Phase 5: Verification

**1. Check merge state (may show UNKNOWN briefly while recalculating):**

```bash

gh pr view ISSUE_NUMBER --json mergeStateStatus,mergeable

```

**2. Wait for recalculation (typically 2-5 minutes):**

```bash

# Should eventually show

# {"mergeStateStatus": "CLEAN", "mergeable": "MERGEABLE"}

```

## 🔧 Prevention Strategies

### Repository Setup Checklist

**When setting up new repositories:**

1. **✅ Set correct default branch immediately:**

   ```bash

   gh api repos/OWNER/REPO -X PATCH --field default_branch=main
   ```

2. **✅ Configure branch protection with actual check names:**

   - Use check run names, not workflow/job combinations

   - Test with a sample PR before enforcing

3. **✅ Validate configuration:**

   ```bash

   # Default branch check

   gh api repos/OWNER/REPO --jq '.default_branch'

   # Protection rules check

   gh api repos/OWNER/REPO/branches/main/protection --jq '.required_status_checks.contexts[]'
   ```

### Monitoring & Detection

**Create monitoring script (`scripts/check_automerge_health.sh`):**

```bash

#!/bin/bash

# Check for automerge hanging issues

# Check default branch alignment

DEFAULT_BRANCH=$(gh api repos/$GITHUB_REPOSITORY --jq -r '.default_branch')
if [ "$DEFAULT_BRANCH" != "main" ]; then
    echo "⚠️  WARNING: Default branch is $DEFAULT_BRANCH, not main"
fi

# Check for pending status with completed checks

PENDING_COUNT=$(gh pr list --state open --json number | jq -r '.[] | .number' | while read pr; do
    STATE=$(gh api repos/$GITHUB_REPOSITORY/commits/$(gh pr view $pr --json headRefOid --jq -r '.headRefOid')/status --jq -r '.state')
    COMPLETED_CHECKS=$(gh pr view $pr --json statusCheckRollup --jq '[.statusCheckRollup[] | select(.conclusion == "SUCCESS")] | length')
    if [ "$STATE" = "pending" ] && [ "$COMPLETED_CHECKS" -gt "0" ]; then
        echo "PR #$pr: Status pending with $COMPLETED_CHECKS completed checks"
    fi
done)

if [ -n "$PENDING_COUNT" ]; then
    echo "🚨 ALERT: Potential automerge hanging detected"
fi

```

## 📋 Quick Reference Commands

### Diagnostic One-Liners

```bash

# Repository health check

gh api repos/$(gh repo view --json owner,name --jq -r '"\(.owner.login)/\(.name)"') --jq '{default_branch, allow_auto_merge}'

# PR merge eligibility check

gh pr view --json mergeStateStatus,mergeable,autoMergeRequest,statusCheckRollup

# Status check alignment verification

diff <(gh api repos/OWNER/REPO/branches/main/protection --jq '.required_status_checks.contexts[]' | sort) <(gh pr view ISSUE_NUMBER --json statusCheckRollup --jq '.statusCheckRollup[] | select(.conclusion == "success") | .name' | sort)

```

### Emergency Fix Commands

```bash

# Emergency repository fix (replace OWNER/REPO and ISSUE_NUMBER)

gh api repos/OWNER/REPO -X PATCH --field default_branch=main && \
echo '{"contexts":["CodeQL","enhanced-potato-policy","Root Artifact Guard","Enforce Terminal Output Policy","validate-docs","check"],"strict":true}' | gh api repos/OWNER/REPO/branches/main/protection/required_status_checks -X PATCH --input - && \

gh pr merge ISSUE_NUMBER --auto --merge

```

## 🎯 Case Study: PR #1212 Resolution

**Timeline:** 2025-09-02, ~21:30-21:45 UTC

**Duration:** ~15 minutes active troubleshooting

**Impact:** Repository-wide automerge restoration

**Initial State:**

- Default branch: `ci-recovery` ❌

- Required checks: `CodeQL/Analyze (python) (dynamic)` ❌

- PR state: `BLOCKED` indefinitely ❌

**Resolution Applied:**

- Default branch: `main` ✅

- Required checks: `CodeQL` ✅

- PR state: `UNKNOWN` → recalculating ✅

**Outcome:**

- Automerge functional across repository

- Pattern of "hanging indefinitely" resolved

- Infrastructure aligned and stable

## 🚀 Related Documentation

- [Branch Protection Configuration](../infrastructure/BRANCH_PROTECTION.md)

- [CI Status Check Troubleshooting](./CI_STATUS_CHECK_MISMATCHES.md)

- [Repository Configuration Best Practices](../standards/REPOSITORY_SETUP.md)

---

**Last Updated:** 2025-09-02

**Next Review:** 2025-12-02

**Maintainer:** Infrastructure Team

**Validation:** Tested on PR #1212 resolution
