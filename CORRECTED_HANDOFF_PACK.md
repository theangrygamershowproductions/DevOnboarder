---
similarity_group: docs-
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
updated_at: 2025-10-27
---
# DevOnboarder — Docs Validation & PR Welcome System: Corrected Handoff Pack

## 1) File Changes

| Path | Change | Purpose | Key Notes |
|------|--------|---------|-----------|
| `.github/workflows/docs-quality.yml` | add | Documentation validation CI workflow | Minimal permissions, concurrency group, triggered on *.md changes |
| `.github/workflows/pr-welcome.yml` | add | PR welcome system for forks | Uses pull_request_target, idempotent comments, fork detection |
| `.pre-commit-config.yaml` | modify | Added internal-link-validation hook | Logs to `logs/link_validation_*.log`, runs only on .md files |
| `scripts/validate_internal_links.sh` | rewrite | Core link validation with parallelization | GitHub-style anchors, metrics, 513 files in ~60s |
| `scripts/anchors_github.py` | add | GitHub-style anchor generation with duplicates | Handles -1, -2 suffixes for repeated headings |
| `scripts/safe_commit_enhanced.sh` | modify | Enhanced commit wrapper hardening | git update-index refresh, staged delta assertions |
| `docs/api/README.md` | add | API documentation structure | Priority Matrix metadata included |
| `docs/setup.md` | add | Setup guide documentation | Priority Matrix metadata included |
| `docs/checklists/agent-review-checklist.md` | add | Agent review process documentation | Priority Matrix metadata included |

**Key Infrastructure Changes:**

- **Workflows Split**: Separated docs validation (pull_request) from PR welcome (pull_request_target)
- **Parallelization**: xargs -P$(nproc) for efficient processing of 513 markdown files
- **Real Metrics**: JSON reports with actual file counts and broken link numbers

## 2) Security & Permissions (Split Systems)

### Docs Quality Workflow (docs-quality.yml)

- **Event**: `pull_request` (safe for forks)
- **Permissions**: `contents: read` only
- **Code Execution**: None from forks - only static validation
- **Secrets**: None required

### PR Welcome Workflow (pr-welcome.yml)

- **Event**: `pull_request_target` (access to secrets)
- **Fork Detection**: `${{ github.event.pull_request.head.repo.fork == true }}`
- **Untrusted Code Protection**: No checkout of fork SHA, no execution of PR code
- **Permissions**: `pull-requests: write`
- **Secrets**: `${{ secrets.WELCOME_BOT_TOKEN || github.token }}`

**Idempotency Guard**:

```bash
existing="$(gh api repos/$REPO/issues/$PR/comments?per_page=100 || true)"
if echo "$existing" | grep -q "Welcome to DevOnboarder"; then
  echo "Welcome already posted."
  exit 0
fi
```

**Rollback Toggle**: Comment lines 2-4 in `.github/workflows/pr-welcome.yml`

## 3) Validators: Design & Edge Cases

**Anchor Normalization (GitHub-compatible)**:

1. `toLowerCase()`: "Hello World"  "hello world"
2. Remove non-word chars: "Hello, World! 🎉"  "hello world "
3. Replace spaces with hyphens: "hello world "  "hello-world"
4. **Duplicates**: First occurrence = `"title"`, second = `"title-1"`, third = `"title-2"`

**Fragment Checks (#section)**:

- **Two-pass approach**: Direct text match first, then GitHub-style anchor transformation
- **Implementation**: `python3 scripts/anchors_github.py` for duplicate-aware processing
- **Fallback**: Direct grep for headers if Python script unavailable

**Known Exemptions**:

- Template directories: `/templates/`, `/.codex/templates/`, `/archive/`
- Placeholder patterns: `{{.*}}`, `^(relative/path|docs/path|path/to)`
- Large files: >2000 lines (timeout protection)

**Runtime & Complexity**:

- **513 markdown files** processed in ~60 seconds with parallelization
- **Parallelization**: `xargs -P$(nproc)` with function export
- **Error Counting**: Post-process error log line count (not shared memory)

## 4) Safe Commit Wrapper Enhancements

**Re-staging Logic Improvements**:

```bash
# Refresh index to catch mode/perm flips
git update-index --refresh >/dev/null 2>&1 || true

# Assert clean delta to avoid silent drift
if ! git diff --quiet --cached; then
    echo " Re-stage incomplete: staged delta remains." >&2
    git status --porcelain
    return 1
fi
```

**Exit Codes & Timeouts**:

- **Exit Code 124**: Specific timeout detection with enhanced messaging
- **60s timeout**: `timeout 60s git commit` prevents hanging
- **Idempotency**: Re-runnable with full diagnostic output

## 5) CI Wiring & Triggers

**Workflows**:

- **docs-quality.yml**: `pull_request` on `'**/*.md'` paths
- **pr-welcome.yml**: `pull_request_target` types `[opened, reopened]`

**Concurrency**:

```yaml
concurrency:
  group: docs-quality-${{ github.ref }}
  cancel-in-progress: true
```

**Performance**:

- **Expected Runtime**: 2-3 minutes for 513 files
- **Parallelization**: CPU core count scaling
- **No Caching**: Static analysis doesn't benefit significantly

**Action Versions**: `actions/checkout@v5` pinned

## 6) Tests & Evidence

**Local Test Commands**:

```bash
# Full validation with metrics
bash scripts/validate_internal_links.sh

# Check anchor duplicate handling
printf '# Title\n# Title\n' > /tmp/dup.md
python3 scripts/anchors_github.py < /tmp/dup.md | grep '"title-1"'

# Verify workflow separation
test -f .github/workflows/docs-quality.yml && echo " docs-quality"
test -f .github/workflows/pr-welcome.yml && echo " pr-welcome"
```

**Current Metrics Evidence**:

```json
{
  "ts": "2025-10-02T15:01:05Z",
  "files_scanned": 513,
  "broken": 14
}
```

**Reality Check**: 513 markdown files currently in repository (not 3,802 or 450)

## 7) Open Risks & TODOs

**Top 3 Risks**:

1. **Fragment False Positives**: Complex markdown with unusual heading formats
   - **Mitigation**: Two-pass validation (direct text  GitHub-style transformation)
2. **Performance Scaling**: Growth beyond 1000 files may impact CI budget
   - **Mitigation**: Parallelization, file size limits, selective path filtering
3. **GitHub Enterprise Differences**: Anchor normalization variations
   - **Mitigation**: Direct text fallback before GitHub-style processing

**Next Implementations**:

- **External Link Checker**: HEAD/GET with timeouts, domain allowlist, ≤2min budget
- **SARIF Integration**: GitHub Security tab integration for broken links
- **Quality Dashboard**: `docs/QUALITY_REPORT.md` with trend analysis

## 8) Compatibility Guard

**GH CLI Usage**:  **COMPLIANT**

- PR welcome workflow uses `gh api` commands (not `--json/--jq` flags)
- Link validator uses only git/bash/python (no gh CLI)
- All commands follow DevOnboarder terminal output policies

**Commands Used**:

```bash
gh api repos/$REPO/issues/$PR/comments?per_page=100  # Compliant
gh api repos/$REPO/issues/$PR/comments -f body="..."  # Compliant
```

---

## Quick Acceptance Results

```bash
  docs-quality workflow exists
  pr-welcome workflow exists
  minimal perms (no security-events in docs job)
  dup suffix handling works
 Current: 513 files scanned, 14 broken links (real metrics)
```

*Generated: October 2, 2025*
*Status: Documentation validation system operational with accurate metrics*
*Evidence: 513 files validated, JSON reports generated, commit d20934ed*
