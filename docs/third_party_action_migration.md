# Third-Party Action Migration Guide

## Problem Statement

The `sersoft-gmbh/setup-gh-cli-action@v2` third-party action has been causing authentication issues that prevent CodeQL wait scripts from properly accessing GitHub API check status. This results in:

- Wait scripts hanging for 14+ minutes
- Failed status check updates
- Unreliable CI pipeline completion
- Potential security risks from third-party dependencies

## Solution: Built-in GITHUB_TOKEN

GitHub Actions provides a built-in `GITHUB_TOKEN` that eliminates the need for third-party actions and provides more reliable authentication.

### Advantages of Built-in Token

1. **No Third-Party Dependencies**: Eliminates security risks and maintenance overhead
2. **Automatic Authentication**: Always available and properly scoped
3. **Better Reliability**: No external service dependencies
4. **Simplified Configuration**: No additional setup required
5. **Official Support**: Maintained by GitHub with guaranteed compatibility

## Migration Steps

### 1. Update CI Workflow

**Before (with third-party action):**

```yaml
- name: Setup GitHub CLI
  uses: sersoft-gmbh/setup-gh-cli-action@v2

- name: Wait for CodeQL
  run: |
    gh auth login --with-token <<< "$GITHUB_TOKEN"
    ./scripts/smart_codeql_wait.sh javascript-typescript ${{ github.sha }}
```

**After (built-in token):**

```yaml
- name: Wait for CodeQL
  run: |
    # No setup needed - GITHUB_TOKEN is automatically available
    ./scripts/smart_codeql_wait_builtin.sh javascript-typescript ${{ github.sha }}
```

### 2. Update Script Implementation

**Before (GitHub CLI):**

```bash
# Requires third-party action setup
gh api "/repos/$REPO/commits/$COMMIT_SHA/check-runs" \
  --jq '.check_runs[] | select(.name | contains("CodeQL")) | .name'
```

**After (curl with built-in token):**

```bash
# Uses built-in GITHUB_TOKEN directly
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$REPO/commits/$COMMIT_SHA/check-runs"
```

### 3. Required Permissions

Ensure your workflow has the necessary permissions:

```yaml
permissions:
  contents: read
  checks: read
  pull-requests: write  # If updating PR status
```

## Files to Update

### 1. CI Workflows

- `.github/workflows/ci.yml` - Main CI pipeline
- `.github/workflows/ci_builtin_token.yml` - Reference implementation
- Any other workflows using `sersoft-gmbh/setup-gh-cli-action@v2`

### 2. Scripts

- `scripts/smart_codeql_wait.sh` - Original script (keep for reference)
- `scripts/smart_codeql_wait_builtin.sh` - New built-in token script

### 3. Documentation

- Update any documentation referencing the third-party action
- Add migration notes for team members

## Testing the Migration

### 1. Test Locally (if possible)

```bash
# Test the new script with a known commit
export GITHUB_TOKEN="your_token_here"
./scripts/smart_codeql_wait_builtin.sh javascript-typescript abc123def456
```

### 2. Test in CI

1. Create a test branch
2. Push changes to trigger CI
3. Monitor the wait job logs for proper authentication
4. Verify check status updates work correctly

### 3. Rollback Plan

- Keep the original workflow as backup
- Test thoroughly before removing third-party action completely
- Have the old script available for comparison

## Security Considerations

### Built-in Token Security

- **Automatic Scoping**: Limited to the repository and workflow
- **No Secret Storage**: No need to store tokens in repository
- **Audit Trail**: All API calls logged in workflow runs
- **Permission Control**: Granular permission control via workflow permissions

### Third-Party Action Risks

- **Supply Chain Attack**: Third-party code could be compromised
- **Maintenance Burden**: Dependencies may become outdated
- **Black Box**: Limited visibility into authentication mechanism
- **Version Drift**: Breaking changes in third-party updates

## Performance Comparison

| Metric | Third-Party Action | Built-in Token |
|--------|-------------------|---------------|
| Setup Time | ~10-15 seconds | ~0 seconds |
| Reliability | Variable | High |
| API Rate Limits | Subject to third-party limits | GitHub's limits |
| Debugging | Complex | Simple |
| Maintenance | Required | Minimal |

## Troubleshooting

### Common Issues

1. **"GITHUB_TOKEN not found"**
   - Ensure `permissions: checks: read` is set
   - Check workflow permissions configuration

2. **API Authentication Failed**
   - Verify the token has necessary permissions
   - Check repository access

3. **Script Hangs**
   - Verify CodeQL job completed successfully
   - Check API rate limits
   - Ensure correct commit SHA

### Debug Commands

```bash
# Test API access
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/commits/SHA/check-runs"

# Check token permissions
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/user" | jq .permissions
```

## Migration Checklist

- [ ] Review all workflows using third-party action
- [ ] Create backup of current workflows
- [ ] Update CI workflow to use built-in token
- [ ] Test new implementation
- [ ] Update documentation
- [ ] Remove third-party action references
- [ ] Monitor for any issues
- [ ] Update team documentation

## Conclusion

Migrating from third-party actions to built-in GitHub tokens provides:

- **Improved Security**: No external dependencies
- **Better Reliability**: Consistent authentication
- **Simplified Maintenance**: Less complexity
- **Future-Proof**: Official GitHub support

The built-in `GITHUB_TOKEN` approach is the recommended solution for GitHub Actions authentication needs.
