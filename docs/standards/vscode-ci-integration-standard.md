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
title: Vscode Ci Integration Standard
updated_at: '2025-09-12'
virtual_env_required: true
visibility: internal
---

# Development Standards: VS Code/CI Integration Framework

**Document Type**: Standard Practice
**Status**: ACTIVE
**Effective Date**: August 7, 2025
**Next Review**: November 7, 2025
**Owner**: DevOnboarder Team

## Overview

This document establishes the mandatory VS Code/CI Integration Framework as the standard development practice for DevOnboarder, based on the successful elimination of "hit and miss" development patterns and achievement of 91% local CI success rate.

## Standard Practice Status

**✅ MANDATORY**: All DevOnboarder development MUST use this integrated framework
**🎯 Objective**: Eliminate CI surprises and ensure 100% consistency between local and CI environments
**📊 Success Criteria**: 90%+ local CI simulation accuracy, 100% YAML linting consistency

## Core Framework Components

### 1. VS Code Workspace Configuration - MANDATORY

#### Required Files (Team Standardization)

**`.vscode/settings.json`**:

- Python virtual environment integration (`python.defaultInterpreterPath: "./.venv/bin/python"`)

- YAML validation with DevOnboarder `.yamllint` rules

- Terminal environment configuration for consistent tooling

- Testing framework integration (pytest, Jest, Vitest)

**`.vscode/tasks.json`**:

- **DevOnboarder: Quick Validation** - Fast development checks

- **DevOnboarder: Full CI Validation** - Complete local CI simulation

- **DevOnboarder: Targeted Validation** - Section/step-specific testing

- **DevOnboarder: Monitor Validation** - Continuous validation monitoring

**`.vscode/extensions.json`**:

- Required extensions for team consistency

- YAML support, Python tooling, testing frameworks

- Markdown and documentation quality tools

#### Implementation Requirements

- **MANDATORY**: Use VS Code workspace configuration for all development

- **MANDATORY**: Install recommended extensions (auto-prompted by VS Code)

- **MANDATORY**: Access DevOnboarder tools via Command Palette (`Ctrl+Shift+P`)

- **MANDATORY**: Activate integrated virtual environment before development

### 2. YAML Linting Consistency - 100% ALIGNMENT

#### `.yamllint` Configuration Standards

**Consistent Indentation**: `spaces: consistent` - Supports both 2-space and 4-space styles

**Reasonable Line Length**: 160 characters (vs default 80) for GitHub Actions
**Truthy Handling**: Allows 'on' as YAML key without warnings
**Document Start**: Disabled for workflow files

#### YAML Development Requirements

- **ALWAYS**: Test YAML changes using VS Code integrated validation

- **NEVER**: Commit YAML that fails local validation

- **ALWAYS**: Use consistent indentation within each file

- **VERIFICATION**: VS Code shows real-time YAML validation status

### 3. Local CI Simulation Framework - 90%+ COVERAGE

#### Comprehensive Validation Script: `validate_ci_locally.sh`

**Coverage**: 47 validation steps across 9 major sections
**Success Rate**: 91% CI prediction accuracy achieved
**Execution Modes**:

- **Full validation**: `./scripts/validate_ci_locally.sh`

- **Targeted validation**: `./scripts/validate_ci_locally.sh --section frontend`

- **Step-specific**: `./scripts/validate_ci_locally.sh --step "Python Tests"`

- **Quick validation**: `./scripts/quick_validate.sh`

#### Local Validation Requirements

- **MANDATORY**: Run local validation before every commit

- **MANDATORY**: Achieve 90%+ local validation success before pushing

- **NEVER**: Push changes that fail local CI simulation

- **ALWAYS**: Use targeted validation for focused development

### 4. Pre-commit Hook Integration - EXACT CI MIRROR

#### Enhanced `.pre-commit-config.yaml`

**yamllint Integration**: Consistent with `.yamllint` configuration
**Terminal Output Policy**: Prevents hanging terminal issues
**Root Artifact Guard**: Blocks repository pollution
**Comprehensive Validation**: 18 hooks covering all quality gates

#### Pre-commit Process Requirements

- **ALWAYS**: Allow pre-commit hooks to run completely

- **NEVER**: Use `--no-verify` to bypass quality gates

- **ALWAYS**: Use `scripts/safe_commit.sh` for commit management

- **ALWAYS**: Address pre-commit failures properly

## Development Workflow Standards

### Daily Development Process

#### 1. Environment Setup

```bash

# Required first step for all development

cd /path/to/DevOnboarder
source .venv/bin/activate
code .  # Opens VS Code with workspace configuration

```

#### 2. Development Phase

- **Before coding**: Run "DevOnboarder: Quick Validation" via Command Palette

- **During development**: Use integrated YAML validation and testing tools

- **File changes**: Monitor VS Code integrated validation status

- **Virtual environment**: Always use `.venv` activated through VS Code

#### 3. Pre-commit Validation

```bash

# MANDATORY: Local CI simulation before commit

./scripts/validate_ci_locally.sh

# Or via VS Code Command Palette

# Ctrl+Shift+P → "DevOnboarder: Full CI Validation"

```

#### 4. Commit Process

```bash

# MANDATORY: Use safe commit wrapper

./scripts/safe_commit.sh "FEAT(component): descriptive commit message"

# NEVER bypass quality gates

# git commit --no-verify  # ❌ FORBIDDEN

```

### Team Collaboration Standards

#### Code Review Requirements

- **MANDATORY**: Reviewer must verify VS Code workspace compliance

- **MANDATORY**: All changes must pass local CI simulation

- **VERIFICATION**: 90%+ local validation success rate demonstrated

- **DOCUMENTATION**: Update workspace configuration if needed

