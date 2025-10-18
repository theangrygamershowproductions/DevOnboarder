---
author: DevOnboarder Team
consolidation_priority: P1
content_uniqueness_score: 5
created_at: '2025-10-01'
description: Comprehensive guide for handling external pull requests securely in DevOnboarder
document_type: security-documentation
merge_candidate: true
project: DevOnboarder
similarity_group: security-guides
status: active
tags:
- security
- external-prs
- workflows
- github-actions
title: External PR Security Guide
updated_at: '2025-10-01'
visibility: public
---

# External Pull Request Security Guide

## Overview

DevOnboarder implements a multi-layered security model to safely handle pull requests from external contributors and forked repositories. This guide provides a comprehensive overview of the security architecture, workflow patterns, and procedures for maintaining security while enabling community contributions.

## Security Architecture

### The External PR Challenge

When external contributors create pull requests from forks, GitHub's security model introduces several constraints:

1. **Token Limitations**: `GITHUB_TOKEN` is read-only for external PRs
2. **Secret Isolation**: Workflow secrets are not accessible to fork PRs
3. **Permission Restrictions**: Limited ability to write comments, create issues, or modify repository state
4. **Code Execution Risks**: Untrusted code could potentially execute in privileged contexts

### DevOnboarder's Security Model

DevOnboarder addresses these challenges through a **three-tier security architecture**:

**Architecture Overview:** The security model consists of three distinct tiers designed to handle external pull requests securely:

1. **Security Tier 1 - Safe Execution Zone**: The outermost tier handles untrusted code from external contributors. It uses the `pull_request` trigger with read-only permissions, no access to repository secrets, and can safely execute testing and validation workflows without security risks.

2. **Security Tier 2 - Privileged Execution Zone**: The middle tier processes trusted code from maintainers and approved contributors. It uses the `pull_request_target` trigger with full write permissions, access to all repository secrets, and can perform privileged operations like auto-fixing and deployment.

3. **Security Tier 3 - Maintainer Override Zone**: The innermost tier provides manual intervention capabilities for repository maintainers. It allows direct workflow triggering, manual token usage, and override of automated security restrictions when human judgment is required.

Each tier provides increasing levels of access while maintaining strict security boundaries between untrusted external contributions and sensitive repository operations.

```text
─────────────────────────────────────────────────────────────┐
│                    SECURITY TIER 1                          │
│                   Safe Execution Zone                       │
│  ─────────────────────────────────────────────────────┐    │
│  │  pull_request trigger                               │    │
│  │  • Read-only GITHUB_TOKEN                           │    │
│  │  • No secrets access                                │    │
│  │  • Executes untrusted code safely                   │    │
│  │  • Testing, linting, basic validation               │    │
│  ─────────────────────────────────────────────────────┘    │
─────────────────────────────────────────────────────────────┘

─────────────────────────────────────────────────────────────┐
│                    SECURITY TIER 2                          │
│                 Privileged Execution Zone                   │
│  ─────────────────────────────────────────────────────┐    │
│  │  workflow_run trigger                               │    │
│  │  • Full GITHUB_TOKEN permissions                    │    │
│  │  • Access to secrets                                │    │
│  │  • Only trusted code execution                      │    │
│  │  • Issue creation, PR comments, auto-fixes          │    │
│  ─────────────────────────────────────────────────────┘    │
─────────────────────────────────────────────────────────────┘

─────────────────────────────────────────────────────────────┐
│                    SECURITY TIER 3                          │
│                  Maintainer Override Zone                   │
│  ─────────────────────────────────────────────────────┐    │
│  │  Manual intervention with personal tokens           │    │
│  │  • Full repository permissions                      │    │
│  │  • Manual workflow dispatch                         │    │
│  │  • Emergency procedures                             │    │
│  ─────────────────────────────────────────────────────┘    │
─────────────────────────────────────────────────────────────┘
```

## Workflow Trigger Patterns

### 1. `pull_request` Trigger (Tier 1 - Safe Zone)

**Primary CI workflow pattern for external PRs:**

```yaml
# .github/workflows/ci.yml
on:
  pull_request:  # Safe for external PRs

permissions:
  contents: read        # Minimal permissions
  # No write permissions for external PRs

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5  # Checks out untrusted code
      - name: Run tests
        run: |
          # Safe to execute untrusted code here
          # Limited by read-only token
```

