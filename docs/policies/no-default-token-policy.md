# No Default Token Policy v1.0

**Policy Version**: 1.0
**Effective Date**: $(date +%Y-%m-%d)
**Classification**: Security Critical - Internal Use
**Review Cycle**: Quarterly

## Executive Summary

The No Default Token Policy establishes comprehensive governance for GitHub token usage within the DevOnboarder project. This policy prohibits the use of default `GITHUB_TOKEN` for API operations and mandates the use of specialized, scoped tokens with clearly defined bot identities and minimal permissions.

## Policy Statement

### Core Principle

**DevOnboarder operates under a zero-default-token model where all automation must use explicitly defined, purpose-built tokens with documented scopes and clear bot identities.**

### Fundamental Requirements

1. **Prohibition of GITHUB_TOKEN**: Direct usage of `GITHUB_TOKEN` for GitHub API operations is strictly prohibited
2. **Specialized Token Mandate**: All automation must use specialized tokens designed for specific purposes
3. **Bot Identity Requirement**: Every token must have a clearly defined bot identity and ownership
4. **Minimal Permissions**: Tokens must implement the principle of least privilege
5. **Comprehensive Documentation**: All tokens must be documented with usage patterns and security assessments

## Policy Scope

### Covered Systems

- All GitHub Actions workflows in `.github/workflows/`
- All automation scripts in `scripts/` directory
- All agent documentation and configurations
- All CI/CD pipeline integrations
- External integrations requiring GitHub API access

### Exclusions

- Local development environments (developer personal tokens)
- One-time manual operations requiring elevated permissions
- Emergency break-glass procedures (with explicit approval and logging)

## Token Governance Framework

### Token Categories

#### 1. CI_AUTOMATION Tokens

**Purpose**: Primary CI/CD pipeline automation
**Risk Level**: Medium to High
**Typical Permissions**: contents:read, issues:write, pull_requests:write
**Examples**: `CI_ISSUE_AUTOMATION_TOKEN`, `CI_BOT_TOKEN`

#### 2. SPECIALIZED_BOT Tokens

**Purpose**: Task-specific automation with defined scopes
**Risk Level**: Low to Medium
**Typical Permissions**: Minimal scope for specific tasks
**Examples**: `CHECKLIST_BOT_TOKEN`, `AAR_BOT_TOKEN`

#### 3. MONITORING Tokens

**Purpose**: Health monitoring and observability
**Risk Level**: Low
**Typical Permissions**: Read-only with limited issue creation
**Examples**: `CI_HEALTH_KEY`, `MONITORING_BOT_TOKEN`

#### 4. SECURITY Tokens

**Purpose**: Security audit and compliance enforcement
**Risk Level**: Medium
**Typical Permissions**: Read access with security event access
**Examples**: `SECURITY_AUDIT_TOKEN`

#### 5. ORCHESTRATION Tokens

**Purpose**: Multi-service coordination and deployment
**Risk Level**: High
**Typical Permissions**: Broad permissions for complex operations
**Examples**: `ORCHESTRATOR_BOT_TOKEN`, `INFRASTRUCTURE_BOT_TOKEN`

### Permission Scoping Principles

#### Minimal Privilege

- Tokens must have only the minimum permissions required for their intended function
- Broad permissions like `contents:write` require explicit justification
- Organization-level permissions are prohibited unless absolutely necessary

#### Time-Limited Scope

- Tokens should be designed for specific operational windows when possible
- Long-running tokens require enhanced monitoring and regular rotation
- Temporary tokens are preferred for one-time operations

#### Function-Specific Design

- Each token should serve a clearly defined automation function
- Multi-purpose tokens are discouraged unless technically necessary
- Token proliferation is acceptable if it improves security posture

## Implementation Requirements

### Token Creation Standards

#### 1. Documentation Requirements

Before creating any new token:

- [ ] Document specific automation requirement
- [ ] Define minimum required permissions
- [ ] Assign bot identity and ownership
- [ ] Classify risk level and usage patterns
- [ ] Update token registry (`.codex/tokens/token_scope_map.yaml`)
- [ ] Update permissions matrix documentation

#### 2. Technical Requirements

All tokens must implement:

- [ ] Proper error handling and validation
- [ ] Audit logging for all API operations
- [ ] Rate limiting and abuse prevention
- [ ] Secure storage in GitHub Secrets
- [ ] Regular rotation schedule

#### 3. Security Requirements

Security measures for all tokens:

- [ ] Regular permission audits
- [ ] Usage pattern monitoring
- [ ] Exposure detection and prevention
- [ ] Emergency revocation procedures
- [ ] Incident response plans

### Workflow Integration Patterns

