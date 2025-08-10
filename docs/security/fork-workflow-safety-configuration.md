# Fork Workflow Safety Configuration

## Purpose

Configure fork pull request workflow permissions to prevent malicious code execution from external contributors while maintaining contribution accessibility.

## Manual Configuration Required

**Location**: Repository Settings → Actions → General → Fork pull request workflows

**This setting is intentionally manual** - GitHub does not expose these controls via API to prevent programmatic security bypasses.

## Recommended Settings

### Fork Pull Request Workflows from Outside Collaborators

#### Option 1: Balanced Security (Recommended)

- ✅ **"Require approval for first-time contributors who are new to GitHub"**
- ✅ **"Send write tokens to workflows from fork pull requests"**: DISABLED

#### Option 2: Maximum Security

- ✅ **"Require approval for all outside collaborators"**
- ✅ **"Send write tokens to workflows from fork pull requests"**: DISABLED

### Additional Fork Controls

- ✅ **"Send secrets to workflows from fork pull requests"**: DISABLED
- ✅ **"Require approval for fork pull request workflows"**: ENABLED

## Security Impact

### Without Fork Workflow Controls

```yaml
# RISK: External fork can execute arbitrary code
# in workflows with access to secrets and write tokens
on:
  pull_request:  # Triggers on ALL PRs including forks

jobs:
  malicious:
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "Accessing secrets: ${{ secrets.GITHUB_TOKEN }}"
          # Malicious code execution with repo access
```

### With Fork Workflow Controls

```yaml
# SAFE: External fork workflows require approval
# before accessing any secrets or write permissions
on:
  pull_request:  # External forks queue for approval

jobs:
  safe:
    runs-on: ubuntu-latest  
    steps:
      - run: echo "Must be approved before execution"
        # No access to secrets until manually approved
```

## Implementation Steps

1. **Navigate to Repository Settings**
   - Go to: `https://github.com/theangrygamershowproductions/DevOnboarder/settings`

2. **Access Actions Settings**
   - Click: **Actions** → **General**

3. **Configure Fork Workflow Settings**
   - Scroll to: **"Fork pull request workflows from outside collaborators"**
   - Select: **"Require approval for first-time contributors who are new to GitHub"** (recommended)
   - OR Select: **"Require approval for all outside collaborators"** (maximum security)

4. **Disable Sensitive Access**
   - Uncheck: **"Send write tokens to workflows from fork pull requests"**
   - Uncheck: **"Send secrets to workflows from fork pull requests"**

5. **Enable Fork Approval**
   - Check: **"Require approval for fork pull request workflows"**

## Verification

### Check Current Settings

1. Navigate to: Repository Settings → Actions → General
2. Verify settings match recommendations above
3. Test with a fork PR (if available) to confirm approval workflow

### Operational Testing

```bash
# Create test fork PR to verify approval requirements
# 1. Fork the repository to a test account
# 2. Make small change and create PR
# 3. Verify workflows show "waiting for approval" status
# 4. Approve via repository settings if testing in production
```

## Maintenance Notes

### Regular Review

- **Monthly**: Verify settings haven't been changed inadvertently
- **Quarterly**: Review if security posture needs adjustment based on contribution patterns

### Documentation Updates

- **Update this document** if GitHub changes the UI or available options
- **Notify team** if settings are adjusted for operational reasons

### Integration with CI Governance

- This setting complements but does not replace branch protection requirements
- External contributors still need approval for PR merge via CODEOWNERS
- Fork workflow approval is an additional security layer for code execution

## Related Security Measures

- **Branch Protection**: Required status checks + signed commits
- **CODEOWNERS**: Mandatory code review before merge  
- **Secret Scanning**: Prevents accidental secret exposure
- **Dependabot**: Automated vulnerability management

## Emergency Procedures

### If Malicious Fork PR Detected

1. **Immediately deny workflow approval** if pending
2. **Close PR without merging** to prevent code execution
3. **Report to GitHub** if clearly malicious intent
4. **Review and tighten** fork workflow settings if needed

### If Settings Accidentally Changed

1. **Immediately restore** recommended settings above
2. **Review recent workflow runs** for unauthorized executions
3. **Audit recent PRs** from external contributors
4. **Document incident** and update procedures if needed

---

**Configuration Type**: Manual (intentionally not automated)  
**Security Level**: High (prevents code execution attacks)  
**Maintenance**: Quarterly review recommended  
**Integration**: Part of complete CI governance framework
