# Docker Service Mesh Phase 2: Quality Gates & Network Contract Enforcement

## Overview

Phase 2 introduces strict quality gates and automated network contract validation for all services. This phase ensures that every service meets minimum coverage, health, and artifact hygiene standards before deployment or merge.

## Key Requirements

- All services must be assigned to correct network tiers
- Health checks must pass for every service
- Minimum test coverage enforced (backend, bot, frontend)
- Artifact hygiene: no root-level artifacts or logs
- Centralized logging in logs/ directory
- CI must fail on any contract or quality gate violation

## Validation & Automation

- `scripts/validate_network_contracts.sh` enforces all requirements
- Codex agent "phase2-quality-gate-enforcer" automates checks and reporting
- All failures are synced to GitHub Projects Phase 2 board

## Troubleshooting

- Check logs/validate_network_contracts_*.log for validation output
- Use `docker compose logs <service>` for service-specific issues
- Run bash scripts/clean_pytest_artifacts.sh to fix artifact violations

---

**Status:** _In Progress_