**Security characteristics:**

-  Executes untrusted code from forks safely
-  GITHUB_TOKEN is read-only
-  No access to repository secrets
-  Cannot comment on PRs or create issues
-  Cannot update repository state

### 2. `workflow_run` Trigger (Tier 2 - Privileged Zone)

**Post-processing pattern for privileged operations:**

```yaml
# .github/workflows/auto-fix.yml
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]

permissions:
  contents: write       # Full permissions available
  pull-requests: write
  issues: write

jobs:
  process-results:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        # SECURITY: Only checkout trusted code from default branch
        # Never checkout untrusted PR code in privileged context

      - name: Process CI results
        run: |
          # Safe to perform privileged operations here
          # Working with trusted code only
```

**Security characteristics:**

-  Full GITHUB_TOKEN permissions
-  Access to repository secrets
-  Can comment on PRs and create issues
-  Only executes trusted code from default branch
-  Cannot directly access fork PR code

### 3. `pull_request_target` Trigger (High Risk - Avoided)

**Pattern avoided in DevOnboarder:**

```yaml
#  NOT USED - Security risk
on:
  pull_request_target:  # Dangerous for external PRs

# Risk: Combines untrusted code execution with privileged permissions
```

**Why DevOnboarder avoids this pattern:**

- Executes in privileged context with full permissions
- Can checkout and execute untrusted code from forks
- High risk of privilege escalation attacks
- Difficult to implement securely

## Fork Detection Methods

DevOnboarder implements several fork detection patterns:

### 1. GitHub Context Detection

```yaml
- name: Check if PR is from fork
  run: |
    if [ "${{ github.event.pull_request.head.repo.fork }}" = "true" ]; then
      echo "External fork PR detected"
      echo "fork_pr=true" >> $GITHUB_OUTPUT
    fi
```

### 2. Repository Comparison

```yaml
- name: Detect external PR
  run: |
    if [ "${{ github.event.pull_request.head.repo.full_name }}" != "${{ github.repository }}" ]; then
      echo "External repository PR detected"
      echo "external_pr=true" >> $GITHUB_OUTPUT
    fi
```

### 3. Conditional Job Execution

```yaml
jobs:
  privileged-operations:
    if: |
      !github.event.pull_request.head.repo.fork &&
      github.event.pull_request.head.repo.full_name == github.repository
```

## Permission Segmentation

### Standard Permission Patterns

| Operation Type | Required Permissions | Trigger Pattern |
|---|---|---|
| **Testing & Validation** | `contents: read` | `pull_request` |
| **PR Comments** | `contents: read`, `pull-requests: write` | `workflow_run` |
| **Issue Creation** | `contents: read`, `issues: write` | `workflow_run` |
| **Auto-fixes** | `contents: write`, `pull-requests: write` | `workflow_run` |
| **Coverage Updates** | `contents: write` | `workflow_run` |

### DevOnboarder Permission Model

```yaml
# Minimal permissions for external PRs
permissions:
  contents: read

# Extended permissions for privileged operations
permissions:
  contents: write
  issues: write
  pull-requests: write
  actions: read
```

## Token Hierarchy

### 1. GITHUB_TOKEN (Default)

**External PR Limitations:**

- Read-only access for fork PRs
- Cannot write comments or create issues
- No access to repository secrets
- Suitable for testing and validation only

### 2. Personal Access Token (Maintainer Override)

**When needed:**

- Manual intervention required for external PRs
- Need to comment on fork PRs
- Emergency workflow dispatch
- Troubleshooting external PR issues

**Setup procedure:**

```bash
# Create PAT with required scopes
# Settings > Developer settings > Personal access tokens
# Required scopes: repo, workflow, issues, pull_requests

# Use for manual operations (ensure $GH_TOKEN is set securely in your environment)
gh pr comment 123 --body "Comment from maintainer"
```

## Maintainer Procedures

### External PR Review Process

1. **Automatic Processing**
   - External PR triggers `pull_request` workflow
   - Tests run with read-only permissions
   - Results reported via `workflow_run` triggered workflows

