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
File: Git.md
Purpose: Overview of repository structure and git standards
Updated: 03 Jun 2025 22:55 (EST)
Version: v1.0.2
-->

<!-- PATCHED v0.5.51 docs/Git.md — document patch headers under YAML -->

# Git Standards

This project follows the guidelines detailed in
[TAGS-Operation-Alignment-Plan.md](./TAGS-Operation-Alignment-Plan.md).

## Branching
- `feature/<module>` for new features
- `bugfix/<module>` for bug fixes
- `hotfix/<module>` for urgent fixes

## Commits
- Use semantic messages under 79 characters
- Prefix with `gitmoji` or tags such as `[PATCH]` or `[FEATURE]`

## Patches
- Add or update patch headers at the top of modified files
- Record each update in [CHANGELOG.md](./CHANGELOG.md)

## Git Hooks

A `.pre-commit-config.yaml` configures checks that run before each commit.
Install the hook once so Git automatically bootstraps the environment
and executes the test suite:

```bash
pre-commit install
```

This command creates `.git/hooks/pre-commit` which runs `pytest -q` inside a
virtual environment
. The legacy script in `hooks/pre-commit` remains available for CI or manual
use.
