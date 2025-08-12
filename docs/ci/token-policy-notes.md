# DevOnboarder Token Policy Implementation

**Policy**: No Default Token Policy v1.0  
**Status**: ✅ ACTIVE AND ENFORCED  
**Last Updated**: August 10, 2025

## 🔐 Token Hierarchy

DevOnboarder uses a **cascading token hierarchy** to maintain security while providing fallback resilience:

```bash
PRIMARY_TOKEN → FALLBACK_TOKEN → GITHUB_TOKEN
```

### Token Assignment by Workflow

| Workflow | Primary Token | Fallback Chain | Permissions Required |
|----------|---------------|----------------|---------------------|
| `ci.yml` | `CI_ISSUE_AUTOMATION_TOKEN` | `CI_BOT_TOKEN` → `GITHUB_TOKEN` | `contents:read`, `issues:write`, `pull-requests:write` |
| `aar.yml` | None (read-only) | N/A | `contents:read` only |
| `orchestrator.yml` | `ORCHESTRATION_BOT_KEY` | `CI_BOT_TOKEN` → `GITHUB_TOKEN` | `contents:write`, `issues:write`, `pull-requests:write` |
| `security-audit.yml` | `SECURITY_AUDIT_TOKEN` | `CI_BOT_TOKEN` → `GITHUB_TOKEN` | `contents:read`, `security-events:write` |

## 🎯 Implementation Pattern

Every workflow using tokens follows this pattern:

```yaml
permissions:
  contents: read          # Always start with minimal
  issues: write          # Only if token supports it
  pull-requests: write   # Only if token supports it
  # Never exceed token capabilities

jobs:
  job-name:
    steps:
      - name: Step using token
        env:
          # Token hierarchy pattern (No Default Token Policy compliant)
          GH_TOKEN: ${{ secrets.PRIMARY_TOKEN || secrets.FALLBACK_TOKEN || secrets.GITHUB_TOKEN }}
        run: |
          gh issue create --title "Automated Issue"
```

## 🔒 Policy Enforcement

### What's Required

1. **Explicit permissions blocks** - CodeQL compliance
2. **Token hierarchy usage** - No direct `GITHUB_TOKEN` usage
3. **Capability alignment** - Permissions ≤ token capabilities
4. **Bot identity mapping** - Each token maps to specific bot identity

### What's Prohibited

- ❌ Direct `GITHUB_TOKEN` usage without fallback chain
- ❌ Permissions exceeding token capabilities  
- ❌ Missing permissions blocks (CodeQL violation)
- ❌ Generic tokens for specialized tasks

## 📋 Validation

### Automated Checks

- `validate-permissions.yml` - Ensures token/permission alignment
- `validate-token-compliance.sh` - Local validation script
- Bot permissions lint via `scripts/lint-bot-permissions.sh`

### Manual Verification

```bash
# Verify token hierarchy is maintained
grep -r "CI_ISSUE_AUTOMATION_TOKEN.*CI_BOT_TOKEN.*GITHUB_TOKEN" .github/workflows/

# Check permissions don't exceed capabilities
./validate-token-compliance.sh

# Validate bot permissions YAML
bash scripts/lint-bot-permissions.sh
```

## 🚨 Token Policy Compliance Matrix

| Component | Status | Notes |
|-----------|--------|-------|
| CI Workflow | ✅ COMPLIANT | Uses token hierarchy + aligned permissions |
| AAR Workflow | ✅ COMPLIANT | Read-only, no token needed |
| Orchestrator | ✅ COMPLIANT | Uses `ORCHESTRATION_BOT_KEY` with proper permissions |
| Security Workflows | ✅ COMPLIANT | Uses scoped security tokens |
| Branch Protection | ✅ COMPLIANT | Enforces all token policy checks |

## 🎯 Success Metrics

- **Zero CodeQL warnings** ✅ - Explicit permissions declared
- **Zero token policy violations** ✅ - All tokens properly scoped  
- **Zero capability mismatches** ✅ - Permissions ≤ token capabilities
- **100% workflow coverage** ✅ - All workflows have proper token usage

## 📚 Related Documentation

- `.codex/bot-permissions.yaml` - Authoritative token capability definitions
- `.codex/tokens/token_scope_map.yaml` - Complete token registry
- `docs/security/token-permissions-matrix.md` - Comprehensive token documentation
- `docs/ci/required-checks.md` - Required status checks for branch protection

**Result**: DevOnboarder achieves both CodeQL security compliance AND No Default Token Policy v1.0 compliance through token-aligned permissions! 🎉

## 🛡️ Validation and Maintenance

### Drift Detection Scripts

DevOnboarder includes comprehensive validation to prevent configuration drift:

#### Required Check Validation

```bash
# Validate required checks against live PR
./scripts/assert_required_checks.sh <pr-number>
```

- Compares `protection.json` contexts with actual PR check runs
- Detects ineffective branch protection due to name mismatches
- Supports both jq and Python fallback parsing

#### Branch Protection Verification

```bash
# Verify server state matches local config
./scripts/verify-branch-protection.sh
```

- Validates GitHub server protection vs `protection.json`
- Detects drift in boolean settings and required contexts
- Ensures configuration synchronization

#### Workflow Header Compliance

```bash
# Audit all workflows for proper documentation
./scripts/audit-workflow-headers.sh
```

- Validates token usage documentation in all workflows
- Ensures policy compliance references are present
- Checks for maintenance and purpose documentation

### Automated Guards

The following CI workflows provide continuous validation:

- **guard-required-checks.yml**: Validates required checks on toolchain changes
- **audit-workflow-headers.yml**: Ensures workflow header compliance
- **Matrix drift protection**: Prevents doc/config inconsistencies
- **Skip behavior confirmation**: Validates conditional job compatibility

### When to Run Guard Scripts

Run these validation scripts when:

1. **Adding new workflows**: Ensure proper header documentation
2. **Modifying check names**: Validate against live PR runs
3. **Updating branch protection**: Verify server synchronization
4. **Toolchain changes**: Check for drift in required checks
5. **Regular maintenance**: Monthly validation recommended
