---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: ci-first-policy.md-docs
status: active
tags: 
title: "Ci First Policy"

updated_at: 2025-10-27
visibility: internal
---

# CI-First OpenAI API Key Policy

The `OPENAI_API_KEY` secret is only available in GitHub Actions. Workflows use this key to request patches from OpenAI. Avoid storing it in `.env` files or committing it to the repository. Run automation that requires the key through CI so usage is auditable. For occasional local testing, export your own key temporarily and remove it afterward.
