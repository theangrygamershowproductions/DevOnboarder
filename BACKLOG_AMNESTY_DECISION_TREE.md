---
title: "Backlog Amnesty Decision Tree - No Second-Guessing"
description: "30-second decision rule for old Issues/PRs - keep or kill"
author: "TAGS Engineering"
created_at: "2025-12-03"
updated_at: "2025-12-03"
status: "active"
visibility: "internal"
tags:
  - backlog-cleanup
  - decision-tree
  - no-overthinking
codex_scope: "DevOnboarder"
codex_role: "CTO"
codex_type: "decision-aid"
---

# Backlog Amnesty Decision Tree

**Purpose**: 30-second decision rule for old backlog items. No overthinking, no second-guessing.

**Rule**: If you can't quickly say where it lives in the v3/v4 plan, it dies.

---

## The Decision Tree (30 Seconds Max)

```
Old Issue/PR
    │
    ├─> Is it explicitly referenced in v3/v4 docs?
    │   (CI_DEBT_DEVONBOARDER.md, CI_DEBT_PROJECT_LINKAGE_PLAN.md,
    │    v3 completion docs, Core-4 obligations)
    │   │
    │   ├─> YES → KEEP (or rewrite if wording stale)
    │   │
    │   └─> NO → Continue to next question
    │
    ├─> Can I say in 30 seconds which v4 CI debt category it maps to?
    │   (Category A: Terminal Policy, B: Required Checks,
    │    C: YAML Validation, D: Docs Lint, E: SonarCloud)
    │   │
    │   ├─> YES → CLOSE as "superseded by Category X"
    │   │
    │   └─> NO → Continue to next question
    │
    ├─> Is it > 6-9 months old AND references pre-v3 concepts?
    │   (Old CI stack, pre-actions-policy, pre-governance,
    │    deprecated infrastructure, failed experiments)
    │   │
    │   ├─> YES → CLOSE as "obsolete architecture"
    │   │
    │   └─> NO → Continue to next question
    │
    └─> Would I recreate this if I closed it?
        (Core idea still valid for v4?)
        │
        ├─> YES → REWRITE (create fresh Issue, close old as superseded)
        │
        └─> NO → CLOSE as "generic amnesty"
```

---

## Blunt Rule of Thumb (When You're Tired)

**If an old Issue/PR isn't explicitly referenced in your v3/v4 docs, and you can't in 30 seconds say which CI_DEBT category or Core-4 obligation it serves:**

→ **CLOSE IT under Backlog Amnesty.**

**Rationale**:
- CI debt is fully catalogued (Categories A-E)
- v3 is locked and complete
- v4 will be driven by new issues/epics, not ancient one-liners
- You have the safety net - don't carry dead weight

---

## Hard Lines: What You MUST NOT Close

### Tier 1: Explicitly Called Out in Docs

**KEEP if mentioned in**:
- `CI_DEBT_DEVONBOARDER.md` (Categories A-E)
- `CI_DEBT_PROJECT_LINKAGE_PLAN.md` (wiring plan)
- `DEVONBOARDER_V3_COMPLETION_SUMMARY.md`
- `ACTIONS_POLICY.md` (actions migration)
- Any v3/v4 completion docs merged in PRs #1893, #1894, #1895

### Tier 2: Clear Category Mapping (Even If Not Explicitly Referenced)

**KEEP if clearly maps to**:
- **Category A**: Terminal output policy violations (HIGH priority)
- **Category B**: Required checks vs path filters (MEDIUM-CONFIG)
- **Category C**: YAML workflow validation (MEDIUM)
- **Category D**: Documentation/markdownlint issues (LOW)
- **Category E**: SonarCloud/code quality gates (LOW)

**Close as "superseded by Category X"** - these have a home in v4 epics.

### Tier 3: Core-4 v3/v4 Obligations

**KEEP if related to**:
- Actions policy migration (v3 work, ongoing monitoring)
- core-instructions v3 compliance (pending work)
- TAGS-wide governance (playbooks, runbooks)
- QA framework repos (tags-qa-framework)

### Tier 4: Recent and Still Valid

**KEEP if**:
- < 60 days old, **AND**
- Fits current v3/v4 architecture (not anchored in old world)
- No archaeology required to understand intent

---

## Aggressive Close Targets (Kill on Sight)

### Red Flag 1: No v3/v4 Mapping

**CLOSE if**:
- Doesn't map to v3 commitments (now complete)
- Doesn't map to v4 CI debt Categories A-E
- Doesn't align with Core-4 roadmap
- You can't say where it lives in the current plan

**Template**: Generic Amnesty

### Red Flag 2: Old + Pre-v3 Concepts

