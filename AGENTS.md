# DevOnboarder Agent Guidelines

## Merge Readiness Policy (MANDATORY)

**CRITICAL**: AI agents working on DevOnboarder PRs **MUST** follow this procedure before declaring any PR "ready" or "v3-complete".

### Single Source of Truth

The **ONLY** authoritative source for merge readiness is:

```bash
./scripts/merge_gate_report.sh <pr-number>
```

**Exit code 0** = MERGE READY  
**Exit code non-zero** = BLOCKED

### Required Checks for v3 Completion

All of these **MUST** be SUCCESS (no exceptions):

1. **QC Gate (Required - Basic Sanity)** - Basic quality gate
2. **Validate Actions Policy Compliance** - SHA pinning enforcement
3. **Terminal Output Policy Enforcement** - ZERO TOLERANCE for violations
4. **SonarCloud Code Analysis** - Security hotspots must be addressed

### Review Requirements

- `reviewDecision == APPROVED` (≥1 approving review)
- `unresolved_non_outdated_threads == 0` (all conversations resolved)

### Prohibited Agent Behavior

Agents **MUST NOT**:

- ❌ Say "CI is green" without running merge_gate_report.sh
- ❌ Declare "PR is merge-ready" without exit code 0 from merge gate
- ❌ Claim "v3-complete" with any BLOCKED verdict
- ❌ Treat SonarCloud or Terminal Policy as "advisory"
- ❌ Ignore failures in non-required checks without explicit justification

### Required Agent Workflow

When evaluating PR merge readiness:

1. **Run merge gate**: `./scripts/merge_gate_report.sh <pr-number>`
2. **Check exit code**:
   - Exit 0 → "PR is MERGE READY"
   - Exit non-zero → "PR is BLOCKED"
3. **Report blockers**: If blocked, list specific failures from report
4. **Fix blockers**: Address each failure before re-evaluating
5. **Never bypass**: No "looks good except..." - blocked is blocked

### SonarCloud Security Hotspots

When SonarCloud reports a security hotspot:

1. **Open the hotspot URL** (available in check details)
2. **Investigate**:
   - Real issue → Fix in this PR
   - False positive → Mark "Won't Fix" in Sonar with documented rationale
3. **Quality Gate must be green** before merge

### Terminal Output Policy (Zero Tolerance)

Violations include:

- `echo "$VAR"` → Use `printf '%s\n' "$VAR"`
- `echo "text $(cmd)"` → Split into separate commands
- Emojis in terminal output
- Non-ASCII characters

**No exceptions.** Fix all violations before merge.

### VSCode / Static Analysis

For **changed files only**:

- Error-level issues → **BLOCKED** (must fix in this PR)
- Warning-level issues → Advisory (log to backlog, don't block)

For **unchanged legacy files**:

- Issues are tech debt, not this PR's responsibility
- Track separately, don't block v3 completion

## v3 Definition of Done

A repository is **v3-complete** when:

1. All required checks GREEN on main branch
2. No open v3-blocking issues
3. Merge gate report returns exit code 0 for any new PR
4. Documentation reflects current state

**Not** when:

- ❌ "Most checks are green"
- ❌ "Only advisory checks failing"
- ❌ "Looks good to me"

---

## Systemic Failure Tracking SOP

**MANDATORY**: Any of the following **MUST** result in a GitHub Issue being opened and linked:

### Triggering Conditions

1. **A new status/decision document is created**:
   - Pattern: `docs/*STATUS*.md` or `docs/*DECISION*.md`
   - Example: `docs/PRIORITY_MATRIX_GPG_STATUS.md`

2. **A merge-gate documented exception is introduced**:
   - Any document containing the phrase "documented exception"
   - Example: `docs/SONAR_SCOPE_DECISION_PR1901.md`

3. **A bot posts a CRITICAL / MANUAL ACTION REQUIRED comment on a PR**:
   - Priority Matrix GPG signing failures
   - SonarCloud security hotspots requiring human review
   - Terminal Policy violations requiring manual fixes

### Requirements (Non-Negotiable)

1. **The document MUST contain a `Tracked in: #<issue>` reference near the top**
   - Format: `Tracked in: Issue #<number>` or `**Tracked in**: Issue #<number>`
   - Location: Within first 10 lines of document (typically in header metadata)
   - Example:
     ```markdown
     # Priority Matrix GPG Signing Status
     
     **Status**: ADVISORY (non-blocking)
     **Created**: 2025-12-04
     **Context**: PR #1901 (SHA pinning migration)
     **Tracked in**: Issue #1904
     ```

2. **The issue MUST be added to an appropriate GitHub Project**
   - v3-blocking issues → Core-4 Hardening project
   - v4 infrastructure → Org Roadmap project
   - Client-specific → Client project board

3. **The merge gate MUST treat undocumented exceptions as BLOCKERS**
   - Enforcement: `scripts/merge_gate_report.sh` validates issue references
   - If `documented exception` found but no `Tracked in: #` → **EXIT 1 (BLOCKED)**
   - No silent bypassing - gate blocks merge until issue created and linked

### Helper Script

Use `./scripts/open_system_issue.sh` to streamline this process:

```bash
./scripts/open_system_issue.sh docs/PRIORITY_MATRIX_GPG_STATUS.md \
  "INFRA: Fix Priority Matrix Bot GPG signing and migrate to BWS/MCP"
```

Then update the document with:
```markdown
**Tracked in**: Issue #<number>
```

### Enforcement

**Merge gate validation** (automatic):
- Scans all `docs/*STATUS*.md` and `docs/*DECISION*.md` files
- For each file containing "documented exception":
  - Verifies `Tracked in: #<number>` reference exists
  - If missing → **BLOCKS merge** with clear error message
- Exit code 1 prevents merge until all exceptions have tracking issues

**Process discipline**:
- "I wrote a doc" without "I opened an issue" is a **process bug**
- Documentation alone is not sufficient - tracking must be external and visible
- At this level of complexity, undocumented exceptions = invisible technical debt

### Rationale

**Why this matters**:
- Prevents "documented but forgotten" technical debt
- Ensures all systemic failures have accountability
- Makes exceptions visible in project planning
- Creates audit trail for governance compliance
- Forces honest assessment (can't hide problems in docs)

**Historical precedent**:
- Priority Matrix GPG signing was documented but had no tracking issue
- This gap was identified as a process bug, not an oversight
- SOP enforcement prevents recurrence across all future exceptions

## Enforcement

This policy is **non-negotiable**. Agents that bypass merge gate validation will:

1. Have their output rejected
2. Be required to re-run proper validation
3. Have the violation documented

## References

- Main TAGS agent guidelines: `~/TAGS/AGENTS.md`
- Merge gate report: `scripts/merge_gate_report.sh`
- Terminal Output Policy: `.github/workflows/terminal-output-policy.yml`
- Actions Policy: `ACTIONS_POLICY.md`
