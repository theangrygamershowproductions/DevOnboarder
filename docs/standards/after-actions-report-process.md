---
author: DevOnboarder Team

ci_integration: true
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Standards documentation
document_type: standards
merge_candidate: false
project: DevOnboarder
similarity_group: standards-standards
status: active
tags:

- standards

- policy

- documentation

title: After Actions Report Process
updated_at: '2025-09-12'
virtual_env_required: true
visibility: internal
---

# After Actions Report (AAR) Process for DevOnboarder

## Overview

After Actions Reports (AARs) are systematic reviews of project activities, issues, and improvements following the DevOnboarder philosophy of "quiet reliability" through continuous learning and documentation.

## AAR Types & Triggers

### 1. **Issue Resolution AARs**

- **Trigger**: When closing issues labeled `critical`, `bug`, `security`, or `infrastructure`

- **Required**: For all issues that required >3 commits to resolve

- **Optional**: For enhancement issues with learning value

### 2. **Sprint/Milestone AARs**

- **Trigger**: Completion of major features or quarterly reviews

- **Scope**: Comprehensive review of development patterns and CI health

- **Format**: Formal AAR document with action items

### 3. **Incident AARs**

- **Trigger**: CI failures lasting >24 hours, security incidents, or service outages

- **Urgency**: Within 48 hours of resolution

- **Distribution**: All team members and stakeholders

### 4. **Automation Enhancement AARs**

- **Trigger**: Major changes to CI/CD pipeline or automation scripts

- **Focus**: Process improvements and tool effectiveness

- **Integration**: Update automation documentation

### 5. **Framework Integration AARs**

- **Trigger**: Implementation of new development frameworks or tool integrations

- **Examples**: VS Code/CI integration, testing framework updates, workflow standardization

- **Documentation**: Update standard practice documents in `docs/standards/`

- **Follow-up**: Team training and adoption verification

## AAR Storage Strategy

### Primary Storage: `.aar/` Directory Structure

```text
.aar/
├── 2025/
│   ├── Q1/
│   │   ├── issues/
│   │   │   ├── issue-1234-git-workflow-enhancement.md
│   │   │   └── issue-5678-pre-commit-failures.md
│   │   ├── sprints/
│   │   │   └── 2025-Q1-git-utilities-enhancement.md
│   │   └── incidents/
│   │       └── 2025-01-30-ci-failure-cascade.md
│   └── archive/
├── templates/
│   ├── issue-aar-template.md
│   ├── sprint-aar-template.md
│   └── incident-aar-template.md
└── index.md

```

### Integration Points

**1. Issue AARs (Attached to Issues):**

- Created when closing issues via automation

- Attached as final comment before closure

- Cross-referenced in `.aar/` directory

**2. Sprint AARs (Standalone Documents):**

- Stored in `.aar/YYYY/QX/sprints/`

- Referenced in relevant PRs and issues

- Linked in quarterly review cycles

**3. Incident AARs (Both Locations):**

- Immediate: Attached to incident issue

- Permanent: Stored in `.aar/YYYY/incidents/`

- Cross-referenced in troubleshooting docs

## AAR Automation Integration

### GitHub Actions Workflow

The AAR automation runs automatically when:

- Issues labeled with `critical`, `infrastructure`, `security`, or `needs-aar` are closed

- Manual workflow dispatch for sprint, incident, or automation AARs

### Script Integration

```bash

# Generate different types of AARs

./scripts/generate_aar.sh issue 1234
./scripts/generate_aar.sh sprint "Q1 Git Utilities Enhancement"
./scripts/generate_aar.sh incident "CI Failure Cascade"
./scripts/generate_aar.sh automation "Enhanced Git Workflow"

```

## AAR Content Standards

### Required Sections

#### 1. Executive Summary

- What was accomplished or resolved

- Key decisions made

- Impact on project goals

#### 2. Timeline & Context

- Start/end dates

- Key milestones

- Related issues/PRs

#### 3. What Worked Well

- Successful patterns

- Effective tools/processes

- Team collaboration highlights

#### 4. Areas for Improvement

- Process bottlenecks

- Tool limitations

- Communication gaps

#### 5. Action Items

- Specific improvements to implement

- Owner assignments

- Target completion dates

#### 6. Lessons Learned

- Knowledge gained

- Best practices identified

- Anti-patterns to avoid

### Integration with DevOnboarder Standards

**Virtual Environment Context:**

- Document any dependency or environment issues

- Record setup improvements for future developers

**CI/CD Integration:**

- Reference relevant workflow runs

- Document automation improvements

- Note coverage or quality impacts

