---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
updated_at: 2025-10-27
---

# Post-Merge Cleanup Exit Code Troubleshooting

## Overview

The Post-Merge Cleanup workflow (`post-merge-cleanup.yml`) automates the closure of CI failure issues after successful PR merges. This document covers common exit code failures and their resolutions.

## Common Exit Code Issues

### Exit Code 1: GitHub CLI Operation Failure

**Symptom**: Post-Merge Cleanup fails with exit code 1, but logs show successful operations.

**Common Causes**:

1. **Already Closed Issue**: Attempting to close an issue that's already been closed

2. **Permission Issues**: Insufficient token permissions for issue operations

3. **Network Timeouts**: GitHub API timeouts during operations

### Issue Already Closed (Most Common)

**Pattern**:

```text
Found PR number: 1339
Closing issue #1344...
 Added resolution comment to issue #1344
FAILED: Failed to close issue #1344

```

**Root Cause**: The issue was closed between script execution start and the close operation.

**Resolution**: This is expected behavior when issues are closed by other processes (manual closure, other automation). The script should be enhanced to handle this gracefully.

**Temporary Workaround**: Re-run the cleanup or ignore the failure if the comment was added successfully.

### Permission Issues

**Pattern**:

```text
FAILED: Failed to comment on issue #1344
FAILED: Failed to close issue #1344

```

**Root Cause**: Token lacks `issues: write` permission.

**Resolution**: Verify token hierarchy:

- `CI_ISSUE_AUTOMATION_TOKEN` (preferred)

- `CI_BOT_TOKEN` (fallback)

- `GITHUB_TOKEN` (default)

### Network/API Issues

**Pattern**: Intermittent failures with timeout messages.

**Resolution**: Retry the operation or check GitHub API status.

## Prevention

- Add issue state checking before close operations

- Implement graceful handling for already-closed issues

- Add retry logic for transient failures

## Related Documentation

- [CI Issue Automation Token Failures](./CI_ISSUE_AUTOMATION_TOKEN_FAILURES.md)

- [Post-Merge Cleanup Workflow](../../.github/workflows/post-merge-cleanup.yml)

- [Issue Management Script](../../scripts/manage_ci_failure_issues.sh)
