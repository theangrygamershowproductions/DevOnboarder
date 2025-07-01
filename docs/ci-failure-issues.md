# Managing CI Failure Issues

When the CI workflow fails, it opens or updates an issue titled `CI Failures for <sha>` with a summary of the failing tests. The workflow closes the issue automatically once the same commit passes CI.

## Automatic Cleanup

- `ci.yml` searches for an open failure issue matching the commit SHA whenever the pipeline succeeds.
- If found, the workflow comments on the issue and closes it using the built-in `GITHUB_TOKEN`.

## Clearing Old Issues

Past failures may leave old `ci-failure` issues open. You can close them in bulk with the GitHub CLI:

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
