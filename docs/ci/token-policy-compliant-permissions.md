# Token Policy Compliant Workflow Permissions

**Date**: August 10, 2025  
**Policy**: No Default Token Policy v1.0  
**Purpose**: CodeQL compliance without violating DevOnboarder token governance

## Problem Analysis

DevOnboarder's **No Default Token Policy v1.0** creates a conflict:

- **CodeQL Security Scanner**: Requires explicit `permissions:` blocks
- **DevOnboarder Token Hierarchy**: Uses scoped tokens (`CI_ISSUE_AUTOMATION_TOKEN` → `CI_BOT_TOKEN` → `GITHUB_TOKEN`)
- **Current State**: Workflows use token hierarchy but lack explicit permissions

## Solution Framework

### 1. Hybrid Permission Strategy

Each workflow gets **both**:

- **Explicit permissions block** (satisfies CodeQL)
- **Continues using token hierarchy** (satisfies No Default Token Policy)

### 2. Permission Alignment Matrix

| Workflow | Token Used | Required Permissions | Policy Compliance |
|----------|------------|---------------------|-------------------|
| `ci.yml` | `CI_ISSUE_AUTOMATION_TOKEN` | `issues:write`, `pull_requests:write`, `contents:read` | ✅ Authorized in `.codex/bot-permissions.yaml` |
| `aar.yml` | `AAR_BOT_TOKEN` | `issues:write`, `contents:read` | ✅ Authorized for AAR generation |
| `dev-orchestrator.yml` | `ORCHESTRATION_BOT_KEY` | `actions:write`, `contents:read` | ✅ Development environment only |

### 3. CodeQL-Safe Permission Blocks

**Pattern**: Set minimum permissions required by the actual token being used

```yaml
# Example: CI workflow using CI_ISSUE_AUTOMATION_TOKEN
permissions:
  contents: read           # Base read access
  issues: write           # Matches CI_ISSUE_AUTOMATION_TOKEN capability
  pull-requests: write    # Matches CI_ISSUE_AUTOMATION_TOKEN capability
  actions: read           # For workflow monitoring

jobs:
  test:
    steps:
      - name: Create issue on failure
        env:
          # Keep the token hierarchy (No Default Token Policy compliance)
          GH_TOKEN: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN || secrets.GITHUB_TOKEN }}
        run: |
          gh issue create --title "CI Failure" --body "Details..."
```

### 4. Token Capability Verification

Before adding permissions, verify against `.codex/bot-permissions.yaml`:

```bash
# Check what CI_ISSUE_AUTOMATION_TOKEN is authorized for:
# - issues: write ✅
# - pull_requests: write ✅
# - contents: read ✅

# Therefore, safe to add these to workflow permissions block
```

## Implementation Plan

### Phase 1: Core CI Workflows

- Update `ci.yml` with `CI_ISSUE_AUTOMATION_TOKEN` aligned permissions
- Update `pr-automation.yml` with appropriate scoped permissions
- Verify no token policy violations

### Phase 2: Specialized Workflows

- Update `aar.yml` for AAR bot capabilities
- Update orchestrator workflows with environment-specific tokens
- Add CodeQL workflow permissions for security scanning

### Phase 3: Validation

- Run `validate-permissions.yml` to ensure policy compliance
- Verify CodeQL scanner accepts explicit permissions
- Test token hierarchy still works correctly

## Key Principles

1. **Never remove token hierarchy** - maintains No Default Token Policy compliance
2. **Add minimal permissions** - only what the actual token supports
3. **Environment-specific tokens** - production vs development token separation
4. **Validate against bot-permissions.yaml** - ensure alignment with registered capabilities

## Risk Mitigation

- **Rollback Plan**: Remove permissions blocks if token policy violations occur
- **Validation**: Check each workflow against `.codex/bot-permissions.yaml` before deployment
- **Testing**: Verify CI functionality after permission changes
