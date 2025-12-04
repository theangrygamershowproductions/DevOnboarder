---
title: "Backlog Amnesty - Green Light Memo"
description: "Final authorization: old Project backlog is killable by default"
author: "TAGS Engineering"
created_at: "2025-12-03"
updated_at: "2025-12-03"
status: "active"
visibility: "internal"
tags:
  - backlog-cleanup
  - authorization
  - execution
codex_scope: "DevOnboarder"
codex_role: "CTO"
codex_type: "authorization"
---

# Backlog Amnesty - Green Light Memo

**Authorization**: Old Project backlog items are **killable by default** under Backlog Amnesty policy.

**Effective**: 2025-12-03 (DevOnboarder v3 complete, v4 CI debt catalogued)

---

## The Blunt Truth

**You already built enough safety net that you cannot nuke anything irreplaceable.**

### What You Have

**v3 Complete and Locked**:
- PRs #1893, #1894, #1895 merged
- Branch protection restored
- Actions policy documented
- v3 completion summary captured

**v4 Explicitly Defined**:
- `CI_DEBT_DEVONBOARDER.md` - Categories A-E with priorities
- `CI_DEBT_PROJECT_LINKAGE_PLAN.md` - GitHub wiring plan
- All critical work catalogued

**Backlog Amnesty Machinery**:
- Decision tree (30-second filter)
- Quickstart (executable commands)
- Full playbook (policy and rationale)
- 1-hour sprint plan (mechanical execution)

### What This Means

**Anything still sitting in old Projects and NOT explicitly referenced in v3/v4 docs is:**

> Historical residue from a previous planning model.

**Those are exactly the candidates you built Backlog Amnesty for.**

---

## Authorization Statement

**For Issues and PRs attached to old Projects:**

### Default Action: CLOSE

**Unless the item clearly meets one of these criteria, CLOSE IT:**

1. **Maps to CI_DEBT A-E** (can say "this is Category X" in 30 seconds)
2. **Maps to Core-4/governance** (actions policy, AGENTS.md, QA framework, security)
3. **Recent + aligned** (< 60 days old, references v3/v4 concepts)

### Keep/Rewrite Only If

**Terminal output issues** → Category A (HIGH priority)
**Required checks/path filters** → Category B (MEDIUM priority)
**YAML validation** → Category C (MEDIUM priority)
**Markdown/docs lint** → Category D (LOW priority)
**SonarCloud/quality** → Category E (LOW priority)
**Actions policy work** → v3 complete, v4 monitoring
**Governance/safety** → Core-4 obligations
**Recent v3/v4 work** → < 60 days, fits current architecture

### Everything Else Dies