#### Approved Token Usage Pattern

```yaml
# ✅ CORRECT: Using specialized token with defined scope
steps:
  - name: Automated Issue Management
    uses: actions/github-script@v7
    with:
      github-token: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN }}
      script: |
        // Specific automation logic with error handling
```

#### Prohibited Token Usage Pattern

```yaml
# ❌ PROHIBITED: Using default GITHUB_TOKEN for API operations
steps:
  - name: Issue Management
    uses: actions/github-script@v7
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
      script: |
        // This violates the No Default Token Policy
```

#### Fallback Token Pattern

```yaml
# ✅ ACCEPTABLE: Fallback to specialized token (not GITHUB_TOKEN)
steps:
  - name: CI Operations
    uses: actions/github-script@v7
    with:
      github-token: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN }}
      script: |
        // Fallback between specialized tokens only
```

## Compliance and Enforcement

### Automated Enforcement

#### Pre-commit Validation

- Token usage scanning in workflow files
- Registry synchronization verification
- Documentation completeness checks
- Permission scope validation

#### CI/CD Pipeline Enforcement

- Workflow token validation during execution
- API usage pattern monitoring
- Violation detection and alerting
- Automatic policy compliance reporting

#### Continuous Monitoring

- Token usage analytics and reporting
- Permission scope drift detection
- Security event correlation
- Performance impact assessment

### Manual Validation Procedures

#### Weekly Reviews

- [ ] Token usage pattern analysis
- [ ] New token request processing
- [ ] Policy violation investigation
- [ ] Documentation accuracy verification

#### Monthly Audits

- [ ] Comprehensive token inventory
- [ ] Permission scope validation
- [ ] Security posture assessment
- [ ] Policy effectiveness review

#### Quarterly Assessments

- [ ] Policy framework evaluation
- [ ] Security control effectiveness
- [ ] Industry best practice alignment
- [ ] Policy update requirements

## Violation Response Procedures

### Violation Classifications

#### Critical Violations

- Direct GITHUB_TOKEN usage for API operations
- Unauthorized token creation or modification
- Token exposure or compromise
- Permission scope violations

**Response Time**: Immediate (within 1 hour)
**Actions**: Token revocation, incident response, security investigation

#### Major Violations

- Undocumented token usage
- Permission scope creep
- Missing audit trails
- Non-compliance with rotation schedules

**Response Time**: Within 24 hours
**Actions**: Remediation planning, documentation updates, process improvements

#### Minor Violations

- Documentation inconsistencies
- Non-optimal token selection
- Missing usage pattern documentation
- Delayed compliance reporting

**Response Time**: Within 1 week
**Actions**: Documentation updates, process refinements, training

### Remediation Procedures

#### Immediate Actions

1. **Identify and isolate** the policy violation
2. **Assess security impact** and exposure risk
3. **Implement containment** measures if necessary
4. **Document incident** details and timeline

#### Short-term Remediation

1. **Correct the violation** using approved methods
2. **Update documentation** to reflect changes
3. **Verify compliance** through testing and validation
4. **Communicate resolution** to relevant stakeholders

#### Long-term Improvements

1. **Analyze root cause** of the violation
2. **Implement preventive measures** to avoid recurrence
3. **Update policies or procedures** as necessary
4. **Enhance monitoring and detection** capabilities

## Integration with DevOnboarder Infrastructure

### Enhanced Potato Policy Integration

The No Default Token Policy integrates with the Enhanced Potato Policy to provide comprehensive security governance:

- **File Protection**: Token-related files are protected by Potato Policy patterns
- **Exposure Prevention**: Automated detection of token exposure in commits
- **Documentation Security**: Security-sensitive documentation is protected
- **Audit Trail Preservation**: All token governance activities are logged

### Virtual Environment Compliance

All token governance tools must operate within DevOnboarder's virtual environment requirements:

- **Python Tools**: Token audit scripts require `.venv` activation
- **Dependency Management**: All governance tools use project dependencies
- **Isolation**: No system-level installations for token management
- **Reproducibility**: Consistent environment across all automation

### Centralized Logging Integration

Token governance activities integrate with DevOnboarder's centralized logging:

- **Audit Logs**: All token operations logged to `logs/token-audit/`
- **Compliance Reports**: Regular compliance reports in standardized format
- **Violation Tracking**: Policy violations tracked with full context
- **Historical Analysis**: Long-term trend analysis and reporting

## Tools and Automation

### Token Governance Scripts

#### `scripts/audit_token_usage.py`

**Purpose**: Comprehensive token usage auditing and compliance validation
**Features**: Registry validation, workflow scanning, violation detection
**Usage**: `python scripts/audit_token_usage.py --project-root . --json-output logs/token-audit/audit.json`

