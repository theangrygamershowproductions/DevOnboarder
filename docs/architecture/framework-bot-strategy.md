# DevOnboarder Framework-Based Bot Architecture Strategy

## Overview

This document outlines the evolution from our current 2-bot system to a comprehensive framework-based bot architecture, where each automation framework has its own dedicated bot identity with separate credentials, GPG keys, and tokens.

## Current State Analysis

### Existing Bots

- **Priority Matrix Bot**: `pmbot@theangrygamershow.com` (AB78428FE3A090D3)
- **AAR Bot**: `aarbot@theangrygamershow.com` (99CA270AD84AE20C)

### Current Workflows Using GPG

- `priority-matrix-synthesis.yml` → Priority Matrix Bot
- `aar-automation.yml` → AAR Bot
- `aar-portal.yml` → AAR Bot
- `test-gpg-framework.yml` → AAR Bot

## Proposed Framework-Based Architecture

### **Core Security Principles**

- **Unified Corporate Account**: All bots managed through `scarabofthespudheap` GitHub account
- **Framework Isolation**: Each framework has dedicated email, GPG key, and token
- **Principle of Least Privilege**: Framework-specific permissions and access
- **Clear Attribution**: Commit signatures clearly identify automation framework
- **Granular Revocation**: Ability to disable specific frameworks independently

### **Framework Bot Mapping**

| Framework | Bot Email | Workflow Categories | Current Workflows |
|-----------|-----------|-------------------|------------------|
| **Priority Matrix Framework** | `priority-matrix@theangrygamershow.com` | Document synthesis, content organization | `priority-matrix-synthesis.yml` |
| **AAR Framework** | `aar@theangrygamershow.com` | After Action Reports, CI analysis | `aar-automation.yml`, `aar-portal.yml` |
| **CI Health Framework** | `ci-health@theangrygamershow.com` | CI monitoring, failure analysis | `ci-health.yml`, `cleanup-ci-failure.yml`, `pr-ci-analysis.yml` |
| **Documentation Framework** | `docs@theangrygamershow.com` | Documentation quality, validation | `markdownlint.yml`, `env-doc-alignment.yml` |
| **Security Framework** | `security@theangrygamershow.com` | Security audits, policy enforcement | `security-audit.yml`, `no-verify-policy.yml`, `terminal-policy-enforcement.yml` |
| **Quality Control Framework** | `quality@theangrygamershow.com` | Code quality, auto-fixing | `auto-fix.yml`, `quality-gate-health.yml` |
| **Environment Framework** | `environment@theangrygamershow.com` | Environment management, orchestration | `prod-orchestrator.yml`, `dev-orchestrator.yml`, `staging-orchestrator.yml` |
| **Issue Management Framework** | `issues@theangrygamershow.com` | Issue automation, PR management | `pr-issue-automation.yml`, `post-merge-cleanup.yml`, `branch-cleanup.yml` |

### **Extended Framework Mapping**

| Framework | Bot Email | Additional Scope |
|-----------|-----------|------------------|
| **Validation Framework** | `validation@theangrygamershow.com` | Agent validation, permission checks |
| **Monitoring Framework** | `monitoring@theangrygamershow.com` | Health monitoring, alerting |
| **Deployment Framework** | `deployment@theangrygamershow.com` | Release management, deployment |
| **Testing Framework** | `testing@theangrygamershow.com` | Test automation, coverage |

## Benefits Analysis

### **Security Benefits**

- **Blast Radius Limitation**: Compromise of one framework doesn't affect others
- **Independent Revocation**: Can disable specific automation without system-wide impact
- **Clear Audit Trails**: Framework-specific commit signatures for compliance
- **Privilege Separation**: Each framework only has access to required resources
- **Corporate Governance**: All bots managed through single corporate account

### **Operational Benefits**

- **Clear Attribution**: Commits clearly show which automation framework made changes
- **Framework Scaling**: Easy to add new automation without credential conflicts
- **Maintenance Isolation**: Can update/maintain one framework without affecting others
- **Debugging Clarity**: Issues can be traced to specific automation frameworks
- **Documentation Clarity**: Framework-to-bot mapping provides clear ownership

### **Development Benefits**

- **Microservice Alignment**: Matches DevOnboarder's microservice architecture principles
- **Independent Evolution**: Frameworks can evolve at different paces
- **Team Specialization**: Different teams can own different automation frameworks
- **Testing Isolation**: Framework changes can be tested independently

## Implementation Strategy

### **Phase 1: Core Framework Separation**

1. **Priority Matrix Framework** - Dedicated bot for document synthesis
2. **AAR Framework** - Dedicated bot for After Action Reports
3. **CI Health Framework** - Dedicated bot for CI monitoring and analysis

### **Phase 2: Quality & Security Frameworks**

1. **Documentation Framework** - Dedicated bot for documentation automation
2. **Security Framework** - Dedicated bot for security policy enforcement
3. **Quality Control Framework** - Dedicated bot for code quality automation

### **Phase 3: Advanced Framework Specialization**

1. **Environment Framework** - Dedicated bot for deployment orchestration
2. **Issue Management Framework** - Dedicated bot for issue and PR automation
3. **Validation Framework** - Dedicated bot for agent and permission validation

### **Phase 4: Extended Framework Support**

1. **Monitoring Framework** - Dedicated bot for health monitoring
2. **Deployment Framework** - Dedicated bot for release management
3. **Testing Framework** - Dedicated bot for test automation

## Technical Implementation

### **GPG Key Management Pattern**

```bash
# Generate framework-specific GPG key
gpg --batch --generate-key << EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: DevOnboarder CI Health Framework Bot
Name-Email: ci-health@theangrygamershow.com
Expire-Date: 2y
%no-protection
%commit
EOF
```

