---
title: "Backlog Amnesty Playbook - DevOnboarder v3/v4 Transition"
description: "Systematic protocol for closing obsolete Issues/PRs from pre-v3 Projects"
author: "TAGS Engineering"
created_at: "2025-12-03"
updated_at: "2025-12-03"
status: "active"
visibility: "internal"
tags:
  - backlog-cleanup
  - v3-freeze
  - v4-debt
  - governance
codex_scope: "DevOnboarder"
codex_role: "CTO"
codex_type: "playbook"
---

# Backlog Amnesty Playbook

**Purpose**: Systematic protocol for closing obsolete Issues and PRs from pre-v3 Projects during the v3 freeze → v4 transition.

**Rationale**: v3 is locked. v4 debt is catalogued in `CI_DEBT_DEVONBOARDER.md`. Anything that doesn't map to either is noise that obscures real work.

**Authority**: Extends "no limbo" principle from `PR_TRIAGE_*.md` to backlog management.

---

## Core Principle: Everything Gets a Verdict

**No item stays in limbo.** Every old Issue/PR attached to deprecated Projects gets one of three outcomes:

1. **KEEP** - Maps to v3/v4 plan, still valid in current architecture
2. **REWRITE** - Core idea valid, but context/wording is obsolete (create fresh Issue, close old)
3. **CLOSE** - Doesn't map to current roadmap, would require archaeology to understand, or superseded by newer work

**Rule**: If you can't confidently answer "which v4 epic or current roadmap item does this support?", it's a CLOSE candidate.

---

## Safety Filter: What NOT to Close

### Tier 1: Explicit v4 Work (NEVER CLOSE)

These are **named v4 workstreams** from `CI_DEBT_DEVONBOARDER.md`:

- **Category A**: Terminal Policy (HIGH priority)
- **Category B**: Required Checks vs Path Filters (MEDIUM-CONFIG)
- **Category C**: YAML Validation (MEDIUM)
- **Category D**: Documentation Lint (LOW)
- **Category E**: SonarCloud Quality Gate (LOW)

**Any Issue/PR clearly tied to Categories A-E stays open** (or gets created if missing).

### Tier 2: Core-4 v3/v4 Obligations (KEEP)

