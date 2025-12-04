---
title: "Backlog Amnesty Quick Start - DevOnboarder"
description: "Executable commands and 3-question filter for immediate backlog cleanup"
author: "TAGS Engineering"
created_at: "2025-12-03"
updated_at: "2025-12-03"
status: "active"
visibility: "internal"
tags:
  - backlog-cleanup
  - quickstart
  - executable
codex_scope: "DevOnboarder"
codex_role: "CTO"
codex_type: "runbook"
---

# Backlog Amnesty Quick Start

**Purpose**: Turn `BACKLOG_AMNESTY_PLAYBOOK.md` into executable commands for immediate cleanup.

**Approach**: Pull batches of 10-20 items, run 3-question filter, apply standard templates.

---

## TL;DR: The 3 Questions

For each old Issue/PR:

1. **Does it map to v3/v4 work?** (CI debt A-E, core-instructions v3, TAGS roadmap)
   - YES → KEEP or REWRITE
   - NO → Question 2

2. **Is it stale + drifted?** (> 6-9 months, pre-v3 assumptions, old stack)
   - YES → CLOSE (candidate)
   - NO → Question 3

3. **Would I recreate this if I closed it?** (core idea still valid)
   - YES → REWRITE (new Issue, close old)
   - NO → CLOSE

---

## Step 1: Pull Your Amnesty Batch

### Issues from Old Backlog

```bash
# Pull 20 oldest open issues
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --limit 20 \
  --json number,title,createdAt,labels,url \
  --jq '.[] | "\(.number)\t\(.title)\t\(.createdAt)\t\(.url)"' \
  | sort -k3
```

**What this does**: Lists issues by age (oldest first) with number, title, date, URL.

### PRs from Old Backlog

```bash
# Pull 20 oldest open PRs
gh pr list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --limit 20 \
  --json number,title,createdAt,labels,url \
  --jq '.[] | "\(.number)\t\(.title)\t\(.createdAt)\t\(.url)"' \
  | sort -k3
```

### Filter by Specific Project (Optional)

```bash
# Issues in specific old project
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --search "project:\"Old Project Name\"" \
  --state open \
  --limit 20 \
  --json number,title,createdAt,url
```

---

## Step 2: Run the 3-Question Filter

**For each item in your batch**, ask:

### Question 1: v3/v4 Mapping Check

**Does this map to current work?**

Check against:
- **v4 CI Debt**: Categories A-E in `CI_DEBT_DEVONBOARDER.md`
  - A: Terminal Policy (HIGH)
  - B: Required Checks vs Path Filters (MEDIUM)
  - C: YAML Validation (MEDIUM)
  - D: Documentation Lint (LOW)
  - E: SonarCloud Quality Gate (LOW)
