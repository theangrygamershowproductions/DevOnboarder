---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: tasks-tasks
status: active
tags:
- documentation
title: Doc Lint Debt
updated_at: '2025-09-12'
visibility: internal
---

# Documentation Lint Debt

This issue tracks Markdown files that still fail `scripts/check_docs.sh`.
Use it when batch-fixing docs.

## How to Help

1. Follow the steps in [doc-quality-onboarding.md](../doc-quality-onboarding.md).

2. Run `codespell -w docs/` and `npx prettier -w "docs/**/*.md"`.

3. Re-run `bash scripts/check_docs.sh` and commit the fixes.

4. Open a small pull request targeting a few files at a time.

Add notes below about any tricky files or skipped warnings.

- Fixed `AGENTS.md` list formatting and updated outreach links in

  `docs/outreach-materials.md`.
