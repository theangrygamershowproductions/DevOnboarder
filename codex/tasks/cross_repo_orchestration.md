---

title: Checklist - Setup Cross-Repo Codex Orchestration
project: DevOnboarder
codex\_scope: orchestration
codex\_role: integration\_engineer
codex\_type: task\_checklist
status: draft
created\_at: 2025-08-03
tags:

* codex-task
* orchestration
* cross-repo

---

## Objective

Establish clean and secure orchestration between DevOnboarder core, the newly split frontend and Discord bot repositories, and the core-instructions Codex control layer.

## Checklist

### 🧭 Codex Agent Routing

* [ ] Ensure `.codex/agents/` directory structure allows multi-repo routing
* [ ] Validate routing metadata in all agents (e.g., `codex_scope`, `codex_role`, `codex_type`)
* [ ] Implement shared routing index file if orchestration spans more than 3 projects

### 🔁 Core-Instructions Integration

* [ ] Update `core-instructions` prompts to reference extracted repo roles
* [ ] Validate that `agent_tags_cto.md`, `agent_tags_ci_guard.md`, etc. reflect correct routing and permissions
* [ ] Implement `core-instructions` agent fallback for repo offline detection

### 🔗 Secure Communication

* [ ] Confirm API tokens are split per repo and scoped accordingly
* [ ] Validate webhook or GitHub Actions-based cross-repo event triggers (optional)
* [ ] Implement `codex_callout` script to target Codex Agents in remote repos

### 📊 Documentation & Logging

* [ ] Update automation logs to indicate which repo triggered which agent
* [ ] Ensure all agent calls log success/failure in `logs/codex_orchestration.log`
* [ ] Document orchestration flow in `docs/orchestration/README.md`

---

Prepared by: Integration Engineer
Date: 2025-08-03
