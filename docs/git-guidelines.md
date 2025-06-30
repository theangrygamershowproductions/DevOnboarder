# Git Guidelines

This document explains how we use Git in this project.

## Branch Naming

Create short-lived branches directly from `main`. Branch names use lowercase
words separated by hyphens and are prefixed with their purpose:

- `feature/` – new functionality
- `fix/` – bug fixes
- `chore/` – maintenance tasks

Examples:

```text
feature/login-form
fix/logout-bug
```

## Commit Message Format

Write commit messages in the imperative mood. Begin with a concise summary line
(about 50 characters), followed by a blank line and an optional description.

Example:

```text
Add login form UI

Includes basic username and password fields.
```

Summarize the purpose of the change in the first line. For example:

```text
Add dedicated CI compose file and environment-specific compose configs
```

## Rebase and Merge Policy

Always rebase your branch onto the latest `main` before opening a pull request
or when updating it:

```bash
git pull --rebase origin main
```

Pull requests are merged using **Squash and merge** to keep history linear.
Delete the feature branch after the merge completes.

## Pre-PR Checklist

 - Before opening a pull request, make sure to:

- Rebase your branch on the latest `main`.
- Install the project and dev requirements:

```bash
pip install -e .
pip install -r requirements-dev.txt
```

- Run the linter and tests to confirm they pass:

```bash
ruff check .
pytest -q
```
- Run documentation checks with `./scripts/check_docs.sh`.
  These use **Vale** and **LanguageTool** and require network access to
  `api.languagetool.org` or a locally hosted server specified via
  `LANGUAGETOOL_URL`.
- Keep Prettier pinned to `v3.1.0`. Run
  `pre-commit autoupdate --repo https://github.com/pre-commit/mirrors-prettier`
  to confirm the hook installs correctly.
- Update `docs/CHANGELOG.md` with a short summary of your change.
- Update any other relevant documentation under `docs/`.
- Follow the pull request template in `docs/pull_request_template.md`.
