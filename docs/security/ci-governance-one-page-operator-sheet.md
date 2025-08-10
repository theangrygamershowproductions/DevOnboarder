# DevOnboarder CI Governance - One-Page Operator Sheet

## 🤖 Autonomous CI Governance Organism - Quick Operator Reference

## 🚨 Go/No-Go Health Check (60 seconds)

```bash
# Branch protection matches file
./scripts/verify-branch-protection.sh

# Required checks match a real PR
PR=$(gh pr list --limit 1 --json number -q '.[0].number'); ./scripts/assert_required_checks.sh "$PR"

# Workflow headers/policy notes present
./scripts/audit-workflow-headers.sh

# Nightly jobs ran (drift detect + sync)
gh run list --workflow "Nightly Drift Detection" --limit 1
gh run list --workflow "Nightly Required Checks Sync" --limit 1
```

## 🔧 Self-Healing Override Commands

```bash
# INSTANT DRIFT FIX - Extract from any green PR and create fix PR
./scripts/sync_required_checks_from_pr.sh <PR_NUMBER>

# EMERGENCY MANUAL SYNC - Use most recent merged PR  
PR=$(gh pr list --search "is:merged" --limit 1 --json number -q '.[0].number')
./scripts/sync_required_checks_from_pr.sh "$PR"

# FORCE APPLY PROTECTION - If config is correct but server is wrong
./scripts/apply-branch-protection.sh
```

## 📊 System Status Dashboard

| Check | Command | Expected |
|-------|---------|----------|
| **Protection Active** | `gh api repos/$OWNER/$REPO/branches/main/protection/required_signatures -q .enabled` | `true` |
| **Drift Detection** | `gh run list --workflow "nightly-drift-checks" --limit 1 --json conclusion -q '.[0].conclusion'` | `success` |
| **Self-Healing** | `gh run list --workflow "nightly-required-checks-sync" --limit 1 --json conclusion -q '.[0].conclusion'` | `success` |
| **Open Drift Issues** | `gh issue list --label drift-detection --json title --jq length` | `0` |

## 🕐 Autonomous Schedule

| Time | System | Action | Human Required |
|------|--------|--------|----------------|
| **02:17 UTC** | Drift Detection | Scans for config mismatches, creates issues | None (monitoring only) |
| **03:23 UTC** | Self-Healing | Generates fix PR from known-good state | Review + merge PR |
| **On PR** | CI Guards | Real-time validation of workflow changes | None (automatic blocking) |
| **On Commit** | Pre-commit | Format/lint validation before commits | Fix issues locally |

## ⚡ Emergency Procedures

### 🚀 Roll-Forward (drift found)

1. **Pick a green PR** and run auto-fix:

```bash
./scripts/sync_required_checks_from_pr.sh <PR_NUMBER>
```

1. **Review the auto-generated PR** → merge it
1. **Re-run Go/No-Go checks** above to verify fix

### 🔄 Roll-Back (in case of lockout)

Temporarily remove failing context from `protection.json`, apply, unblock, fix, then re-add:

```bash
# Edit protection.json to remove failing check
# Then apply the temporary config
gh api -X PUT repos/$OWNER/$REPO/branches/main/protection --input protection.json \
  -H "Accept: application/vnd.github+json"
```

### 🔍 Quick Signature Sanity Check

```bash
gh api repos/$OWNER/$REPO/branches/main/protection/required_signatures -q .enabled
# Expected: true
```

## 🎯 Success Indicators

### 🟢 System Healthy

- ✅ All validation scripts pass
- ✅ No drift-detection issues open  
- ✅ No pending auto-fix PRs
- ✅ Nightly workflows succeeding

### 🟡 Maintenance Needed

- ⚠️ Auto-fix PR pending review (normal)
- ⚠️ Drift detected but fix generated (working as designed)
- ⚠️ Manual workflow trigger needed (rare)

### 🔴 Emergency Action Required

- ❌ Validation scripts failing repeatedly
- ❌ Self-healing not generating fix PRs
- ❌ Protection disabled or bypassed
- ❌ Multiple drift issues accumulating

## 🛠️ Operator Commands

### Information Gathering

```bash
# List recent CI events
gh run list --limit 10 --json displayTitle,conclusion,createdAt

# Check current required checks
jq -r '.required_status_checks.contexts[]' protection.json

# Show protection status
gh api repos/$OWNER/$REPO/branches/main/protection --jq '.required_status_checks.contexts | length'
```

### Manual Controls

```bash
# Force drift check now
gh workflow run nightly-drift-checks.yml

# Force self-healing now
gh workflow run nightly-required-checks-sync.yml

# Sync from specific good PR
./scripts/sync_required_checks_from_pr.sh 1123
```

### Validation & Testing

```bash
# Test all protection scripts
./scripts/verify-branch-protection.sh
./scripts/assert_required_checks.sh <PR_NUMBER>
./scripts/audit-workflow-headers.sh

# Check comprehensive health
./scripts/qc_pre_push.sh
```

## � Telemetry & Maintenance

### 📈 Light Telemetry (optional)

Add status logging to nightly jobs:

```bash
echo "fortress_status=OK date=$(date -u +%F) drift=$DRIFT pr=$PR" >> logs/ci-fortress.log
```

### 🔄 Quarterly Audit Checklist

```bash
# 1. Bump toolchains (Python/Node) → test against live PR
PR=$(gh pr list --limit 1 --json number -q '.[0].number')
./scripts/assert_required_checks.sh "$PR"

# 2. Review CODEOWNERS ownership reflects current reality
cat .github/CODEOWNERS

# 3. Spot-check workflows for token/policy headers
./scripts/audit-workflow-headers.sh

# 4. Confirm org-level security features still enabled
# (Manual: GitHub Settings → Security → Dependabot + Secret Scanning)
```

## �🚀 What Makes This System Autonomous

**🔍 DETECTION**: Multi-layer drift detection across PRs, server config, docs, workflow headers  
**🔧 CORRECTION**: Self-healing sync extracts known-good state and auto-generates fix PRs  
**✅ VERIFICATION**: Nightly validation, post-fix checks, human approval gates maintained  
**📋 DOCUMENTATION**: Every action documented with audit trails and clear remediation steps  

## 📞 Escalation Path

1. **Try quick fixes above** (90% of issues resolve automatically)
2. **Check workflow logs** for specific error details
3. **Review auto-generated issues** for detailed remediation guidance  
4. **Contact platform team** if patterns indicate systemic issues

---

**🤖 STATUS**: Autonomous CI Governance Organism OPERATIONAL  
**🛡️ PROTECTION**: Bulletproof with self-healing capabilities  
**👤 HUMAN ROLE**: Review auto-generated PRs, approve fixes  
**⚡ ZERO-TOUCH**: System maintains itself, humans validate changes