#### `scripts/validate_token_cleanup.sh`

**Purpose**: Token policy enforcement and cleanup validation
**Features**: Policy compliance checking, artifact cleanup, comprehensive reporting
**Usage**: `bash scripts/validate_token_cleanup.sh`

#### `scripts/manage_test_artifacts.sh`

**Purpose**: Enhanced test artifact management with token governance integration
**Features**: Session management, token validation, compliance tracking
**Usage**: `bash scripts/manage_test_artifacts.sh run`

### Registry Management

#### Token Scope Registry (`.codex/tokens/token_scope_map.yaml`)

**Purpose**: Authoritative source for all token definitions and scopes
**Structure**: YAML format with comprehensive token metadata
**Validation**: Automated synchronization with actual token usage

#### Permissions Matrix (`docs/security/token-permissions-matrix.md`)

**Purpose**: Human-readable documentation of all token permissions and usage
**Format**: Markdown tables with comprehensive token information
**Maintenance**: Regular updates synchronized with registry changes

## Training and Awareness

### Developer Education

#### Onboarding Requirements

All team members must complete:

- [ ] No Default Token Policy training
- [ ] Token governance tool usage
- [ ] Security best practices for automation
- [ ] Incident response procedures

#### Ongoing Training

Regular training sessions covering:

- Policy updates and changes
- New token governance tools
- Security threat landscape evolution
- Industry best practice adoption

### Documentation Resources

#### Quick Reference Guides

- Token selection decision tree
- Common usage patterns and examples
- Troubleshooting guide for policy compliance
- Emergency procedures for token incidents

#### Comprehensive Documentation

- Complete policy documentation (this document)
- Technical implementation guides
- Security architecture documentation
- Compliance reporting templates

## Policy Maintenance

### Version Control

This policy is maintained under version control with:

- **Change Tracking**: All policy modifications tracked in git
- **Review Process**: Changes require security team approval
- **Communication**: Policy updates communicated to all stakeholders
- **Training Updates**: Training materials updated with policy changes

### Review Schedule

#### Quarterly Reviews

- Policy effectiveness assessment
- Industry best practice alignment
- Tool and process evaluation
- Security control validation

#### Annual Reviews

- Comprehensive policy framework evaluation
- Major version updates if necessary
- Stakeholder feedback incorporation
- Strategic alignment verification

### Continuous Improvement

The policy framework includes mechanisms for:

- **Feedback Collection**: Regular stakeholder input on policy effectiveness
- **Metric Analysis**: Quantitative assessment of policy impact
- **Automation Enhancement**: Continuous improvement of enforcement tools
- **Process Optimization**: Regular refinement of governance procedures

## Appendices

### Appendix A: Token Classification Matrix

See [Token Permissions Matrix](token-permissions-matrix.md) for comprehensive token documentation.

### Appendix B: Violation Examples and Remediation

#### Example 1: GITHUB_TOKEN Usage in Workflow

**Violation**: Using `${{ secrets.GITHUB_TOKEN }}` for GitHub API operations
**Remediation**: Replace with appropriate specialized token
**Prevention**: Pre-commit hooks and CI validation

#### Example 2: Undocumented Token Creation

**Violation**: Creating tokens without updating registry
**Remediation**: Document token and update all governance documentation
**Prevention**: Token creation approval workflow

#### Example 3: Permission Scope Creep

**Violation**: Token permissions expanded beyond original scope
**Remediation**: Create new token with appropriate scope, deprecate old token
**Prevention**: Regular permission audits and monitoring

### Appendix C: Emergency Procedures

#### Token Compromise Response

1. **Immediate Revocation**: Revoke compromised token within 1 hour
2. **Impact Assessment**: Analyze potential security exposure
3. **Replacement**: Create new token with same or reduced permissions
4. **Communication**: Notify security team and stakeholders
5. **Investigation**: Conduct full security investigation
6. **Documentation**: Complete incident report and lessons learned

#### Policy Violation Escalation

1. **Detection**: Automated or manual violation detection
2. **Classification**: Determine violation severity level
3. **Notification**: Alert appropriate response team
4. **Containment**: Implement immediate containment measures
5. **Remediation**: Follow appropriate remediation procedures
6. **Follow-up**: Ensure completion and process improvement

---

**Document Classification**: Security Critical - Internal Use
**Next Review Date**: $(date -d "+3 months" +%Y-%m-%d)
**Policy Owner**: DevOnboarder Security Team
**Approved By**: DevOnboarder Project Lead
**Implementation Date**: $(date +%Y-%m-%d)
