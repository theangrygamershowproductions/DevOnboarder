---
task: "Implement DevOnboarder Modular Runtime & Module Manifest System"
priority: "high"
status: "planning"
created: "2025-08-03"
assigned: "architecture-team"
dependencies: ["phase2/devonboarder-readiness.md", "repo_init_tags-discord-bot.sh", "repo_init_tags-frontend.sh"]
related_files: [
  ".codex/modules/module_manifest.yaml",
  "scripts/module_integrity_checker.py",
  "scripts/register_module_usage.sh",
  "docs/v1/modules/runtime-config.md",
  "docs/public/module-usage-examples.md"
]
validation_required: true
---

# DevOnboarder Modular Runtime Task

## Overview

Create a slot-based module system to allow DevOnboarder to dynamically load components such as the Discord Bot or Frontend based on client or environment configuration. This will support runtime flexibility, simplify client onboarding, and centralize module state validation.

## Phase 1: Manifest System

### 1.1 Module Manifest (`.codex/modules/module_manifest.yaml`)

- Define all supported modules (name, repo, type, default enabled, required tokens)
- Allow client-specific overlays for module opt-in/out
- Include validation schema (YAML)

### 1.2 Module Registry Checker (`scripts/module_integrity_checker.py`)

- Validates presence of enabled modules
- Logs missing or misconfigured modules to `logs/module_validation.log`
- Virtual environment enforcement

## Phase 2: Runtime Integration

### 2.1 Module Registration Script (`scripts/register_module_usage.sh`)

- Auto-registers active modules based on config
- Outputs JSON or text log for runtime orchestration agents

### 2.2 Codex Support

- Each agent can read `module_manifest.yaml` to determine active features
- Add `module_required` flag in agent metadata for dynamic gating

## Phase 3: Documentation & Testing

### 3.1 Docs (`docs/v1/modules/runtime-config.md`)

- Explain how modules are defined, validated, and invoked
- Show how to define client-specific module profiles

### 3.2 Public Starter Guide (`docs/public/module-usage-examples.md`)

- Example: how to enable the Discord bot for a client
- Explain CI/CD impact and how to test locally

### 3.3 Unit Tests (`tests/test_module_runtime.py`)

- Validate manifest loading, module presence logic, error handling

---

## DevOnboarder Compliance Requirements

- **Virtual Environment Enforcement**: All scripts must validate `.venv`
- **Centralized Logging**: All logs go to `logs/`, not root
- **Token Awareness**: Modules must declare required tokens
- **Modular CLI Compliance**: No hard-coded assumptions about module presence

---

## Success Criteria

- [ ] Module manifest format adopted and integrated into runtime
- [ ] Missing module detection prevents misconfigured deployments
- [ ] Codex agents support module-based routing and opt-in behaviors
- [ ] Discord bot and frontend can be plugged in dynamically
- [ ] Module usage documented and tested with public-facing instructions

---

**Status**: Ready for implementation
**Next Steps**: Begin Phase 1 manifest design and checker script
**Blocking On**: Repo extraction and Phase 2 modular validation
**Validation**: Ensure all modules are correctly registered and validated against the manifest schema
