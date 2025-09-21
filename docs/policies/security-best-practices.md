---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Comprehensive security requirements including environment variable management
  and access control policies
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- potato-policy.md

- virtual-environment-policy.md

similarity_group: security-framework
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- security

- environment-variables

- best-practices

- access-control

title: DevOnboarder Security Best Practices
updated_at: '2025-09-11'
visibility: internal
---

e: ".github/copilot-instructions.md"

extraction_date: "2025-09-11"
module_type: "policy"
priority: "high"
description: "Security requirements and environment variable management"
enforcement: "mandatory"
related_modules: ["potato-policy.md", "quality-control-policy.md"]
---

DevOnboarder Security & Best Practices

=======================================

Security Requirements
=====================

- **No system installation**: All tools in virtual environments

- **No remote code execution**: Prohibited `curl | sh` patterns

- **Secret management**: Use GitHub Actions secrets

- **Token security**: Secure Discord bot token storage

- **CI token hierarchy**: CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN

- **Fine-grained tokens**: Prefer GitHub fine-grained tokens for security

- **HTTPS enforcement**: All production endpoints

- **Input validation**: Sanitize all user inputs

Environment Variable Security Model
==================================================

**CRITICAL**: DevOnboarder implements centralized environment variable management with security boundaries:

- **Source of Truth**: `.env` file contains all configuration (GITIGNORED)

- **Synchronization**: Use `bash scripts/smart_env_sync.sh --sync-all` to propagate changes

- **Security Boundaries**: Production secrets NEVER in committed files

- **CI Protection**: `.env.ci` uses test/mock values only

- **Audit System**: `bash scripts/env_security_audit.sh` for continuous validation

**Security Model**:

- `.env` - Source of truth (GITIGNORED)

- `.env.dev` - Development config (GITIGNORED)

- `.env.prod` - Production config (GITIGNORED)

- `.env.ci` - CI test config (COMMITTED with test values)

**Agent Requirements**:

- NEVER suggest manual editing of multiple environment files

- ALWAYS use centralized synchronization system

- ALWAYS validate security boundaries before file modifications

- REMEMBER: Production secrets in CI files is CRITICAL security violation

Documentation Standards
==================================================

- **Vale linting**: `python -m vale docs/` (in virtual environment)

- **README updates**: Update for all major changes

- **Changelog**: Maintain `docs/CHANGELOG.md`

- **API docs**: Keep OpenAPI specs current

Quality Assurance Checklist
==================================================

Pre-Commit Requirements
------------------------------

- [ ] **Virtual environment activated** and dependencies installed

- [ ] All tests pass with required coverage

- [ ] **Jest timeout configured in bot/package.json** (if working with bot)

- [ ] Linting passes (`python -m ruff`, ESLint for TypeScript)

- [ ] **Dependency PRs: Review breaking changes** (if dependency update)

- [ ] Documentation updated and passes Vale

- [ ] No secrets or sensitive data in commits

- [ ] Commit message follows imperative mood standard

PR Review Checklist
------------------------------

- [ ] **Virtual environment setup documented** in PR if needed

- [ ] Coverage does not decrease

- [ ] All CI checks pass

- [ ] Documentation is clear and accurate

- [ ] Security best practices followed

- [ ] Multi-environment considerations addressed

- [ ] Breaking changes properly documented
