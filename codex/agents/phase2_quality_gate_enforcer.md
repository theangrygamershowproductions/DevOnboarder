# Phase 2 Quality Gate Enforcer Agent

```yaml
codex-agent: true
name: "phase2-quality-gate-enforcer"
type: "automation"
permissions: ["read", "write", "issues", "workflows"]
description: "Enforces Phase 2 quality gates: coverage, health, network contracts, and artifact hygiene."
```

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