- **Actions policy migration** (v3 complete, v4 monitoring/rotation automation)
- **Core-instructions v3 compliance** (pending - same pattern as DevOnboarder PR #1893)
- **TAGS-wide governance** (playbooks, runbooks, policy docs)
- **QA framework repos** (tags-qa-framework, test infrastructure)

### Tier 3: Recent Work Still Valid (KEEP)

- **Age < 30-60 days AND fits current architecture**
- Still references v3+ concepts (post-freeze, post-governance)
- Doesn't require "archaeology" to understand intent

---

## Aggressive Close Filter: What IS Safe to Kill

### Red Flag 1: Age + Drift Combo

**CLOSE** if:
- Open > 6-9 months, **AND**
- References pre-v3 concepts (old CI stack, pre-governance, pre-MCP baseline, etc.)
- Would require significant effort just to re-understand original intent

**Examples**:
- "Improve CI quality gate" (vague, pre-v3, now covered by Categories A-E)
- "Clean up workflows" (pre-Actions Policy, now covered by YAML + Docs categories)
- Issues from 2024 referencing deprecated infrastructure/tooling

### Red Flag 2: Duplication with v4 Epics

**CLOSE** if:
- Core intent is **already captured** in CI_DEBT_DEVONBOARDER.md Categories A-E
- New epic provides better framing/scope/priority
- Old Issue adds no unique value beyond what's in the epic

**Close comment pattern**: "Superseded by [Category X] in CI_DEBT_DEVONBOARDER.md"

### Red Flag 3: Obsolete Infrastructure References

**CLOSE** if:
- Describes manual workflows you've since automated
- References environments/stacks fully replaced in 2025 v3 work
- Proposes experiments that got "done right" in production deployments

**Examples**:
- Legacy automation experiments (pre-Enhanced Automation framework)
- Old Project tracking for deprecated dev environments
- CI experiments superseded by current .github/workflows/ suite

---

## Execution Protocol: 3-Pass Triage

### Pass 1: Quick Filter (5-10 min per 10 Issues/PRs)

For each Item in old Projects backlog:

**Question 1**: Does this map to v3/v4 work?
- YES → Check if still valid in current architecture → KEEP or REWRITE
- NO → Move to Pass 2

**Question 2**: Is this < 60 days old AND still relevant?
- YES → KEEP
- NO → Move to Pass 2

### Pass 2: Deep Inspection (2-3 min per item)

**Question 3**: Would I need "archaeology" to understand this?
- YES (requires context from 2+ architectures ago) → CLOSE
- NO → Move to Pass 3

**Question 4**: Does this duplicate a v4 epic or recent doc?
- YES → CLOSE with reference to newer artifact
- NO → Move to Pass 3

### Pass 3: Judgment Call (1-2 min per item)

**Question 5**: If I close this, will I lose unique value?
- YES → REWRITE as fresh Issue with 2025 context
- NO → CLOSE

**Question 6**: Am I keeping this "just in case"?
- YES → CLOSE (you already have the map in CI_DEBT_DEVONBOARDER.md + Projects 4/6)
- NO → KEEP

---

## Standard Close Comment Templates

### Template 1: Superseded by v4 Epic

```markdown
**Closing as superseded by v4 CI debt epic.**

This Issue/PR is now covered by:
- **Category [A/B/C/D/E]**: [Name] (Priority: [HIGH/MEDIUM/LOW])
- **Documentation**: `CI_DEBT_DEVONBOARDER.md` (lines XXX-YYY)
- **Tracking**: Projects 4 & 6

The v4 epic provides better scoping, prioritization, and fix options. No unique value lost by closing this older artifact.
```

### Template 2: Obsolete Architecture Context

```markdown
**Closing as obsolete - references pre-v3 architecture no longer in use.**

This Issue/PR was opened [X months] ago and references:
- [Old stack/environment/pattern that's been replaced]

Current equivalent (if any):
- [Pointer to v3/v4 equivalent, or "N/A - approach superseded"]

Part of v3/v4 transition backlog cleanup. No action required.
```

### Template 3: Duplicate Intent, Stale Wording

```markdown
**Closing - core intent captured in newer Issue #[NEW_ID].**

Original concept still valid, but context/wording is anchored in [old world]. Created fresh Issue with 2025 framing:
- **New Issue**: #[NEW_ID] - [Brief title]
- **What changed**: [1-2 line summary of reframing]

Part of v3/v4 transition backlog cleanup.
```

### Template 4: Generic Amnesty Close

```markdown
**Closing as part of v3/v4 backlog amnesty.**

This Issue/PR:
- Does not map to v3 commitments (now complete)
- Does not map to v4 CI debt Categories A-E
- Does not align with current Core-4 roadmap

v3/v4 work is fully catalogued in:
- `CI_DEBT_DEVONBOARDER.md` (v4 epics)
- `DEVONBOARDER_V3_COMPLETION_SUMMARY.md` (v3 achievements)
- Projects 4 & 6 (active tracking)

No unique value lost by closing. Eliminates stale backlog noise.
```

---

## Metrics to Track

**Before Cleanup**:
- Total Issues/PRs in old Projects: [COUNT]
- Average age: [DAYS]
- Issues with no activity in 6+ months: [COUNT]

**After Cleanup**:
- Items KEPT: [COUNT] ([REASON_BREAKDOWN])
- Items REWRITTEN: [COUNT] (new Issues: #XXX, #YYY, ...)
- Items CLOSED: [COUNT]
  - Superseded by v4 epic: [COUNT]
  - Obsolete architecture: [COUNT]
  - Duplicate/stale: [COUNT]

**Outcome**:
- Active backlog reduced by [XX]%
- All remaining items map to v3/v4 plan
- No limbo items remain

---

## Integration with Existing Workflows

### Links to Current Playbooks

This playbook extends:
- **PR_TRIAGE_PLAYBOOK_V1.md**: "No limbo" principle (every PR gets a verdict)
- **PR_TRIAGE_STRATEGIC_CONTEXT.md**: Batch triage patterns, decision frameworks
- **CI_DEBT_DEVONBOARDER.md**: Authoritative v4 epic catalogue

### When to Run Backlog Amnesty

**Recommended cadence**:
- **Once per v3/v4 transition** (NOW - immediate cleanup)
- **Quarterly** going forward (prevent accumulation)
- **After major architecture changes** (e.g., v5 planning)

**Effort estimate**: 30-60 min per 20 old Issues/PRs (depending on triage pass depth)

---

## Audit Trail Requirements

For all CLOSE operations:

1. **Use standard template** (see above) - ensures consistency
2. **Reference specific v4 epic or doc** where applicable
3. **Apply `backlog-amnesty` label** (create if missing)
4. **Apply v3/v4 transition label** (e.g., `v3-freeze`, `v4-scope`)
5. **Comment before closing** (no silent closes - GitHub Issue remains searchable)

**GitHub Search Query** (to find all amnesty closes later):
```
repo:theangrygamershowproductions/DevOnboarder is:closed label:backlog-amnesty
```

---

## Emergency Rollback Protocol

**If you close something you shouldn't have**:

1. **Reopen immediately** (GitHub preserves all history)
2. **Add comment**: "Reopened - premature close, still maps to [v4 epic/roadmap item]"
3. **Apply correct label** (e.g., `v4-scope`, `category-A`, etc.)
4. **Update this playbook** with the mistake pattern (prevent recurrence)

**Key safety**: GitHub Issues/PRs are never truly deleted - all closures are reversible.

---

## Success Criteria

**Backlog Amnesty is complete when**:

- [ ] All Issues/PRs in old Projects have one of: KEEP, REWRITE, CLOSE verdict
- [ ] All KEPT items have clear v3/v4 mapping (label + comment if ambiguous)
- [ ] All REWRITTEN items have fresh Issue with 2025 context (old Issue closed with reference)
- [ ] All CLOSED items have standard template comment with audit trail
- [ ] Metrics tracked (before/after counts, breakdown by close reason)
- [ ] No items remain in "limbo" (unclear status or purpose)

**Outcome**: Clean backlog that accurately reflects v3/v4 work, zero archaeology required to understand remaining items.

---

## Example Execution (Sample Batch)

### Old Project: "DevOnboarder CI Improvements" (2024-era)

**Issue #123**: "Improve CI speed" (open 8 months, vague)
- **Verdict**: CLOSE (Template 4 - Generic Amnesty)
- **Reason**: Superseded by Category C (YAML Validation) which includes performance optimization

**Issue #456**: "Add markdownlint to CI" (open 4 months, specific)
- **Verdict**: CLOSE (Template 1 - Superseded by v4 Epic)
- **Reason**: Now Category D (Documentation Lint) in CI_DEBT_DEVONBOARDER.md

**Issue #789**: "Migrate to Actions Policy" (open 2 months, aligns v3)
- **Verdict**: KEEP
- **Reason**: Maps to Actions Policy v3 work (PR #1893 pattern), still relevant for core-instructions v3

**PR #234**: "Experiment with new test framework" (open 6 months, draft, abandoned)
- **Verdict**: CLOSE (Template 2 - Obsolete Architecture)
- **Reason**: Experiment scope replaced by current test infrastructure in v3

**Issue #567**: "Fix terminal emoji policy violations" (open 1 month, specific)
- **Verdict**: KEEP
- **Reason**: Maps directly to Category A (Terminal Policy - HIGH priority), active v4 work

### Batch Results
- Total: 5 items
- KEPT: 2 (40%)
- CLOSED: 3 (60%)
- Average close comment: 3-4 lines (standard template)
- Time: ~10 min total

---

## Version History

- **2025-12-03**: Initial playbook created (v3/v4 transition context, backlog cleanup protocol)

---

## References

- **CI_DEBT_DEVONBOARDER.md**: v4 CI debt categories (authoritative epic catalogue)
- **PR_TRIAGE_PLAYBOOK_V1.md**: "No limbo" principle, triage decision frameworks
- **DEVONBOARDER_V3_COMPLETION_SUMMARY.md**: v3 achievements (what's done)
- **TAGS_V3_FEATURE_FREEZE_2025-11-28.md**: v3 freeze contract (stability-only scope)
