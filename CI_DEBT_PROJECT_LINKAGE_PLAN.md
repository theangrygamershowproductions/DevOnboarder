---
title: "DevOnboarder CI Debt – Issue & Project Linkage Plan"
description: "Execution playbook to align CI debt docs with GitHub Issues and Projects after DevOnboarder v3 completion."
author: "Chad Reesey (Mr. Potato)"
created_at: "2025-12-03"
updated_at: "2025-12-03"
project: "DevOnboarder"
document_type: "execution_playbook"
status: "draft"
tags:
  - ci
  - governance
  - v3
  - v4
  - projects
  - debt-tracking
codex_scope: "DevOnboarder"
codex_role: "cto"
codex_type: "execution-brief"
codex_runtime: "cli+github"
---

# DevOnboarder CI Debt – Issue & Project Linkage Plan

## 0. Objective

Bring **reality**, **issues**, and **Projects** into alignment:

- v3 work (actions policy + QC gate) is **closed and linked**.
- v4 CI debt (terminal policy, YAML, markdownlint, SonarCloud) is tracked as **explicit epics**.
- All epics are **on Projects 4 & 6** with the right labels and cross-links.

_Assumption_: PR **#1893** is merged or will be merged as part of this run.

---

## 1. Preconditions (HUMAN CHECK)

Run these locally (or in Codespaces):

```bash
cd ~/TAGS/ecosystem/DevOnboarder

# 1. Confirm PR #1893 is merged
gh pr view 1893 --json state,mergedAt,headRefName,baseRefName \
  --jq '{state, mergedAt, head: .headRefName, base: .baseRefName}'

# 2. Confirm v3 docs exist
ls CI_DEBT_DEVONBOARDER.md PR_1893_MERGE_VERIFICATION*.md \
   AGENT_MERGE_READINESS_BUG_FIX.md PROCESS_BUG_FIX_STATUS.md \
   READY_TO_EXECUTE.md 2>/dev/null || echo "⚠️ Some expected docs missing"
```

If `state != "MERGED"`, **stop** and merge #1893 first.

---

## 2. Anchor the v3 Epic (DevOnboarder Actions Policy)

### 2.1. Ensure v3 epic issue is linked to #1893

Expected existing epic (adjust number if different):

* `#294` – *"DevOnboarder SHA Pinning Crisis"* (or equivalent)

Check linkage:

```bash
gh pr view 1893 --json closingIssuesReferences \
  --jq '.closingIssuesReferences[]? | {number, title}'
```

If `#294` (or your v3 epic issue) is **not** listed, add a comment to #1893:

```bash
gh pr comment 1893 \
  --body "Linking to tracking issue: fixes #294 (DevOnboarder actions policy / SHA pinning)."
```

Then manually close #294 if it isn't auto-closed on merge.

---

## 3. Create v4 CI Debt Epic Issues

Use `CI_DEBT_DEVONBOARDER.md` as the single source of truth.

Planned epics (rename if you already decided on other titles):

1. **Terminal Policy**
   * Title: `v4-epic: Terminal Output Policy Cleanup (DevOnboarder)`
2. **YAML Validation**
   * Title: `v4-epic: Workflow YAML Validation Cleanup (DevOnboarder)`
3. **Markdownlint**
   * Title: `v4-epic: Markdownlint & Docs Formatting Cleanup (DevOnboarder)`
4. **SonarCloud**
   * Title: `v4-epic: SonarCloud Quality Gate Remediation (DevOnboarder)`

Create issues if they don't exist yet:

```bash
cd ~/TAGS/ecosystem/DevOnboarder

# 1) Terminal Policy
gh issue create \
  --title "v4-epic: Terminal Output Policy Cleanup (DevOnboarder)" \
  --body-file CI_DEBT_DEVONBOARDER.md \
  --label "v4-scope" --label "epic" --label "ci" --label "terminal-policy" --label "high-priority"

# 2) YAML Validation
gh issue create \
  --title "v4-epic: Workflow YAML Validation Cleanup (DevOnboarder)" \
  --body-file CI_DEBT_DEVONBOARDER.md \
  --label "v4-scope" --label "epic" --label "ci" --label "yaml" --label "medium-priority"

# 3) Markdownlint
gh issue create \
  --title "v4-epic: Markdownlint & Docs Formatting Cleanup (DevOnboarder)" \
  --body-file CI_DEBT_DEVONBOARDER.md \
  --label "v4-scope" --label "epic" --label "docs" --label "markdownlint" --label "low-priority"

# 4) SonarCloud
gh issue create \
  --title "v4-epic: SonarCloud Quality Gate Remediation (DevOnboarder)" \
  --body-file CI_DEBT_DEVONBOARDER.md \
  --label "v4-scope" --label "epic" --label "ci" --label "sonarcloud" --label "low-priority"
```

Then capture their numbers:

```bash
gh issue list --state open --search "v4-epic DevOnboarder" \
  --json number,title,labels \
  --jq '.[] | {number,title,labels:[.labels[].name]}'
```

Record the mapping back into `CI_DEBT_DEVONBOARDER.md` under each section.

---

## 4. Add Epics to GitHub Projects (4 & 6)

Org Projects (from your notes):

* **Project 4** – Team Planning Board
* **Project 6** – Org Roadmap

First, get project IDs (once):

```bash
gh project list --owner theangrygamershowproductions \
  --format json --limit 10 \
  | jq '.projects[] | {id,title,number}'
```

Note the `id` for:

* `number == 4` (Team Planning Board)
* `number == 6` (Org Roadmap)

Then add each epic issue to both projects:

