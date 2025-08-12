---
title: "Codex Enforcement Mode Policy"
description: "Defines the hard enforcement strategy for all Codex-integrated projects, including documentation, CI, agent behavior, and AI-assisted contributions."
author: "TAGS Engineering"
created_at: "2025-08-08"
updated_at: "2025-08-08"
tags: ["codex", "enforcement", "ci", "policy", "linting", "discipline", "compliance", "ai-behavior"]
project: "core-instructions"
related_components: ["DevOnboarder", "Codex Agents", "CI Triage Guard"]
document_type: "policy"
status: "active"
visibility: "internal"
canonical_url: "https://github.com/theangrygamershowproductions/core-instructions/docs/policies/ENFORCEMENT_MODE.md"
codex_scope: "global"
codex_role: "system"
codex_type: "policy"
codex_runtime: true
---

# Codex Enforcement Mode Policy

## 🔒 Overview

As of **August 8, 2025**, the TAGS engineering platform has officially entered **Codex Enforcement Mode**. This policy establishes non-negotiable quality gates across all human and AI contributions. Any attempt to bypass established linting, metadata, documentation, or test enforcement will be logged, blocked, and flagged for remediation.

## 🎯 Objectives

- Prevent regression in code, documentation, and infrastructure hygiene
- Ensure all AI agents (e.g. Claude, Codex, Copilot) operate within enforced boundaries
- Maintain trust in the automation stack
- Reduce downstream debugging caused by lint violations and unstructured inputs
- Lock in platform integrity ahead of LLM deployment and multi-agent orchestration

## ✅ Enforced Criteria

### 🧾 Documentation

All `.md` files must:

- Pass `markdownlint-cli2`
- Use **valid frontmatter** headers
- Contain no `**bold headings**` (MD036)
- Wrap all URLs as `[link](url)` (MD034)
- Avoid `--no-verify` workflows unless documented in a `triage_log.md`

### 🧠 Codex Agent Metadata

All agents under `.codex/agents/` must:

- Contain valid YAML metadata
- Include `codex_scope`, `codex_role`, `codex_type`, `status`, and `visibility`
- Pass `agent_schema_validator.py`

### 🧪 CI/CD

All commits must:

- Pass all CI stages, including linting and validation
- Not skip tests, validation, or suppression phases
- Be authored by authenticated actors (human or Codex-verified agent)

## ❌ Forbidden Shortcuts

| Shortcut | Status | Resolution |
|----------|--------|------------|
| `--no-verify` | 🚫 BLOCKED | Only allowed in triage branches + must trigger `CI BYPASS DETECTED` log |
| Unquoted here-docs (`<<EOF`) | 🚫 BLOCKED | Must use `<<'EOF'` unless shell expansion is intended and justified |
| Raw `echo $VAR` | 🚫 BLOCKED | Must use `printf` for clarity and safety |
| Pushes with unresolved lint errors | 🚫 BLOCKED | Must be resolved or explicitly suppressed with justification |

## 🛡️ CI Enforcement Agents

- `ci_enforcement_guard`: Activates on PR and commit events to block all violations
- `doc_lint_enforcer`: Runs markdown and frontmatter schema validation
- `triage_logger`: Tracks bypasses, suppressions, and justifications

## 📓 Triage Exception Process

If a bypass is temporarily required:

1. Use a branch prefixed with `triage/`
2. Log the reason in `.codex/enforcement/triage_log.md`
3. Assign a task for cleanup before merge

**NOTE:** Bypasses without logs will be considered violations.

## 🤖 AI Assistant Compliance Requirements

### For Claude, GitHub Copilot, and All AI Agents

**You are NOT exempt from quality gates. You are part of the enforcement system.**

#### Mandatory Behaviors

- **ALWAYS** follow established patterns from NO_SHORTCUTS_POLICY.md
- **NEVER** suggest bypassing quality gates with `--no-verify` or similar
- **ALWAYS** use proper shell patterns: `printf` not `echo`, `<<'EOF'` not `<<EOF`
- **RESPECT** suppression systems - add suppressions only for genuinely safe patterns
- **VALIDATE** all generated content against project standards before suggesting

#### Violation Response

AI agents that generate non-compliant content will:

- Have their suggestions automatically rejected by CI
- Trigger enforcement logging and pattern analysis
- Require human review for pattern recognition and correction

#### Success Metrics

- Zero AI-generated quality gate violations
- Consistent adherence to established patterns
- Proactive compliance checking before content generation

## 🏁 Final Note to All AI Assistants

If you are generating content for this platform:

- You **must** follow this policy
- Any output violating these rules will be rejected or auto-corrected
- You are not above the enforcement system. You are part of it
- Your role is to **prevent** technical debt, not create it

**Remember**: Every shortcut you suggest creates future validation noise and violates the "quiet reliability" philosophy that defines this platform.

Welcome to the new standard.

---

**Signed:** TAGS Engineering CTO, Enforcement Lead
**Effective:** August 8, 2025
