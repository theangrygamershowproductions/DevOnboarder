---
title: "DevOnboarder Backlog Amnesty - 1-Hour Sprint Plan"
description: "Mechanical execution plan to clear 20-30 old tickets in focused 60-min block"
author: "TAGS Engineering"
created_at: "2025-12-03"
updated_at: "2025-12-03"
status: "active"
visibility: "internal"
tags:
  - backlog-cleanup
  - sprint
  - execution
codex_scope: "DevOnboarder"
codex_role: "CTO"
codex_type: "runbook"
---

# DevOnboarder Backlog Amnesty - 1-Hour Sprint

**Purpose**: Clear 20-30 old Issues/PRs in one focused 60-minute block using mechanical execution.

**Rule**: 30-second decision per item. No overthinking. Trust the filter.

---

## Pre-Sprint Setup (5 min)

### 1. Set Working Directory
```bash
cd ~/TAGS/ecosystem/DevOnboarder
```

### 2. Create Tracking File
```bash
cat > /tmp/amnesty_batch_$(date +%Y%m%d_%H%M).txt << 'EOF'
# DevOnboarder Backlog Amnesty Batch
# Date: $(date)
# Target: 20-30 items in 60 min

## Before Counts
# Open Issues: 
# Open PRs:

## Decisions
# Format: NUMBER | TITLE | DECISION | REASON

## After Counts
# Closed: 
# Kept: 
# Rewritten:
EOF
```

### 3. Record Before Counts
```bash
echo "Open Issues: $(gh issue list --state open --json number --jq 'length')"
echo "Open PRs: $(gh pr list --state open --json number --jq 'length')"
```

---

## Sprint Execution (50 min)

### Phase 1: Issues Batch (25 min - Target 12-15 closures)

#### Pull Target Issues
```bash
gh issue list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --limit 20 \
  --json number,title,createdAt,url \
  --jq '.[] | "\(.number)\t\(.title)\t\(.createdAt)"' \
  | sort -k3 > /tmp/issues_batch.txt

cat /tmp/issues_batch.txt
```

#### For Each Issue: Mechanical Decision Flow

**30-Second Filter**:
1. Read title
2. Check: Maps to CI_DEBT A-E? (Terminal, Checks, YAML, Docs, SonarCloud)
3. Check: Maps to Core-4 v3/v4?
4. Decide: KEEP, CLOSE (superseded), CLOSE (obsolete), or REWRITE

**Quick Close Commands** (copy/paste ready):

**Pattern A: CI Debt Superseded**
```bash
# Example: "Add markdownlint" → Category D
ISSUE=XXX
CATEGORY="D: Documentation Lint"

gh issue comment $ISSUE --body "**Closing under Backlog Amnesty.**

This intent is now tracked in our v4 CI debt plan:
- **Category $CATEGORY** in \`CI_DEBT_DEVONBOARDER.md\`
- Future work will be executed via v4 epic instead of this legacy ticket."

gh issue edit $ISSUE --add-label "backlog-amnesty,v4-scope" --state closed
```

**Pattern B: Obsolete/No Mapping**
```bash
# Example: old experiment, pre-v3 stack
ISSUE=XXX

gh issue comment $ISSUE --body "**Closing under Backlog Amnesty.**

This ticket no longer matches current DevOnboarder v3/v4 architecture.
If this need resurfaces, it will be captured as fresh issue in the new model."

gh issue edit $ISSUE --add-label "backlog-amnesty" --state closed
```

**Pattern C: Keep (Quick Label)**
```bash
# Example: terminal emoji policy → Category A
ISSUE=XXX
CATEGORY="A"

gh issue edit $ISSUE --add-label "v4-scope,category-$CATEGORY"
```

**Common Mappings (Quick Reference)**:
- Terminal output, emoji, formatting → **Category A** (HIGH)
- Path filters, required checks → **Category B** (MEDIUM)
- YAML validation, workflow lint → **Category C** (MEDIUM)
- Markdown, docs, markdownlint → **Category D** (LOW)
- SonarCloud, quality gate → **Category E** (LOW)
- Actions policy, SHA pinning → **v3 work** (KEEP)
- Old experiment, pre-v3 stack → **Obsolete** (CLOSE)

---

### Phase 2: PRs Batch (25 min - Target 8-12 closures)