```bash
TEAM_PROJ_ID="<ID_FOR_4>"
ROADMAP_PROJ_ID="<ID_FOR_6>"

# Replace ISSUE_NUM with actual epic issue numbers
for ISSUE_NUM in 1234 1235 1236 1237; do
  # Add to Team Planning Board
  gh project item-add $TEAM_PROJ_ID --owner theangrygamershowproductions \
    --url "https://github.com/theangrygamershowproductions/DevOnboarder/issues/$ISSUE_NUM"

  # Add to Org Roadmap
  gh project item-add $ROADMAP_PROJ_ID --owner theangrygamershowproductions \
    --url "https://github.com/theangrygamershowproductions/DevOnboarder/issues/$ISSUE_NUM"
done
```

(An agent can fill in the actual IDs & issue numbers.)

---

## 5. Wire Backlinks & Labels

For each new v4 epic issue:

1. **Add backlinks to docs:**
   * `CI_DEBT_DEVONBOARDER.md`
   * Any relevant status docs (`PROCESS_BUG_FIX_STATUS.md`, `READY_TO_EXECUTE.md`)

   Example comment:

   ```text
   Linked debt analysis: CI_DEBT_DEVONBOARDER.md
   Related docs: PROCESS_BUG_FIX_STATUS.md, READY_TO_EXECUTE.md
   ```

2. **Add consistent labels:**
   * `component:devonboarder`
   * `phase:v4`
   * `type:ci-debt`
   * Priority (`P1`/`P2`/`P3`) matching your HIGH/MEDIUM/LOW classification.

```bash
# Example: set labels on one epic
ISSUE_NUM=1234
gh issue edit $ISSUE_NUM \
  --add-label "component:devonboarder" \
  --add-label "phase:v4" \
  --add-label "type:ci-debt" \
  --add-label "P1"
```

---

## 6. Verify Wiring (No Hand-Waving)

### 6.1. Issues ↔ PR

```bash
# Verify PR #1893 links to its tracking issue
gh pr view 1893 --json closingIssuesReferences \
  --jq '.closingIssuesReferences[]? | {number,title}'

# Verify each v4 epic issue remains OPEN
gh issue list --state open --search "v4-epic DevOnboarder" \
  --json number,title,state \
  --jq '.[]'
```

### 6.2. Issues ↔ Projects

```bash
# Spot-check one epic on each project via web UI,
# or with project item listing if you've scripted that.
```

(If you have a helper script for `gh project item-list`, reference it here.)

---

## 7. When This Playbook Is "Done"

This document is **complete** when ALL are true:

1. PR **#1893** is merged and linked to its v3 tracking issue.
2. All four v4 CI debt epics exist and are **open**.
3. Each epic is on:
   * Project 4 (Team Planning Board)
   * Project 6 (Org Roadmap)
4. `CI_DEBT_DEVONBOARDER.md` references each epic by number.
5. `PROCESS_BUG_FIX_STATUS.md` clearly states:
   * DevOnboarder v3 actions-policy **complete**
   * CI debt moved to **v4 epics**.

After that, DevOnboarder's CI story is:

> v3 = stable, compliant, shippable.
> v4 = hardening and polishing, fully tracked and scheduled.

---

## Execution Log

### Phase 1: Preconditions ⏳
- [ ] PR #1893 merge status verified
- [ ] Required v3 docs exist and accessible
- [ ] `gh` CLI configured with proper auth

### Phase 2: v3 Epic Linkage ⏳
- [ ] PR #1893 linked to tracking issue #294 (or equivalent)
- [ ] v3 epic closed if auto-close didn't trigger

### Phase 3: v4 Epic Creation ⏳
- [ ] Terminal Policy epic created (issue #____)
- [ ] YAML Validation epic created (issue #____)
- [ ] Markdownlint epic created (issue #____)
- [ ] SonarCloud epic created (issue #____)
- [ ] Issue numbers recorded in `CI_DEBT_DEVONBOARDER.md`

### Phase 4: Project Wiring ⏳
- [ ] Project 4 (Team Planning) ID retrieved: ____
- [ ] Project 6 (Org Roadmap) ID retrieved: ____
- [ ] All 4 epics added to Project 4
- [ ] All 4 epics added to Project 6

### Phase 5: Labels & Backlinks ⏳
- [ ] Terminal Policy: labels applied, docs linked
- [ ] YAML Validation: labels applied, docs linked
- [ ] Markdownlint: labels applied, docs linked
- [ ] SonarCloud: labels applied, docs linked

### Phase 6: Verification ⏳
- [ ] PR #1893 → issue linkage confirmed
- [ ] All v4 epics showing OPEN state
- [ ] Project board items visible (spot check)

### Phase 7: Documentation Update ⏳
- [ ] `CI_DEBT_DEVONBOARDER.md` updated with issue numbers
- [ ] `PROCESS_BUG_FIX_STATUS.md` updated with v3 completion
- [ ] This playbook marked COMPLETE

---

## Post-Completion Actions

Once all phases complete:

1. **Update Status Documents**:
   ```bash
   # Mark v3 complete in CI campaign status
   # Update governance completion tracking
   # Reference v4 epics in roadmap docs
   ```

2. **Close This Playbook**:
   - Mark status: `complete`
   - Archive in `docs/execution-logs/`
   - Reference from `DEVONBOARDER_V3_COMPLETION_SUMMARY.md`

3. **Begin v4 Planning**:
   - Prioritize Terminal Policy epic (HIGH)
   - Schedule YAML Validation (MEDIUM)
   - Defer docs/quality to later v4 phases

---

**Session Status**: Ready for Execution  
**Time**: 2025-12-03T21:30:00Z  
**State**: Playbook created, awaiting agent execution on gh-configured host