2. **Manual Intervention (When Required)**
   - Fork PR cannot be automatically commented on
   - Maintainer uses personal token for communication
   - Manual workflow dispatch for privileged operations

3. **Security Review**
   - Code review focuses on potential security issues
   - Verify no malicious code in PR changes
   - Check for sensitive data exposure

### Common External PR Scenarios

#### Scenario 1: Test Failures on Fork PR

```bash
# Problem: Cannot automatically comment on fork PR test failures
# Solution: Maintainer manual comment

gh pr comment 123 \
  --body "Tests failed. Please see CI logs for details."
```

#### Scenario 2: Auto-fix Needed for Fork PR

```bash
# Problem: Auto-fix workflow cannot push to fork
# Solution: Manual fix application

# 1. Checkout fork PR locally
git fetch origin pull/123/head:pr-123
git checkout pr-123

# 2. Apply fixes manually
./scripts/apply_fixes.sh

# 3. Create comment with suggested changes
gh pr comment 123 \
  --body "Suggested fixes: [paste diff or provide guidance]"
```

#### Scenario 3: Workflow Dispatch for Fork PR

```bash
# Problem: Need to rerun workflow for fork PR
# Solution: Manual workflow trigger

gh workflow run ci.yml \
  -f ref=refs/pull/123/head
```

## DevOnboarder Quality Gates Integration

DevOnboarder implements comprehensive quality validation that affects how external PRs are processed. Understanding these integrations is crucial for maintainers and external contributors.

### Quality Control Validation (`qc_pre_push.sh`)

**Impact on External PRs:**

External PRs trigger the same quality gates as internal PRs, but with different permission contexts:

```bash
# External PR workflow - read-only validation
- name: Quality Control Validation
  run: |
    # 8 critical metrics validation
    ./scripts/qc_pre_push.sh
    # Results available but cannot auto-fix due to read-only permissions
```

**Quality Metrics Applied to External PRs:**

1. **YAML Linting**: Validates all workflow and configuration files
2. **Python Linting (Ruff)**: Code quality enforcement
3. **Python Formatting (Black)**: Consistent code style
4. **Type Checking (MyPy)**: Type safety validation
5. **Test Coverage**: 95% coverage requirement
6. **Documentation Quality (Vale)**: Writing standards enforcement
7. **Commit Message Format**: Conventional commit validation
8. **Security Scanning (Bandit)**: Vulnerability detection

**External PR Limitations:**

-  All quality gates run and report results
-  Auto-fixes cannot be applied directly to fork PRs
-  Failures require manual contributor action or maintainer intervention

### Safe Commit Wrapper (`safe_commit.sh`)

**External Contributor Impact:**

The safe commit wrapper provides comprehensive validation but has different behavior for external contributors:

```bash
# DevOnboarder's safe commit validation
./scripts/safe_commit.sh "FEAT(component): description"

# Validations applied:
# 1. Branch protection (prevents main branch commits)
# 2. Commit message format validation
# 3. QC validation (95% quality threshold)
# 4. Terminal output compliance
# 5. Forbidden file detection
# 6. Emoji usage detection
# 7. Virtual environment verification
```

**Branch Protection for External PRs:**

External contributors cannot directly commit to protected branches, but the validation helps ensure their PR branches meet standards:

```bash
# Protected branches (external PRs cannot target directly)
- main
- dev
- staging
- production
- feat/potato-ignore-policy-focused (special CI fix branch)
```

**Quality Gate Failures:**

When external PRs fail quality gates:

1. **Automatic Feedback**: CI reports specific failures
2. **Maintainer Notification**: Issues created for persistent failures
3. **Manual Intervention**: Maintainer can apply fixes and request changes
4. **Contributor Guidance**: Clear instructions for resolution

### Branch Protection Rules Impact

**External PR Considerations:**

DevOnboarder's branch protection affects external PRs in several ways:

```yaml
# Branch protection characteristics for external PRs
required_status_checks:
  - CI (pull_request trigger)  Runs for external PRs
  - Quality Gates  Validates external PRs
  - Security Scans  Applies to external PRs

required_reviews:
  - CODEOWNERS approval  Requires maintainer review
  - Status check passage  Must pass for external PRs
```

**Special Branch Protections:**