### **GitHub Secrets Structure**

```yaml
# Framework-specific secrets pattern
PRIORITY_MATRIX_BOT_GPG_PRIVATE: <base64-encoded-key>
AAR_BOT_GPG_PRIVATE: <base64-encoded-key>
CI_HEALTH_BOT_GPG_PRIVATE: <base64-encoded-key>
DOCS_BOT_GPG_PRIVATE: <base64-encoded-key>
SECURITY_BOT_GPG_PRIVATE: <base64-encoded-key>
QUALITY_BOT_GPG_PRIVATE: <base64-encoded-key>
```

### **GitHub Variables Structure**

```yaml
# Framework-specific variables pattern
PRIORITY_MATRIX_BOT_KEY_ID: <gpg-key-id>
PRIORITY_MATRIX_BOT_NAME: "Priority Matrix Framework Bot"
PRIORITY_MATRIX_BOT_EMAIL: "priority-matrix@theangrygamershow.com"

CI_HEALTH_BOT_KEY_ID: <gpg-key-id>
CI_HEALTH_BOT_NAME: "CI Health Framework Bot"
CI_HEALTH_BOT_EMAIL: "ci-health@theangrygamershow.com"
```

### **Workflow Template Pattern**

```yaml
name: Framework Automation Workflow

on:
  workflow_dispatch:

jobs:
  framework-automation:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5
        with:
          token: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN || secrets.GITHUB_TOKEN }}

      - name: Setup GPG commit signing (Framework Bot)
        env:
          FRAMEWORK_BOT_GPG_PRIVATE: ${{ secrets.CI_HEALTH_BOT_GPG_PRIVATE }}
          FRAMEWORK_BOT_GPG_KEY_ID: ${{ vars.CI_HEALTH_BOT_KEY_ID }}
          FRAMEWORK_BOT_NAME: ${{ vars.CI_HEALTH_BOT_NAME }}
          FRAMEWORK_BOT_EMAIL: ${{ vars.CI_HEALTH_BOT_EMAIL }}
        run: |
          printf '%s\n' "$FRAMEWORK_BOT_GPG_PRIVATE" | base64 -d | gpg --batch --import --quiet
          git config --global user.name "$FRAMEWORK_BOT_NAME"
          git config --global user.email "$FRAMEWORK_BOT_EMAIL"
          git config --global user.signingkey "$FRAMEWORK_BOT_GPG_KEY_ID"
          git config --global commit.gpgsign true

      # Framework-specific automation steps here

      - name: Commit changes (GPG signed)
        run: |
          git add .
          git commit -m "AUTO(framework): automation description [signed]"
          git push
```

## Migration Strategy

### **Current to Framework Transition**

1. **Keep existing bots operational** during transition
2. **Map current workflows** to appropriate framework bots
3. **Generate new framework-specific credentials** for unmapped workflows
4. **Update workflow configurations** to use framework-specific bots
5. **Validate framework isolation** through testing
6. **Deprecate general-purpose bots** once all workflows migrated

### **Workflow Migration Schedule**

- **Week 1**: Priority Matrix and AAR frameworks (already implemented)
- **Week 2**: CI Health framework (3-4 workflows)
- **Week 3**: Documentation and Security frameworks (4-5 workflows each)
- **Week 4**: Quality Control and Environment frameworks (3-4 workflows each)
- **Week 5**: Issue Management and Validation frameworks (remaining workflows)

## Governance & Compliance

### **Corporate Security Requirements**

- **All GPG keys managed** through corporate `scarabofthespudheap` account
- **Multi-factor authentication** required for corporate account access
- **Regular credential rotation** scheduled (annually for GPG keys)
- **Emergency revocation procedures** documented and tested
- **Audit trail compliance** for all automated commits

### **Framework Ownership Model**

- **Framework Lead**: Responsible for bot credentials and workflow maintenance
- **Security Review**: Corporate approval required for new framework bots
- **Documentation Standards**: Each framework must document bot usage and scope
- **Access Reviews**: Quarterly review of framework bot permissions and usage

## Recommended Next Steps

### **Immediate Actions (This Week)**

1. **Document current bot→framework mapping** for existing workflows
2. **Generate CI Health Framework Bot** credentials (highest priority unmapped category)
3. **Create framework bot setup scripts** based on existing AAR/Priority Matrix patterns
4. **Update GPG framework documentation** with framework-specific guidance

### **Short Term (Next 2 Weeks)**

1. **Implement CI Health Framework Bot** and migrate 3-4 workflows
2. **Generate Documentation Framework Bot** and migrate markdown/validation workflows
3. **Create framework-specific setup documentation** for each bot
4. **Validate framework isolation** through testing and commit signature verification

### **Medium Term (Next Month)**

1. **Complete migration** of all 22+ workflows to framework-specific bots
2. **Implement framework governance procedures** and documentation
3. **Establish credential rotation schedule** and emergency procedures
4. **Create framework monitoring dashboard** for bot health and usage

## Conclusion

Framework-specific bot architecture represents a significant evolution in DevOnboarder's automation security posture. This approach provides:

- **Enhanced Security**: Granular access control and blast radius limitation
- **Operational Clarity**: Clear framework ownership and attribution
- **Scalability**: Easy addition of new automation frameworks
- **Enterprise Compliance**: Corporate governance and audit trail requirements

The investment in framework-specific bots aligns with DevOnboarder's enterprise security standards and positions the project for robust, scalable automation growth.

---

**Status**: Strategic Planning Complete - Ready for Implementation
**Next Action**: Begin CI Health Framework Bot implementation
**Priority**: High - Supports DevOnboarder's enterprise security evolution
