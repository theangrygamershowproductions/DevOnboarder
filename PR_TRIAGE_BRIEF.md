---
title: DevOnboarder PR Triage After QC Gate Refactor
description: Systematic cleanup plan for ~30 open PRs now that qc-gate-minimum and actions-policy-enforcement are the only merge gates.
author: Mr. Potato (TAGS)
project: DevOnboarder
tags:
  - v3
  - ci
  - qc
  - pr-triage
  - governance
document_type: execution-brief
status: active
---

# DevOnboarder PR Triage After QC Gate Refactor

## 1. Ground Truth (Do NOT Handwave)

**Repository:** `theangrygamershowproductions/DevOnboarder`  
**Key PR:** `#1893` – DevOnboarder actions policy migration (v3 compliance)  
**Branch:** `feat/devon-actions-migration-rollup`

### 1.1 Branch Protection (Source of Truth)

Required status checks for `main` **must be treated as law**:

- ✅ `qc-gate-minimum` (a.k.a. "QC Gate (Required - Basic Sanity)")
- ✅ `Validate Actions Policy Compliance` (or equivalent label, depending on UI)

Anything **not** in branch protection is **informational**, not a merge blocker.

Examples of **non-blocking** checks:

- `qc-full` (full coverage & YAML lint)
- `markdownlint`
- `validate-yaml`
- `Terminal Output Policy`
- `SonarCloud`

They *matter*, but they **do not** decide whether a PR *can* merge.  
Only the branch-protected checks do.

---

## 2. Mission Objectives

1. **Short-term (v3 window):**
   - Land #1893 (actions policy + QC gate refactor) on `main`.
   - Unstick the CI pipeline so infra PRs can merge again.
   - Ensure **no PR** merges while failing:
     - `qc-gate-minimum`
     - Actions policy enforcement

2. **Mid-term (v4):**
   - Plan and execute cleanup of historical debt:
     - YAML workflow lint errors
     - Coverage deficits (XP / Discord services)
     - Misc markdownlint / SonarCloud issues
   - Only then consider making `qc-full` required.

3. **Operational:**
   - Triage ~30 open PRs into:
     - **Merge soon**
     - **Needs fix**
     - **Superseded / close**
     - **Archive / won't merge**

---

## 3. CI Semantics the Agent MUST Respect

### 3.1 Required Checks

A PR is **mergeable** only if **all** of these are green:

- `qc-gate-minimum`
- `Validate Actions Policy Compliance` (or whatever exact name is configured)

If either is red → **PR is NOT merge ready.**  
No amount of "but coverage is fine" or "Copilot is happy" overrides this.

### 3.2 Non-required Checks

For **this v3 window**, the following are **informational**:

- `qc-full`
- `markdownlint`
- `validate-yaml`
- `Terminal policy` / `Terminal Output Policy`
- `SonarCloud`

Rules for the agent:

- **Log them.**  
- **Do not** use them to block merges **unless** they uncover *new* problems introduced by the PR (not pre-existing on `main`).
- Label related work as **P2 / v4 hardening**, not v3 gate.

---

## 4. Step 0 – Validate #1893 Is Still Merge-Ready

Before touching the other ~30 PRs, confirm #1893 is still clean.

**Commands (for the operator / agent):**

```bash
cd ~/TAGS/ecosystem/DevOnboarder

# Check required checks
gh pr view 1893 \
  --json statusCheckRollup \
  --jq '.statusCheckRollup[] | {name, status, conclusion}' \
  | jq -s 'sort_by(.name)'
```

Expected for **merge-ready**:

* `QC Gate (Required - Basic Sanity)` → `status: COMPLETED`, `conclusion: SUCCESS`
* `Validate Actions Policy Compliance` → `status: COMPLETED`, `conclusion: SUCCESS`

If those two are **not both green**, this document must **NOT** treat #1893 as merge-able.

---

## 5. Step 1 – Merge Strategy for #1893

Once Step 0 confirms both required checks are ✅:

1. **Merge policy:**
   * Prefer `--squash` to keep the actions-migration work as a single logical change.
   * Delete branch after merge (`feat/devon-actions-migration-rollup`).

2. **Human-only command** (agents must not run this themselves):

```bash
cd ~/TAGS/ecosystem/DevOnboarder
gh pr merge 1893 --squash --delete-branch
```

3. **Post-merge actions (agent can perform):**
   * Pull latest main
   * Update:
     * `DEVONBOARDER_CI_STATUS_2025-12-01.md` (mark P1 complete)
     * `GOVERNANCE_IMPLEMENTATION_STATUS.md` (DevOnboarder v3: compliant)
     * `ACTIONS_REPLACEMENT_MATRIX.md` (all 4 migrations implemented)
     * `DEVONBOARDER_V3_V4_QC_STANDARDS.md` (confirm two-tier QC reality)

---

## 6. Step 2 – PR Inventory & Classification

After #1893 merges:

1. Get all open PRs:

```bash
gh pr list --limit 100 --json number,title,headRefName,author,createdAt,isDraft \
  --jq '.[] | {number,title,headRefName,author:.author.login,createdAt,isDraft}'
```

2. **Classify each PR into one bucket:**

