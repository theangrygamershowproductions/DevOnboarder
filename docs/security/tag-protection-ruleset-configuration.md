# Tag Protection Ruleset Configuration

## Purpose

Protect version tags from unauthorized modification or deletion, ensuring release integrity and preventing accidental or malicious tag manipulation.

## Manual Configuration Required

**Location**: Repository Settings → Tags → Tag protection rules

**Note**: Tag protection uses GitHub's rulesets system, which provides more granular control than legacy tag protection.

## Recommended Ruleset Configuration

### Basic Tag Protection Rule

**Rule Name**: `Version Tag Protection`  
**Pattern**: `v*`  
**Description**: `Protect all semantic version tags (v1.0.0, v2.1.3, etc.)`

### Rule Details

#### Target Pattern

```text
v*
```

This pattern matches:

- `v1.0.0` - Major releases
- `v2.1.3` - Semantic versioning  
- `v1.0.0-beta.1` - Pre-releases
- `v3.2.1-rc.2` - Release candidates

#### Protection Settings

**Tag Restrictions**:

- ✅ **Prevent tag deletion** - Tags cannot be deleted once created
- ✅ **Prevent tag modification** - Existing tags cannot be moved to different commits

**Creation Restrictions**:

- ✅ **Restrict creation to repository maintainers** - Only maintainers can create new version tags
- ✅ **Require signed commits** - Version tags must point to signed commits (if signed commits enabled)

**Exception Handling**:

- ❌ **No bypass allowed** - Even administrators cannot bypass these rules
- ❌ **No force push exceptions** - Force push cannot override tag protection

## Implementation Steps

### 1. Navigate to Tag Protection Settings

```text
1. Go to: https://github.com/theangrygamershowproductions/DevOnboarder/settings
2. Click: "Tags" in the left sidebar
3. Click: "Add rule" button
```

### 2. Configure Rule Pattern

```text
Pattern: v*
Description: Protect all semantic version tags
```

### 3. Set Enforcement Options

```text
☑ Restrict creation
☑ Restrict updates  
☑ Restrict deletion
```

### 4. Define Permitted Actors

```text
Role: Maintain
Include administrators: No (recommended for maximum security)
```

### 5. Save and Activate

```text
Click: "Create" to activate the protection rule
```

## Security Benefits

### Without Tag Protection

```bash
# RISK: Anyone with write access can delete or modify release tags
git tag -d v1.0.0        # Delete release tag
git tag -f v1.0.0 HEAD   # Move tag to different commit
git push origin :v1.0.0  # Delete remote tag
```

### With Tag Protection

```bash
# SAFE: Tag operations are restricted and audited
git tag -d v1.0.0        # Local deletion still possible
git push origin :v1.0.0  # ERROR: Remote deletion blocked
git tag -f v1.0.0 HEAD   # Local move possible
git push origin v1.0.0   # ERROR: Remote modification blocked
```

## Verification

### Test Tag Protection

```bash
# 1. Create a test version tag (as maintainer)
git tag v99.99.99-test
git push origin v99.99.99-test

# 2. Attempt to delete (should fail for non-maintainers)  
git push origin :v99.99.99-test

# 3. Clean up test tag (as maintainer)
git push origin :v99.99.99-test
git tag -d v99.99.99-test
```

### Check Rule Status

```bash
# View current tag protection rules
gh api repos/theangrygamershowproductions/DevOnboarder/rulesets

# List existing tags
git tag -l "v*" | head -10
```

## Integration with Release Process

### Recommended Release Workflow

1. **Create Release Branch**

   ```bash
   git checkout -b release/v1.2.3
   ```

2. **Update Version Files**

   ```bash
   # Update package.json, pyproject.toml, etc.
   git commit -m "RELEASE: bump version to v1.2.3"
   ```

3. **Create Signed Tag** (Maintainer Only)

  ```bash
   git tag -s v1.2.3 -m "Release v1.2.3"
   git push origin v1.2.3
   ```

1. **Create GitHub Release**

   ```bash
   gh release create v1.2.3 --generate-notes
   ```

2. **Verify Protection Active**

   ```bash
   gh release create v1.2.3 --generate-notes
   ```

### Automated Release Integration

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create GitHub Release
        run: gh release create ${{ github.ref_name }} --generate-notes
```

## Maintenance

### Regular Review

- **Monthly**: Verify tag protection rules are active and effective
- **Per Release**: Ensure new version tags are properly protected after creation
- **Quarterly**: Review list of protected tags and clean up test tags if any

### Rule Updates

```text
Modify rule patterns if versioning scheme changes:
- v* (current) - covers semantic versioning
- release/* - if using release/ prefix
- prod-* - if using production prefixes
```

## Troubleshooting

### Common Issues

**Issue**: "Permission denied" when creating version tags
**Solution**: Ensure user has maintainer role or is included in rule exceptions

**Issue**: "Tag protection rule not applying to new tags"  
**Solution**: Verify pattern matches tag name exactly (case sensitive)

**Issue**: "Cannot delete old test tags"
**Solution**: Update rule pattern to exclude test tags, or delete via admin override

### Emergency Procedures

**If Wrong Tag Created**:

1. Contact repository administrator immediately
2. Admin can temporarily disable rule if emergency fix needed
3. Recreate correct tag and re-enable protection
4. Document incident for process improvement

**If Rule Needs Bypass**:

1. Requires administrator access with valid business justification
2. Temporarily disable rule → perform operation → re-enable rule
3. Audit and document all bypass operations

## Related Documentation

- **Release Process**: See CONTRIBUTING.md for complete release workflow
- **Signing Keys**: See docs/security/ for GPG/SSH key setup
- **Branch Protection**: See protection.json for complementary protections
- **CI Integration**: See .github/workflows/ for automated release workflows

---

**Configuration Type**: Manual (repository rulesets)  
**Security Level**: High (prevents tag tampering)  
**Scope**: Version tags matching `v*` pattern  
**Enforcement**: Blocks unauthorized tag operations  
**Maintenance**: Monthly verification recommended
