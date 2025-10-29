---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "Mandatory virtual environment requirements for all development and tooling"

document_type: standards
merge_candidate: false
project: core-instructions
related_modules: 
similarity_group: policies-standards
source: .github/copilot-instructions.md
status: active
tags: 
title: "DevOnboarder Virtual Environment Policy"

updated_at: 2025-10-27
visibility: internal
---

# DevOnboarder Virtual Environment Requirements

##  CRITICAL: Virtual Environment Requirements

### NEVER INSTALL TO SYSTEM - ALWAYS USE VIRTUAL ENVIRONMENTS

This project REQUIRES isolated environments for ALL tooling:

### Mandatory Environment Usage

- **Python**: ALWAYS use `.venv` virtual environment

- **Node.js**: ALWAYS use project-local `node_modules`

- **Development**: ALWAYS use devcontainers or Docker

- **CI/CD**: ALWAYS runs in isolated containers

### Commands Must Use Virtual Environment Context

```bash

#  CORRECT - Virtual environment usage

source .venv/bin/activate
pip install -e .[test]
python -m pytest
python -m black .
python -m openapi_spec_validator src/devonboarder/openapi.json

#  WRONG - System installation

sudo pip install package
pip install --user package
black .  # (if not in venv)

```

### Why This Matters

- **Reproducible builds**: Same environment everywhere

- **Security**: No system pollution with project dependencies

- **Reliability**: Exact version control across team

- **CI compatibility**: Matches production environment

- **Multi-project safety**: No conflicts between projects

### Developer Setup Requirements

```bash

# Required first step for ALL development

python -m venv .venv
source .venv/bin/activate  # Linux/macOS

# .venv\Scripts\activate   # Windows

# Then install project

pip install -e .[test]

```
