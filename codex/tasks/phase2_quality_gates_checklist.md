# Phase 2: Quality Gates & Network Contract Enforcement Checklist

## 1. Quality Gate Definition

- [ ] Define minimum coverage thresholds for all services (backend, bot, frontend)
- [ ] Specify required health checks for each service
- [ ] Document network contract validation requirements
- [ ] List all critical CI validation steps

## 2. Codex Agent Prompts

- [ ] Draft prompts for Codex agents to enforce:
    - Coverage thresholds
    - Health check status
    - Network contract compliance
    - Artifact hygiene
- [ ] Review and approve agent prompt language

## 3. CI Validation Scripts

- [ ] Create or update scripts/validate_network_contracts.sh for Phase 2
- [ ] Integrate network contract checks into CI pipeline
- [ ] Add artifact location and log centralization checks
- [ ] Ensure scripts fail on contract violations

## 4. GitHub Projects Sync

- [ ] Create/Update Phase 2 project board
- [ ] Add all Phase 2 tasks as issues/cards
- [ ] Link checklist items to project tracking
- [ ] Assign owners and due dates

## 5. Documentation & Reporting

- [ ] Update docs/docker-service-mesh-phase2.md with Phase 2 requirements
- [ ] Document troubleshooting and validation patterns
- [ ] Add summary of Phase 2 outcomes to AAR system

---

**Status:** _In Progress_
