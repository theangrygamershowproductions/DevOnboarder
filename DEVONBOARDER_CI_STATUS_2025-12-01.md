# DevOnboarder CI Status - 2025-12-01

## Actions Policy Enforcement - Violations Report

**PR**: #1888 (feat/add-actions-policy-enforcement)  
**Workflow Run**: 19832709346  
**Status**: ❌ FAILED (expected - violations present)  
**Timestamp**: 2025-12-01T18:08:49Z  

---

### Executive Summary

DevOnboarder actions migration is **a finite, bounded problem** with exactly **2 violation categories** affecting **14 workflow files**.

**Violation Categories**:
1. **Banned Actions**: 4 distinct third-party actions (14 total occurrences)
2. **Non-Allowlisted Owners**: 2 owner namespaces outside `actions/*` and `docker/*`

**Tag-Based References**: ✅ NONE FOUND (DevOnboarder already uses SHA pinning)

---

## Violation Category 1: Banned Actions

### Summary
- **4 distinct banned actions**
- **14 total occurrences across workflows**
- **Replacement strategies**: Documented in `tags-qa-framework/docs/ACTIONS_REPLACEMENT_MATRIX.md`

### Detailed Breakdown

#### 1. `DavidAnson/markdownlint-cli2-action` (1 occurrence)

**Affected Files**:
- `.github/workflows/markdownlint.yml`

**Replacement Strategy** (from ACTIONS_REPLACEMENT_MATRIX.md):
```yaml
# Replace with:
- uses: actions/setup-node@<sha>  # v4.1.0
- run: npm install -g markdownlint-cli2
- run: markdownlint-cli2 "**/*.md" --config .markdownlint.json
```

**QA Validation**:
- Verify `.markdownlint.json` config exists
- Test locally: `npx markdownlint-cli2 "**/*.md"`
- Confirm same rule enforcement as action version

---

#### 2. `dorny/paths-filter` (1 occurrence)

**Affected Files**:
- `.github/workflows/ci.yml`

**Replacement Strategy** (from ACTIONS_REPLACEMENT_MATRIX.md):

**Option A - GitHub Script** (recommended for simple path checks):
```yaml
- uses: actions/github-script@<sha>  # v7.0.1
  id: filter
  with:
    script: |
      const { data: files } = await github.rest.pulls.listFiles({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: context.payload.pull_request.number
      });
      const srcChanged = files.some(f => f.filename.startsWith('src/'));
      const testChanged = files.some(f => f.filename.startsWith('tests/'));
      return { src: srcChanged, tests: testChanged };
```

**Option B - Git Diff** (for base branch comparison):
```yaml
- run: |
    git fetch origin ${{ github.base_ref }}
    SRC_CHANGED=$(git diff --name-only origin/${{ github.base_ref }}...HEAD | grep '^src/' || echo '')
    echo "src_changed=$([ -n "$SRC_CHANGED" ] && echo true || echo false)" >> $GITHUB_OUTPUT
```

**QA Validation**:
- Test with PR containing path changes
- Verify filter outputs match expected paths
- Confirm downstream jobs trigger correctly

---

#### 3. `ibiqlik/action-yamllint` (11 occurrences) ⚠️ **Highest impact**

**Affected Files**:
- `.github/workflows/ci-health.yml`
- `.github/workflows/validate-permissions.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/close-codex-issues.yml`
- `.github/workflows/security-audit.yml`
- `.github/workflows/notify.yml`
- `.github/workflows/env-doc-alignment.yml`
- `.github/workflows/secrets-alignment.yml`
- `.github/workflows/auto-fix.yml`
- `.github/workflows/cleanup-ci-failure.yml`
- `.github/workflows/ci-monitor.yml`

**Replacement Strategy** (from ACTIONS_REPLACEMENT_MATRIX.md):
```yaml
# Replace with:
- uses: actions/setup-python@<sha>  # v5.3.0
  with:
    python-version: '3.12'
- run: pip install yamllint
- run: yamllint -c .yamllint .github/workflows/
```