#### Pull Target PRs
```bash
gh pr list \
  --repo theangrygamershowproductions/DevOnboarder \
  --state open \
  --limit 15 \
  --json number,title,createdAt,headRefName,url \
  --jq '.[] | "\(.number)\t\(.headRefName)\t\(.title)\t\(.createdAt)"' \
  | sort -k4 > /tmp/prs_batch.txt

cat /tmp/prs_batch.txt
```

#### For Each PR: Same Filter

**Quick Close Commands**:

**Pattern A: PR Intent Now in CI Debt**
```bash
PR=XXX
CATEGORY="C: YAML Validation"

gh pr comment $PR --body "**Closing under Backlog Amnesty.**

This PR's intent is now covered by v4 CI debt:
- **Category $CATEGORY** in \`CI_DEBT_DEVONBOARDER.md\`

If implementation is still needed, it will be done via v4 epic with updated scope."

gh pr edit $PR --add-label "backlog-amnesty,v4-scope" --state closed
```

**Pattern B: Abandoned/Obsolete PR**
```bash
PR=XXX

gh pr comment $PR --body "**Closing under Backlog Amnesty.**

This PR is from pre-v3 architecture and is no longer aligned with current stack.
Branch will be deleted after 30 days if no objection."

gh pr edit $PR --add-label "backlog-amnesty" --state closed
```

**Pattern C: Has Real Value Not Yet Captured**
```bash
# Create Issue first, then close PR as superseded
gh issue create --title "[Clean title]" --body "[Body]" --label "v4-scope"
# Returns NEW_ISSUE number

PR=XXX
NEW_ISSUE=YYYY

gh pr comment $PR --body "**Closing under Backlog Amnesty (superseded).**

This PR's work has been captured in Issue #$NEW_ISSUE with v4 context.
Implementation will be done fresh when v4 epic is activated."

gh pr edit $PR --add-label "backlog-amnesty,superseded" --state closed
```

---

## Post-Sprint Cleanup (5 min)

### 1. Record After Counts
```bash
echo "=== After Amnesty ==="
echo "Closed with backlog-amnesty: $(gh issue list --state closed --label backlog-amnesty --json number --jq 'length')"
echo "Still open: $(gh issue list --state open --json number --jq 'length')"
echo "PRs closed: $(gh pr list --state closed --label backlog-amnesty --json number --jq 'length')"
echo "PRs still open: $(gh pr list --state open --json number --jq 'length')"
```

### 2. Verify Labels Applied
```bash
# Check backlog-amnesty label exists and is applied
gh label list --search "backlog-amnesty"

# If missing, create it
gh label create "backlog-amnesty" \
  --description "Closed during v3/v4 backlog cleanup" \
  --color "cccccc"
```

### 3. Quick Sanity Check
```bash
# Spot-check: any v4-scope items that should be in Projects?
gh issue list --label "v4-scope" --state open --limit 10

# Spot-check: did we accidentally close something critical?
gh issue list --label "backlog-amnesty" --state closed --limit 10
```

---

## Decision Patterns (Cheat Sheet)

### CLOSE: Superseded by CI Debt

**Indicators**:
- Title mentions: CI, workflow, lint, validation, quality, docs, terminal
- Pre-dates v3 completion (before Oct 2025)
- Intent clearly matches Categories A-E

**Mapping**:
- "Terminal output" → A
- "Path filters" → B  
- "YAML lint" → C
- "Markdownlint" → D
- "SonarCloud" → E

**Action**: Close with "superseded by Category X" comment + `backlog-amnesty,v4-scope` labels

### CLOSE: Obsolete Architecture

**Indicators**:
- References old stack/environment
- Experiment that was abandoned
- Pre-governance assumptions
- Would require archaeology to understand

**Action**: Close with "obsolete architecture" comment + `backlog-amnesty` label

### KEEP: Maps to Current Work

**Indicators**:
- Recent (< 60 days)
- Clearly maps to v4 category
- Referenced in v3/v4 completion docs
- Core-4 obligation (actions policy, governance)

**Action**: Add `v4-scope,category-X` labels, leave open

### REWRITE: Good Idea, Bad Artifact

**Indicators**:
- Core concept still valid
- Context/wording is stale
- You'd recreate this if closed

