---
author: "DevOnboarder Team"
ci_integration: true
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Standards documentation"

document_type: standards
merge_candidate: false
project: DevOnboarder
similarity_group: standards-standards
status: active
tags: 
title: Readme

updated_at: 2025-10-27
virtual_env_required: true
visibility: internal
---

# DevOnboarder Standards Index

This directory contains the standard practices and policies that govern DevOnboarder development and operations.

## Active Standards

### Development Practices

| Standard | Document | Status | Last Updated |
|----------|----------|---------|--------------|
| **VS Code/CI Integration Framework** | [`vscode-ci-integration-standard.md`](vscode-ci-integration-standard.md) |  ACTIVE | 2025-08-07 |

| **After Actions Report Process** | [`after-actions-report-process.md`](after-actions-report-process.md) |  ACTIVE | 2025-07-30 |

| **Debug Protocol Macro v1.2** | [`debug-protocol-macro.md`](debug-protocol-macro.md) |  ACTIVE | 2025-09-13 |

| **Centralized Logging Policy** | [`centralized-logging-policy.md`](centralized-logging-policy.md) |  ACTIVE | TBD |

## Standard Types

###  Development Standards

**Purpose**: Establish consistent development practices across the team
**Scope**: Tools, workflows, quality gates, and team collaboration
**Examples**: VS Code integration, CI/CD practices, code review processes

###  Process Standards

**Purpose**: Define operational procedures and governance
**Scope**: Issue management, documentation, reporting, and communication
**Examples**: AAR process, logging requirements, security policies

### 🔒 Policy Standards

**Purpose**: Establish security, compliance, and governance requirements
**Scope**: Security practices, data handling, access control, and audit
**Examples**: Enhanced Potato Policy, token management, artifact handling

## Implementation Requirements

### Mandatory Compliance

All standards marked as ** ACTIVE** are mandatory for:

- **All team members**: Must follow established practices

- **Code contributions**: Must meet standard requirements

- **Pull requests**: Must demonstrate compliance

- **Onboarding**: Must include standards training

### Review Cycle

- **Monthly**: Compliance verification and effectiveness assessment

- **Quarterly**: Standard updates and improvement implementation

- **Annual**: Complete governance review and strategic alignment

- **Ad-hoc**: Emergency updates for security or critical issues

## Standard Development Process

### 1. **Identification**

- Need identified through AAR process, team feedback, or operational issues

- Impact assessment and priority determination

- Stakeholder review and consensus building

### 2. **Development**

- Draft standard creation using established template

- Technical validation and feasibility assessment

- Team review and feedback incorporation

### 3. **Implementation**

- Pilot testing with subset of team or projects

- Training materials development and delivery

- Gradual rollout with success metrics monitoring

### 4. **Maintenance**

- Regular effectiveness review and metric tracking

- Continuous improvement based on feedback and results

- Version control and change management

## Quick Reference

### For Developers

- **Start here**: [`vscode-ci-integration-standard.md`](vscode-ci-integration-standard.md) - Essential development workflow

- **When debugging**: [`debug-protocol-macro.md`](debug-protocol-macro.md) - Structured problem resolution framework

- **When issues arise**: [`after-actions-report-process.md`](after-actions-report-process.md) - AAR process

- **For operations**: [`centralized-logging-policy.md`](centralized-logging-policy.md) - Logging requirements

### For Team Leads

- **Standards overview**: This index document

- **Compliance monitoring**: Standard-specific KPIs and metrics

- **Change management**: Standard development and update process

- **Training coordination**: Team onboarding and capability development

### For Project Management

- **Process governance**: AAR system and continuous improvement

- **Quality assurance**: Standard compliance verification

- **Risk management**: Policy adherence and security practices

- **Strategic alignment**: Standards effectiveness and project goals

## Integration Points

### GitHub Copilot Instructions

Standards are referenced in [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) to ensure AI agents follow established practices.

### CI/CD Pipeline

Standards compliance is enforced through:

- Pre-commit hooks validating standard requirements

- GitHub Actions workflows checking adherence

- Automated quality gates and metrics collection

### Documentation

Standards are integrated with:

- AAR process for continuous improvement

- Team onboarding materials and training

- Project documentation and troubleshooting guides

---

**Index Maintained By**: DevOnboarder Team

**Last Updated**: September 13, 2025
**Next Review**: November 7, 2025

*This index follows DevOnboarder's philosophy of "quiet reliability" through systematic documentation and process standardization.*
