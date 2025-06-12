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
<!-- PATCHED v0.2.18 docs/CONTRIBUTING.md — reference issue templates -->

<!--
Project: DevOnboarder
File: CONTRIBUTING.md
Purpose: Guide for contributing via pull requests
Updated: 04 Jun 2025 07:08 (EST)
Version: v1.1.0
-->

# Contributing Guidelines

Thank you for wanting to contribute!
Please follow these basic rules when submitting changes:

1. **Create a branch** for your work.
2. **Write descriptive commit messages** using the form `TYPE(scope): subject`.
3. **Add tests** for new features and run `pytest -q`
and `pnpm --dir frontend test:unit` before pushing.
4. **Update documentation and CHANGELOG** when relevant.
5. **Open a pull request** describing what you changed and why.
6. **Use templates in `.github/ISSUE_TEMPLATE/` for bug and feature reports.**

Refer to [docs/Git/Git.md](./Git/Git.md) for more details on our git workflow.

## Node and pnpm

Ensure Node.js **22** is installed. Activate the correct pnpm version with
Corepack:

```bash
corepack enable
corepack prepare pnpm@10 --activate
```

## Contributing Guide

Use this guide when preparing a pull request.

## Branching and Commits

1. **Create a branch** from `development` or the relevant feature base.
2. **Use semantic commit messages** in the `<type>(<scope>): <subject>` format
(see [Git.md](./Git/Git.md)).
3. **Lint commit messages** with `npx commitlint --edit`.
4. **Apply patch headers** to the top of any modified files.
5. **Record changes** in `CHANGELOG.md`.

## Formatting

- Run `black .` for all Python code.
- From `frontend/`, run `npm run lint` (ESLint/Prettier).

## Testing

- Run `./scripts/setup-dev.sh` before executing the tests.
- Execute `pre-commit install` so commits run the test suite automatically.
- Execute `pytest` from the repository root.
- From `frontend/`, run `npm run test:unit`.

## Pull Request Requirements

1. Use the template in `docs/TAGS-PR-Template.md` for the PR description.
2. Confirm all items in `docs/MERGE_CHECKLIST.md` are complete.
3. CI workflows (GitHub Actions) must show green status for lint and test jobs.

Only request review after all checks succeed.