**CLOSE if**:
- Open > 6-9 months, **AND**
- References:
  - Pre-actions-policy CI workflows
  - Pre-governance assumptions
  - Deprecated infrastructure/environments
  - Abandoned experiments
  - Manual workflows now automated

**Template**: Obsolete Architecture

### Red Flag 3: Duplicate Intent with v4 Epic

**CLOSE if**:
- Says "Improve CI" (vague) → now Categories A-E
- Says "Clean up workflows" → now Category C (YAML)
- Says "Add linting" → now Category D (Docs)
- Says "Fix quality gate" → now Category E (SonarCloud)
- Says "Terminal output issues" → now Category A (Terminal Policy)

**Template**: Superseded by v4 Epic (cite specific category)

### Red Flag 4: Keeping "Just in Case"

**CLOSE if**:
- Only reason to keep is "might need this someday"
- No concrete v4 epic or roadmap tie
- Reading it requires archaeology (3+ context switches)

**Template**: Generic Amnesty

---

## The 80/20 Reality Check

For old Project-attached backlog:

**Assume CLOSE unless it very obviously maps to CI debt A-E or Core-4.**

**In practice**:
- **~80%** of old backlog will fail the mapping test → close with audit trail
- **~15%** will map to v4 categories → close as superseded, point to category
- **~5%** will need to stay open or get rewritten

**Your job**: Run the 30-second filter and let the dead tickets die cleanly.

---

## Common Examples (Quick Reference)

| Old Issue Title | Age | Decision | Reason |
|----------------|-----|----------|--------|
| "Improve CI speed" | 8 mo | **CLOSE** | Vague, now Category C: YAML Validation |
| "Add markdownlint to CI" | 4 mo | **CLOSE** | Now Category D: Documentation Lint |
| "Fix terminal emoji policy" | 1 mo | **KEEP** | Category A: Terminal Policy (HIGH) |
| "Migrate to Actions Policy" | 2 mo | **KEEP** | v3 work, maps to ACTIONS_POLICY.md |
| "Experiment with new test framework" | 6 mo | **CLOSE** | Abandoned, stack replaced in v3 |
| "Clean up old workflows" | 10 mo | **CLOSE** | Pre-v3, now Category C + Actions Policy |
| "SonarCloud quality gate failing" | 3 mo | **CLOSE** | Now Category E: SonarCloud |
| "Add path filters to reduce CI waste" | 2 mo | **KEEP** | Category B: Required Checks vs Paths |

---

## When You're Not Sure (Tie-Breaker)

**Ask yourself**:
1. "If I close this, will I lose something I can't recreate from v3/v4 docs?"
   - YES → REWRITE or KEEP
   - NO → CLOSE

2. "Am I keeping this because it's valuable, or because I'm nervous about deleting things?"
   - Valuable → KEEP
   - Nervous → CLOSE (you have the safety net)

3. "Does this help me complete v4 work, or is it just noise?"
   - Helps v4 → KEEP or REWRITE
   - Noise → CLOSE

**Default action when unsure**: CLOSE with Generic Amnesty template.
- All GitHub Issues/PRs are reversible
- You can reopen if you made a mistake
- Better to have clean backlog than carry dead weight

---

## Safety Net Reminder

You've already built the safety net:
- ✅ v3 work is complete and documented
- ✅ v4 CI debt is fully catalogued (Categories A-E)
- ✅ All critical work is referenced in current docs
- ✅ GitHub never truly deletes Issues/PRs (all closures reversible)

**You can't lose anything important by running this filter.**

The only risk is keeping garbage that obscures real work.

---

## Execution Protocol

### Step 1: Pull Batch
```bash
gh issue list --state open --limit 20 --json number,title,createdAt | sort
```

### Step 2: For Each Item (30 Seconds Max)

**Question**: Where does this live in v3/v4?
- Can answer quickly → KEEP or CLOSE (superseded by category)
- Can't answer → CLOSE (generic amnesty)

### Step 3: Apply Template

Use standard templates from `BACKLOG_AMNESTY_QUICKSTART.md`:
- Template 1: Superseded by v4 epic (cite category)
- Template 2: Obsolete architecture
- Template 3: Rewrite with fresh Issue
- Template 4: Generic amnesty

### Step 4: Move to Next Batch

Don't overthink. Trust the filter. Keep moving.

---

## Success Metrics

**Before amnesty**:
- Open issues: 150+
- Can't quickly explain what 80% of them are for
- Backlog obscures real work

**After amnesty**:
- Open issues: 30-50 (focused on v4 work)
- Every item maps to v3/v4 plan
- No archaeology required to understand backlog
- Clean slate for v4 execution

---

## Version History

- **2025-12-03**: Initial decision tree created (no second-guessing, blunt rules)
