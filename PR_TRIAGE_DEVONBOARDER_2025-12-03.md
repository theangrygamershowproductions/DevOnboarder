---
title: DevOnboarder PR Triage Report
date: 2025-12-03
project: DevOnboarder
repository: theangrygamershowproductions/DevOnboarder
total_prs: 30
status: in-progress
---

# DevOnboarder PR Triage Report - 2025-12-03

**Context:** After merging PR #1893 (actions policy + QC gate refactor), this report systematically triages the 30 open PRs against the new v3 compliance reality.

**Required Checks (Source of Truth):**

- ✅ `qc-gate-minimum` (Basic sanity: deps install, imports work, tests runnable)
- ✅ `Validate Actions Policy Compliance`

**Non-blocking Checks (Informational):**

- `qc-full` (coverage, YAML lint) - v4 hardening target
- `markdownlint`, `validate-yaml`, `Terminal Output Policy`, `SonarCloud`

---

## Classification Legend

**Type:**

- **A** - Dependabot / tooling-only (lockfiles, dependencies)
- **B** - Infra / CI / governance (workflows, scripts, policy docs)
- **C** - Feature / code changes (backend, bot, frontend)
- **D** - Docs-only (markdown, metadata)

**Recommendation:**

- `merge` - Ready to merge (required checks green)
- `merge-after-quick-fix` - Minor fix needed, then mergeable
- `needs-rework` - Conflicts, failing required checks, or design outdated
- `close-superseded` - Obsolete, replaced by newer work
- `archive/park-for-v4` - Valid but defer to v4 hardening phase

---

## Triage Table

| PR | Title | Type | Author | Age (days) | qc-gate-minimum | Actions Policy | Other Red Checks | Recommendation | Notes |
|----|-------|------|--------|------------|-----------------|----------------|------------------|----------------|-------|
| #1694 | Feat/frontend/dark mode toggle | C | RabbitAlbatross | 63 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Feature PR, significant age |
| #1810 | DOCS(aar): update AAR portal | D | reesey275 | 57 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Docs PR, automated AAR update |
| #1813 | FEAT(monitoring): token expiry monitoring | C | reesey275 | 52 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Feature PR, monitoring enhancement |
| #1815 | CLEANUP: DevOnboarder workspace organization | B | reesey275 | 52 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Infra cleanup, labeled documentation/enhancement/maintenance |
| #1816 | CLEANUP: main branch garbage removal | B | reesey275 | 52 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Infra cleanup, labeled enhancement |
| #1855 | Build(deps-dev): Bump @typescript-eslint/eslint-plugin | A | dependabot | 37 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies |
| #1857 | Build(deps-dev): Bump @typescript-eslint/parser | A | dependabot | 37 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies |
| #1862 | Build(deps-dev): Bump typescript | A | dependabot | 37 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies |
| #1863 | Build(deps-dev): Bump @eslint/js (frontend) | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies |
| #1864 | Build(deps): Bump react-router-dom | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies |
| #1865 | Build(deps-dev): Bump @vitest/coverage-v8 | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies |
| #1866 | Build(deps-dev): Bump vitest | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies |
| #1867 | Build(deps): Bump discord.js | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies |
| #1868 | Build(deps-dev): Bump eslint (bot) | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies |
| #1869 | Build(deps-dev): Bump @eslint/js (bot) | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies |
| #1871 | Build(deps-dev): Bump vale | A | dependabot | 30 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, Python dependencies |
| #1872 | chore(codeowners): add final catch-all | B | reesey275 | 29 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Governance PR, CODEOWNERS |
| #1874 | Build(deps): Bump tar (ci-toolkit) | A | dependabot | 29 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, CI toolkit dependencies |
| #1875 | Build(deps-dev): Bump pre-commit | A | dependabot | 23 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, Python dependencies |
| #1876 | Build(deps-dev): Bump language-tool-python | A | dependabot | 23 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, Python dependencies |
| #1878 | Build(deps-dev): Bump pytest | A | dependabot | 16 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, Python dependencies |
| #1879 | Build(deps-dev): Bump ruff | A | dependabot | 16 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, Python dependencies |
| #1880 | Build(deps): Bump js-yaml (frontend) | A | dependabot | 15 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies (multi) |
| #1881 | Build(deps): Bump js-yaml (bot) | A | dependabot | 15 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies (multi) |
| #1882 | Build(deps): Bump glob (bot) | A | dependabot | 13 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, bot dependencies |
| #1883 | Build(deps): Bump glob (frontend) | A | dependabot | 13 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, frontend dependencies |
| #1884 | Build(deps): Bump glob (ci-toolkit) | A | dependabot | 13 | ❓ | ❓ | ❓ | **NEEDS ANALYSIS** | Dependabot, CI toolkit dependencies |
| #1885 | FIX(ci): pin all GitHub Actions to full SHAs | B | reesey275 | 11 | ❓ | ❓ | ❓ | **LIKELY SUPERSEDED** | Superseded by #1893 (actions policy migration) |
| #1888 | FEAT(ci): Add actions policy enforcement | B | reesey275 | 2 | ❓ | ❓ | ❓ | **LIKELY SUPERSEDED** | Superseded by #1893 (actions policy migration) |
| #1893 | CI: DevOnboarder actions policy migration | B | reesey275 | 1 | ✅ | ✅ | qc-full, markdownlint, etc. | **MERGE READY** | Required checks green, merge first |

---

## Summary Statistics

- **Total PRs:** 30
- **Dependabot (Type A):** 22 (73%)
- **Infra/CI (Type B):** 6 (20%)
- **Feature/Code (Type C):** 2 (7%)
- **Docs-only (Type D):** 1 (3%)

