# Managing CI Failure Issues

When the CI workflow fails, it opens or updates an issue titled `CI Failures for <sha>` with a summary of the failing tests. The workflow closes all open `ci-failure` issues once any CI run succeeds.

## Automatic Cleanup

- `ci.yml` closes every open `ci-failure` issue whenever the pipeline succeeds using the built-in `GITHUB_TOKEN`.
- The workflow uploads a `ci-logs` artifact with the full job log for download after each run.

## Root Cause Summaries

Run `scripts/ci_log_audit.py` on a downloaded log to highlight common errors.

```bash
python scripts/ci_log_audit.py ci.log > audit.md
```

Attach the `audit.md` output to CI failure issues so maintainers can quickly spot the failing step.

## Clearing Old Issues

Past failures may leave old `ci-failure` issues open. You can close them in bulk with the GitHub CLI:

> **Note**: These examples require GitHub CLI v2 or later for the `--json` and `--jq` flags.
> Run `./scripts/install_gh_cli.sh` to install the CLI if it isn't already available.

```bash
export GH_TOKEN=your_personal_token
for n in $(gh issue list --label ci-failure --state open --json number --jq '.[].number'); do
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
          for n in $(gh issue list --label ci-failure --state open --json number --jq '.[].number'); do
            gh issue close "$n" --reason completed
            echo "Closed CI-failure issue #$n"
          done
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Trigger the workflow from the **Actions** tab using the **Run workflow** button. Schedule it with a `schedule:` trigger if you want regular cleanup.
