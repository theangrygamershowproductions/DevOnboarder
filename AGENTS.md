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

3. **Development Environment**
   - Use the provided container setup and compose files for local development.
   - Ensure all tests pass before submitting a PR.

4. **Contribution Guidelines**
   - Keep pull requests focused and small.
   - Update documentation and the changelog with each change.