- **v3 Complete Work**: Actions policy (PR #1893), governance playbooks
- **Core-4 Roadmap**: core-instructions v3, TAGS ecosystem infrastructure

**Decision**:
- Maps clearly → **KEEP** (or REWRITE if wording stale)
- Doesn't map → Go to Question 2

### Question 2: Age + Drift Check

**Is it old and obsolete?**

Red flags:
- Open > 6-9 months
- References pre-v3 concepts (old CI stack, pre-governance, deprecated tools)
- Talks about infrastructure you've replaced
- Would require "archaeology" to understand original intent

**Decision**:
- Old + drifted → **CLOSE** (candidate)
- Still relevant → Go to Question 3

### Question 3: Recreate Test

**If I close this, will I immediately recreate it?**

Ask yourself:
- Is the core idea still valid in v4?
- Would I just open a new Issue with cleaner wording?
- Am I keeping it "just in case" (not a good reason)?

**Decision**:
- Would recreate → **REWRITE** (new Issue, close old with reference)
- Would not recreate → **CLOSE**

---

## Step 3: Apply Standard Templates

### Template 1: Superseded by v4 Epic

**Use when**: Issue intent is now in CI_DEBT_DEVONBOARDER.md Categories A-E

```markdown
**Closing under Backlog Amnesty.**

This Issue/PR is now covered by our v4 CI debt plan:
- **Category [A/B/C/D/E]**: [Name] (Priority: [HIGH/MEDIUM/LOW])
- **Documentation**: `CI_DEBT_DEVONBOARDER.md`
- **Tracking**: Projects 4 & 6

The v4 epic provides better scoping and prioritization. No unique value lost by closing this older artifact.
```

**Apply label**: `backlog-amnesty`, `v4-scope`

**Command**:
```bash
gh issue close [NUMBER] \
  --comment "**Closing under Backlog Amnesty.**

This Issue is now covered by our v4 CI debt plan:
- **Category C**: YAML Validation (Priority: MEDIUM)
- **Documentation**: \`CI_DEBT_DEVONBOARDER.md\`
- **Tracking**: Projects 4 & 6

The v4 epic provides better scoping and prioritization." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit [NUMBER] \
  --add-label "backlog-amnesty,v4-scope" \
  --repo theangrygamershowproductions/DevOnboarder
```

### Template 2: Obsolete Architecture

**Use when**: References pre-v3 stack, deprecated environments, old automation

```markdown
**Closing under Backlog Amnesty.**

This was written for an older DevOnboarder/TAGS architecture that no longer exists in the current v3/v4 design.

Original context: [Brief 1-line summary of what it referenced]

If we need this behavior in the new stack, it will be reintroduced via a fresh issue aligned to current repos and workflows.
```

**Apply label**: `backlog-amnesty`, `obsolete-architecture`

**Command**:
```bash
gh issue close [NUMBER] \
  --comment "**Closing under Backlog Amnesty.**

This was written for an older DevOnboarder/TAGS architecture that no longer exists in the current v3/v4 design.

If we need this behavior in the new stack, it will be reintroduced via a fresh issue." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit [NUMBER] \
  --add-label "backlog-amnesty,obsolete-architecture" \
  --repo theangrygamershowproductions/DevOnboarder
```

### Template 3: Rewrite with Fresh Issue

**Use when**: Core idea valid, but context/wording anchored in old world

**Process**:
1. Create new Issue with 2025 framing
2. Close old Issue with reference to new

```markdown
**Closing - core intent captured in newer Issue #[NEW_ID].**

Original concept still valid, but context/wording anchored in [old world].

Created fresh Issue with current v3/v4 framing:
- **New Issue**: #[NEW_ID] - [Brief title]
- **What changed**: [1-2 line reframing summary]

Part of v3/v4 backlog amnesty.
```

**Apply label**: `backlog-amnesty`, `superseded`

**Commands**:
```bash
# Step 1: Create new issue
gh issue create \
  --repo theangrygamershowproductions/DevOnboarder \
  --title "[Fresh title matching v4 context]" \
  --body "[Body with current v3/v4 framing]" \
  --label "v4-scope"

# Step 2: Close old issue (use NEW_ID from step 1)
gh issue close [OLD_NUMBER] \
  --comment "**Closing - core intent captured in newer Issue #[NEW_ID].**

Created fresh Issue with current v3/v4 framing." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit [OLD_NUMBER] \
  --add-label "backlog-amnesty,superseded" \
  --repo theangrygamershowproductions/DevOnboarder
```

### Template 4: Generic Amnesty

**Use when**: Doesn't fit other categories, just doesn't map to current work

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

No unique value lost by closing.
```

**Apply label**: `backlog-amnesty`

**Command**:
```bash
gh issue close [NUMBER] \
  --comment "**Closing as part of v3/v4 backlog amnesty.**

This Issue does not map to v3 commitments or v4 CI debt Categories A-E.

v3/v4 work is fully catalogued in \`CI_DEBT_DEVONBOARDER.md\` and Projects 4 & 6." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit [NUMBER] \
  --add-label "backlog-amnesty" \
  --repo theangrygamershowproductions/DevOnboarder
```

---

## Step 4: Track Your Progress

### Before Starting

```bash
# Total open issues
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --json number \
  --jq 'length'

# Total open PRs
gh pr list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --json number \
  --jq 'length'

# Issues with no activity in 6+ months
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --json number,updatedAt \
  --jq '[.[] | select(.updatedAt | fromdateiso8601 < (now - (180 * 86400)))] | length'
```

### After Each Batch

```bash
# Count amnesty closes
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state closed \
  --label "backlog-amnesty" \
  --json number \
  --jq 'length'

# Breakdown by close reason
echo "Superseded by v4 epic:"
gh issue list --state closed --label "backlog-amnesty,v4-scope" --json number --jq 'length'

echo "Obsolete architecture:"
gh issue list --state closed --label "backlog-amnesty,obsolete-architecture" --json number --jq 'length'

echo "Rewritten:"
gh issue list --state closed --label "backlog-amnesty,superseded" --json number --jq 'length'
```

---

## Quick Reference: What to KEEP vs CLOSE

### ✅ KEEP (Do NOT close)

- **v4 CI Debt**: Anything clearly mapping to Categories A-E
- **Core-4 Work**: Actions policy, governance, QA framework
- **Recent + Valid**: < 60 days old, fits current architecture
- **Active Discussion**: Has recent comments, still being worked

### ❌ CLOSE (Safe to kill)

- **No v3/v4 Mapping**: Doesn't fit current roadmap
- **Old + Drifted**: > 6-9 months, references pre-v3 concepts
- **Duplicates v4 Epic**: Intent captured in CI_DEBT_DEVONBOARDER.md
- **Obsolete Infrastructure**: References replaced/deprecated stack
- **Keeping "Just in Case"**: No concrete reason to keep

### 🔄 REWRITE (Create fresh, close old)

- **Core Idea Valid**: Still relevant to v4
- **Context Stale**: Wording/framing anchored in old world
- **Would Recreate**: If closed, you'd immediately open new Issue

---

## Sample Execution (First Batch)

### Pull 10 oldest issues

```bash
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --limit 10 \
  --json number,title,createdAt,url \
  --jq '.[] | "\(.number)\t\(.title)\t\(.createdAt)"' \
  | sort -k3
```

### For each issue, quick decision

**Example outputs**:

```
123    "Improve CI speed"                      2024-03-15
456    "Add markdownlint to CI"               2024-08-01
789    "Migrate to Actions Policy"            2024-10-15
234    "Experiment with new test framework"   2024-04-20
567    "Fix terminal emoji policy"            2024-11-01
```

**Quick verdicts**:

- #123: "Improve CI speed" → **CLOSE** (vague, now Category C: YAML Validation)
- #456: "Add markdownlint" → **CLOSE** (now Category D: Documentation Lint)
- #789: "Migrate to Actions Policy" → **KEEP** (maps to v3 work, still relevant)
- #234: "Experiment with new test framework" → **CLOSE** (abandoned, stack replaced)
- #567: "Fix terminal emoji policy" → **KEEP** (Category A: Terminal Policy - HIGH)

**Execute closes**:

```bash
# Close #123
gh issue close 123 \
  --comment "**Closing under Backlog Amnesty.**
This is now covered by Category C: YAML Validation in \`CI_DEBT_DEVONBOARDER.md\`." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit 123 --add-label "backlog-amnesty,v4-scope"

# Close #456
gh issue close 456 \
  --comment "**Closing under Backlog Amnesty.**
This is now covered by Category D: Documentation Lint in \`CI_DEBT_DEVONBOARDER.md\`." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit 456 --add-label "backlog-amnesty,v4-scope"

# Close #234
gh issue close 234 \
  --comment "**Closing under Backlog Amnesty.**
This experiment was for an older architecture. Current test infrastructure is established in v3." \
  --repo theangrygamershowproductions/DevOnboarder

gh issue edit 234 --add-label "backlog-amnesty,obsolete-architecture"
```

**Result**: 3 closed, 2 kept, 10 min total time.

---

## Emergency Rollback

**If you close something you shouldn't have**:

```bash
# Reopen issue
gh issue reopen [NUMBER] \
  --repo theangrygamershowproductions/DevOnboarder

# Add comment explaining
gh issue comment [NUMBER] \
  --body "Reopened - premature close, still maps to [v4 epic/roadmap item]." \
  --repo theangrygamershowproductions/DevOnboarder

# Remove backlog-amnesty label
gh issue edit [NUMBER] \
  --remove-label "backlog-amnesty" \
  --repo theangrygamershowproductions/DevOnboarder

# Add correct v4 label
gh issue edit [NUMBER] \
  --add-label "v4-scope,category-A" \
  --repo theangrygamershowproductions/DevOnboarder
```

**Key safety**: GitHub never truly deletes Issues/PRs - all closures are reversible.

---

## Batch Size Recommendations

**First pass**: 10-20 items
- Get comfortable with 3-question filter
- Validate templates work as expected
- Estimate time per item (typically 1-3 min)

**Subsequent passes**: 20-40 items
- Faster with practice
- Pattern recognition improves
- Can parallelize across multiple terminals if needed

**Don't try to do everything in one session**:
- Cognitive load increases with batch size
- Better to do 3-4 focused 30-min sessions than one 3-hour marathon
- Track progress between sessions (counts above)

---

## Success Criteria

**Batch complete when**:
- [ ] All items in batch have verdict (KEEP/REWRITE/CLOSE)
- [ ] All CLOSE items have standard template comment
- [ ] All CLOSE items have `backlog-amnesty` label (+ category label)
- [ ] All REWRITE items have fresh Issue created + old closed with reference
- [ ] Progress tracked (before/after counts)

**Amnesty campaign complete when**:
- [ ] No items remain in "limbo" (unclear status)
- [ ] All remaining open Issues/PRs map to v3/v4 plan
- [ ] Backlog accurately reflects current work (no archaeology required)

---

## References

- **BACKLOG_AMNESTY_PLAYBOOK.md**: Full policy and rationale
- **CI_DEBT_DEVONBOARDER.md**: v4 CI debt Categories A-E (mapping authority)
- **DEVONBOARDER_V3_COMPLETION_SUMMARY.md**: v3 achievements (what's done)

---

## Version History

- **2025-12-03**: Initial quick start created (executable commands, 3-question filter)
