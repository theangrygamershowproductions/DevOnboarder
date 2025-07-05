# DevOnboarder Protocol

This repository follows the DevOnboarder protocol. Key points:

1. **Trunk-based workflow**
- All stable code lives on `main`.
- Short-lived branches are created off `main` for every change.
- Changes are merged back into `main` through pull requests.
- Feature branches are deleted after merge.

2. **Documentation**
- General onboarding instructions: `docs/README.md`.
- Git guidelines: `docs/git-guidelines.md`.
- Pull request template: `docs/pull_request_template.md`.
- Maintainer merge checklist: `docs/merge-checklist.md`.
- Project changelog: `docs/CHANGELOG.md`.
- Offline setup instructions: `docs/offline-setup.md`.

3. **Development Environment**
- Use the provided container setup and compose files for local development.
- Ensure all tests pass before submitting a PR.
 - Workflows install the GitHub CLI with the official `actions/setup-gh` action.

4. **Contribution Guidelines**
- Keep pull requests focused and small.
- Update documentation and the changelog with each change.

## Commit Message Guidelines

All contributors **must** follow these standards for commit messages:

- Use the **imperative mood** (describe what this commit does, not what you did).
- Be descriptive and concise; every commit should make sense when read in isolation.
- Avoid non-descriptive messages like "update," "fix," "misc," or "Applying previous commit."
- Reference related issues or PRs when appropriate.

### Format

```plaintext
<type>(<scope>): <subject>
```

- **type**: One of FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE.
- **scope**: The part of the codebase affected (optional, but recommended).
- **subject**: Brief, imperative summary of the change.

#### Types

- **FEAT**: New features
- **FIX**: Bug/security fixes
- **DOCS**: Documentation
- **STYLE**: Formatting/linting
- **REFACTOR**: Structural changes
- **TEST**: Tests
- **CHORE**: Tooling, config, CI/CD

#### Example

```plaintext
docs: Document built-in GITHUB_TOKEN usage for CI failure issues

- Clarifies workflow token use in README
- Updates changelog with policy details
```

See [docs/git-guidelines.md](./docs/git-guidelines.md) and the files under [docs/git/](./docs/git/) for additional Git best practices.

## Commit History Policy: No Rewriting or Force-Pushing

- **Commit messages on pushed commits cannot be changed.** Once a commit is pushed to a shared branch, avoid `git commit --amend`, interactive rebases, and `git push --force`.
- If a commit message is unclear, add context in a new commit or the pull request description instead of rewriting history.
- This rule preserves repository integrity and auditability.

## Potato Ignore Policy

"Potato" and `Potato.md` must remain in `.gitignore`, `.dockerignore`, and `.codespell-ignore`.
Contributors may not remove or modify these entries without project lead approval and an
explanation recorded in `docs/CHANGELOG.md`.
Both pre-commit and CI run `scripts/check_potato_ignore.sh` to verify the entries exist.

## Codex CI Monitoring Policy

The `codex.ci.yml` workflow watches every CI job and step. When a failure
occurs, Codex automatically opens a task describing the error so maintainers can
investigate. The bot retries the build once and includes logs in the task if the
second attempt fails.
