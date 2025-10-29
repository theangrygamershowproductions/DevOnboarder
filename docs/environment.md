---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Environment variable management and documentation maintenance procedures"

document_type: reference
merge_candidate: false
project: DevOnboarder
similarity_group: environment.md-docs
status: active
tags: 
title: "Environment Variable Management"

updated_at: 2025-10-27
visibility: internal
---

# Environment Maintenance

Use `scripts/regenerate_env_docs.py` whenever you update any `.env.example` file.
The script parses the example files and rewrites the environment variable table
in `agents/index.md`.

```bash
python scripts/regenerate_env_docs.py

```

CI runs this command automatically before validating the docs, but running it
locally ensures the documentation stays current.
