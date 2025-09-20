---
author: TAGS Engineering

codex_role: cto
codex_scope: tags
codex_type: documentation
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-04'
description: How we author, validate, mock, and consume OpenAPI contracts.
document_type: guide
merge_candidate: false
project: DevOnboarder
similarity_group: openapi.md-guide
status: draft
tags:

- docs

- openapi

- contracts

title: OpenAPI in DevOnboarder
updated_at: '2025-09-04'
visibility: internal
---

## Why

OpenAPI complements our YAML front-matter governance by defining machine-readable HTTP contracts for internal and external services.

## Where

Specs live under `/openapi/*.yaml`. Governance mirrors via `x-codex`.

## Validate

- Local: `source .venv/bin/activate && python -m openapi_spec_validator openapi/**/*.yaml`

- CI: `.github/workflows/openapi-validate.yml` (uses built-in openapi-spec-validator)

## Mock

- Local: Use existing DevOnboarder test infrastructure with mocked endpoints

- Wire tests against the API endpoints to stabilize agent behavior

## Generate Clients (optional)

- `make openapi-client-python` → outputs to `/clients/python`

- Pin generator version in CI to avoid drift.

## Authoring Guidelines

- Use 3.1 format when possible.

- Prefer component schemas with enums for stability.

- Use `x-codex` to preserve our governance metadata.

- Keep breaking changes behind feature branches; PR must update version.

## Versioning

- Bump `info.version` using SemVer when paths/schemas change.
