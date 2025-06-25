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

4. **Contribution Guidelines**
- Keep pull requests focused and small.
- Update documentation and the changelog with each change.

## Potato Ignore Policy

"Potato" and `Potato.md` must remain in `.gitignore`, `.dockerignore`, and `.codespell-ignore`.
Contributors may not remove or modify these entries without project lead approval and an
explanation recorded in `docs/CHANGELOG.md`.

## Codex CI Monitoring Policy

The `codex.ci.yml` workflow watches every CI job and step. When a failure
occurs, Codex automatically opens a task describing the error so maintainers can
investigate. The bot retries the build once and includes logs in the task if the
second attempt fails.
