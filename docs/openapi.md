---
title: "OpenAPI in DevOnboarder"
description: "How we author, validate, mock, and consume OpenAPI contracts."
author: "TAGS Engineering"
created_at: "2025-09-04"
updated_at: "2025-09-04"
tags: ["docs", "openapi", "contracts"]
project: "DevOnboarder"
document_type: "guide"
status: "draft"
visibility: "internal"
codex_scope: "tags"
codex_role: "cto"
codex_type: "documentation"
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
