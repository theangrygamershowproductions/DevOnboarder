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

## Rebase and Merge Policy

Always rebase your branch onto the latest `main` before opening a pull request
or when updating it:

```bash
git pull --rebase origin main
```

Pull requests are merged using **Squash and merge** to keep history linear.
Delete the feature branch after the merge completes.

## Pre-PR Checklist

Before opening a pull request, make sure to:

- Rebase your branch on the latest `main`.
- Run the linter and tests to confirm they pass:

```bash
ruff check .
pytest -q
```
- Update `docs/CHANGELOG.md` with a short summary of your change.
- Update any other relevant documentation under `docs/`.