- **AAR Documentation**: `docs/ci/**/*-archived.md` requires @reesey275 approval
- **Agent Instructions**: `.codex/**` requires @tags-devsecops review
- **Security Files**: Potato Policy prevents sensitive file commits

## Codex Agent System Integration

DevOnboarder's Codex agent system has specific security considerations for external PRs, particularly when modifying agent instructions or triggering agent workflows.

### Agent Workflow Security

**External PR Limitations with Agents:**

```yaml
# Agent workflows triggered by external PRs
triggers:
  - pull_request:      # Safe execution for external PRs
      paths: ['.codex/**', 'agents/**']
  - workflow_run:      # Privileged operations (post-processing)
      workflows: ["CI"]
```

**Agent Security Model:**

1. **Read-Only Validation**: External PRs can trigger agent validation
2. **No Agent Execution**: External PRs cannot execute agents in privileged context
3. **Metadata Validation**: Agent instruction format verified automatically
4. **Review Requirements**: Agent changes require DevSecOps approval

### Agent Instruction Modifications

**External Contributor Workflow for `.codex/**` Changes:**

```bash
# 1. External contributor modifies agent instructions
# Triggers validation workflow with read-only permissions

# 2. Required validations for external PR:
- Agent metadata schema validation
- YAML frontmatter completeness
- Routing tags presence (#cto, #agent:ci_guard)
- Updated timestamp verification
- No sensitive information disclosure

# 3. Review process:
- CODEOWNERS requires @tags-devsecops approval
- Security review for agent logic changes
- Staging branch testing (maintainer-controlled)
```

**Agent Metadata Requirements:**

External PRs modifying agents must include proper metadata:

```yaml
---
agent: agent_name
authentication_required: true|false
author: External Contributor Name
codex_dry_run: false
codex_runtime: true
created_at: 'YYYY-MM-DD'
description: Clear agent purpose description
environment: CI|production|development
permissions:
  - repo:read
  - workflows:write
routing_tags:
  - "#cto"
  - "#agent:role_name"
status: active|inactive
updated_at: 'YYYY-MM-DD'  # Must be current
---
```

### Agent Execution Security

**Prevention of Malicious Agent Execution:**

```yaml
# Security measures for external PR agent changes
validation_checks:
  - Schema validation against agent template
  - Malicious code pattern detection
  - Resource limit verification
  - Permission scope validation
  - Routing tag authorization check

execution_isolation:
  - External PRs cannot execute modified agents
  - Agent changes require staging branch validation
  - Privileged agent operations use workflow_run trigger
  - Maintainer approval required for agent deployment
```

**Agent Sandbox Environment:**

DevOnboarder implements agent sandboxing for external contributions:

```bash
# Sandbox branch pattern for external agent changes
sandbox/external-pr-123-agent-modification

# Validation process:
1. External PR creates sandbox branch automatically
2. Agent validation runs in isolated environment
3. Security review by @tags-devsecops team
4. Staging deployment for testing
5. Manual promotion to main after approval
```

### Agent Security Best Practices

**For External Contributors:**

1. **Follow Agent Templates**: Use provided agent instruction templates
2. **Include Required Metadata**: All YAML frontmatter fields mandatory
3. **Document Changes**: Clear description of agent modifications
4. **Security Awareness**: No sensitive data in agent instructions
5. **Routing Tags**: Include appropriate routing tags for review

**For Maintainers:**

1. **Agent Code Review**: Thorough review of agent logic changes
2. **Permission Validation**: Verify agent permission requirements
3. **Staging Testing**: Test agent changes in staging environment
4. **Security Impact Assessment**: Evaluate security implications
5. **Rollback Planning**: Ensure rollback procedures documented

## DevOnboarder Automation Framework

DevOnboarder's comprehensive automation framework handles external PRs with specific security and operational considerations.

### PR Automation System (`automate_pr_process.sh`)

**External PR Automation Behavior:**

DevOnboarder's PR automation operates in different modes based on PR origin:

```bash
# Automation modes for external PRs
MODES:
  analyze:    # Safe for external PRs - read-only analysis
  execute:    # Limited for external PRs - maintainer intervention required
  full-auto:  # Disabled for external PRs - security restriction

# External PR workflow
if [[ "$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FORK" == "true" ]]; then
  AUTOMATION_MODE="analyze"  # Force analyze-only mode
  echo "External PR detected - restricting to analysis mode"
fi
```

