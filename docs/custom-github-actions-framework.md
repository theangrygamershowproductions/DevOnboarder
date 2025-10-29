---
similarity_group: custom-github-actions-framework.md-docs
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
updated_at: 2025-10-27
---
# DevOnboarder Custom GitHub Actions Framework

## Overview

When third-party GitHub Actions fail to meet DevOnboarder's quality standards, we follow a systematic approach for replacement and custom development.

## Decision Framework

### 1. Issue Classification

**Critical Issues** (Immediate Action Required):

- Security vulnerabilities
- Functionality breaking changes
- Version incompatibilities (like Node.js conflicts)
- Abandonment (>90 days without updates)

**Non-Critical Issues** (Monitor & Plan):

- Performance suboptimal
- Missing features
- Documentation issues

### 2. Remediation Options

#### Option A: Fork & Patch

```yaml
# When: Simple fixes needed, active upstream
# Example: Minor compatibility patches
uses: devonboarder/forked-action@v1  # Our maintained fork
```

#### Option B: Custom Implementation

```yaml
# When: Core functionality needed, simple to implement
# Example: Our custom setup-gh-cli action
uses: ./.github/actions/setup-gh-cli
with:
  version: 'latest'
  token: ${{ secrets.GITHUB_TOKEN }}
```

#### Option C: Alternative Solution

```yaml
# When: Multiple alternatives exist
# Example: Replace abandoned action with maintained alternative
uses: actions/setup-node@v4  # Instead of outdated third-party
```

## Custom Action Standards

### File Structure

```text
.github/actions/action-name/
── action.yml          # Action metadata and interface
── README.md          # Usage documentation
── src/               # Source code (if composite action)
│   ── main.sh
── tests/             # Action testing
    ── test.yml
```

### Quality Requirements

1. **Metadata Compliance**
   - Clear name, description, author
   - Proper input/output definitions
   - Semantic versioning

2. **Code Standards**
   - Error handling (`set -euo pipefail`)
   - Proper logging and output
   - Cross-platform compatibility
   - Timeout handling

3. **Documentation**
   - Usage examples
   - Input/output specifications
   - Troubleshooting guide

4. **Testing**
   - Unit tests for all functions
   - Integration tests in real workflows
   - Failure scenario testing

## Implementation Process

### Phase 1: Analysis & Design

1. Identify exact requirements
2. Evaluate existing alternatives
3. Design interface (inputs/outputs)
4. Plan implementation approach

### Phase 2: Development

1. Create action structure
2. Implement core functionality
3. Add error handling and logging
4. Create comprehensive tests

### Phase 3: Integration

1. Update dependency validation whitelist
2. Replace in affected workflows
3. Monitor performance and reliability
4. Document migration path

### Phase 4: Maintenance

1. Regular security updates
2. Feature enhancements
3. Compatibility monitoring
4. Community contributions

## Current Custom Actions

### setup-gh-cli

**Problem**: `sersoft-gmbh/setup-gh-cli-action@v2` installs wrong Node.js version
**Solution**: Custom implementation with proper version control
**Status**: Ready for deployment

**Usage**:

```yaml
- name: Setup GitHub CLI
  uses: ./.github/actions/setup-gh-cli
  with:
    version: '2.40.1'  # Specific version control
    token: ${{ secrets.GITHUB_TOKEN }}
```

**Benefits**:

-  No Node.js version conflicts
-  Explicit version control
-  Cross-platform compatibility
-  Proper error handling
-  DevOnboarder quality standards

## Migration Strategy

### Immediate Actions (sersoft-gmbh issue)

1. Deploy custom `setup-gh-cli` action
2. Update all affected workflows (12 files)
3. Test in staging environment
4. Gradual rollout to production

### Long-term Strategy

1. **Action Registry**: Maintain catalog of approved/custom actions
2. **Dependency Scanning**: Continuous monitoring of third-party actions
3. **Quality Gates**: Automated validation of all action updates
4. **Team Training**: Guidelines for action selection and development

## Integration with Dependency Management

Our GitHub Actions dependency validator now supports:

- **Custom Action Detection**: Recognizes `./.github/actions/*` patterns
- **Version Pinning**: Enforces specific versions for stability
- **Quality Metrics**: Tracks custom action performance
- **Update Notifications**: Alerts when dependencies need updates

## Examples of DevOnboarder Custom Actions

### 1. setup-gh-cli (Implemented)

- Replaces: `sersoft-gmbh/setup-gh-cli-action@v2`
- Reason: Version conflicts, abandonment
- Status: Ready

### 2. quality-gate-reporter (Planned)

- Replaces: Multiple reporting actions
- Reason: Unified DevOnboarder quality reporting
- Status: Design phase

### 3. secure-artifact-upload (Future)

- Replaces: `actions/upload-artifact@v4`
- Reason: Enhanced security requirements
- Status: Evaluation

## Benefits of Custom Actions

1. **Full Control**: No dependency on external maintainers
2. **Quality Assurance**: Meets DevOnboarder's 95% quality threshold
3. **Security**: Audited code, no supply chain risks
4. **Consistency**: Unified interface and behavior
5. **Performance**: Optimized for DevOnboarder's specific needs
6. **Reliability**: Maintained according to our standards

## Risks and Mitigation

**Risk**: Maintenance overhead
**Mitigation**: Automated testing, clear documentation, team ownership

**Risk**: Feature lag behind community
**Mitigation**: Regular evaluation, selective feature adoption

**Risk**: Knowledge silos
**Mitigation**: Documentation, code reviews, shared ownership

---

**Last Updated**: October 5, 2025
**Maintainer**: DevOnboarder Infrastructure Team
**Quality Standard**: 95% threshold compliance required
