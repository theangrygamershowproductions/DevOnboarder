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

# Milestone Title - Brief Description

## Transformation Overview

**What**: Clear description of what was accomplished
**Impact**: TRANSFORMATIONAL|SIGNIFICANT|MODERATE - Business impact description
**Scope**: Technical scope and deliverables summary

## [Strategic Impact Analysis OR Technical Implementation]

<!-- For organizational/process improvements, use Strategic Impact Analysis -->
### Strategic Impact Analysis

| Metric | Before | After | Improvement |
|--------|--------|-------|------------|
| Decision Speed | Previous state | Current state | **Quantified improvement** |
| Process Clarity | Previous approach | New systematic approach | **Measurable change** |
| Quality Gates | Manual process | Automated validation | **Efficiency gain** |

<!-- For technical milestones, use Technical Implementation -->
### Technical Implementation

**Architecture Changes:**

- Component modifications
- New system integrations
- Configuration updates

**Quality Assurance:**

- Test coverage metrics
- Validation procedures
- Quality gate results

## Evidence Anchors

**Code & Scripts:**

- [specific-script.sh](relative/path/to/file) - Description of purpose and functionality
- [configuration-file.yml](relative/path/to/file) - Configuration changes made

**GitHub History:**

- [PR #1234](https://github.com/theangrygamershowproductions/DevOnboarder/pull/1234) - Brief description of changes
- [Issue #5678](https://github.com/theangrygamershowproductions/DevOnboarder/issues/5678) - Problem addressed
- [Commit abc123d](https://github.com/theangrygamershowproductions/DevOnboarder/commit/abc123d) - Specific important change

**CI Evidence:**

- [Workflow run](https://github.com/theangrygamershowproductions/DevOnboarder/actions/runs/123456789) - Test results and validation
- Coverage reports or quality gate evidence

**Documentation:**

- [New documentation](docs/path/to/new-doc.md) - Purpose and audience
- [Updated guides](docs/path/to/updated-doc.md) - What changes were made

## [Optional: Additional Sections]

### Lessons Learned

- Key insights gained during implementation
- Process improvements identified
- Future considerations

### Future Work

- Follow-up tasks identified
- Enhancement opportunities
- Long-term strategic implications

---

**Validation Checklist:**

- [ ] All required YAML front matter fields completed
- [ ] Unique milestone_id follows format: `YYYY-MM-DD-brief-descriptive-name`
- [ ] Evidence Anchors includes at least one direct GitHub link
- [ ] Impact/Implementation section appropriate to milestone type
- [ ] File named according to convention: `YYYY-MM-DD-type-brief-name.md`
- [ ] File placed in appropriate directory: `milestones/YYYY-MM/`