**Automation Safety Controls:**

```json
{
  "safety": {
    "protected_files": ["Potato.md", "*.key", "*.pem"],
    "protected_branches": ["main", "master", "production"],
    "external_pr_restrictions": {
      "auto_merge": false,
      "auto_fix_application": false,
      "privileged_operations": false
    },
    "require_approval": true
  }
}
```

### PR Decision Engine (`pr_decision_engine.sh`)

**External PR Decision Logic:**

The decision engine applies different criteria for external PRs:

```bash
# Decision engine logic for external PRs
if [[ "$IS_EXTERNAL_PR" == "true" ]]; then
  # Apply stricter criteria
  HEALTH_THRESHOLD=95  # Higher threshold for external PRs
  MANUAL_REVIEW=true   # Always require manual review
  AUTO_MERGE=false     # Never auto-merge external PRs

  # Additional security checks
  SECURITY_SCAN_REQUIRED=true
  MAINTAINER_APPROVAL_REQUIRED=true
fi

# Decision outcomes for external PRs:
# - MANUAL_REVIEW_REQUIRED (most common)
# - SECURITY_REVIEW_NEEDED
# - MAINTAINER_INTERVENTION_REQUIRED
# - ANALYZE_ONLY (safe default)
```

**Health Assessment for External PRs:**

```bash
# PR health metrics with external PR considerations
METRICS:
  - Code quality score (standard validation)
  - Security impact assessment (enhanced for external PRs)
  - Change scope analysis (stricter limits)
  - Test coverage validation (same requirements)
  - Documentation completeness (standard)
  - Commit message compliance (enforced)
  - Branch protection compliance (validated)

# External PR specific penalties:
# - Privilege escalation attempts: -50 points
# - Sensitive file modifications: -100 points
# - Missing security reviews: -25 points
```

### Auto-Merge and Health Checks

**External PR Auto-Merge Restrictions:**

DevOnboarder explicitly disables auto-merge for external PRs:

```yaml
# Auto-merge configuration for external PRs
auto_merge_policy:
  external_prs:
    enabled: false
    reason: "Security policy - manual review required"
    override: "maintainer_approval_with_security_review"

  bypass_conditions:
    - approved_by: "@theangrygamershowproductions/maintainers"
    - security_review: "completed"
    - health_score: ">= 98%"
    - change_scope: "minimal"
```

**Health Check Integration:**

```bash
# Health check behavior for external PRs
./scripts/check_automerge_health.sh

# External PR specific checks:
1. Origin repository validation
2. Contributor verification
3. Change impact assessment
4. Security scan results
5. Required review completion
6. Branch protection compliance

# Results for external PRs:
- Auto-merge: Always disabled
- Health score: Reported but with external PR context
- Recommendations: Always include manual review requirement
```

### Automation Framework Security

**Multi-Layer Security for External PRs:**

```bash
# Security validation pipeline for external PRs
SECURITY_LAYERS:
  1. Origin Detection: Identify fork PRs automatically
  2. Permission Restriction: Limit automation capabilities
  3. Privileged Operation Blocking: Prevent sensitive actions
  4. Maintainer Gate: Require explicit approval
  5. Audit Logging: Record all automation decisions

# Implementation example:
if is_external_pr "$PR_NUMBER"; then
  log "SECURITY: External PR detected - applying restrictions"
  RESTRICTED_MODE=true
  REQUIRE_MAINTAINER_APPROVAL=true
  DISABLE_AUTO_ACTIONS=true
fi
```

**Automation Audit Trail:**

DevOnboarder maintains comprehensive audit logs for external PR automation:

```bash
# Audit log entries for external PRs
LOG_ENTRIES:
  - External PR detection timestamp
  - Automation mode restrictions applied
  - Security checks performed
  - Maintainer interventions required
  - Decision engine recommendations
  - Health assessment results
  - Final disposition and reasoning

# Log location: logs/external-pr-automation-<date>.log
```

## Enhanced Potato Policy Integration

DevOnboarder's Enhanced Potato Policy provides automated security enforcement that is particularly important for external PRs to prevent accidental exposure of sensitive information.

### Security File Detection

