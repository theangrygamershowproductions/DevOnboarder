# Token Policy Compliant CI Fix

## The Issue

DevOnboarder's "No Default Token Policy v1.0" creates a conflict:

- CodeQL wants explicit `permissions:` blocks
- DevOnboarder uses token hierarchy: `CI_ISSUE_AUTOMATION_TOKEN` → `CI_BOT_TOKEN` → `GITHUB_TOKEN`
- Permissions must match token capabilities exactly

## Token-Aligned Permissions

### CI Workflow (uses CI_ISSUE_AUTOMATION_TOKEN)

```yaml
permissions:
  contents: read          # Safe base access
  issues: write          # ✅ CI_ISSUE_AUTOMATION_TOKEN has this
  pull-requests: write   # ✅ CI_ISSUE_AUTOMATION_TOKEN has this  
  actions: read          # For workflow monitoring
```

### AAR Workflow (should use AAR_BOT_TOKEN)

```yaml
permissions:
  contents: read         # Safe base access
  issues: write         # ✅ AAR_BOT_TOKEN has this (from .codex/bot-permissions.yaml)
```

### Orchestrator Workflow (uses ORCHESTRATION_BOT_KEY)

```yaml
permissions:
  contents: write       # ✅ Development orchestration needs this
  pull-requests: write  # ✅ For PR automation
  issues: write        # ✅ For issue management
  actions: read        # For workflow coordination
```

## Key Fixes Applied

1. **Keep token hierarchy** - Don't change `GH_TOKEN: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || ... }}`
2. **Add aligned permissions** - Only what the token actually supports
3. **Validate against bot-permissions.yaml** - Ensure no capability mismatches

## Testing Token Policy Compliance

```bash
# Verify permissions match token capabilities
bash scripts/lint-bot-permissions.sh

# Check validate-permissions workflow passes
gh workflow run validate-permissions.yml --ref $BRANCH
```

The key insight: **permissions blocks must be a subset of token capabilities**, not exceed them.