* **A. Dependabot / tooling-only**
  * Labeled `dependencies` or `dependabot`.
  * Only touches lockfiles, pyproject, package.json, etc.

* **B. Infra / CI / governance**
  * Touches `.github/workflows`, `scripts/`, policy docs.

* **C. Feature / code changes**
  * Touches `backend/`, `bot/`, frontend paths, etc.

* **D. Docs-only**
  * Touches `docs/`, markdown, metadata.

3. Create a working doc:

`PR_TRIAGE_DEVONBOARDER_<YYYY-MM-DD>.md` with a table:

```markdown
| PR | Title | Type | Required Checks | qc-gate-minimum | Actions Policy | Recommendation |
|----|--------|------|-----------------|-----------------|----------------|----------------|
| #NNNN | ...  | A/B/C/D | pass/fail      | pass/fail       | pass/fail      | merge/fix/close|
```

This doc is the **canonical triage artifact**.

---

## 7. Step 3 – Triage Rules Per PR Category

### 7.1 Category A – Dependabot / Tooling

**Goal:** Either merge or consciously close; do not leave them rotting.

For each PR:

1. Re-run CI against **current main** (rebase or `gh pr checkout` + `git merge main`).
2. Evaluate **required** checks only:
   * If `qc-gate-minimum` & actions policy are green:
     * ✅ Tag as **safe-to-merge**.
   * If `qc-gate-minimum` fails:
     * Check if it's a **real regression** (tests/imports broken) vs "old QC debt."
     * If it breaks imports/tests → **needs fix** or close.
3. If the dependency bump is clearly obsolete / superseded:
   * Mark as **close (superseded)** in triage doc.

**Output row example:**

```markdown
| #1901 | chore: bump httpx | A | qc-gate-minimum: ✅ | actions-policy: ✅ | merge (low risk) |
```

---

### 7.2 Category B – Infra / CI / Governance

These are **high leverage**. Handle next after Dependabot.

Rules:

1. If they **conflict** with #1893 changes (actions policy, QC refactor):
   * Rebase onto new `main` or recreate PR with updated patterns.
2. CI evaluation:
   * Must pass:
     * `qc-gate-minimum`
     * Actions policy enforcement
   * Other failures:
     * Log them.
     * Only block if **introduced by the PR**, not pre-existing on `main`.

Recommendation per PR:

* **merge** – if it meaningfully improves CI/governance and passes required checks.
* **needs rewrite** – if it reintroduces banned actions or breaks QC gate.
* **archive** – if it's an old experiment superseded by current reality.

---

### 7.3 Category C – Feature / Code

These are the most likely to be broken by drift.

Rules:

1. Confirm they still apply:
   * If target files were heavily refactored since PR was opened → likely **stale**.
2. Run quick sanity:
   * Does `qc-gate-minimum` pass after rebase?
   * Do tests related to touched area still exist / succeed locally?
3. Recommendations:
   * **merge soon** – if still relevant & green on required checks.
   * **rework** – if conflicts, failing required checks, or design is outdated.
   * **close** – if they no longer match current architecture.

---

### 7.4 Category D – Docs-only

These are low-risk but often blocked by markdownlint / metadata.

Rules:

1. If `qc-gate-minimum` passes and actions policy is irrelevant (most of the time):
   * They are **mergeable** even if markdownlint is mad.
2. But:
   * If a doc PR explicitly tries to "fix CI docs," ensure it doesn't conflict with new standards in `DEVONBOARDER_V3_V4_QC_STANDARDS.md`.

Recommendations:

* Merge if:
  * No regressions to metadata patterns.
  * No obvious conflicts with v3/v4 QC standards.

---

## 8. Step 4 – Final Output: Consolidated PR Triage Report

The agent's deliverable is a **single markdown report** committed or attached:

`PR_TRIAGE_DEVONBOARDER_<YYYY-MM-DD>.md`

Minimum columns:

```markdown
| PR | Title | Type (A/B/C/D) | qc-gate-minimum | Actions Policy | Other Red Checks | Recommendation | Notes |
|----|--------|----------------|-----------------|----------------|------------------|----------------|-------|
```

Recommendations must be one of:

* `merge`
* `merge-after-quick-fix`
* `needs-rework`
* `close-superseded`
* `archive/park-for-v4`

---

## 9. Non-negotiables for the Agent

1. **Never claim "merge ready"** unless all branch-protected checks are ✅ green.
2. **Always distinguish**:
   * "This PR is bad" vs
   * "This PR is exposing existing repo debt."
3. **Do not auto-lower standards silently.**
   * Any branch protection changes must be explicitly documented in:
     * `DEVONBOARDER_V3_V4_QC_STANDARDS.md`
     * A GitHub issue or governance doc.

---

## 10. Success Criteria

This triage is **done** when:

* PR #1893 is merged to `main`.
* All ~30 open PRs are:
  * Merged, or
  * Explicitly closed, or
  * Parked with a clear note in the triage report.
* `qc-gate-minimum` and actions policy remain the only required checks, both green on `main`.
* `qc-full` and other red checks are:
  * Documented as **v4 hardening work**.
  * Not silently ignored.

At that point, DevOnboarder is:

* v3 actions-policy compliant,
* CI gates are sane,
* PR backlog is intentionally handled, not just "red everywhere."
