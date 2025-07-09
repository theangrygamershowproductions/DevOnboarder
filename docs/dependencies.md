# Dependency Update Process

Dependabot checks our npm and pip packages every week. It opens pull requests when new versions are available.
Maintainers review each PR as follows:

- Verify CI passes without new warnings or test failures.
- Read the release notes to spot breaking changes.
- Update the changelog entry if a significant upgrade lands.
- Merge the PR using the squash option once checks succeed.

They follow [merge-checklist.md](merge-checklist.md) before finalizing the pull request.
