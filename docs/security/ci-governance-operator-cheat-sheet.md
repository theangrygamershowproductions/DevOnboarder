# CI Governance Operator Cheat Sheet

## DevOnboarder Self-Healing CI Fortress - Quick Reference

## 🚨 Emergency 60-Second Health Check

```bash
# 1) Branch protection matches file (contexts + toggles)
./scripts/verify-branch-protection.sh

# 2) Required checks match a live PR (pick the most recent)
PR=$(gh pr list --limit 1 --json number -q '.[0].number')
./scripts/assert_required_checks.sh "$PR"

# 3) Workflow headers are compliant (token + policy notes)
./scripts/audit-workflow-headers.sh

# 4) Nightly drift workflow status (ensure it ran)
gh run list --workflow "Nightly Required Checks Sync" --limit 1
```

## 🔧 Quick Fixes

### Fix Drift Immediately

```bash
# Sync from known-good PR (creates fix PR automatically)
./scripts/sync_required_checks_from_pr.sh <PR_NUMBER>

# Then review and merge the generated PR
```

### Manual Validation Commands

```bash
# Test all protection scripts locally
./scripts/verify-branch-protection.sh
./scripts/assert_required_checks.sh <PR_NUMBER>
./scripts/audit-workflow-headers.sh

# Comprehensive QC check
./scripts/qc_pre_push.sh
```

### Check Security Settings

```bash
# Verify signed commits enforced
gh api repos/$OWNER/$REPO/branches/main/protection/required_signatures -q .enabled
# Expected: true

# Check workflow runs
gh run list --workflow "nightly-drift-checks" --limit 3
gh run list --workflow "nightly-required-checks-sync" --limit 3
```

## 📊 Monitoring Dashboard

### Daily Health Indicators

- ✅ **Drift Detection**: No issues created by nightly check
- ✅ **Self-Healing**: No auto-fix PRs pending review
- ✅ **Protection Status**: All validation scripts pass
- ✅ **Workflow Compliance**: All headers documented

### Weekly Health Review

```bash
# Review recent drift detection results
gh issue list --label=drift-detection --limit 5

# Check self-healing PR history
gh pr list --label=drift-fix,auto-generated --limit 5

# Verify current protection state
./scripts/verify-branch-protection.sh
```

## 🛡️ Security Verification

### Branch Protection Checklist

- [ ] 12 required status checks active
- [ ] Signed commits enforced (`true`)
- [ ] Admin restrictions enabled (`true`)
- [ ] Conversation resolution required (`true`)
- [ ] CODEOWNERS review required

### Workflow Security Checklist

- [ ] All workflows have token documentation
- [ ] No workflows use deprecated `GITHUB_TOKEN` patterns
- [ ] Policy compliance referenced in headers
- [ ] Purpose/maintenance notes documented

## 🔄 Self-Healing System Status

### Automatic Processes

| Time | Process | Purpose |
|------|---------|---------|
| **02:17 UTC** | Drift Detection | Identify configuration mismatches |
| **03:23 UTC** | Self-Healing Sync | Auto-generate fix PRs |

### Manual Override Options

```bash
# Trigger nightly sync manually with specific PR
gh workflow run nightly-required-checks-sync.yml -f source_pr=1123

# Trigger drift detection manually
gh workflow run nightly-drift-checks.yml
```

## 🚨 Incident Response

### When Drift Detection Alerts Fire

1. **Review the auto-created issue** - contains detailed analysis
2. **Check if self-healing triggered** - look for auto-generated PR
3. **Review and merge fix PR** - if auto-generated solution looks correct
4. **Manual fix if needed** - use `./scripts/sync_required_checks_from_pr.sh <PR>`

### When Protection Fails Completely

```bash
# Emergency re-application of protection
jq . protection.json  # Verify JSON is valid
./scripts/apply-branch-protection.sh  # Re-apply all settings

# Verify it worked
./scripts/verify-branch-protection.sh
```

### When Self-Healing Fails

```bash
# Check workflow status
gh run list --workflow "nightly-required-checks-sync" --limit 3

# Manual sync from recent good PR
PR=$(gh pr list --search "is:merged" --limit 1 --json number -q '.[0].number')
./scripts/sync_required_checks_from_pr.sh "$PR"
```

## 📚 Quick Reference Links

- **Complete Framework**: `docs/security/ci-governance-framework-complete-summary.md`
- **Self-Healing Guide**: `docs/security/self-healing-ci-governance-guide.md`
- **Final Hardening**: `docs/security/final-hardening-toggles-guide.md`
- **Source of Truth**: `protection.json` - branch protection configuration
- **Policy Documentation**: `docs/policies/` directory

## 🎯 Success Metrics

### Green Status Indicators

- ✅ All validation scripts pass
- ✅ No pending drift-fix PRs
- ✅ No drift-detection issues open
- ✅ Signed commits enforced
- ✅ All workflows header-compliant

### Escalation Triggers

- ❌ Validation scripts fail repeatedly
- ❌ Self-healing PRs rejected multiple times
- ❌ Manual fixes required frequently
- ❌ Security settings disabled unexpectedly

---

**Last Updated**: 2025-08-10  
**System Status**: Self-healing operational  
**Emergency Contact**: Platform team via GitHub issues  
**Documentation**: Complete framework documentation available