**QA Validation**:
- Verify `.yamllint` config exists (or create with same rules as action)
- Test locally: `yamllint -c .yamllint .github/workflows/`
- Compare output format with action version
- Ensure CI fails on same violations

**Migration Notes**:
- **11 files affected** - consider scripted replacement
- Ensure consistent Python version across all workflows (recommend: 3.12)
- Validate `.yamllint` config covers all rules from action

---

#### 4. `peter-evans/create-pull-request` (1 occurrence)

**Affected Files**:
- `.github/workflows/auto-fix.yml`

**Replacement Strategy** (from ACTIONS_REPLACEMENT_MATRIX.md):

**Option A - GitHub Script** (recommended for simple PR creation):
```yaml
- uses: actions/github-script@<sha>  # v7.0.1
  with:
    script: |
      const { data: pr } = await github.rest.pulls.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: 'Automated fix',
        head: 'auto-fix-branch',
        base: 'main',
        body: 'Automated fixes applied'
      });
      console.log(`Created PR #${pr.number}`);
```

**Option B - GitHub CLI** (for complex PR operations):
```yaml
- run: |
    gh pr create \
      --title "Automated fix" \
      --body "Automated fixes applied" \
      --base main \
      --head auto-fix-branch
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**QA Validation**:
- Test PR creation with actual changes
- Verify title, body, base/head branches correct
- Confirm labels, reviewers, assignees if used
- Check PR URL captured in workflow output

---

## Violation Category 2: Non-Allowlisted Owners

### Summary
- **2 owner namespaces violating allowlist**
- **Allowlist**: `actions/*`, `docker/*` only
- **Violations detected in banned actions above**

### Detailed Breakdown

#### 1. `dorny/*` (dorny/paths-filter)
- **File**: `.github/workflows/ci.yml`
- **Action**: `dorny/paths-filter`
- **Resolution**: Replace with `actions/github-script` (see Category 1, Item 2)

#### 2. `peter-evans/*` (peter-evans/create-pull-request)
- **File**: `.github/workflows/auto-fix.yml`
- **Action**: `peter-evans/create-pull-request`
- **Resolution**: Replace with `actions/github-script` or gh CLI (see Category 1, Item 4)

**Note**: Non-allowlisted owner violations are **inherently resolved** by replacing banned actions. No additional work required beyond Category 1 replacements.

---

## Violation Category 3: Tag-Based References

### Status: ✅ **NO VIOLATIONS**

**Verification**:
```bash
# Checked for any tag-based action references
grep -rhE "uses:\s+[^@]+@v[0-9]" .github/workflows/
# Result: No matches
```

**Conclusion**: DevOnboarder workflows already use **full 40-character SHA pinning** for all action references. No migration work required for this category.

**CI Detection**: The enforcement workflow detected _potential_ for tag violations but found none in practice. This is a **false positive detection** (the check ran, found nothing, but still logged the error message format).

---

## Migration Checklist

**Total Work**: 4 distinct replacements across 14 files

### Phase 1: Replace Banned Actions (4 tasks)

- [ ] **Task 1.1**: Replace `DavidAnson/markdownlint-cli2-action` (1 file)
  - File: `.github/workflows/markdownlint.yml`
  - Strategy: setup-node + npm install + script
  - Time estimate: 15 min

- [ ] **Task 1.2**: Replace `dorny/paths-filter` (1 file)
  - File: `.github/workflows/ci.yml`
  - Strategy: github-script OR git diff
  - Time estimate: 30 min (requires understanding CI logic)

- [ ] **Task 1.3**: Replace `ibiqlik/action-yamllint` (11 files) ⚠️
  - Files: ci-health.yml, validate-permissions.yml, ci.yml, close-codex-issues.yml, security-audit.yml, notify.yml, env-doc-alignment.yml, secrets-alignment.yml, auto-fix.yml, cleanup-ci-failure.yml, ci-monitor.yml
  - Strategy: setup-python + pip install + script
  - Time estimate: 2-3h (11 files, verify .yamllint config, test thoroughly)