#### Onboarding Requirements

- **New developers**: Must complete VS Code workspace setup

- **Training**: Command Palette task usage demonstration

- **Validation**: Local CI simulation training and verification

- **Standards**: This document review and acknowledgment

## Success Metrics & Monitoring

### Key Performance Indicators

**Local CI Success Rate**: 90%+ validation accuracy (Target: 95%)

**YAML Consistency**: 100% VS Code/CI alignment (Maintained)
**Developer Experience**: <5 minutes from code to validated commit
**CI Surprises**: <5% failures that pass local validation

### Quality Gates

**Pre-commit Success**: 95%+ first-attempt success rate

**Framework Adoption**: 100% team usage of VS Code workspace
**Tool Integration**: 100% use of Command Palette tasks
**Documentation Currency**: Monthly review and updates

### Monitoring & Reporting

**Weekly**: CI success rate tracking and trend analysis
**Monthly**: Framework effectiveness review and improvement identification
**Quarterly**: Complete framework assessment and standard updates

## Troubleshooting & Support

### Common Issues & Solutions

#### 1. YAML Linting Conflicts

**Symptom**: VS Code shows different validation than CI
**Solution**: Verify `.yamllint` configuration is current and applied
**Prevention**: Always use VS Code integrated YAML validation

#### 2. Local CI Simulation Failures

**Symptom**: Local validation passes but CI fails
**Root Cause**: Virtual environment or dependency inconsistency
**Solution**: Re-run `pip install -e .[test]` and validate environment

#### 3. Pre-commit Hook Failures

**Symptom**: Commit blocked by formatting or linting issues
**Solution**: Use `scripts/safe_commit.sh` for automatic re-staging
**Prevention**: Run quick validation before attempting commits

#### 4. Command Palette Integration Missing

**Symptom**: DevOnboarder tasks not available in VS Code
**Solution**: Verify `.vscode/tasks.json` is current and reload window
**Prevention**: Regular VS Code workspace configuration updates

### Escalation Process

**Level 1**: Review this documentation and run local diagnostics
**Level 2**: Check AAR documents for similar issues and solutions
**Level 3**: Create issue with `needs-aar` label for team review
**Level 4**: Schedule framework review session with team

## Framework Evolution & Updates

### Continuous Improvement Process

#### Monthly Reviews

- Analyze CI success rate trends and framework effectiveness

- Collect developer feedback on workflow integration

- Identify process bottlenecks and improvement opportunities

- Update tools and configurations based on lessons learned

#### Quarterly Assessments

- Complete framework evaluation against success metrics

- Team training updates and onboarding process refinement

- Integration of new tools and DevOnboarder capabilities

- Update this standard practice document with improvements

#### Annual Framework Audit

- Comprehensive review of all framework components

- Technology stack updates and compatibility verification

- Process effectiveness measurement against project goals

- Strategic planning for framework enhancements

### Change Management

**Minor Updates**: Configuration tweaks, script improvements
**Major Updates**: New tool integration, workflow changes
**Breaking Changes**: Require team consensus and migration plan
**Emergency Updates**: Security or critical reliability fixes

## Implementation History

### Framework Development

**August 7, 2025**: VS Code/CI Integration Framework completed
**Achievement**: 91% CI success rate, 100% YAML consistency
**Commit**: `41bfd63` - Complete VS Code/CI consistency integration

**Documentation**: AAR_VSCODE_CI_INTEGRATION_2025-08-07.md

### Key Milestones

**Technical Deliverables**: 18 files modified, 1622 insertions
**Success Metrics**: 47-step validation framework, 9 major sections
**Team Impact**: Eliminated "hit and miss" development experience
**Process Transformation**: Predictable development with local CI simulation

## Compliance & Governance

### Mandatory Compliance

This framework is **MANDATORY** for all DevOnboarder development work:

- **Code contributions**: Must use VS Code workspace configuration

- **Pull requests**: Must demonstrate local CI validation success

- **Team onboarding**: Must include framework training and setup

- **Process deviations**: Require explicit approval and documentation

### Audit & Verification

**Monthly**: Team compliance verification and metrics review
**Quarterly**: Framework effectiveness audit and improvement planning
**Ad-hoc**: Issue investigation and process validation
**Annual**: Complete governance review and standard updates

## References & Resources

### Documentation

- **AAR Document**: `docs/AAR_VSCODE_CI_INTEGRATION_2025-08-07.md`

- **Implementation Summary**: `docs/AAR_VSCODE_CI_INTEGRATION_SUMMARY.md`

- **GitHub Copilot Instructions**: `.github/copilot-instructions.md` (VS Code section)

- **Targeted Testing Framework**: `docs/TARGETED_TESTING_FRAMEWORK.md`

### Scripts & Tools

- **Local CI Simulation**: `scripts/validate_ci_locally.sh`

- **Quick Validation**: `scripts/quick_validate.sh`

- **Safe Commit Wrapper**: `scripts/safe_commit.sh`

- **VS Code Setup**: `scripts/setup_vscode_integration.sh`

### Configuration Files

- **YAML Linting**: `.yamllint`

- **Pre-commit Hooks**: `.pre-commit-config.yaml`

- **VS Code Workspace**: `.vscode/settings.json`, `.vscode/tasks.json`, `.vscode/extensions.json`

---

**Standard Practice Established**: August 7, 2025

**Based on AAR**: VS Code/CI Integration Framework Success
**Success Rate**: 91% CI prediction accuracy, 100% YAML consistency
**Team Impact**: Eliminated "hit and miss" development patterns
**Next Review**: November 7, 2025 (Quarterly cycle)

This standard practice embodies DevOnboarder's philosophy of "quiet reliability" through systematic process improvement and comprehensive automation integration.
