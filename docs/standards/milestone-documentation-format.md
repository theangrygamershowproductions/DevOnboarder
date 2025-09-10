# Milestone Documentation Format Standard

## Overview

This document defines the standardized format for milestone documentation across the DevOnboarder project. It codifies successful patterns that have emerged organically and ensures consistency, cross-referencing capability, and automation compatibility.

## Document Structure

### YAML Front Matter (Required)

Every milestone document must include a YAML front matter section with the following fields:

```yaml
---
milestone_id: "YYYY-MM-DD-brief-descriptive-name"
date: "YYYY-MM-DD"
type: "enhancement|feature|bugfix|infrastructure|process"
issue_number: ""  # GitHub issue number if applicable
pr_number: ""     # GitHub PR number if applicable
priority: "critical|high|medium|low"
complexity: "simple|moderate|complex|very-complex"
generated_by: "manual|scripts/generate_milestone.sh"
---
```

#### Required Fields

- **milestone_id**: Unique identifier in format `YYYY-MM-DD-brief-descriptive-name`
    - Must be unique across all milestones
    - Used for cross-referencing in issues, PRs, and documentation
    - Should be URL-safe (lowercase, hyphens only)
    - Examples: `2025-09-09-strategic-foundation-systems`, `2025-09-04-token-architecture-v2.1-clearance`

- **date**: ISO date format (YYYY-MM-DD) of milestone completion
- **type**: Category of work performed
- **priority**: Business/strategic importance level
- **complexity**: Technical implementation complexity

#### Optional Fields

- **issue_number**: GitHub issue number (without #) if milestone addresses specific issue
- **pr_number**: GitHub PR number (without #) if milestone delivered via specific PR
- **generated_by**: Tool or process that created the milestone document

### Document Content Structure

#### 1. Title and Summary (Required)

```markdown
# Milestone Title - Brief Description

## Transformation Overview

**What**: Clear description of what was accomplished
**Impact**: TRANSFORMATIONAL|SIGNIFICANT|MODERATE - Business impact description
**Scope**: Technical scope and deliverables summary
```

#### 2. Evidence Anchors (Required)

Every milestone must include Evidence Anchors with direct GitHub links:

```markdown
### Evidence Anchors

**Code & Scripts:**
- [specific-script.sh](relative/path/to/file) - Description
- [configuration-file.yml](relative/path/to/file) - Purpose

**GitHub History:**
- [PR #1234](https://github.com/theangrygamershowproductions/DevOnboarder/pull/1234) - Brief description
- [Issue #5678](https://github.com/theangrygamershowproductions/DevOnboarder/issues/5678) - Problem addressed
- [Commit abc123d](https://github.com/theangrygamershowproductions/DevOnboarder/commit/abc123d) - Specific change

**CI Evidence:**
- [Workflow run](https://github.com/theangrygamershowproductions/DevOnboarder/actions/runs/123456789) - Test results
- Coverage reports or quality gate evidence

**Documentation:**
- [New documentation](docs/path/to/new-doc.md) - Purpose
- [Updated guides](docs/path/to/updated-doc.md) - Changes made
```

#### 3. Impact Metrics (When Applicable)

For organizational or process improvements, include measurable impact:

```markdown
### Strategic Impact Analysis

| Metric | Before | After | Improvement |
|--------|--------|-------|------------|
| Decision Speed | 30-60 minutes | <15 minutes | **4x faster** |
| Process Clarity | Ad-hoc | Systematic | **100% systematic** |
| Quality Gates | Manual | Automated | **Automated validation** |
```

#### 4. Technical Details (When Applicable)

For technical milestones, include implementation details:

```markdown
### Technical Implementation

**Architecture Changes:**
- Component modifications
- New system integrations
- Configuration updates

**Quality Assurance:**
- Test coverage metrics
- Validation procedures
- Quality gate results
```

## Cross-Referencing Standards

### Milestone ID Usage

Milestone IDs should be referenced consistently across the project:

- **In GitHub Issues**: Reference as `milestone:2025-09-09-strategic-foundation-systems`
- **In Pull Requests**: Include in description as "Addresses milestone_id: 2025-09-09-strategic-foundation-systems"
- **In Documentation**: Link as `[Strategic Foundation Systems](milestones/2025-09/2025-09-09-enhancement-strategic-foundation-systems-implementation.md)`
- **In Reports**: Use milestone_id as unique identifier for tracking

### GitHub Link Standards

All GitHub references must be direct, clickable links:

- **Pull Requests**: `[PR #1234](https://github.com/theangrygamershowproductions/DevOnboarder/pull/1234)`
- **Issues**: `[Issue #5678](https://github.com/theangrygamershowproductions/DevOnboarder/issues/5678)`
- **Commits**: `[Commit abc123d](https://github.com/theangrygamershowproductions/DevOnboarder/commit/abc123d)`
- **Workflow Runs**: `[Build #123](https://github.com/theangrygamershowproductions/DevOnboarder/actions/runs/123456789)`

## File Organization

### Directory Structure

```text
milestones/
├── YYYY-MM/                           # Year-month grouping
│   ├── YYYY-MM-DD-type-brief-name.md  # Individual milestone docs
│   └── ...
├── templates/
│   └── milestone.md                   # Template for new milestones
└── MILESTONE_LOG.md                   # Historical consolidated log
```

### File Naming Convention

Milestone files must follow the pattern:
`YYYY-MM-DD-type-brief-descriptive-name.md`

Examples:

- `2025-09-09-enhancement-strategic-foundation-systems-implementation.md`
- `2025-09-04-infrastructure-token-architecture-v2.1-clearance.md`
- `2025-08-15-bugfix-coverage-masking-solution.md`

## Automation Integration

### Validation Requirements

Milestone documents must pass automated validation for:

1. **YAML Front Matter**: All required fields present and properly formatted
2. **Milestone ID Format**: Matches `YYYY-MM-DD-brief-descriptive-name` pattern
3. **Evidence Anchors**: Contains at least one GitHub link
4. **Unique IDs**: No duplicate milestone_id values across project

### Pre-commit Hook Integration

The milestone validation will be integrated into pre-commit hooks to ensure:

- Format compliance before commits
- Milestone ID uniqueness checking
- Required section presence validation
- GitHub link format verification

## Migration from Legacy Format

### Existing Documentation Updates

When updating existing milestone documentation:

1. **Add YAML Front Matter**: Include all required fields, infer values from content
2. **Convert References**: Change GitHub references to direct links
3. **Standardize Sections**: Reorganize content to match standard structure
4. **Generate Milestone IDs**: Create unique IDs for historical milestones

### Backward Compatibility

- Legacy milestone references will continue to work
- Gradual migration approach - update as documents are modified
- Automated tools to assist with bulk updates where appropriate

## Success Metrics

This standardization framework enables:

✅ **Cross-Reference Capability**: Unique IDs allow precise milestone referencing
✅ **Automated Tracking**: Consistent format enables dashboard and reporting automation
✅ **Quality Assurance**: Validation ensures complete and properly formatted documentation
✅ **Team Efficiency**: Templates and standards reduce documentation time
✅ **Historical Traceability**: Direct GitHub links provide immediate access to implementation details

## Examples

### Complete Example: Enhancement Milestone

See `milestones/2025-09/2025-09-09-enhancement-strategic-foundation-systems-implementation.md` for a complete example following this standard.

### Quick Reference Template

See `templates/milestone.md` for a template to copy when creating new milestone documentation.

---

*This standard document is itself subject to the milestone documentation format when updated. Current milestone_id: `2025-09-09-milestone-documentation-standardization`*
