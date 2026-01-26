---
title: 30-PR Triage Execution Playbook
date: 2025-12-03
project: DevOnboarder
repository: theangrygamershowproductions/DevOnboarder
status: ready-for-execution
---

# 30-PR Triage Execution Playbook

**Context**: After merging PR #1893, systematically resolve all 30 open PRs using strict decision rules - no limbo, no drift.

**Decision Framework**: Every PR gets one of three outcomes:

1. **MERGE** - Required checks green, value clear, merge now
2. **CLOSE** - Obsolete, superseded, or stale beyond recovery
3. **REFRESH** - Value exists but needs rebase/update (rare, v4-deferred if complex)

**No Fourth Option**: No "park it and think about it later." Decide and act.

---

## Execution Phases

### Phase 0: Pre-Flight (Human Only)

**BLOCKER**: This playbook cannot start until PR #1893 is merged.

```bash
# Human merges #1893 (governance boundary)
cd ~/TAGS/ecosystem/DevOnboarder
gh pr merge 1893 --squash --delete-branch

# Agent pulls latest main
git checkout main && git pull

# Agent updates post-merge docs
# - DEVONBOARDER_CI_STATUS_2025-12-01.md (P1 complete)
# - GOVERNANCE_IMPLEMENTATION_STATUS.md (DevOnboarder v3 compliant)
# - ACTIONS_REPLACEMENT_MATRIX.md (4 migrations complete)
```

**Gate**: Phase 1 starts only after above complete.

---

## Phase 1: Close Superseded PRs (5 minutes)

**Target**: #1885, #1888 (definitively superseded by #1893)

**Decision Rule**: If PR attempted to fix actions policy or SHA pinning and #1893 already did it comprehensively, close immediately.

### PR #1885: "FIX(ci): pin all GitHub Actions to full SHAs"

**Status**: Superseded by #1893  
**Age**: 11 days  
**Action**: CLOSE

**Command**:

```bash
gh pr close 1885 --comment "Superseded by #1893 (comprehensive actions policy migration). All workflows now SHA-pinned with banned actions replaced. Changes incorporated into v3 compliance work."
```

### PR #1888: "FEAT(ci): Add actions policy enforcement"

**Status**: Superseded by #1893  
**Age**: 2 days  
**Action**: CLOSE

**Command**:

```bash
gh pr close 1888 --comment "Superseded by #1893 (comprehensive actions policy migration + QC gate refactor). Enforcement workflow already deployed and passing. Changes incorporated into v3 compliance work."
```

**Outcome**: 30 PRs → 28 PRs

---

## Phase 2: Dependabot Strategy (22 PRs, 30 minutes)

**Philosophy**: Dependabot PRs conflict with each other (same lockfile). Merge oldest passing PR per lockfile group, close duplicates.

### Grouping (by lockfile target)

**Bot Group** (7 PRs):

- #1855, #1857, #1867, #1868, #1869, #1881, #1882
- Lockfile: `bot/package-lock.json`

**Frontend Group** (7 PRs):

- #1862, #1863, #1864, #1865, #1866, #1880, #1883
- Lockfile: `frontend/package-lock.json`

**CI Toolkit Group** (2 PRs):

- #1874, #1884
- Lockfile: `.github/actions/ci-toolkit/package-lock.json`

**Python Group** (6 PRs):

- #1871, #1875, #1876, #1878, #1879
- Lockfile: `pyproject.toml` / `requirements*.txt`

### Per-Group Procedure

**For each group:**

1. **Pick oldest PR** (lowest number)
2. **Check required status**:

   ```bash
   gh pr view {PR} --json statusCheckRollup \
     --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {name, conclusion}'
   ```

3. **Decision**:
   - If `conclusion: "SUCCESS"` → **MERGE** oldest PR
   - If `conclusion: "FAILURE"` → Check if real regression or pre-existing debt
     - Real regression (breaks imports/tests) → **CLOSE** (dependency incompatible)
     - Pre-existing debt → **MERGE** oldest PR anyway (debt not introduced by dependency bump)
4. **After first merge** → **CLOSE** all other PRs in group as superseded

### Example: Bot Group

**Oldest PR**: #1855 (Bump @typescript-eslint/eslint-plugin, 37 days old)

**Check**:

```bash
gh pr view 1855 --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {name, conclusion}'
```

**If green**:

```bash
# Merge oldest
gh pr merge 1855 --squash --delete-branch

# Close remaining 6 in group
for PR in 1857 1867 1868 1869 1881 1882; do
  gh pr close $PR --comment "Superseded by #1855 merge. Lockfile (bot/package-lock.json) already updated with latest compatible versions."
done
```