**Potato Policy Protected Files:**

```bash
# Files automatically protected by Potato Policy
PROTECTED_PATTERNS:
  - "Potato.md"           # SSH keys, setup instructions
  - "*.env"               # Environment variables
  - "*.pem"               # Private keys
  - "*.key"               # Certificate files
  - "secrets.yaml"        # Configuration secrets
  - "secrets.yml"         # Configuration secrets
  - "auth.db"             # Authentication database
```

**External PR Security Scanning:**

External PRs trigger enhanced security scanning:

```bash
# Enhanced security validation for external PRs
./scripts/check_potato_ignore.sh

# Validation checks:
1. .gitignore contains required "Potato" entries
2. .dockerignore prevents container inclusion
3. .codespell-ignore protects from spell-check exposure
4. No protected files in PR changeset
5. No sensitive patterns in code changes
6. No credential exposure in commit history
```

### Violation Detection and Response

**Automatic Violation Detection:**

```bash
# Potato Policy violation detection for external PRs
if external_pr_contains_sensitive_files "$PR_NUMBER"; then
  log "SECURITY VIOLATION: External PR contains protected files"

  # Immediate actions:
  1. Block PR merge automatically
  2. Create security incident issue
  3. Notify maintainers via security channel
  4. Request immediate contributor action
  5. Generate audit report
fi
```

**Violation Response Workflow:**

```yaml
# Security incident response for external PRs
violation_response:
  immediate:
    - pr_status: "blocked"
    - security_label: "security-violation"
    - maintainer_notification: true

  contributor_notification:
    template: "external-pr-security-violation"
    actions_required:
      - "Remove sensitive files from PR"
      - "Update commit history if necessary"
      - "Confirm .gitignore compliance"

  maintainer_actions:
    - security_review: "required"
    - violation_assessment: "impact_analysis"
    - remediation_guidance: "provide_to_contributor"
```

### Security File Prevention

**Pre-commit Security Validation:**

External contributors benefit from the same security validation:

```bash
# Security validation applied to all PRs
VALIDATION_STEPS:
  1. Forbidden file pattern detection
  2. Sensitive string pattern matching
  3. Environment variable exposure check
  4. Private key detection algorithms
  5. Configuration secret scanning
  6. Historical commit analysis (if needed)

# Results for external PRs:
- Pass: PR proceeds with standard workflow
- Fail: PR blocked with detailed remediation guidance
```

**Potato Policy Enforcement Levels:**

```bash
# Three-tier enforcement for external PRs
ENFORCEMENT_LEVELS:

  Level 1 - Warning:
    - Pattern detected but not confirmed violation
    - Contributor guidance provided
    - Manual review flagged

  Level 2 - Block:
    - Confirmed sensitive file inclusion
    - PR merge blocked automatically
    - Maintainer intervention required

  Level 3 - Security Incident:
    - Credential exposure detected
    - Immediate containment actions
    - Security team notification
    - Audit trail initiated
```

### Enhanced Security Reporting

**External PR Security Audit:**

DevOnboarder generates enhanced security reports for external PRs:

```bash
# Security audit report generation
./scripts/generate_potato_report.sh --external-pr $PR_NUMBER

# Report includes:
- Contributor identity verification
- Change impact security assessment
- Sensitive file exposure analysis
- Policy compliance validation
- Risk score calculation
- Recommended actions

# Report location: logs/security-audit-external-pr-<number>-<date>.log
```

**Audit Trail for External PRs:**

```json
{
  "external_pr_security_audit": {
    "pr_number": 123,
    "contributor": "external-contributor",
    "repository_origin": "fork",
    "security_checks": {
      "potato_policy_compliance": "pass",
      "sensitive_file_detection": "pass",
      "credential_exposure_scan": "pass",
      "historical_analysis": "pass"
    },
    "risk_assessment": "low",
    "maintainer_review_required": true,
    "audit_timestamp": "2025-10-01T15:30:00Z"
  }
}
```

## Review Process and CODEOWNERS Integration

DevOnboarder implements sophisticated review requirements and approval flows that apply specifically to external PRs, ensuring security and quality standards are maintained.

### CODEOWNERS Requirements

**Current CODEOWNERS Configuration:**

