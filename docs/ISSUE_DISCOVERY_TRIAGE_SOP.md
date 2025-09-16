---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: ISSUE_DISCOVERY_TRIAGE_SOP.md-docs
status: active
tags:
- documentation
title: Issue Discovery Triage Sop
updated_at: '2025-09-12'
visibility: internal
---

# Issue Discovery & Triage Standard Operating Procedure

## Purpose

Systematize the decision-making process when discovering new issues during active development work, ensuring strategic alignment with the Priority Stack Framework while maintaining development momentum.

## Scope

This SOP applies to all development work when:

- New issues are discovered during feature implementation

- Systemic problems are identified during bug fixes

- Technical debt is uncovered during refactoring

- Process gaps are revealed during workflow execution

## Decision Framework

### Step 1: Immediate Impact Assessment

**Question**: Does this issue block current work completion?

- **YES**: Address immediately as part of current work

- **NO**: Proceed to Priority Stack Framework evaluation

### Step 2: Priority Stack Framework Classification

Classify the discovered issue using the 4-tier system:

#### Tier 1: Organizational Systems & Meta-Frameworks

- Issues affecting development decision-making processes

- Problems with priority frameworks, workflow standards

- Meta-issues that impact how other issues are handled

- **Decision**: Usually create separate issue for proper strategic treatment

#### Tier 2: Infrastructure & Automation

- CI/CD pipeline problems

- Development environment issues

- Systemic automation failures

- **Decision**: Evaluate scope impact (see Step 3)

#### Tier 3: Quality & Standards

- Code quality issues

- Documentation problems

- Testing gaps

- **Decision**: Usually defer to separate issue unless trivial fix

#### Tier 4: Features & Enhancements

- New functionality requests

- User experience improvements

- Performance optimizations

- **Decision**: Always defer to separate issue

### Step 3: Scope Impact Evaluation

For Tier 2 issues, assess scope impact:

**Low Impact** (affects <5 files):

- Consider integrating with current work

- Quick wins that eliminate future friction

**Medium Impact** (affects 5-20 files):

- Usually create separate issue

- Document thoroughly for future sprint

**High Impact** (affects 20+ files):

- Always create separate issue

- Requires dedicated sprint planning

### Step 4: Integration Decision Matrix

| Tier | Scope | Current Work Impact | Decision |
|------|-------|-------------------|----------|
| 1 | Any | Any | Separate issue (strategic importance) |
| 2 | Low | None/Minimal | Consider integration |
| 2 | Medium/High | Any | Separate issue |
| 3 | Low | None | Consider integration |
| 3 | Medium/High | Any | Separate issue |
| 4 | Any | Any | Separate issue |

## Standard Process Flow

### When Creating Separate Issue

1. **Document comprehensively**:

   - Problem summary with impact assessment

   - Technical details and root cause analysis

   - Solution options with effort estimates

   - Discovery context and relationships

2. **Apply appropriate labels**:

   - Tier classification (`tier-1-priority`, `tier-2-priority`, etc.)

   - Type classification (`infrastructure`, `quality-standards`, etc.)

   - Impact scope (`systemic-issue`, `workflow-friction`, etc.)

3. **Link to current work**:

   - Reference in commit message

   - Note discovery context in issue description

   - Update related issues if applicable

4. **Prioritize appropriately**:

   - Tier 1: Immediate next sprint

   - Tier 2: Next sprint or within current milestone

   - Tier 3: Upcoming milestone

   - Tier 4: Product backlog

### When Integrating with Current Work

1. **Validate scope assumptions**:

   - Confirm effort estimate accuracy

   - Verify no hidden dependencies

   - Ensure no testing complexity

2. **Update current work scope**:

   - Modify PR description to include integrated fixes

   - Update commit message to reflect broader changes

   - Document integration decision rationale

3. **Maintain focus discipline**:

   - Set time-box for integrated work

   - Abandon integration if complexity exceeds estimate

   - Create separate issue if scope grows beyond initial assessment

## Quality Gates

### Before Integration Decision

- [ ] Issue has been classified using Priority Stack Framework

- [ ] Scope impact has been honestly assessed

- [ ] Current work completion timeline considered

- [ ] Integration effort realistically estimated

### Before Creating Separate Issue

- [ ] Problem is documented with sufficient detail for future work

- [ ] Root cause analysis has been performed

- [ ] Solution options have been identified

- [ ] Discovery context has been preserved

### Before Proceeding with Current Work

- [ ] Decision has been made using systematic process

- [ ] If integrated: scope has been updated and communicated

- [ ] If separated: issue has been created and linked

- [ ] Strategic priorities remain aligned

## Success Metrics

### Process Effectiveness

- Time from issue discovery to triage decision: <15 minutes

- Accuracy of scope estimates for integrated issues: >80%

- Reduction in scope creep incidents: >50%

### Strategic Alignment

- Tier 1 issues receive immediate strategic attention: 100%

- Tier 2 issues are addressed within one sprint: >90%

- Current work maintains focus discipline: >95%

## Examples & Case Studies

### Case Study 1: Systemic Markdown Compliance Issue

**Discovery**: Found 20+ automation scripts generating non-compliant markdown

**Classification**: Tier 2 (Infrastructure & Automation), High Impact
**Decision**: Separate issue (Issue #1315)
**Rationale**: High impact (20+ files), systemic nature requires dedicated focus

**Outcome**: Current work completed without scope creep, systemic issue properly documented

### Case Study 2: Simple Documentation Fix

**Discovery**: Missing blank line in generated milestone report
**Classification**: Tier 3 (Quality & Standards), Low Impact
**Decision**: Integrate with current work
**Rationale**: Single file, trivial fix, eliminates immediate friction
**Outcome**: Fixed immediately with markdownlint --fix

## Integration with Priority Stack Framework

This SOP serves as the **operational implementation** of the Priority Stack Framework decision-making process, providing:

1. **Concrete decision criteria** for abstract priority classifications

2. **Systematic process flow** for consistent triage decisions

3. **Quality gates** to prevent scope creep and maintain strategic focus

4. **Metrics and feedback loops** for continuous improvement

## Maintenance & Updates

- **Review quarterly** with Priority Stack Framework updates

- **Update based on** real-world triage decisions and outcomes

- **Incorporate lessons learned** from scope creep incidents

- **Align with** evolving DevOnboarder strategic priorities

---

**Created**: September 9, 2025

**Version**: 1.0
**Next Review**: December 2025
**Related**: Priority Stack Framework (docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md)