**Pre-v3 CI ideas** → CLOSE (obsolete architecture)
**Vague "improve X" tickets** → CLOSE (now covered by Categories A-E)
**Old experiments** → CLOSE (tied to dead branches)
**References to replaced workflows** → CLOSE (stack changed)
**Items requiring archaeology** → CLOSE (can't remember context)

---

## The Hard Rules (What NOT to Close)

### Tier 1: Explicitly Referenced in v3/v4 Docs

**Do not close if mentioned in**:
- `CI_DEBT_DEVONBOARDER.md`
- `CI_DEBT_PROJECT_LINKAGE_PLAN.md`
- `DEVONBOARDER_V3_COMPLETION_SUMMARY.md`
- `ACTIONS_POLICY.md`
- v3 completion docs (PRs #1893, #1894, #1895)

### Tier 2: Clear Category Mapping

**Keep if clearly maps to**:
- Category A: Terminal Policy (terminal output, emoji, formatting)
- Category B: Required Checks (path filters, required status checks)
- Category C: YAML Validation (workflow lint, YAML structure)
- Category D: Documentation Lint (markdownlint, docs quality)
- Category E: SonarCloud (code quality gates, static analysis)

**Close as "superseded by Category X"** - these have a home in v4 epics.

### Tier 3: Core-4 Obligations

**Keep if related to**:
- Actions policy (v3 work, ongoing monitoring)
- core-instructions v3 compliance
- TAGS-wide governance (playbooks, runbooks, policy docs)
- QA framework (tags-qa-framework, test infrastructure)
- Security baselines (no-verify guard, dangerous-git, etc.)

### Tier 4: Recent and Still Valid

**Keep if ALL of**:
- Age < 60 days
- References v3/v4 concepts (post-freeze, post-governance)
- Fits current architecture (no archaeology required)

---

## How to Treat Old Project Backlog

### Project is NOT Source of Truth

**Old Projects** → historical planning artifacts

**New source of truth**:
- `CI_DEBT_DEVONBOARDER.md` (v4 work)
- v3 completion docs (what's done)
- v4 epics (when created)

### 30-Second Mapping Rule

**For each item**:

**Can you say "This is Category X" or "This is Core-4" in 30 seconds?**
- YES → Keep or rewrite
- NO → Close with Backlog Amnesty template

### Always Leave Fingerprint

**On every close**:
1. Comment with standard template (superseded/obsolete/generic)
2. Add `backlog-amnesty` label
3. Optionally add `v4-scope` or `superseded` label

**Result**: Defensible audit trail, nothing vanished silently

---

## Direct Answer to the Question

> "Are these all Issues and Pull Requests that are in the Backlog and attached to older Projects that we can close out?"

### YES, by default.

**You ONLY spare the ones that**:
- Map cleanly to CI_DEBT A-E or Core-4, OR
- Are recent (< 60 days) and clearly aligned with current architecture

**Everything else is noise you've already superseded in v3/v4 design.**

---

## Execution Authorization

### You Are Authorized To

**Immediately execute Backlog Amnesty on**:
- All Issues/PRs in old Projects
- All Issues/PRs not referenced in v3/v4 docs
- All Issues/PRs that fail 30-second mapping test

**Without further approval or second-guessing**

### Safeguards in Place

**Cannot lose anything important because**:
1. v3 work is complete and documented
2. v4 CI debt is fully catalogued (Categories A-E)
3. All critical work is referenced in current docs
4. GitHub never truly deletes Issues/PRs (all closures reversible)
5. Every closure has audit trail (comment + label)

**Only risk**: Carrying garbage that obscures real work

**Risk of closing**: Essentially zero (can reopen if wrong)

### Wave Marking (Optional)

**For searchability, consider adding**:
- `backlog-amnesty-2025-12-wave1` label
- Allows "December purge" to be searchable
- Not required, but helpful for historical analysis

---

## Success Criteria

**Amnesty campaign succeeds when**:

### Quantitative
- [ ] 80%+ of old Project backlog closed or relabeled
- [ ] All remaining open items have v4 labels (v4-scope, category-X)
- [ ] All closed items have backlog-amnesty label
- [ ] All closed items have comment explaining reason

### Qualitative
- [ ] Can explain purpose of any remaining open item in 30 seconds
- [ ] No items in "limbo" (unclear status or mapping)
- [ ] Backlog accurately reflects v3/v4 work (no archaeology required)
- [ ] New Issues/PRs created to replace any rewritten items

---

## Common Close Patterns (Quick Reference)

### Pattern 1: Superseded by CI Debt (~40% of closures)

**Examples**:
- "Add markdownlint to CI" → Category D
- "Improve workflow validation" → Category C
- "Fix terminal output" → Category A
- "SonarCloud failing" → Category E
- "Path filter optimization" → Category B

**Template**: "Closing under Backlog Amnesty. This is now tracked as Category X in CI_DEBT_DEVONBOARDER.md"

### Pattern 2: Obsolete Architecture (~40% of closures)

**Examples**:
- "Experiment with [old framework]"
- "Migrate to [deprecated tool]"
- "Fix [pre-v3 CI issue]"
- "Improve [replaced infrastructure]"

**Template**: "Closing under Backlog Amnesty. This was for pre-v3 architecture that no longer exists."

### Pattern 3: Keep with v4 Label (~15% of items)

**Examples**:
- Terminal emoji policy violations
- Actions policy migration work
- Recent governance/security items

**Action**: Add `v4-scope,category-X` labels, leave open

### Pattern 4: Rewrite Fresh (~5% of items)

**Examples**:
- Good core idea, but context is stale
- Would recreate if closed

**Action**: Create new Issue, close old as superseded

---

## Anti-Patterns (Do NOT Do This)

### ❌ Keeping "Just in Case"

**If only reason to keep is "might need this someday"**:
- Close it
- You have the safety net (v4 CI debt catalogued)
- Can recreate if truly needed

### ❌ Second-Guessing the Filter

**If you hit 30 seconds and still unsure**:
- Default to CLOSE
- You can reopen if wrong (GitHub never deletes)
- Better clean backlog than carry dead weight

### ❌ Closing Without Comment

**Every closure MUST have**:
- Standard template comment (why it's closing)
- backlog-amnesty label (for searchability)

**No silent closes** - audit trail is mandatory

### ❌ Overthinking Complex Items

**If an item needs > 3 min to decide**:
- SKIP and move to next
- Come back in separate session
- Don't let edge cases block the bulk cleanup

---

## Emergency Rollback Protocol

**If you close something you shouldn't have**:

```bash
# Reopen immediately
gh issue reopen [NUMBER]

# Add comment
gh issue comment [NUMBER] --body "Reopened - premature close, maps to [v4 epic/Core-4]."

# Remove amnesty label
gh issue edit [NUMBER] --remove-label "backlog-amnesty"

# Add correct label
gh issue edit [NUMBER] --add-label "v4-scope,category-X"
```

**No harm done** - GitHub preserves full history, reopen is instant.

---

## Final Authorization

**This memo authorizes immediate execution of Backlog Amnesty on DevOnboarder old Project backlog.**

**Default action**: CLOSE (with comment + label)

**Exception**: Only if clearly maps to CI_DEBT A-E, Core-4, or recent v3/v4 work

**No further approval required** - you have the machinery, safety net, and green light.

---

## Next Actions

### Immediate (Next 5 min)
```bash
cd ~/TAGS/ecosystem/DevOnboarder

# Pull first batch
gh issue list --state open --limit 20 --json number,title,createdAt \
  --jq '.[] | "\(.number)\t\(.title)\t\(.createdAt)"' | sort -k3
```

### Execute (60 min sprint)
- Follow `BACKLOG_AMNESTY_1HR_SPRINT.md`
- Target: 20-30 items closed or labeled
- Use `BACKLOG_AMNESTY_DECISION_TREE.md` for decisions
- Use `BACKLOG_AMNESTY_QUICKSTART.md` for commands

### Report (After sprint)
- Before/after counts
- Close reason breakdown (superseded/obsolete/kept/rewritten)
- Any patterns that needed clarification

---

## Groundwork Complete - Execute Now

**Philosophy time is over. Execution time begins.**

You have:
- ✅ v3 complete and locked
- ✅ v4 CI debt catalogued
- ✅ Decision tree (30-second filter)
- ✅ Executable commands (quickstart)
- ✅ Full policy (playbook)
- ✅ Sprint plan (1-hour mechanical execution)
- ✅ Authorization (this memo)

**There is nothing left to build. Run the filter and let dead tickets die.**

---

## Version History

- **2025-12-03**: Green light memo issued (v3 complete, v4 catalogued, execution authorized)
