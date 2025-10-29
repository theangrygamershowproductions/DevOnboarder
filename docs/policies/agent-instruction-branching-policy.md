---
title: "Agent Instruction Branching & Staging Policy"

description: ""A disciplined Git and orchestration policy for developing, testing,"

author: "TAGS DevSecOps Manager"
project: DevOnboarder
version: v1.0.0
status: proposed
visibility: internal
created_at: 2025-09-21
updated_at: 2025-10-27
canonical_url: "https://codex.theangrygamershow.com/docs/devonboarder/agent-instruction-branching-policy"
related_components: 
codex_scope: DevOnboarder
codex_role: devsecops_manager
codex_type: policy
codex_runtime: github_actions
tags: "["automation", "codex", "agents", "branching", "devsecops", "gitops", "ci-guard"]"
document_type: policy
similarity_group: ci-automation
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Agent Instruction Branching & Staging Policy

## Purpose

Establish a safe, repeatable method to develop and stage **agent instruction changes** (prompts, charters, checklists, orchestration manifests) **without impacting production** in the **DevOnboarder** repository. This doc is designed as a **handoff to Claude** to implement guardrails, CI rules, and repo alignment.

---

## Scope

- Repo: `DevOnboarder`.
- Artifacts: everything under `.codex/agents/`, `.codex/orchestration/`, `.codex/policies/`, `.github/` CI guardrails, and agent metadata.
- Environments: `sandbox/*` (local/dev), `staging`, `main` (prod). Optional: `release/*` for long-lived preprod hardening.

---

## Directory & Metadata Standards

### Canonical Layout

- `.codex/agents/devonboarder/<role>/` (e.g., `cto`, `cfo`, `ciso`, `chief_operating_officer`, `cpo`, `cmo`, `ceo`)
- Each agent MUST include:
    - `agent_devonboarder_<role>.md` (instruction)
    - `charter_devonboarder_<role>.md`
    - `checklist_devonboarder_<role>.md`
- All files MUST include YAML metadata fields:
    - `title, description, author, created_at, updated_at, tags, project, related_components, document_type, status, visibility, canonical_url, codex_scope, codex_role, codex_type, codex_runtime`

### Naming Conventions

- File: `agent_<project>_<role>.md` (project = `devonboarder`) with matching charter/checklist filenames.
- Branch prefixes reserve meaning (see Branch Model).

---

## Branch Model

- **Production**: `main` — only code/instructions that are approved for live use.
- **Staging**: `staging` — integration testing for instruction sets; mirrors prod infra with test toggles.
- **Sandbox**: `sandbox/<topic>` — local/experimental instruction work, never merged directly to `main`.
- **Do-Not-Merge**: `dnm/<topic>` — long-running spikes or reference drafts; merging blocked by policy.
- **Release (optional)**: `release/<yymmdd>-<codename>` — frozen bundles queued for promotion.

> **Rule**: All agent instruction development starts on `sandbox/*` and is promoted via PR to `staging`  baked  PR to `main`.

---

## Required Branch Protections (GitHub)

1. **`main`**
   - Require PR with reviews (≥1), status checks passing, linear history.
   - Block pushes from `sandbox/*` or `dnm/*` via CODEOWNERS  branch rules.
   - Require signed commits (bots included) and verified authors.

2. **`staging`**
   - Require PR  checks; allow squash merges only.

3. **Pattern Protections**
   - Disallow merges from branches matching: `sandbox/**`, `dnm/**`.
   - Optional: Delete branch on merge (for `sandbox/*`).

> Claude: Configure these protections via repo settings API or manual steps; export a `branch-protection.md` with current rules.

---

## CI/CD Guardrails (GitHub Actions)

- **ci_triage_guard**: If CI reports infra/network/tooling failures (e.g., `pytest` artifacts in `logs/pytest-of-*`, Vale download blocks), **halt codegen** and fail early.
- **codex_doc_validator**: Lint all `.codex/**` for metadata schema, naming, markdownlint, Vale.
- **Instruction Diff Sentinel**: On PRs, detect changes in `.codex/agents/**` and require:
    - Checklist confirmation (see PR Template)
    - Updated `updated_at` timestamps
    - No unscaffolded routing tags (generate soft warning  issue if missing)
- **Environment Toggle Test**: In `staging` workflows, exercise agents with sandbox inputs; in `main`, run smoke-only.

---

## Orchestration & Runtime Selection

### Branch-aware Loading

- Local dev and test runners must load agent instructions **from the current Git branch** by default.
- Production runners pin to `main` (or a signed release tag).

### Config Surfaces

- ENV vars: `CODEX_AGENT_BRANCH`, `CODEX_ENV` in runner containers.
- Fallback precedence: `CODEX_AGENT_BRANCH`  current git branch  `main`.

### Secrets

- Use env-specific secrets; never commit secrets.
- Confirm `LLAMA2_API_KEY` and `TEAMS_APP_PASSWORD` are unset until services exist (known gap).

---

## Local-Only Experimentation

