---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: codex-issue-autoclose.md-docs
status: active
tags:

- documentation

title: Codex Issue Autoclose
updated_at: '2025-09-12'
visibility: internal
---

# Automatic Codex Issue Closing

Pull requests can reference Codex-created issues using `Fixes #<number>`. When
such a PR merges, the `close-codex-issues.yml` workflow checks each referenced
issue. If the issue was opened by `codex[bot]`, the workflow comments that the
fix landed and closes the issue.

This automation keeps the board free of stale Codex tasks without manual cleanup.
