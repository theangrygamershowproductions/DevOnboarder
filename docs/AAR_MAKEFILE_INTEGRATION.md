---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: AAR_MAKEFILE_INTEGRATION.md-docs
status: active
tags:

- documentation

title: Aar Makefile Integration
updated_at: '2025-09-12'
visibility: internal
---

# AAR System Quick Setup Guide

## Automated Setup via Makefile

The AAR system has been integrated into the project Makefile for easy automation:

### 1. Environment Setup

```bash

# Create/update .env file with AAR variables

make aar-env-template

# Edit .env to set your actual tokens (uncomment and replace placeholders)

# Example

# CI_ISSUE_AUTOMATION_TOKEN=ghp_your_actual_token_here

# CI_BOT_TOKEN=ghp_your_bot_token_here

```

### 2. System Setup

```bash

# Run complete AAR system setup (loads .env automatically)

make aar-setup

```

### 3. Validation

```bash

# Check AAR system status and configuration

make aar-check

# Validate markdown templates

make aar-validate

```

### 4. Usage

```bash

# Generate AAR for specific workflow run

make aar-generate WORKFLOW_ID=12345

# Generate AAR and create GitHub issue

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true

```

## Environment Variable Management

### Automatic .env Loading

All AAR Makefile targets automatically:

- Load `.env` if it exists

- Source virtual environment

- Validate DevOnboarder compliance

### Token Priority (DevOnboarder No Default Token Policy v1.0)

1. **CI_ISSUE_AUTOMATION_TOKEN** (Primary - for issue creation)

2. **CI_BOT_TOKEN** (Secondary - for bot operations)

3. **GITHUB_TOKEN** (Fallback only - broad permissions)

### Smart .env Management

- **New setup**: `make aar-env-template` creates new `.env` with AAR variables

- **Existing .env**: Appends AAR variables only if they don't exist

- **Duplicate detection**: Won't add duplicate variables

- **Manual review**: Always prompts user to review and set actual tokens

## Complete Workflow Example

```bash

# 1. Initial setup

make aar-env-template     # Create/update .env

vim .env                  # Edit tokens (uncomment and set values)

# 2. System setup

make aar-setup           # Full AAR system setup

# 3. Validation

make aar-check           # Verify system status

make aar-validate        # Check templates

# 4. Usage

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true

```

## Integration Benefits

 **Automated environment loading**
 **DevOnboarder compliance enforced**

 **Virtual environment managed automatically**

 **Smart .env file management**

 **No duplicate variable creation**

 **Clear usage instructions**

 **Token hierarchy respected**

The Makefile integration provides a seamless developer experience while maintaining DevOnboarder's security and compliance standards.