**Age Distribution:**

- 50+ days: 5 PRs
- 30-49 days: 10 PRs
- 15-29 days: 8 PRs
- <15 days: 7 PRs

---

## Immediate Actions Required

### Phase 1: Merge #1893 (Human Operator)

**Status:** ✅ Both required checks green

**Command (human-only):**

```bash
cd ~/TAGS/ecosystem/DevOnboarder
gh pr merge 1893 --squash --delete-branch
```

**Post-merge updates (agent can perform):**

- Update `DEVONBOARDER_CI_STATUS_2025-12-01.md` (mark P1 complete)
- Update `GOVERNANCE_IMPLEMENTATION_STATUS.md` (DevOnboarder: v3 compliant)
- Update `ACTIONS_REPLACEMENT_MATRIX.md` (all 4 migrations complete)
- Update `DEVONBOARDER_V3_V4_QC_STANDARDS.md` (two-tier QC reality confirmed)

---

### Phase 2: Analyze Each PR (Agent Execution)

**For each PR (1694, 1810, 1813, etc.):**

1. **Check required checks status:**

```bash
gh pr view NNNN --json statusCheckRollup \
  --jq '.statusCheckRollup[] | select(.name == "QC Gate (Required - Basic Sanity)" or .name == "Validate Actions Policy Compliance") | {name, status, conclusion}'
```

1. **Check conflicts with main:**

```bash
gh pr view NNNN --json mergeable,mergeStateStatus
```

1. **Review files changed:**

```bash
gh pr view NNNN --json files --jq '.files[].path'
```

1. **Update triage table** with findings:
   - qc-gate-minimum: ✅/❌/⏸️ (pending)
   - Actions Policy: ✅/❌/N/A
   - Other Red Checks: List (informational)
   - Recommendation: merge/merge-after-quick-fix/needs-rework/close-superseded/archive

---

### Phase 3: Close Superseded PRs

**Likely Candidates:**

- #1885 (FIX: pin actions to SHAs) - Superseded by #1893
- #1888 (FEAT: actions policy enforcement) - Superseded by #1893

**Process:**

```bash
gh pr close NNNN --comment "Superseded by #1893 (actions policy migration). Changes incorporated into comprehensive v3 compliance work."
```

---

### Phase 4: Dependabot Strategy

**Bulk Analysis Approach:**

1. **Group by lockfile target:**
   - `bot/package-lock.json`: #1855, #1857, #1867, #1868, #1869, #1881, #1882
   - `frontend/package-lock.json`: #1862, #1863, #1864, #1865, #1866, #1880, #1883
   - `.github/actions/ci-toolkit/package-lock.json`: #1874, #1884
   - `pyproject.toml` / `requirements*.txt`: #1871, #1875, #1876, #1878, #1879

2. **For each group:**
   - Check oldest PR in group for required checks
   - If green → merge oldest first
   - If red → investigate if regression or pre-existing debt
   - Close remaining as superseded after first merge (lockfile will update)

3. **Rationale:**
   - Dependabot PRs conflict with each other (same lockfile)
   - Only need one per lockfile to be current
   - Merge oldest passing PR, close duplicates

---

### Phase 5: Feature/Code PRs (Manual Review)

**High Priority:**

- #1694 (dark mode toggle) - 63 days old, may be stale
- #1813 (token expiry monitoring) - 52 days old, feature PR

**Review Criteria:**

1. Does feature still align with current architecture?
2. Required checks status?
3. Conflicts with main?
4. Value vs effort to update?

**Recommendation:** Park for detailed review unless obviously broken.

---

### Phase 6: Cleanup/Infra PRs

**Candidates:**

- #1815 (DevOnboarder workspace organization) - 52 days old
- #1816 (main branch garbage removal) - 52 days old
- #1872 (CODEOWNERS catch-all) - 29 days old

**Strategy:**

1. Check for conflicts with #1893 changes
2. Evaluate if still relevant post-QC refactor
3. Required checks status
4. Merge if green and non-conflicting, else park for v4

---

## Success Criteria

This triage is **complete** when:

- ✅ PR #1893 merged to `main`
- ✅ All 30 PRs have status in triage table (not ❓)
- ✅ Superseded PRs (#1885, #1888) closed with explanation
- ✅ Dependabot PRs: One merged per lockfile group OR explicitly closed
- ✅ Feature/code PRs: Recommendation recorded (merge/rework/park)
- ✅ Infra PRs: Merged if green, parked if conflicts
- ✅ `qc-gate-minimum` and actions policy remain only required checks
- ✅ No PRs merge while failing required checks

---

## Next Agent Task

**Execute Phase 2:** Systematic PR analysis

**Command pattern:**

```bash
# For each PR number from inventory
for PR in 1694 1810 1813 1815 1816 1855 1857 1862 1863 1864 1865 1866 1867 1868 1869 1871 1872 1874 1875 1876 1878 1879 1880 1881 1882 1883 1884 1885 1888; do
  echo "=== PR #$PR ==="
  gh pr view $PR --json statusCheckRollup,mergeable,files \
    --jq '{
      checks: [.statusCheckRollup[] | select(.name | test("QC Gate|Actions Policy")) | {name, conclusion}],
      mergeable: .mergeable,
      filesChanged: [.files[].path]
    }'
  echo ""
done
```

**Output:** Update triage table with concrete status for each PR.

---

**Report Status:** INITIAL SKELETON - Phase 1 (merge #1893) ready, Phase 2+ awaiting agent execution

**Updated:** 2025-12-03 (initial)