```text
# DevOnboarder CODEOWNERS for external PRs
*       @theangrygamershowproductions/maintainers

# Special protection for archived documentation
docs/ci/ci-modernization-2025-09-01-archived.md    @reesey275
docs/ci/**/*-archived.md                          @reesey275

# Agent instructions require DevSecOps review
/.codex/agents/**                                 @tags-devsecops
/.codex/orchestration/**                          @tags-devsecops
```

**External PR Review Requirements:**

External PRs have enhanced review requirements based on changed files:

```bash
# Review requirements by file type for external PRs
FILE_PATTERNS:

  General Changes:
    - reviewers: "@theangrygamershowproductions/maintainers"
    - count: 1 required
    - bypass: none

  Archived Documentation:
    - reviewers: "@reesey275"
    - count: 1 required (specific reviewer)
    - bypass: "approved-crit-change" label

  Agent Instructions:
    - reviewers: "@tags-devsecops"
    - count: 1 required (security team)
    - additional: security impact assessment

  Security Files:
    - reviewers: "security team  maintainers"
    - count: 2 required
    - additional: security audit required
```

### AAR Protection System

**AAR Document Protection for External PRs:**

DevOnboarder's AAR (After Action Report) protection system applies special rules to external PRs:

```yaml
# AAR protection workflow for external PRs
protection_levels:

  archived_documents:
    pattern: "docs/ci/**/*-archived.md"
    external_pr_policy: "block_unless_approved"
    required_label: "approved-crit-change"
    required_reviewer: "@reesey275"

  pre_commit_protection:
    hook: "prevent-archived-doc-edits"
    external_pr_behavior: "warn_and_block"
    bypass: "--no-verify (emergency only)"

  github_actions_protection:
    workflow: ".github/workflows/protect-archived-aar.yml"
    external_pr_checks:
      - authorized_team_member: false (external contributor)
      - label_check: "approved-crit-change" required
      - reviewer_approval: required
```

**AAR Protection Workflow for External Contributors:**

```bash
# External contributor workflow for AAR document changes
1. External contributor modifies archived AAR document
2. Pre-commit hook warns but allows commit (external environment)
3. PR created and triggers protection workflow
4. Workflow detects external PR  archived document changes:
   - Blocks merge automatically
   - Requires "approved-crit-change" label
   - Requires @reesey275 approval
   - Logs protection action

5. Maintainer review process:
   - Assess legitimacy of changes
   - Add "approved-crit-change" label if appropriate
   - Provide review approval
   - Document justification in PR
```

### Approval Flow Architecture

**Multi-Stage Approval for External PRs:**

```bash
# DevOnboarder external PR approval stages
APPROVAL_STAGES:

  Stage 1 - Automated Validation:
    - CI pipeline execution (pull_request trigger)
    - Quality gates validation (95% threshold)
    - Security scanning (Potato Policy  Bandit)
    - Status: Required before human review

  Stage 2 - Code Review:
    - CODEOWNERS review assignment
    - Technical review by maintainers
    - Security impact assessment (if applicable)
    - Status: Required for all external PRs

  Stage 3 - Security Review (Conditional):
    triggers:
      - Agent instruction changes
      - Security file modifications
      - Privileged operation requirements
    reviewers: "@tags-devsecops"
    requirements:
      - Security impact analysis
      - Risk assessment documentation
      - Mitigation strategy validation

  Stage 4 - Final Approval:
    - All required reviews completed
    - All status checks passed
    - Manual merge by maintainer (no auto-merge)
    - Post-merge monitoring initiated
```

### Review Process Automation

**Automated Review Assignment:**

DevOnboarder automatically manages review assignments for external PRs:

```yaml
# Automated review assignment logic
review_assignment:

  file_pattern_detection:
    - .codex/**: assign @tags-devsecops
    - docs/ci/*-archived.md: assign @reesey275
    - *.md: assign documentation team
    - src/**: assign code reviewers
    - .github/workflows/**: assign DevOps team

  external_pr_enhancements:
    - automatic_security_label: true
    - enhanced_review_checklist: true
    - maintainer_notification: true
    - audit_trail_initiation: true
```

**Review Process Monitoring:**