- [ ] **Task 1.4**: Replace `peter-evans/create-pull-request` (1 file)
  - File: `.github/workflows/auto-fix.yml`
  - Strategy: github-script OR gh CLI
  - Time estimate: 30 min

### Phase 2: Validate Replacements

- [ ] **Task 2.1**: Run CI locally (act or manual testing)
  - Verify markdownlint, yamllint, paths-filter, PR creation all work
  - Confirm same behavior as original actions

- [ ] **Task 2.2**: Push to PR branch, verify CI green
  - Run `actions-policy-enforcement` workflow
  - Confirm 0 violations detected

- [ ] **Task 2.3**: Merge PR #1888
  - Actions policy enforcement now active in DevOnboarder

### Phase 3: Document Edge Cases

- [ ] **Task 3.1**: Update Issue #294 with migration notes
  - Any surprises during replacement
  - Performance differences observed
  - Future maintenance considerations

---

## Time Estimates

**Optimistic**: 4 hours (smooth replacements, no issues)  
**Realistic**: 6 hours (some troubleshooting, testing iterations)  
**Pessimistic**: 8 hours (complex CI interactions, extensive debugging)

**Critical Path**: Task 1.3 (ibiqlik yamllint - 11 files) is 50%+ of total work.

---

## Success Criteria

**PR #1888 merge requirements**:
1. ✅ All 4 banned actions replaced with approved alternatives
2. ✅ All non-allowlisted owners removed (implicit via #1)
3. ✅ `actions-policy-enforcement` workflow passes (exit code 0)
4. ✅ Existing CI workflows still function correctly
5. ✅ No functional regressions in linting, path filtering, or PR automation

**v3 Completion Gate**:
- DevOnboarder CI green (all workflows pass)
- Actions policy enforcement active and passing
- No outstanding violations in Core-4 repositories

---

## Reference Documentation

- **Actions Policy**: `TAGS-META/ACTIONS_POLICY.md`
- **Replacement Matrix**: `tags-qa-framework/docs/ACTIONS_REPLACEMENT_MATRIX.md`
- **Copilot Enforcement**: `tags-qa-framework/docs/COPILOT_INLINE_ENFORCEMENT.md`
- **Agent Output Policy**: `tags-qa-framework/docs/AGENT_OUTPUT_ENFORCEMENT.md`
- **Implementation Status**: `TAGS-META/GOVERNANCE_IMPLEMENTATION_STATUS.md`

---

## Appendix: Full CI Log

**Location**: `/tmp/devon_actions_enforcement.log`  
**Workflow Run**: https://github.com/theangrygamershowproductions/DevOnboarder/actions/runs/19832709346

**Key Log Excerpts**:

```
❌ ERROR: Banned action detected:
  Action: DavidAnson/markdownlint-cli2-action
  File: .github/workflows/markdownlint.yml

❌ ERROR: Banned action detected:
  Action: dorny/paths-filter
  File: .github/workflows/ci.yml

❌ ERROR: Banned action detected:
  Action: ibiqlik/action-yamllint
  Files: [11 workflow files listed in Category 1, Item 3]

❌ ERROR: Banned action detected:
  Action: peter-evans/create-pull-request
  File: .github/workflows/auto-fix.yml

❌ ERROR: Non-allowlisted owner detected: dorny
❌ ERROR: Non-allowlisted owner detected: peter-evans

Checking SHA pinning compliance...
✅ All actions are SHA-pinned (verified: no tag-based references found)

Exit code: 1 (violations present)
```

---

**Status**: This is now a **finite checklist**, not a mystery. DevOnboarder migration is bounded, concrete work.

**Next**: Execute P0 Task B (check core-instructions PR #48 CI status), then schedule P1 (DevOnboarder migration 4-8h block).
