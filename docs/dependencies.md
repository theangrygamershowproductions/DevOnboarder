---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Dependency update process and maintenance procedures using Dependabot
document_type: reference
merge_candidate: false
project: DevOnboarder
similarity_group: dependencies.md-docs
status: active
tags:

- reference

- dependencies

- maintenance

- dependabot

title: Dependency Update Process
updated_at: '2025-09-12'
visibility: internal
---

# Dependency Update Process

Dependabot checks our npm and pip packages every week. It opens pull requests when new versions are available.
Maintainers review each PR as follows:

- Verify CI passes without new warnings or test failures.

- Read the release notes to spot breaking changes.

- Update the changelog entry if a significant upgrade lands.

- Merge the PR using the squash option once checks succeed.

They follow [merge-checklist.md](merge-checklist.md) before finalizing the pull request.
