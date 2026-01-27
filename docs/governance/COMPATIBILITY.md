# DevOnboarder Public Governance Contract

**Version**: 1.0.0
**Effective**: 2026-01-21
**Status**: ACTIVE

## Overview

DevOnboarder is a **public open-source repository**. This document defines the governance contract between the project and its contributors, ensuring:

1. **CI is the source of truth** — not local tooling
2. **Local enforcement is optional** — contributor convenience, not mandatory gates
3. **Consistent outcomes** — CI produces identical results regardless of local setup

## Two-Lane CI Model

DevOnboarder uses a two-lane CI model for security and cost efficiency:

### Lane 1: Untrusted PR Validation

| Property | Value |
|----------|-------|
| **Trigger** | `pull_request` (all sources, including forks) |
| **Runner** | `ubuntu-latest` (GitHub-hosted) |
| **Secrets** | ❌ None (untrusted code) |
| **Scope** | Lint, type-check, unit tests (read-only) |
| **Billing** | GitHub-hosted minutes |

**Rationale**: Fork PRs execute attacker-controlled code. We cannot trust workflow modifications or expose secrets.

### Lane 2: Trusted Branch CI

| Property | Value |
|----------|-------|
| **Trigger** | `push` to protected branches |
| **Runner** | `ubuntu-latest` or self-hosted (context-dependent) |
| **Secrets** | ✅ Allowed (for deployment, publishing) |
| **Scope** | Full CI including secret-using steps |
| **Billing** | Varies by runner |

**Rationale**: Code merged to protected branches has been reviewed. Secrets can be safely used.

## Pinning Rules

### GitHub Actions

All actions are **SHA-pinned** to immutable commit references:

```yaml
# ✅ Correct: SHA-pinned to immutable commit
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

# ❌ Forbidden: Mutable tag reference (subject to supply-chain attacks)
uses: actions/checkout@v4
```

**Policy**: Immutable refs only. Tags are mutable and subject to supply-chain attacks.

### Reusable Workflows

Consumed from `tags-workflows` with immutable version tags:

```yaml
uses: theangrygamershowproductions/tags-workflows/.github/workflows/ci-lite.yml@v1.0.0
```

**Policy**: Only use tagged releases (e.g., `@v1.0.0`), never branch refs.

## CI vs Local Enforcement

| Check | CI (Authoritative) | Local (Optional) |
|-------|-------------------|------------------|
| Linting (ruff, flake8) | ✅ Required | 🟡 Convenience |
| Type checking (pyright) | ✅ Required | 🟡 Convenience |
| Unit tests | ✅ Required | 🟡 Convenience |
| Security scanning | ✅ Required | ❌ Not run locally |
| Commit message format | ❌ Not enforced | 🟡 Convenience |
| Pre-commit hooks | ❌ Not required | 🟡 Convenience |

**Key Principle**: Contributors don't need to install local tooling. If their code passes CI, it's valid.

## Pre-commit (Optional)

A `.pre-commit-config.yaml` is provided as a **contributor convenience**, not a requirement.

### Installation (Optional)

```bash
# Optional: Install pre-commit hooks for local feedback
pip install pre-commit
pre-commit install
```

### Why Optional?

1. **Barrier to entry**: Requiring local tooling discourages contributions
2. **Environment drift**: "Works on my machine" debugging wastes maintainer time
3. **CI authority**: CI runs the authoritative checks — local hooks are just early feedback

### What Happens Without Local Hooks?

Your PR will be validated by CI. If checks fail, you'll see the failure in the PR and can fix it. The workflow is:

```
Push → CI runs checks → Fix failures if any → Merge when green
```

No local tooling required.

## Compatibility with TAGS-META

DevOnboarder **mirrors TAGS-META policies** but not its internal enforcement machinery:

| Aspect | TAGS-META (Internal) | DevOnboarder (Public) |
|--------|---------------------|----------------------|
| **Gate authority** | `.githooks/` + scripts | CI workflows |
| **Pre-commit** | Strict (local-only) | Optional (convenience) |
| **Network at commit** | Forbidden | N/A (CI runs remotely) |
| **Supply-chain control** | Maximum | Via SHA pinning in CI |

**Rationale**: TAGS-META is internal infrastructure. DevOnboarder is public OSS. Different environments require different enforcement postures, but policy outcomes should be identical.

## For Maintainers

### Adding New Checks

1. Add the check to CI workflow (authoritative)
2. Optionally add to `.pre-commit-config.yaml` (convenience)
3. Never make local hooks mandatory

### Debugging Contributor Issues

If a contributor's local environment behaves differently than CI:

1. Trust CI — it's the source of truth
2. Don't debug their local setup
3. Point them to this document

### Updating Workflow Versions

When `tags-workflows` releases a new version:

```yaml
# Update the version tag
uses: theangrygamershowproductions/tags-workflows/.github/workflows/ci-lite.yml@v1.1.0
```

Test in a PR before merging.

## References

- [TWO_TIER_RUNNER_POLICY.md](https://github.com/theangrygamershowproductions/TAGS-META/blob/main/docs/governance/TWO_TIER_RUNNER_POLICY.md) — Full runner policy
- [ACTIONS_POLICY.md](https://github.com/theangrygamershowproductions/TAGS-META/blob/main/ACTIONS_POLICY.md) — SHA pinning requirements
- [tags-workflows](https://github.com/theangrygamershowproductions/tags-workflows) — Reusable CI platform
