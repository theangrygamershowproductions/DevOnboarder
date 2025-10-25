---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: pr-issue-automation.md-docs
status: active
tags:

- documentation

title: Pr Issue Automation
updated_at: '2025-09-12'
visibility: internal
---

# PR-to-Issue Automation System

## Overview

DevOnboarder now includes **automatic issue creation and linking** when Pull Requests are opened, providing comprehensive tracking throughout the development lifecycle.

## SYNC: How It Works

### 1. **Automatic Issue Creation**

When a PR is opened:

- **Workflow**: `.github/workflows/pr-issue-automation.yml` triggers

- **Script**: `scripts/create_pr_tracking_issue.sh` creates detailed tracking issue

- **Labels**: Automatically applies `pr-tracking`, `automated`, and type-specific labels

- **Linking**: Issues and PRs are cross-referenced with comments

### 2. **Automatic Issue Closure**

When a PR is merged:

- **Workflow**: `.github/workflows/pr-merge-cleanup.yml` triggers

- **Action**: Finds and closes associated tracking issue

- **Comments**: Adds completion summary to both issue and PR

##  Issue Content Structure

Each tracking issue includes:

###  Development Progress Checklist

- [ ] Initial Implementation: Code changes committed

- [ ] Code Review: PR reviewed by maintainers

- [ ] CI/CD Validation: All automated checks passing

- [ ] Testing Complete: Manual testing validated

- [ ] Documentation Updated: Required docs updated

- [ ] Ready for Merge: PR approved for integration

### 🎯 Acceptance Criteria

- All CI checks passing (coverage, linting, security)

- Code reviewed and approved by maintainers

- Documentation updated where applicable

- No breaking changes or proper migration provided

- Follows DevOnboarder quality standards

###  Technical Details

- Implementation scope and architecture notes

- Integration requirements

- Compliance requirements

## LABEL: Labeling System

### Automatic Labels Applied

**Base Labels** (always applied):

- `pr-tracking` - Identifies PR tracking issues

- `automated` - Indicates automated creation

- `development` - Development-related issue

**Type-Specific Labels** (based on PR title):

- `type-feature` - FEAT: prefix detected

- `type-bugfix` -  prefix detected

- `type-documentation` - DOCS: prefix detected

- `type-maintenance` - CHORE: prefix detected

##  Token Security

Uses DevOnboarder's **hierarchical token system**:

1. **CI_ISSUE_AUTOMATION_TOKEN** (primary) - Fine-grained permissions

2. **CI_BOT_TOKEN** (secondary) - Bot operations

3. **GITHUB_TOKEN** (fallback) - Standard GitHub Actions token

##  File Structure

```text
.github/workflows/
── pr-issue-automation.yml     # Creates issues when PRs opened

── pr-merge-cleanup.yml        # Closes issues when PRs merged

scripts/
── create_pr_tracking_issue.sh # Issue creation logic

logs/
── pr_issue_creation_*.log     # Centralized logging

```

## 🎯 Benefits

### For Developers

- **Clear Progress Tracking**: Visual progress through development stages

- **Automatic Documentation**: Issues capture full development context

- **Historical Record**: Complete audit trail of feature development

### For Project Management

- **Comprehensive Tracking**: Every PR has corresponding issue

- **Automated Workflows**: No manual issue creation required

- **Consistent Labeling**: Standardized categorization across all development

### For DevOnboarder Philosophy

- **"Quiet Reliability"**: Works automatically without manual intervention

- **Quality Standards**: Enforces acceptance criteria and completion tracking

- **Centralized Logging**: All automation logged to `logs/` directory

##  Configuration

### Required Permissions

**GitHub Actions Workflows**:

```yaml
permissions:
    contents: read
    pull-requests: write
    issues: write

```

### Environment Variables

**Recommended Setup**:

```bash

# Fine-grained token with issues:write, pull_requests:write

CI_ISSUE_AUTOMATION_TOKEN=github_pat_...

# Bot token with appropriate permissions

CI_BOT_TOKEN=ghp_...

# Standard GitHub Actions token (fallback)

GITHUB_TOKEN=ghp_...

```

##  Usage Examples

### Manual Triggering

**Create tracking issue for existing PR**:

```bash
gh workflow run pr-issue-automation.yml -f pr_number=1234

```

**Close tracking issue for merged PR**:

```bash
gh workflow run pr-merge-cleanup.yml -f pr_number=1234

```

### Script Usage

**Direct script execution**:

```bash
bash scripts/create_pr_tracking_issue.sh 1234 "FEAT: new feature" "username" "feat/feature-branch"

```

##  Integration Points

### Existing DevOnboarder Automation

- **CI Failure Issues**: Separate from PR tracking (uses `ci-failure` label)

- **AAR System**: Can reference PR tracking issues in After Action Reports

- **Quality Gates**: PR tracking respects existing quality standards

- **Centralized Logging**: Follows established logging patterns

### Workflow Triggers

- **PR Events**: `opened`, `reopened` trigger issue creation

- **PR Events**: `closed` (with merged=true) triggers issue closure

- **Manual Dispatch**: Both workflows support manual triggering

## 🎉 Success Metrics

### Automation Coverage

- **100% PR Coverage**: Every non-draft PR gets tracking issue

- **Automatic Lifecycle**: Creation and closure fully automated

- **Zero Manual Work**: No developer intervention required

### Quality Improvement

- **Progress Visibility**: Clear development stage tracking

- **Consistent Documentation**: Standardized issue format

- **Historical Tracking**: Complete development audit trail

##  Example Issue Created

```markdown

# PR Tracking Issue: #1234

##  Overview

This issue tracks the development and review progress of **Pull Request #1234**.

### LINK: PR Details

- **Title**: FEAT: implement user authentication system

- **Author**: @developer

- **Branch**: `feat/user-auth`

- **Type**: feature-development

- **Priority**: medium

###  Development Progress

- [ ] **Initial Implementation**: Code changes committed to feature branch

- [ ] **Code Review**: PR reviewed by maintainers

- [ ] **CI/CD Validation**: All automated checks passing

- [ ] **Testing Complete**: Manual testing validated

- [ ] **Documentation Updated**: Any required docs updated

- [ ] **Ready for Merge**: PR approved and ready for integration

[... full issue template ...]

```

---

**Implementation Status**:  Complete and Ready for Production

**DevOnboarder Integration**:  Follows all project standards
**Automation Level**:  Fully automated with zero manual intervention
