---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: NPM_SECURITY_QUICK_REFERENCE.md-docs
status: active
tags:
- documentation
title: Npm Security Quick Reference
updated_at: '2025-09-12'
visibility: internal
---

# NPM Security Quick Reference

## CRITICAL: Root Pollution Prevention

### NEVER RUN FROM ROOT

```bash
npm audit fix       # Creates 500+ package pollution

npm install         # Violates Root Artifact Guard

npm ci              # Creates root node_modules

```

### CORRECT COMMANDS

```bash

# Service-specific fixes

npm audit fix --prefix frontend
npm audit fix --prefix bot

# Documentation tooling

npx markdownlint-cli2 docs/
npx ajv-cli validate schema.json

```

### Emergency Cleanup

```bash
rm -rf node_modules
bash scripts/enforce_output_location.sh

```

## References

- Full documentation: `docs/security/npm-security-standards.md`

- Root Artifact Guard: `scripts/enforce_output_location.sh`

- Terminal Output Policy: Plain ASCII text only in commands
