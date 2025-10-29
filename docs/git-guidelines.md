---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: git-guidelines.md-docs
status: active
tags: 
title: "Git Guidelines"

updated_at: 2025-10-27
visibility: internal
---

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

Commit types must be uppercase. Standard types include `FEAT`, `FIX`, `DOCS`, `STYLE`,
`REFACTOR`, `TEST`, `CHORE`, `SECURITY`, `BUILD`, and `REVERT`. Extended types for
DevOnboarder workflow include `PERF`, `CI`, `OPS`, `WIP`, `INIT`, `TAG`, `POLICY`,
`HOTFIX`, and `CLEANUP`. Use `CHORE` for routine maintenance, `CI` for workflow
changes, `PERF` for performance improvements, and `CLEANUP` for code cleanup tasks.
The parenthesized `<scope>` is optional but helps clarify the affected area.

Examples:

```text
CHORE(ci): update Node version in workflow
PERF(auth): optimize JWT token validation
CI(actions): add automated dependency updates
CLEANUP(deps): remove unused dependencies

```

See the **commit-message policy** in [Agents Overview](../agents/index.md) for a detailed

explanation of the required format and history rules.

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

## Commit History Policy

Once commits are pushed to a shared branch, avoid rewriting history. Do not run
`git commit --amend`, `git rebase -i`, or `git push --force`. If you need to
clarify a message, create a follow-up commit or add details in the pull request
description.

## Pre-PR Checklist

- Before opening a pull request, make sure to:

- Rebase your branch on the latest `main`.

- Install the project and dev requirements:

```bash
pip install -e .
pip install -r requirements-dev.txt

```

Run these commands **before** invoking `pytest` so all dev dependencies are available.

- Run the linter and tests to confirm they pass:

```bash
ruff check .
pytest --cov=src --cov-fail-under=95

```

- Run documentation checks with `./scripts/check_docs.sh`.

  The script runs **Vale** only.

  LanguageTool checks are optional. If desired, run a local server and
  set `LANGUAGETOOL_URL` to its address.

- Keep Prettier pinned to `v3.6.2`. Run

  `pre-commit autoupdate --repo https://github.com/pre-commit/mirrors-prettier`
  to confirm the hook installs correctly.

- CI lints commit messages using `scripts/check_commit_messages.sh`.

    - Run `bash scripts/install_commit_msg_hook.sh` after cloning to install a

      local `commit-msg` hook so mistakes are caught before you push. See
      [CONTRIBUTING.md](../CONTRIBUTING.md).
      Past violations do not require rewriting history.
    - Enable the `pytest` pre-commit hook to run tests automatically and catch

      failures locally. Run `pre-commit run pytest --all-files` once to enable it.

- Update `docs/CHANGELOG.md` with a short summary of your change.

- Update any other relevant documentation under `docs/`.

- Follow the pull request template in `.github/pull_request_template.md`.

## Stale Branch Cleanup

The `cleanup_branches.sh` script removes merged branches that haven't changed in
30 days. The nightly `branch-cleanup.yml` workflow runs this task with
`DRY_RUN=true` by default. To delete branches immediately, set `DRY_RUN=false`
when triggering the workflow with the `codex:cleanup` label.
