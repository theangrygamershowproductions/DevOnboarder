# DevOnboarder Protocol

This repository follows the DevOnboarder protocol. Key points:

1. **Trunk-based workflow**

- All stable code lives on `main`.
- Short-lived branches are created off `main` for every change.
- Changes are merged back into `main` through pull requests.
- Feature branches are deleted after merge.

1. **Documentation**

- General onboarding instructions: `docs/README.md`.
- Git guidelines: `docs/git-guidelines.md`.
- Pull request template: `docs/pull_request_template.md`.
- Maintainer merge checklist: `docs/merge-checklist.md`.
- Project changelog: `docs/CHANGELOG.md`.
- Offline setup instructions: `docs/offline-setup.md`.
- Multi-bot orchestration guide: `docs/orchestration.md`.

1. **Development Environment**

- Use the provided container setup and compose files for local development.
- Ensure all tests pass before submitting a PR.
    - Workflows rely on the preinstalled GitHub CLI or the
      `ksivamuthu/actions-setup-gh-cli` action.

1. **Contribution Guidelines**

- Keep pull requests focused and small.
- Update documentation and the changelog with each change.

## Agent Index Requirements

All agent documentation must include a `codex-agent` YAML header and be listed
in `codex/agents/index.json` so Codex can locate each role during automation.

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
DOCS(ci): Document built-in GITHUB_TOKEN usage for CI failure issues

- Clarifies workflow token use in README
- Updates changelog with policy details
```

See [docs/git-guidelines.md](./docs/git-guidelines.md) and the files under
[docs/git/](./docs/git/) for additional Git best practices.

## Commit History Policy: No Rewriting or Force-Pushing

- **Commit messages on pushed commits cannot be changed.** Once a commit is
  pushed to a shared branch, avoid `git commit --amend`, interactive rebases,
  and `git push --force`.
- If a commit message is unclear, add context in a new commit or the pull request
  description instead of rewriting history.
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

## Skipping CI Runs

Prefix a commit message with `[no-ci]` to skip the CI workflow when pushing
directly to a branch. Pull requests always run the workflow regardless of this
marker.

The workflow also skips its test job when a push only modifies documentation or
Markdown files. It uses `dorny/paths-filter` to set `steps.filter.outputs.code`
to `false` in that case.

## \U0001F512 Security Note

CI/CD scripts must not fetch and execute remote code via `curl | sh`. Tools like
Codecov are prohibited due to past security breaches. Use local coverage
reporting instead and vet all third-party integrations carefully.

## Troubleshooting Guide: CI Failure Issue Automation

If you notice that CI failure issues (`ci-failure` or `ci-health`) are not being closed automatically—or that you’re receiving duplicate or excessive notification emails—follow these steps:

### 1. Check Workflow Logs

* Go to **Actions** in your GitHub repository.
* Find the run where issues were supposed to be closed (typically on a successful build or during the cleanup job).
* Open the workflow run and review the logs for any errors or warnings in the steps related to:
  * `gh issue close`
  * `gh issue create`
* **Common error messages:** “Resource not accessible by integration”, “insufficient permission”, “No issues found”, etc.

### 2. Verify Token Usage

* In the workflow YAML (`.github/workflows/ci-health.yml` and others), confirm that you are setting the environment variable:

  ```yaml
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  ```
* Ensure all steps that use the `gh` CLI have access to this variable.

### 3. Confirm Token Permissions

* The default `GITHUB_TOKEN` **should** have `issues: write` permission in your repository’s main branch context.
* **Forks or external contributors:**
  * For security, `GITHUB_TOKEN` in forks has reduced permissions. Closing issues may not work from forked PR workflows.
* **To check:**
  * Go to your repo → **Settings** → **Actions** → **General** → **Workflow permissions**.
  * Ensure “Read and write permissions” is enabled for `GITHUB_TOKEN`.

### 4. Review Issue-Cleanup Logic

* Open your workflow YAML and locate the step that closes issues. Example:

  ```yaml
  - name: Close CI failure issues
    if: ${{ success() }}
    run: |
      gh issue list --label ci-failure --state open | awk '{print $1}' | xargs -n1 gh issue close
    env:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  ```
* Ensure:
  * The `gh` CLI commands are not being skipped (check any `if:` conditions).
  * The filter logic (labels, state, etc.) matches the actual issues.
  * There are no silent failures—add `set -e` or print error output for failed commands.

### 5. Handle Duplicates or Stale Issues

* If issues remain open or duplicate:
  * Run `gh issue list --label ci-failure --state open` manually in your local terminal (with a PAT or appropriate token).
  * Close leftover issues by hand if needed.
* Consider adding a scheduled cleanup workflow (e.g., weekly) to close any lingering CI failure issues automatically.

### 6. Escalate/Automate Further

* If you routinely hit token limitations, create a [Personal Access Token (PAT)](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) with `issues: write`, and add it as a secret (e.g., `CI_ISSUE_TOKEN`).
* Update your workflow to use `CI_ISSUE_TOKEN` when available, falling back to `GITHUB_TOKEN` otherwise.

### 7. Document Known Limitations

* Note in your README or AGENTS.md:

  > *“Issue automation may fail or duplicate on forks or when GitHub token permissions are restricted. For persistent problems, see [Troubleshooting Guide](#troubleshooting-guide-ci-failure-issue-automation).”*

## Quick Checklist

* [ ] Reviewed workflow logs for errors.
* [ ] Confirmed correct token usage and permissions.
* [ ] Checked issue-closing step logic.
* [ ] Closed stale issues as needed.
* [ ] (Optional) Scheduled periodic cleanup workflow.
* [ ] Documented limitations for future contributors.
