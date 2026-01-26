# DevOnboarder PR Triage - Quick Command Reference

**Status**: Ready for execution (independent of #1893)  
**Time**: 60-90 minutes systematic work  
**Source**: PR_TRIAGE_EXECUTION_PLAYBOOK.md (657 lines, complete)

---

## Pre-Flight Setup

```bash
export REPO="theangrygamershowproductions/DevOnboarder"
cd ~/TAGS/ecosystem/DevOnboarder
```

---

## Phase Summary

| Phase | Target | Time | Complexity | Outcome |
|-------|--------|------|------------|---------|
| 0 | Snapshot all PRs | 2 min | Low | Archive baseline |
| 1 | Superseded (2 PRs) | 5 min | Low | Close #1885, #1888 |
| 2 | Dependabot (22 PRs) | 30 min | Medium | Merge 4-6, close rest |
| 3 | Infra (3 PRs) | 15 min | Medium | Triage per PR |
| 4 | Feature (2 PRs) | 20 min | High | Explicit decision |
| 5 | Docs (1 PR) | 5 min | Low | Merge or close |
| 6 | Verification | 3 min | Low | Confirm 0-3 remain |

**Total**: ~75 minutes  
**Expected Result**: 4-6 merged, 24-26 closed, 0 in limbo

---

## Quick Command Lookup

### Check Branch Protection (Source of Truth)

```bash
gh api repos/$REPO/branches/main/protection \
  --jq '.required_status_checks.contexts[]'
```

**Expected**: `["qc-gate-minimum"]`

### Check PR Required Checks

```bash
gh pr view XXXX --repo "$REPO" \
  --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)") | {name, conclusion}'
```

### Close PR (Standard Pattern)

```bash
gh pr close XXXX --repo "$REPO" \
  --comment "Closed during DevOnboarder triage as **[reason]**. See PR_TRIAGE_DEVONBOARDER_2025-12-03.md for context."
```

### Merge PR (After Human Review)

```bash
gh pr checks XXXX --repo "$REPO"  # Verify first
gh pr merge XXXX --repo "$REPO" --squash --delete-branch
```

---

## Decision Framework Per Phase

### Phase 1: Superseded PRs

**Rule**: Close immediately, no review needed  
**Reason**: #1893 rollup includes all relevant changes

### Phase 2: Dependabot Groups

**Rule**: Merge oldest passing, close rest  
**Process**:

1. Group by lockfile (bot, frontend, python, ci-toolkit)
2. Check oldest PR's required checks
3. If green → merge, close duplicates
4. If red → close all in group (can reopen fresh Dependabot)

### Phase 3: Infra PRs

**Rule**: Manual review per PR  
**Decision Tree**:

- Obsolete/superseded → CLOSE
- Stale but relevant → Label for REFRESH (rare)
- Clean and relevant → MERGE

### Phase 4: Feature PRs

**Rule**: No auto-merge, explicit design call  
**Options**:

- Close as out-of-scope (likely for 60+ day age)
- Salvage (requires re-spec + heavy refactor)

### Phase 5: Docs PR

**Rule**: Quick merge if current, close if stale  
**Check**: Does content match current system state?

---

## Safety Rules

1. **Branch protection is law**: Only `qc-gate-minimum` is required
2. **Human approval for merges**: Agent may prepare, human executes `gh pr merge`
3. **No limbo state**: Every PR gets MERGE, CLOSE, or REFRESH
4. **Document exceptions**: Any deviation requires note in triage doc

---

## Post-Triage Actions

After completing all phases:

1. **Count PRs**:

   ```bash
   gh pr list --repo "$REPO" --state open --limit 100 | wc -l
   ```

2. **Append results to PR_TRIAGE_DEVONBOARDER_2025-12-03.md**:
   - Total merged: X
   - Total closed: Y
   - Remaining: Z (list with intent)

3. **Update DEVONBOARDER_CI_STATUS.md**:
   - Remove triaged PRs from blockers
   - Note any new baseline

---

## Execution Pattern

**Recommended**:

1. Start with Phase 0 (snapshot)
2. Run Phase 1 (quick wins)
3. Work through Phase 2 groups systematically
4. Take break before Phases 3-4 (require more judgment)
5. Finish with Phase 5-6 (cleanup)

**Script vs Manual**:

- Phases 0-2: Script-friendly (repetitive)
- Phases 3-5: Manual recommended (judgment calls)
- Phase 6: Script (verification)

---

## References

- **Full Playbook**: PR_TRIAGE_EXECUTION_PLAYBOOK.md (657 lines)
- **30-PR Inventory**: PR_TRIAGE_DEVONBOARDER_2025-12-03.md
- **Process Bug Fix**: AGENT_MERGE_READINESS_BUG_FIX.md
- **Merge Discipline**: AGENTS.md § "Merge Readiness Discipline"

---

**Created**: 2025-12-03  
**Status**: Ready for execution
