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

### Primary Storage: `docs/AAR/` Directory Structure

```text
docs/AAR/
├── data/
│   ├── project_name.aar.json          # JSON schema data files
│   └── another_project.aar.json
├── reports/
│   ├── 2025/
│   │   ├── Q1/
│   │   │   ├── Infrastructure/
│   │   │   │   ├── 2025-01-30_ci_failure_cascade.md
│   │   │   │   └── 2025-02-15_git_workflow_enhancement.md
│   │   │   ├── CI/
│   │   │   │   └── 2025-03-10_pre_commit_failures.md
│   │   │   └── Feature/
│   │   │       └── 2025-Q1_git_utilities_enhancement.md
│   │   └── Q2/
│   │       └── Documentation/
│   │           └── 2025-04-01_aar_system_migration.md
│   └── archive/
├── templates/
│   └── aar.hbs                        # Handlebars template for markdown generation
├── schema/
│   └── aar.schema.json                # JSON Schema validation
└── portal/
    └── index.html                     # Auto-generated AAR portal
```

### Schema-Driven AAR System

**Modern AAR Workflow**:

1. **Create JSON Data**: Use helper script or manual creation with schema validation
2. **Generate Markdown**: Automated rendering via Node.js with Handlebars templates
3. **Structured Storage**: Quarterly organization by type (Infrastructure, CI, Feature, etc.)
4. **Portal Integration**: Automatic HTML portal generation for easy navigation

### Integration Points

**1. Issue AARs (Schema-Driven):**

- Created using `./scripts/create_aar_json.sh` with structured data
- Generated markdown stored in `docs/AAR/reports/YYYY/QX/type/`
- Cross-referenced in portal and automated navigation

**2. Sprint AARs (Comprehensive Documentation):**

- JSON data in `docs/AAR/data/` with full phase tracking
- Rendered reports in `docs/AAR/reports/YYYY/QX/Feature/`
- Linked in quarterly portal views with action item tracking

**3. Incident AARs (Dual Integration):**

- Immediate: JSON schema validation ensures complete data capture
- Permanent: Structured storage in `docs/AAR/reports/YYYY/QX/CI/` or `Infrastructure/`
- Cross-referenced in troubleshooting docs

## AAR Automation Integration

### GitHub Actions Workflow

The AAR automation runs automatically when:

- Issues labeled with `critical`, `infrastructure`, `security`, or `needs-aar` are closed
- Manual workflow dispatch for sprint, incident, or automation AARs

### Script Integration

```bash
# Schema-driven AAR creation workflow
./scripts/create_aar_json.sh "Project Title" "Infrastructure" "High"

# Generate markdown from JSON data
node scripts/render_aar.js docs/AAR/data/project-title.aar.json docs/AAR/reports

# Generate AAR portal with all reports
python scripts/generate_aar_portal.py

# Validate AAR against schema
npm run aar:validate docs/AAR/data/project-title.aar.json

# Legacy shell generators (for existing workflows)
./scripts/enhanced_aar_generator.sh automation --title "Enhanced Git Workflow"
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

**Full AAR**: See `docs/AAR/reports/2025/Q1/Infrastructure/issue-1234-description.md`

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

- [x] Create `docs/AAR/` directory structure
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

- **Portal**: `docs/AAR/portal/index.html` - Auto-generated navigation portal
- **Current Quarter**: `docs/AAR/reports/2025/Q1/` - Current quarter's AARs by type
- **Templates**: `docs/AAR/templates/aar.hbs` - Handlebars template for markdown generation

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
