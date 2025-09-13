---
title: Phase 2 Rollout – DevOnboarder Readiness Tasks

labels: ["codex", "ci-fix", "documentation", "modular-extraction", "security"]
assignees: ["@codex-bot", "@claude-dev"]
priority: high
codex_runtime: true
codex_type: task-bundle
codex_scope: tags/devonboarder
codex_target_branch: main
---

## 🎯 Objective

Begin implementation of DevOnboarder Phase 2 rollout based on the August 2025 readiness review. This includes security fixes, CI stabilization, modular repo extraction, and Codex agent validation prep.

---

## ✅ Tasks to Execute

### 🛠 CI/CD + Automation

- [x] Replace `GITHUB_TOKEN` usage in `validate_pr_checklist.sh` with `CHECKLIST_BOT_TOKEN` ✅ (script doesn't use GITHUB_TOKEN)

- [x] Refactor `close-codex-issues.yml` to remove `jq`/regex; use `gh --json` instead ✅ (replaced with --jq)

- [x] Patch `check_docs.sh` to gracefully handle offline environments (Vale fallback) ✅ (already implemented)

- [x] Add `pip check` to `scripts/run_tests.sh` to detect broken installs ✅ (already implemented)

### 🔐 Token Hygiene & Security

- [ ] Rotate and validate all write-scope GitHub tokens (bots + CI)

- [x] Ensure `.env.example` placeholders remain safe and never real credentials ✅ (verified safe)

### 🧱 Modular Extraction

- [ ] Extract `discord-bot/` into a new repo: `tags-discord-bot`

- [ ] Extract `frontend/` into a new repo: `tags-devonboarder-ui`

- [ ] Update Docker Compose files in each repo for standalone builds

### 📚 Documentation Refactor

- [x] Migrate all Markdown files into versioned `docs/v1/` structure ✅ (core files migrated)

- [x] Update CI to lint against `docs/v1/` directory ✅ (markdownlint.yml updated)

- [ ] Re-index `.codex/agents/` metadata for doc links if paths change

### ⚙️ Codex Agent Certification

- [x] Validate YAML frontmatter schema for all `.codex/agents/**` prompts ✅ (all 7 agents certified)

- [x] Flag missing metadata fields, incorrect roles, or non-routable agents ✅ (validation script created)

- [x] Log readiness status per agent in `docs/v1/agent_certification_log.md` ✅ (log created and populated)

---

## 🧪 Optional Test Prep (Can be scheduled separately)

- Prepare orchestration test for multi-agent Codex runtime under simulated load

- Validate Discord bot + backend API response under concurrent workflows

---

## 🧾 Reference Document

> `DevOnboarder CEO Briefing – August 2025`
> Canvas Link: `textdoc://688fba1785ec819189242c4657aa0e7c`
> Prepared by: CTO, Lead Dev, DevSecOps Manager
> Date: 2025-08-03

---

> Please commit staged changes under:
>
> **Branch:** `phase2/devonboarder-readiness`
>
> **Prefix Commits:** `PHASE2:`