**If red** (check why):

```bash
# Get failure details
gh run view --log | grep -A5 "qc-gate-minimum"

# If breaks imports → close as incompatible
gh pr close 1855 --comment "Dependency bump breaks imports/tests. Blocked until underlying compatibility issues resolved. See CI logs for details."

# Try next oldest (#1857) with same procedure
```

**Repeat for all 4 groups** (bot, frontend, ci-toolkit, python)

**Expected Outcome**: 22 PRs → 4 merged (one per group) + 18 closed = 4 remaining PRs

---

## Phase 3: Infra/CI PRs (4 PRs, 15 minutes)

**Candidates**: #1815, #1816, #1872, plus any from Phase 2 analysis

### PR #1815: "CLEANUP: DevOnboarder workspace organization"

**Type**: Infra cleanup  
**Age**: 52 days  
**Labels**: documentation, enhancement, maintenance

**Check**:

1. Conflicts with #1893 changes?

   ```bash
   gh pr view 1815 --json mergeable,mergeStateStatus
   ```

2. Required checks status?

   ```bash
   gh pr view 1815 --json statusCheckRollup \
     --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {name, conclusion}'
   ```

**Decision Tree**:

- Conflicts with main → **CLOSE** (stale, refactor needed)
- No conflicts + required checks green → **MERGE**
- No conflicts + required checks red (pre-existing debt) → **MERGE** (v3 gate is permissive)
- Introduces new quality issues → **CLOSE** (must fix first)

### PR #1816: "CLEANUP: main branch garbage removal"

**Type**: Infra cleanup  
**Age**: 52 days  
**Labels**: enhancement

**Check**: Same procedure as #1815

**Likely Outcome**: Both are 52 days old, high risk of conflicts. Unless they're trivial and green, lean toward **CLOSE** with note "v4: revisit after workspace cleanup."

### PR #1872: "chore(codeowners): add final catch-all"

**Type**: Governance  
**Age**: 29 days  

**Special Check**: Does this conflict with current CODEOWNERS state?

```bash
gh pr view 1872 --json files --jq '.files[].path'
# If only touches .github/CODEOWNERS, check diff
gh pr diff 1872 -- .github/CODEOWNERS
```

**Decision**:

- If adds catch-all that's still needed → **MERGE** (if required checks green)
- If catch-all already exists → **CLOSE** (superseded)
- If catch-all conflicts with current org structure → **CLOSE** (needs redesign)

**Expected Outcome**: 2-4 PRs → likely 1-2 merged, 1-2 closed

---

## Phase 4: Feature/Code PRs (2 PRs, 20 minutes)

**High-Risk Category**: Long-lived feature PRs are usually stale.

### PR #1694: "Feat/frontend/dark mode toggle"

**Type**: Feature  
**Age**: 63 days  
**Author**: RabbitAlbatross (external contributor)

**Analysis Required**:

1. **Still relevant?** Check if dark mode already implemented elsewhere
2. **Architecture drift?** 63 days of frontend changes likely conflict
3. **Required checks?** Probably red due to age

**Check**:

```bash
# Check mergeable
gh pr view 1694 --json mergeable,mergeStateStatus,files

# Check required status
gh pr view 1694 --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {name, conclusion}'

# Review changed files
gh pr view 1694 --json files --jq '.files[].path'
```

**Decision Framework**:

- Conflicts + required checks red → **CLOSE** with note "Stale after 63 days. If dark mode still desired, open fresh PR against current main with updated implementation."
- No conflicts + required checks green + still relevant → **MERGE** (rare case)
- No conflicts + required checks green + feature obsolete → **CLOSE** (not needed)

**Likely Outcome**: **CLOSE** (external contributor, 63 days old, high conflict risk)

### PR #1813: "FEAT(monitoring): token expiry monitoring"

**Type**: Feature  
**Age**: 52 days  
**Author**: reesey275 (internal)

**Analysis**:

1. Is token expiry monitoring already implemented?
2. Does this fit current architecture?
3. Required checks status?

**Check**: Same procedure as #1694

**Decision**:

- If monitoring already exists → **CLOSE** (superseded)
- If still valuable + green + no conflicts → **MERGE**
- If conflicts or red → **CLOSE** with note "v4: Revisit monitoring enhancement after Core-4 stable"

**Likely Outcome**: **CLOSE** or **REFRESH** (defer to v4 if complex)

