---
similarity_group: github-review-process-guide.md-docs
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
updated_at: 2025-10-27
---
# GitHub Review Process Guide

## GitHub Copilot Review System

### Understanding Review Comment Lifecycle

**Key Behavior Learned from PR #1715:**

 **Immediate "Outdated" Marking**: GitHub immediately marks Copilot review comments as "Outdated" when code changes address the issues, regardless of when the comments were originally made.

 **Common Misconception**: Comments are NOT based on stale commit hashes - GitHub's review system actively tracks resolution status in real-time.

### Review Resolution Process

1. **Copilot Comments Generated**: When PR is opened, Copilot reviews code and generates inline comments
2. **Code Fixes Applied**: Developer addresses the issues identified in comments
3. **Changes Pushed**: Fixed code is committed and pushed to the PR branch
4. **Automatic Resolution**: GitHub immediately marks resolved comments as "Outdated"
5. **Status Tracking**: Unresolved comments remain active until addressed

### Troubleshooting Review Status

**If comments appear unresolved after fixes:**

1. **Verify Fix Quality**: Ensure the actual issue was addressed, not just the symptom
2. **Check Comment Context**: Some comments may require different solutions than expected
3. **Wait for System Update**: Very rarely, there may be a brief delay in status updates
4. **Manual Review**: Have maintainer manually review if system doesn't update

### Best Practices

- **Address Root Cause**: Fix the underlying issue, not just the immediate problem
- **Test Thoroughly**: Ensure fixes don't introduce new issues
- **Document Changes**: Include clear commit messages explaining how Copilot concerns were addressed
- **Verify Resolution**: Check that comments are marked "Outdated" after pushing fixes

### API Reference for Status Checking

```bash
# Get PR review status
gh pr view <PR_NUMBER> --json reviewDecision,reviews

# Get specific review comments (using correct Copilot bot identity)
gh api repos/<OWNER>/<REPO>/pulls/<PR_NUMBER>/comments --jq '.[] | select(.user.login == "copilot-pull-request-reviewer") | {file: .path, line: .original_line, body: .body[0:100]}'

# Alternative method to get all automated review comments
gh api repos/<OWNER>/<REPO>/pulls/<PR_NUMBER>/comments --jq '.[] | select(.user.login | test("copilot|github-advanced-security")) | {file: .path, line: .original_line, body: .body[0:100]}'
```

---
**Source**: Lessons learned from DevOnboarder PR #1715 External PR Security Guide implementation
**Date**: October 2, 2025
