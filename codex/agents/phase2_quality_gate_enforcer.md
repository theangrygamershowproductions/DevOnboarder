---
codex-agent:
    name: Agent.Phase2QualityGateEnforcer
    role: Enforces Phase 2 quality gates for coverage, health, network contracts, and artifact hygiene
    scope: quality assurance
    triggers: on_pull_request, on_push_to_main, phase_transition
    environment: CI
    output: .codex/logs/phase2_quality_gate_enforcer.log
permissions:
    - repo:read
    - content:write
    - issues:write
    - workflows:write
---

# Phase 2 Quality Gate Enforcer Agent

## Codex Agent Prompts

- "Check that all services meet minimum coverage thresholds."
- "Validate that all health checks pass for every service."
- "Enforce network contract compliance for all containers."
- "Block CI if artifact hygiene or log centralization is violated."
- "Report all failures to GitHub Projects and open issues as needed."

## Enforcement Actions

- Run scripts/validate_network_contracts.sh and parse results
- Check coverage reports for backend, bot, and frontend
- Validate log and artifact locations
- Sync failures to GitHub Projects Phase 2 board
