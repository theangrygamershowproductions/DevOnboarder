# Automatic Codex Issue Closing

Pull requests can reference Codex-created issues using `Fixes #<number>`. When such a PR merges, the `close-codex-issues.yml` workflow checks each referenced issue. If the issue was opened by `codex[bot]`, the workflow comments that the fix landed and closes the issue.

This automation keeps the board free of stale Codex tasks without manual cleanup.
