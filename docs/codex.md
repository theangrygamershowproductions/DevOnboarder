---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!--
Project: DevOnboarder
File: codex.md
Purpose: Codex CI agent configuration
Updated: 16 Jul 2025 00:00 (EST)
Version: v1.1.0
-->
<!-- PATCHED v0.5.9 docs/codex.md — Document Codex CI workflow -->

<!-- PATCHED v0.5.21 docs/codex.md — Add guard rails summary -->

# Codex Agent

This document describes the Codex CI agent used to automate code
refactoring and generation tasks.

## Docker Image

- **Dockerfile:** `Dockerfile.codex`
- Runs Node 22-slim with Codex CLI installed.
- Default entrypoint is `codex`.

## Local Development

Use `docker-compose.codex.yml` to start the Codex container:

```bash
docker compose -f docker-compose.codex.yml run --rm codex --help
```

## CI Workflow

`.github/workflows/codex.yaml` builds the Docker image, runs Codex with
the provided prompt, and commits any generated changes back to the
branch. It requires the `OPENAI_API_KEY` secret, which should be set in
`.env.development` for local runs or configured as a repository secret
in CI.

## Guard Rails

The Codex agent follows the policies defined in `.codex/rules.yml`. These rules
specify the allowed branch patterns, commit message style, approved plugin list,
and nightly build schedule. Custom scripts in `.codex/scripts/` enforce asset
naming and plugin usage during CI runs. The workflow file
`.github/workflows/codex-ci.yml` ties these checks together and performs tests
and optional Snyk scans.

## Policy Injection

Codex can copy standard policy files into your project using the
`injectPolicies` helper. The CLI accepts an `--owner` value to replace the
`<<COPYRIGHT_OWNER>>` placeholder and outputs a summary of files added or
skipped. Use `--skip-policies` to disable this step.

```ts
const summary = await copyPolicies('out/policies', 'Example Co.');
// { added: 3, skipped: 0 }
```
