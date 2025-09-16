---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: task-management.md-docs
status: active
tags:
- documentation
title: Task Management
updated_at: '2025-09-12'
visibility: internal
---

# Task Management

This project tracks work items in `codex.tasks.json`. Active tasks live under the `tasks` array.
When a task's `status` is set to `complete`, move it to the `completedTasks` array to keep the main list short.

1. Open `codex.tasks.json`.

2. Move any finished entries into `completedTasks`.

3. Commit the changes alongside your code updates.

Keeping completed items separate helps Codex automation and maintainers review progress quickly.