- Prefer **worktrees** for parallel sandboxes:

  ```bash
  git fetch origin
  git checkout -b sandbox/agents-instructions origin/main
  git worktree add ../agents-instructions sandbox/agents-instructions
  ```

- Keep private notes/scripts untracked via `.git/info/exclude`.
- For ephemeral edits you don't want in history, use `git stash` (preferred) or emergency-only sandbox commits.
<!-- POTATO: EMERGENCY APPROVED - documentation-example-20250921 -
<!-- Emergency context: `git commit --no-verify` reference in sandbox branch workflow documentation -

---

## GPG & Bot Identity (Commit Signing)

- All commits to `staging` and `main` must be **verified**.
- Bot accounts should use an org-managed GPG key **not embedded in repo**. Publish the **public key** to GitHub, store **private key** in org secrets.
- CI signing flow guidance:
    - Import signing key at runtime from secrets; configure `git config user.signingkey ...`.
    - Use `-S` for signed commits if CI creates commits (e.g., version bumps). Avoid when not necessary.

---

## PR Template (Instructions Change)

```markdown
## Summary

- What agent(s) changed: <role(s)>
- Branch: <sandbox/topic>

## Validation

- [ ] Updated YAML frontmatter: title/description/tags/updated_at
- [ ] Passed `codex_doc_validator`
- [ ] No undisclosed secrets
- [ ] Routing tags present (e.g., #cto, #agent:ci_guard)

## Risk & Rollback

- Impacted services: <list>
- Rollback plan: revert commit / disable feature flag / pin previous tag

## Evidence

- Links to CI, sandbox runs, screenshots
```

---

## CODEOWNERS (Partial)

```gitignore
# Agent instructions require review by DevOnboarder DevSecOps owners
/.codex/agents/**  @tags-devsecops
/.codex/orchestration/**  @tags-devsecops
```

---

## Promotion Workflow

1. **Develop** on `sandbox/<topic>`; commit granular changes.
2. **Open PR  `staging`** with template; CI runs full instruction validation  integration tests.
3. **Bake** in `staging` for 24–72 hours of usage/tests (configurable).
4. **Open PR  `main`**; run smoke tests and governance checks.
5. **Tag release** (optional): `vYYYY.MM.DD-<codename>`; runners may pin to tags.
6. **Cleanup**: auto-delete `sandbox/*` branches upon merge/close.

---

## Enforcement Checks (What Claude Must Implement)

- **Schema**: Reject PRs modifying `.codex/**` if required metadata missing or dates not updated.
- **Naming**: Enforce `agent_devonboarder_<role>.md` etc.
- **Branch**: Block direct PRs from `sandbox/*`  `main`.
- **Labels**: Auto-label PRs touching `.codex/**` with `area:agents`.
- **Issues**: If routing tags missing, open issue "Scaffold missing agent routing" with context.
- **Docs**: Update changelog and `MILESTONE_LOG.md` when instruction files change.

---

## Migration Steps (One-Time Alignment)

1. Inventory current `.codex/agents/**` and normalize filenames/metadata.
2. Create `staging` branch from `main` if absent.
3. Apply branch protection rules and CODEOWNERS.
4. Add workflows: `ci_triage_guard`, `codex_doc_validator`, instruction diff sentinel.
5. Update runners to respect `CODEX_AGENT_BRANCH`  `CODEX_ENV`.
6. Draft `branch-protection.md`  export GitHub settings for audit.
7. Run a test cycle: sandbox  staging  main with a trivial metadata update.

---

## Command Snippets

```bash
# Create sandbox branch and worktree
git fetch origin
git switch -c sandbox/cto-copyedits origin/main
git worktree add ../cto-copyedits sandbox/cto-copyedits

# Open PR to staging
gh pr create --base staging --head sandbox/cto-copyedits -t "Agent: CTO copyedits" -b "Promote to staging for bake"

# After bake, PR to main
gh pr create --base main --head staging -t "Release: agent instruction batch" -b "Promote staged instructions to prod"
```

---

## Acceptance Criteria (for Claude)

- Repo contains `staging`  protections; `main` locked; pattern rules for `sandbox/**`  `dnm/**`.
- CI fails on invalid `.codex/**` metadata or naming.
- PR template present and auto-applied for `.codex/**` changes.
- CODEOWNERS enforce reviews by `@tags-devsecops`.
- Runners respect branch-aware loading; `CODEX_ENV` toggles applied.
- Documentation updated (`branch-protection.md`, changelog, migration log).

---

## Notes & Future

- Consider `release/*` hardening for regulated clients.
- Add policy-as-code checks (OpenPolicyAgent/Conftest) for metadata.
- Integrate Discord notifications on promotion events.

---

## Integration with DevOnboarder Instructions

This policy directly supports the enhanced agent instruction management established in [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md). The branching model ensures:

- **Safe experimentation** on `sandbox/*` branches without impacting production agents
- **Staged validation** through `staging` branch for instruction changes
- **Production protection** via branch rules and required reviews
- **Quality enforcement** through CI/CD guardrails and metadata validation

All agent instruction changes must follow this policy to maintain the "quiet reliability" principle that guides DevOnboarder development.