```bash
# External PR review monitoring
./scripts/monitor_external_pr_reviews.sh

# Monitoring includes:
- Review assignment completion tracking
- Response time monitoring
- Escalation triggers for delayed reviews
- Security review compliance validation
- Approval flow progression tracking

# Alerts:
- 48h review delay: notify maintainers
- Security review required: notify security team
- Protection bypass attempt: immediate escalation
```

### Special Review Scenarios

**High-Risk External PR Review:**

```bash
# Criteria for high-risk external PR classification
HIGH_RISK_INDICATORS:
  - Workflow file modifications
  - Security configuration changes
  - Agent instruction updates
  - Sensitive file pattern changes
  - Large change scope (>100 files)
  - New contributor (first-time)

# Enhanced review process for high-risk external PRs:
1. Automatic security team notification
2. Enhanced security scanning
3. Staged review approach (technical  security  final)
4. Extended review period (minimum 48h)
5. Post-merge monitoring for 7 days
```

**Emergency Review Procedures:**

```bash
# Emergency procedures for critical external PR fixes
EMERGENCY_CRITERIA:
  - Security vulnerability fix
  - Production outage resolution
  - Zero-day exploit mitigation

EMERGENCY_PROCESS:
  1. Security team immediate notification
  2. Expedited review (< 4 hours)
  3. Enhanced post-merge monitoring
  4. Rollback plan preparation
  5. Incident documentation required
```

## Troubleshooting Guide

### Common Issues

#### Issue: "Resource not accessible by integration"

**Cause:** External PR trying to perform privileged operation
**Solution:** Check if operation is in `workflow_run` triggered workflow

#### Issue: Fork PR not getting automatic comments

**Cause:** `workflow_run` triggered jobs cannot access fork PR context
**Solution:** Implement PR context passing or manual maintainer intervention

#### Issue: Secrets not available in external PR workflow

**Cause:** GitHub security model prevents secret access for forks
**Solution:** Move secret-dependent operations to `workflow_run` triggered workflows

### Debug Commands

```bash
# Check PR origin
gh pr view 123 --json headRepository,baseRepository

# Check workflow permissions
gh run view 123456 --json permissions

# Check if PR is from fork
gh pr view 123 --json headRepository.owner.login,baseRepository.owner.login
```

## Security Best Practices

### 1. Code Review Guidelines

- **Review external PRs thoroughly** before merging
- **Check for credential exposure** in PR changes
- **Verify workflow modifications** don't introduce security risks
- **Test locally** before merging if suspicious

### 2. Workflow Design

- **Use explicit permissions** for all jobs
- **Avoid `pull_request_target`** unless absolutely necessary
- **Separate privileged operations** into `workflow_run` triggered workflows
- **Never checkout untrusted code** in privileged contexts

### 3. Token Management

- **Rotate personal tokens regularly**
- **Use minimal required scopes**
- **Store tokens securely** (not in repository)
- **Document token usage** for audit purposes

## Integration with Existing Documentation

This guide consolidates information from:

- [`docs/ci-failure-issues.md`](ci-failure-issues.md) - Fork PR limitations and maintainer procedures
- [`docs/WORKFLOW_SECURITY_STANDARDS.md`](WORKFLOW_SECURITY_STANDARDS.md) - Permission patterns and security principles
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) - External PR safe execution patterns
- [`.github/workflows/auto-fix.yml`](../.github/workflows/auto-fix.yml) - Privileged operation security model

## Quick Reference

### External PR Checklist

- [ ] Tests run automatically via `pull_request` trigger
- [ ] No privileged operations in `pull_request` workflows
- [ ] Privileged operations handled by `workflow_run` workflows
- [ ] Manual maintainer intervention procedures documented
- [ ] Security review completed before merge

### Maintainer Quick Commands

```bash
# Comment on fork PR (requires GH_TOKEN environment variable)
gh pr comment 123 --body "Your message"

# Trigger workflow for fork PR (requires GH_TOKEN environment variable)
gh workflow run workflow.yml -f ref=refs/pull/123/head

# Review fork PR locally
gh pr checkout 123
```

---

**Last Updated:** October 1, 2025
**Related Documentation:** [CI Failure Issues](ci-failure-issues.md), [Workflow Security Standards](WORKFLOW_SECURITY_STANDARDS.md)
**Maintainer:** DevOnboarder Security Team