**Expected Outcome**: 2 PRs → likely 0 merged, 2 closed

---

## Phase 5: Docs-Only PRs (1 PR, 5 minutes)

### PR #1810: "DOCS(aar): update AAR portal"

**Type**: Docs  
**Age**: 57 days  
**Author**: reesey275 (automated AAR update)

**Analysis**:

- AAR portal updates are usually automated and cumulative
- 57 days old likely means superseded by newer AAR runs

**Check**:

```bash
# Check if conflicts with current AAR state
gh pr view 1810 --json files --jq '.files[].path'
gh pr view 1810 --json mergeable,mergeStateStatus

# Check required status (docs usually pass)
gh pr view 1810 --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {name, conclusion}'
```

**Decision**:

- Required checks green + no conflicts → **MERGE** (low risk)
- Conflicts or outdated content → **CLOSE** (next AAR run will regenerate)

**Expected Outcome**: 1 PR → likely 1 closed (superseded by time)

---

## Final Accounting

**Starting**: 30 open PRs  
**Phase 1** (Superseded): -2 (#1885, #1888)  
**Phase 2** (Dependabot): -18 closed, +4 merged = -14 net  
**Phase 3** (Infra): -2 to -4 (likely 2 closed, 0-1 merged)  
**Phase 4** (Feature): -2 (likely both closed)  
**Phase 5** (Docs): -1 (likely closed)

**Ending**: ~4-6 merged, ~24-26 closed, **0 in limbo**

---

## Success Criteria

This triage is **COMPLETE** when:

- ✅ All 30 PRs have one of three states: MERGED, CLOSED, or explicitly documented as v4-deferred
- ✅ No PR remains in "we should think about this" state
- ✅ Triage report updated with actual outcomes
- ✅ DevOnboarder PR backlog is clean (only actively developed PRs remain)

---

## Execution Command Block

**For agent execution** (after human merges #1893):

```bash
#!/bin/bash
# DevOnboarder 30-PR Triage - Systematic Execution
# Run from: ~/TAGS/ecosystem/DevOnboarder

set -euo pipefail

# Phase 1: Close superseded
echo "=== Phase 1: Superseded PRs ==="
gh pr close 1885 --comment "Superseded by #1893 (comprehensive actions policy migration)."
gh pr close 1888 --comment "Superseded by #1893 (actions policy + QC gate refactor)."

# Phase 2: Dependabot (Bot Group Example)
echo "=== Phase 2: Dependabot - Bot Group ==="
# Check oldest PR status
BOT_STATUS=$(gh pr view 1855 --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | .conclusion')

if [[ "$BOT_STATUS" == "SUCCESS" ]]; then
  echo "Merging #1855 (bot deps - oldest passing)"
  gh pr merge 1855 --squash --delete-branch
  
  echo "Closing remaining bot deps PRs"
  for PR in 1857 1867 1868 1869 1881 1882; do
    gh pr close $PR --comment "Superseded by #1855 merge (bot/package-lock.json updated)."
  done
else
  echo "⚠️ #1855 required check not green - manual intervention needed"
fi

# Repeat for frontend, ci-toolkit, python groups
# (similar pattern, check oldest, merge if green, close rest)

# Phase 3: Infra PRs - Manual review recommended
echo "=== Phase 3: Infra PRs - Review Required ==="
for PR in 1815 1816 1872; do
  echo "PR #$PR:"
  gh pr view $PR --json mergeable,statusCheckRollup \
    --jq '{mergeable, qc_gate: [.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {conclusion}]}'
done

# Phase 4: Feature PRs - High probability of closure
echo "=== Phase 4: Feature PRs ==="
for PR in 1694 1813; do
  echo "PR #$PR (age >50 days, likely stale):"
  gh pr view $PR --json mergeable,statusCheckRollup \
    --jq '{mergeable, qc_gate: [.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {conclusion}]}'
done

# Phase 5: Docs PR
echo "=== Phase 5: Docs PR ==="
gh pr view 1810 --json mergeable,statusCheckRollup \
  --jq '{mergeable, qc_gate: [.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {conclusion}]}'

echo ""
echo "=== Triage Complete - Update PR_TRIAGE_DEVONBOARDER_2025-12-03.md with outcomes ==="
```

---

## Detailed Execution Commands

**Usage**: Run these command blocks in order. Each phase is self-contained with explicit decision points.

**Setup** (run once per shell):

```bash
export REPO="theangrygamershowproductions/DevOnboarder"
cd ~/TAGS/ecosystem/DevOnboarder
```

### Phase 0: Snapshot Current State (Read-Only)

Archive all open PRs before making changes:

```bash
# Create snapshot directory if needed
mkdir -p .github/pr_snapshots

# Snapshot all open PRs (for later archaeology)
gh pr list --repo "$REPO" --state open \
  --limit 100 \
  --json number,title,headRefName,author,createdAt,isDraft,labels,statusCheckRollup \
  > .github/pr_snapshots/PR_SNAPSHOT_$(date +%Y-%m-%d).json

# Optional: View as table
jq -r '
  .[] |
  [.number, .title, .author.login, .createdAt, (.statusCheckRollup | length)] |
  @tsv
' .github/pr_snapshots/PR_SNAPSHOT_$(date +%Y-%m-%d).json \
  | column -t
```

### Phase 1: Close Superseded PRs (5 min)

PRs #1885 and #1888 are superseded by #1893:

```bash
for PR in 1885 1888; do
  gh pr close "$PR" --repo "$REPO" \
    --comment "Closed as **superseded** by rollup PR #1893 (DevOnboarder actions policy migration). All relevant changes are included there. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md for context."
done
```

### Phase 2: Dependabot Herding (30 min)

**Strategy**: For each lockfile group, merge oldest passing PR, close rest as superseded.

#### 2.1: List All Dependabot PRs (Sanity Check)

```bash
gh pr list --repo "$REPO" \
  --author "app/dependabot" \
  --state open \
  --limit 100 \
  --json number,title,headRefName,createdAt \
  | jq -r '.[] | [.number, .createdAt, .headRefName, .title] | @tsv' \
  | sort -k2 \
  | column -t
```

#### 2.2: Template Per Lockfile Group

**Instructions**:

1. Identify PRIMARY (oldest/cleanest) and DUPS (newer overlapping) from Phase 2 analysis in this doc
2. Fill in PR numbers in template below
3. Run block per group

```bash
# === TEMPLATE: Adjust numbers per group ===
PRIMARY=XXXX          # oldest/cleanest Dependabot PR for this lockfile
DUPS="YYYY ZZZZ"      # newer overlapping PRs for same file(s)

# Step 1: Check primary's status
gh pr checks "$PRIMARY" --repo "$REPO"

# Step 2: HUMAN decision - if checks acceptable:
gh pr merge "$PRIMARY" --repo "$REPO" --squash --delete-branch

# Step 3: Close duplicates
for PR in $DUPS; do
  gh pr close "$PR" --repo "$REPO" \
    --comment "Closed as superseded by Dependabot PR #$PRIMARY for the same dependency/lockfile. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md for batch details."
done
```

**Groups to Process** (from Phase 2 analysis above):

- Bot lockfile group (7 PRs)
- Frontend lockfile group (7 PRs)
- CI toolkit group (2 PRs)
- Python/backend group (6 PRs)

### Phase 3: Infra/CI PRs (15 min)

**Template per PR** (3 remaining infra PRs: #1815, #1816, #1872):

```bash
PR=XXXX   # fill from list above

# 1) Show summary + CI status
gh pr view "$PR" --repo "$REPO" \
  --json number,title,author,createdAt,headRefName,statusCheckRollup \
  | jq '{number,title,author,createdAt,headRefName,statusCheckRollup}'

# 2) Check required checks (branch protection = source of truth)
gh api repos/"$REPO"/branches/main/protection \
  --jq '.required_status_checks.contexts[]'

# 3) Cross-reference PR checks vs required
gh pr view "$PR" --repo "$REPO" \
  --json statusCheckRollup \
  --jq '.statusCheckRollup[] | {name,conclusion}'

# 4) HUMAN DECISION:
# - If obsolete/superseded → close with comment
# - If stale but relevant → label for REFRESH
# - If clean and relevant → approve + merge
```

**Close obsolete infra PR**:

```bash
gh pr close "$PR" --repo "$REPO" \
  --comment "Closed during DevOnboarder PR triage as **superseded/obsolete**. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md for reasoning. If this work is still needed, please open a fresh PR based on current main."
```

### Phase 4: Feature/Code PRs (20 min)

PRs #1694 and #1813 require explicit design review:

```bash
for PR in 1694 1813; do
  echo "=== PR #$PR ==="
  gh pr view "$PR" --repo "$REPO" \
    --json number,title,author,createdAt,headRefName,body \
    | jq '{number,title,author,createdAt,headRefName,body}'
  
  gh pr view "$PR" --repo "$REPO" \
    --json statusCheckRollup \
    --jq '.statusCheckRollup[] | {name,conclusion}'
done
```

**HARD CALL per PR** (no auto-merge):

**Option A: Close as out-of-scope**:

```bash
PR=1694  # or 1813

gh pr close "$PR" --repo "$REPO" \
  --comment "Closed during DevOnboarder triage as **out of alignment with current architecture/v3 scope**. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md for analysis. If these ideas are still needed, they should be re-proposed against the latest design as a fresh PR."
```

**Option B: Salvage** (requires explicit re-spec in docs first, then heavy refactor or fresh PR)

### Phase 5: Docs-Only PR (5 min)

**PR #1810** (docs-only):

```bash
PR=1810

gh pr view "$PR" --repo "$REPO" \
  --json title,body,author,createdAt

# Option A: Merge if still matches reality
gh pr checks "$PR" --repo "$REPO"
# If nothing obviously wrong:
gh pr merge "$PR" --repo "$REPO" --squash --delete-branch

# Option B: Close if obsolete
gh pr close "$PR" --repo "$REPO" \
  --comment "Closed during DevOnboarder PR triage as **docs no longer matching current system**. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md for context."
```

### Phase 6: Final Verification

Confirm PR count after triage:

```bash
gh pr list --repo "$REPO" --state open --limit 100 \
  --json number,title,author,createdAt \
  | jq -r '.[] | [.number, .title, .author.login, .createdAt] | @tsv' \
  | column -t
```

**Expected outcome**: 0-3 PRs remaining, all with explicit intent documented.

**Append results to triage doc**:

- How many merged
- How many closed  
- Which (if any) remain and why

---

## Quick Reference: Single Executable Script

If you prefer a single script with fill-in-the-blanks:

```bash
#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
export REPO="theangrygamershowproductions/DevOnboarder"
cd ~/TAGS/ecosystem/DevOnboarder

# === Phase-specific PR lists (FILL THESE FROM TRIAGE DOC) ===
SUPERSEDED_PRS="1885 1888"

# Dependabot groups (PRIMARY=oldest, DUPS=newer)
BOT_PRIMARY="XXXX"
BOT_DUPS="YYYY ZZZZ"

FRONTEND_PRIMARY="XXXX"
FRONTEND_DUPS="YYYY ZZZZ"

PYTHON_PRIMARY="XXXX"
PYTHON_DUPS="YYYY ZZZZ"

INFRA_PRS="1815 1816 1872"
FEATURE_PRS="1694 1813"
DOCS_PR="1810"

# === Phase 0: Snapshot ===
echo "=== Phase 0: Creating PR snapshot ==="
mkdir -p .github/pr_snapshots
gh pr list --repo "$REPO" --state open --limit 100 \
  --json number,title,headRefName,author,createdAt,isDraft,labels,statusCheckRollup \
  > ".github/pr_snapshots/PR_SNAPSHOT_$(date +%Y-%m-%d).json"

# === Phase 1: Close superseded ===
echo "=== Phase 1: Closing superseded PRs ==="
for PR in $SUPERSEDED_PRS; do
  gh pr close "$PR" --repo "$REPO" \
    --comment "Closed as superseded by #1893. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md"
done

# === Phase 2: Dependabot (per group) ===
echo "=== Phase 2: Processing Dependabot PRs ==="

# Bot group
echo "Bot lockfile group..."
gh pr checks "$BOT_PRIMARY" --repo "$REPO"
echo "HUMAN ACTION REQUIRED: Review checks above, then run:"
echo "  gh pr merge $BOT_PRIMARY --repo $REPO --squash --delete-branch"
read -p "Press Enter after merging $BOT_PRIMARY..."

for PR in $BOT_DUPS; do
  gh pr close "$PR" --repo "$REPO" \
    --comment "Superseded by Dependabot PR #$BOT_PRIMARY"
done

# Repeat pattern for FRONTEND_, PYTHON_ groups
echo "MANUAL: Repeat for frontend and python groups using template above"

# === Phases 3-6: Use templates ===
echo "=== Phases 3-6: See PR_TRIAGE_EXECUTION_PLAYBOOK.md for per-PR templates ==="
echo "Remaining PRs to triage manually:"
gh pr list --repo "$REPO" --state open --limit 100 \
  --json number,title \
  --jq '.[] | "\(.number): \(.title)"'
```

---

**Playbook Status**: Ready for execution (independent of #1893 merge)  
**Estimated Time**: 60-90 minutes total  
**Expected Outcome**: Clean PR backlog, no limbo state, v3 infrastructure stable