**Action**: Create fresh Issue, close old as superseded

---

## Time Budgets (Strict)

**Per Item Average**: 2-3 minutes
- Read/understand: 30 sec
- Decide: 30 sec
- Execute command: 1-2 min
- Move to next: immediate

**Batch Targets**:
- **25 min** → 10-12 items (Issues)
- **25 min** → 8-10 items (PRs)
- **Total**: 18-22 items closed in 50 min + 10 min overhead = **60 min**

**Don't overthink**:
- If you hit 30 seconds and still unsure → CLOSE (you can reopen if wrong)
- If you spend > 3 min on one item → SKIP, move to next

---

## Success Criteria

**Sprint complete when**:
- [ ] 20-30 items processed (closed or kept with labels)
- [ ] All closed items have comment explaining why
- [ ] All closed items have `backlog-amnesty` label
- [ ] All kept items have `v4-scope` or category label
- [ ] Before/after counts recorded
- [ ] No items left in "limbo" (unclear status)

**Outcome**:
- Backlog reduced by 15-25%
- Remaining items clearly map to v3/v4 work
- Clean audit trail for all decisions

---

## Example Sprint Run (Simulated)

### Issues Processed (14 items, 25 min)

```
123 | "Improve CI speed" | CLOSE | Vague → Category C
124 | "Add markdownlint" | CLOSE | Category D
125 | "Terminal emoji violations" | KEEP | Category A (HIGH)
126 | "Actions policy migration" | KEEP | v3 work
127 | "Old test framework" | CLOSE | Obsolete
128 | "YAML lint errors" | CLOSE | Category C
129 | "Path filter issue" | KEEP | Category B
130 | "SonarCloud failing" | CLOSE | Category E
131 | "Pre-v3 automation" | CLOSE | Obsolete
132 | "Governance playbook" | KEEP | Core-4
133 | "Random experiment" | CLOSE | Obsolete
134 | "Docs lint setup" | CLOSE | Category D
135 | "Required checks" | KEEP | Category B
136 | "Old CI stack" | CLOSE | Obsolete
```

**Results**: 9 closed, 5 kept, 25 min

### PRs Processed (10 items, 25 min)

```
234 | feat/old-ci | CLOSE | Pre-v3
235 | fix/terminal | KEEP | Category A
236 | feat/yaml-lint | CLOSE | Category C
237 | docs/setup | CLOSE | Obsolete
238 | fix/sonar | CLOSE | Category E
239 | feat/actions | KEEP | v3 work
240 | experiment/new | CLOSE | Abandoned
241 | fix/paths | REWRITE | Create #1902, close
242 | chore/old | CLOSE | Obsolete
243 | feat/docs | CLOSE | Category D
```

**Results**: 7 closed, 2 kept, 1 rewritten, 25 min

**Total Sprint**: 16 closed, 7 kept, 1 rewritten = 24 items in 50 min

---

## Troubleshooting

**Problem**: "I'm spending too long deciding"
**Solution**: Set 2-min timer per item. When timer expires, default to CLOSE if can't map to v4.

**Problem**: "I'm worried I'll close something important"
**Solution**: You have safety net - GitHub never deletes, you can reopen. v4 debt is catalogued.

**Problem**: "I hit an item that needs more research"
**Solution**: SKIP and move to next. Come back to complex items in separate session.

**Problem**: "I closed something I shouldn't have"
**Solution**: Reopen immediately, add comment, apply correct label. Update this playbook with pattern.

---

## After First Sprint

**Review questions**:
1. How many items did you process? (Target: 20-30)
2. What was average time per item? (Target: 2-3 min)
3. Any patterns you missed in decision tree?
4. Any commands that need to be in cheat sheet?

**Next sprint**:
- Increase batch size if comfortable (30-40 items)
- Target older items (created:<2024-06-01)
- Tackle PRs with code changes (may need longer review)

---

## References

- **BACKLOG_AMNESTY_DECISION_TREE.md**: 30-second decision filter
- **BACKLOG_AMNESTY_QUICKSTART.md**: Command templates
- **CI_DEBT_DEVONBOARDER.md**: Category A-E definitions (mapping authority)

---

## Version History

- **2025-12-03**: Initial 1-hour sprint plan created (mechanical execution, no overthinking)