**Security & Quality:**

- Enhanced Potato Policy implications

- Code quality pattern observations

- Security considerations addressed

## AAR Review Process

### 1. **Draft Creation**

- Generated automatically via scripts or manual template

- Created within 24 hours of issue closure

- Includes all required sections

### 2. **Team Review**

- Posted for team review (2-3 days)

- Comments and suggestions incorporated

- Final version approved by project lead

### 3. **Integration & Follow-up**

- Action items tracked in project management

- Process improvements implemented

- Knowledge shared in team communications

### 4. **Quarterly Review**

- AAR patterns analyzed for meta-improvements

- Process effectiveness assessed

- AAR process itself refined

## Automation Integration

### Issue Comment AARs

When closing qualifying issues, automation adds:

```markdown

## 📋 After Actions Report

**Issue Summary**: [Brief description]
**Resolution**: [How it was resolved]
**Key Learnings**: [What we learned]
**Process Improvements**: [What we'll do differently]

**Full AAR**: See `.aar/2025/Q1/issues/issue-1234-description.md`

**Action Items**:

- [ ] Update documentation (Owner: @username, Due: YYYY-MM-DD)

- [ ] Enhance automation (Owner: @username, Due: YYYY-MM-DD)

```

### Cross-Reference System

**In Issue Comments:**

- Link to permanent AAR storage

- Reference related issues/PRs

- Tag stakeholders for visibility

**In AAR Files:**

- Link back to original issue/PR

- Reference related AARs

- Connect to project milestones

## AAR Metrics & KPIs

### Process Effectiveness

- **AAR Completion Rate**: % of qualifying issues with completed AARs

- **Action Item Resolution**: % of AAR action items completed on time

- **Knowledge Transfer**: Documentation updates resulting from AARs

### Quality Indicators

- **Issue Recurrence**: Reduction in similar issues over time

- **Process Improvement**: Measurable improvements in development velocity

- **Team Learning**: Knowledge sharing and capability growth

### DevOnboarder Integration

- **CI Health**: Correlation between AAR insights and CI stability

- **Code Quality**: Impact on test coverage and code standards

- **Automation Effectiveness**: Improvements in script reliability

## Implementation Plan

### Phase 1: Infrastructure Setup (Week 1)

- [x] Create `.aar/` directory structure

- [x] Implement AAR generation scripts

- [x] Create GitHub Actions workflow

- [x] Establish templates

### Phase 2: Process Integration (Week 2-3)

- [ ] Update issue closure automation

- [ ] Train team on AAR process

- [ ] Pilot with recent issues

- [ ] Refine based on feedback

### Phase 3: Full Deployment (Week 4)

- [ ] Enable automatic AAR generation

- [ ] Establish quarterly review cycle

- [ ] Create metrics dashboard

- [ ] Document lessons learned

### Phase 4: Continuous Improvement (Ongoing)

- [ ] Monthly process review

- [ ] Quarterly meta-AAR

- [ ] Process refinement based on team feedback

- [ ] Integration with project management tools

## Integration with DevOnboarder Philosophy

This AAR process supports DevOnboarder's core principle of "quiet reliability" by:

- **Systematic Learning**: Converting every issue into institutional knowledge

- **Process Improvement**: Continuously refining development workflows

- **Quality Assurance**: Preventing issue recurrence through documentation

- **Team Growth**: Sharing knowledge and best practices across the team

- **Automation Enhancement**: Improving CI/CD based on real-world feedback

The AAR system operates "quietly" in the background while building a comprehensive knowledge base that makes the entire project more reliable over time.

## Quick Reference

### Creating AARs

```bash

# Issue AAR (automatic for critical/infrastructure/security issues)

./scripts/generate_aar.sh issue 1234

# Sprint AAR

./scripts/generate_aar.sh sprint "Sprint Name or Description"

# Incident AAR

./scripts/generate_aar.sh incident "Incident Description"

# Automation AAR

./scripts/generate_aar.sh automation "Enhancement Description"

```

### Viewing AARs

- **Index**: `.aar/index.md` - Overview of all AARs

- **Current Quarter**: `.aar/2025/Q1/` - Current quarter's AARs

- **Templates**: `.aar/templates/` - AAR templates for manual creation

### Follow-up Process

1. Review generated AAR for completeness

2. Assign specific action items to team members

3. Set realistic due dates based on priority

4. Track progress in follow-up issues or project management

5. Reference AAR insights in future similar situations

---

**Process Owner**: DevOnboarder Team

**Last Updated**: 2025-07-30
**Next Review**: 2025-10-30 (Quarterly)
