---
author: TAGS Engineering
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Plugin development guidelines with virtual environment requirements and
  discovery patterns
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:
- virtual-environment-policy.md
- file-structure-conventions.md
similarity_group: development-standards
source: .github/copilot-instructions.md
status: active
tags:
- devonboarder
- plugin-development
- virtual-environment
- guidelines
title: DevOnboarder Plugin Development
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Plugin Development

## Creating Plugins (Virtual Environment Required)

```python

# plugins/example_plugin/__init__.py

"""Example plugin for DevOnboarder."""

def initialize():
    """Plugin initialization function."""
    return {"name": "example", "version": "1.0.0"}

```

Plugins are automatically discovered from the `plugins/` directory.

**Development Setup**:

```bash
source .venv/bin/activate
pip install -e .[test]
python -m pytest plugins/example_plugin/

```

## Environment Variables

### Required Variables

- `DISCORD_TOKEN`: Bot authentication token

- `DATABASE_URL`: Database connection string

- `JWT_SECRET`: Token signing secret

- `IS_ALPHA_USER` / `IS_FOUNDER`: Feature flag access

### Development vs Production

- Use `.env.dev` for development

- Environment-specific Discord guild routing

- Different database backends (SQLite vs PostgreSQL)
