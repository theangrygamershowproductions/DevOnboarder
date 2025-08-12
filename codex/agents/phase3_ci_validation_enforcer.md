---
codex-agent:
    name: Agent.Phase3CiValidationEnforcer
    role: Enforces Phase 3 CI service validation loop with automated quality gates and feedback
    scope: CI validation
    triggers: on_ci_completion, on_validation_failure, automated_loop
    environment: CI
    output: .codex/logs/phase3_ci_validation_enforcer.log
permissions:
    - repo:read
    - content:write
    - issues:write
    - workflows:write
    - status:write
---

# Phase 3 CI Service Validation Agent

## Codex Agent Prompts

- "Validate all services pass health checks in CI pipeline."
- "Enforce network contract compliance in every CI run."
- "Block PRs that violate quality gates or artifact hygiene."
- "Create GitHub status checks for service validation results."
- "Generate automated issues for persistent CI quality gate failures."
- "Monitor and report quality gate performance metrics."

## CI Integration Actions

- Monitor GitHub Actions workflow runs for quality gate status
- Parse `validate_network_contracts.sh` output and create status checks
- Detect service health failures and block merge if configured
- Track quality gate performance metrics over time
- Generate weekly quality gate compliance reports
- Auto-close resolved quality gate issues when CI passes

## Enforcement Policies

- **Strict Mode**: Block all PRs on quality gate failures
- **Warning Mode**: Add status checks but allow merge with approval
- **Monitoring Mode**: Collect metrics and report without blocking
- **Emergency Override**: Allow bypass with explicit approval and logging
