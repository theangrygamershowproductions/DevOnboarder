# Managing CI Failure Issues

When the CI workflow fails, it opens or updates an issue titled `CI Failures for
<sha>` with a summary of the failing tests. The workflow closes all open
`ci-failure` issues once any CI run succeeds.

## Automatic Cleanup

- `ci.yml` closes every open `ci-failure` issue whenever the pipeline succeeds using the built-in `GITHUB_TOKEN`.
- The workflow uploads a `ci-logs` artifact with the full job log for download after each run.
- The issue number is saved as a `ci-failure-issue` artifact so later runs update the same issue.

## Forked Pull Requests

`${{ secrets.GITHUB_TOKEN }}` is read-only when a pull request originates from a
fork. To update or close issues from those builds, you need a token granted
`issues: write` permissions. Use a personal access token or run the workflow in
`pull_request_target` to access repository secrets safely.

The same guidance appears in the issues section of
[README.md](README.md#issues-and-pull-requests). Forked pull requests must
provide a personal access token or run this workflow in `pull_request_target`
so CI can update the failure issue automatically.

### Maintainer Token Setup

Create a personal access token with `issues: write` permission when you need to
rerun CI on a contributor fork. Provide it via `GH_TOKEN` so the GitHub CLI can
comment on the failure issue:

```bash
GH_TOKEN=your_personal_token gh workflow run ci.yml -F ref=<branch>
```

Remove the token after the run completes.

## Root Cause Summaries

The workflow automatically runs `scripts/ci_log_audit.py` on the CI job log when
 a step fails and appends the resulting `audit.md` to the failure issue comment.

Run the script manually on a downloaded log if you need to dig deeper:

```bash
python scripts/ci_log_audit.py ci.log > audit.md
```

Attach the `audit.md` output to CI failure issues so maintainers can quickly spot the failing step.

## Automated Audit Step

CI runs `scripts/ci_log_audit.py` whenever a job fails. The script searches the
log for common error patterns such as `Traceback`, `npm ERR`, `ERROR`, and
`FAIL`. It counts how many times each line appears and writes the results to
`audit.md`.

The workflow uploads `audit.md` with the job logs and appends its contents to
the failure issue. The file begins with `# CI Log Audit` followed by lines
prefixed with `Nx` when a message appears multiple times or `-` if it occurs
once. Use these counts to find the most frequent errors before opening the full
log artifact.

## Clearing Old Issues

Past failures may leave old `ci-failure` issues open. You can close them in bulk with the GitHub CLI.
Install the CLI from <https://cli.github.com/> if it isn't already available.

```bash
export GH_TOKEN=your_personal_token
for n in $(gh issue list --label ci-failure --state open | awk '{print $1}' | grep -Eo '[0-9]+'); do
  gh issue close "$n" --reason completed
  echo "Closed CI-failure issue #$n"
done
```

## One-Time Cleanup Workflow

Add a workflow file to run the same commands on GitHub:

```yaml
name: Bulk Close CI-failure Issues

on:
  workflow_dispatch:

jobs:
  close-ci-failure-issues:
    runs-on: ubuntu-latest
    steps:
      - name: Bulk close all open ci-failure issues
        run: |
          for n in $(gh issue list --label ci-failure --state open | awk '{print $1}' | grep -Eo '[0-9]+'); do
            gh issue close "$n" --reason completed
            echo "Closed CI-failure issue #$n"
          done
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Trigger the workflow from the **Actions** tab using the **Run workflow** button.
Schedule it with a `schedule:` trigger if you want regular cleanup.

## Troubleshooting

- The workflow logs `gh auth status` before creating the failure issue so you can
  verify the token scopes in `gh_cli.log`.
- Download `gh_cli.log` and `audit.md` from the run's **Artifacts** section to
  inspect GitHub CLI output and the log audit summary.
- Downloading workflow run logs with `curl` or `gh run download` requires a
  token granted the `actions: read` scope. The built-in `GITHUB_TOKEN` only
  works inside GitHub Actions.
- Duplicate or missing issues are usually caused by insufficient token permissions or leftover issues from earlier runs.
