---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: token-setup-guide.md-docs
status: active
tags: 
title: "Token Setup Guide"

updated_at: 2025-10-27
visibility: internal
---

# DevOnboarder Token Setup Guide

## Critical Issue Identified

**Date**: 2025-09-04
**Issue**: All GitHub tokens only have `contents:read` permission, missing critical permissions for intended operations.

## Required Token Permissions

### For AAR System Operations

**AAR_TOKEN** needs:

-  `contents:read` (already has)

-  **MISSING**: `actions:read` (to access workflow runs, jobs, artifacts)

-  **MISSING**: `issues:write` (to create AAR issues)

### For CI Automation

**CI_ISSUE_AUTOMATION_TOKEN** needs:

-  `contents:read` (already has)

-  **MISSING**: `issues:write` (to create CI failure issues)

-  **MISSING**: `pull_requests:write` (to manage PR automation)

**CI_BOT_TOKEN** needs:

-  `contents:read` (already has)

-  **MISSING**: `actions:read` (for CI health monitoring)

### For Orchestration Operations

**DEV_ORCHESTRATION_BOT_KEY** needs:

-  `contents:read` (already has)

-  **MISSING**: `actions:write` (for workflow coordination)

-  **MISSING**: `pull_requests:write` (for automated PRs)

-  **MISSING**: `issues:write` (for orchestration issues)

## Quick Fix for AAR System

**Immediate Action**: Update the `AAR_TOKEN` permissions to include:

1. **actions:read** - Required to access:

   - `/repos/{owner}/{repo}/actions/runs`

   - `/repos/{owner}/{repo}/actions/jobs/{job_id}`

   - `/repos/{owner}/{repo}/actions/artifacts`

2. **issues:write** - Required to create AAR reports as GitHub issues

## GitHub Fine-Grained Token Configuration

To update token permissions:

1. Go to GitHub  Settings  Developer settings  Personal access tokens  Fine-grained tokens

2. Find the `AAR_TOKEN`

3. Edit permissions:

   - **Repository permissions**:

     - Actions: **Read**

     - Contents: **Read** (keep existing)

     - Issues: **Write**

     - Metadata: **Read**

     - Pull requests: **Read**

## Validation Script

Run this to verify the fix:

```bash
cd /home/potato/DevOnboarder
source .venv/bin/activate
python scripts/token_manager.py

```bash

Expected result after fix:

```bash
🎯 Operation Coverage:
    actions_api: 1 suitable tokens
      Available: AAR_TOKEN
    issue_management: 1 suitable tokens
      Available: AAR_TOKEN

```bash

## Complete Token Permission Matrix

| Token Name | actions:read | issues:write | contents:read | pull_requests:write |
|------------|--------------|--------------|---------------|---------------------|
| `AAR_TOKEN` | **NEEDED** | **NEEDED** |  Has | Recommended |

| `CI_ISSUE_AUTOMATION_TOKEN` | Nice-to-have | **NEEDED** |  Has | **NEEDED** |

| `CI_BOT_TOKEN` | **NEEDED** | Nice-to-have |  Has | Nice-to-have |

| `DEV_ORCHESTRATION_BOT_KEY` | **NEEDED** | **NEEDED** |  Has | **NEEDED** |

## Long-term Strategy

1. **Phase 1**: Fix AAR_TOKEN permissions (immediate)

2. **Phase 2**: Update CI_ISSUE_AUTOMATION_TOKEN permissions

3. **Phase 3**: Create missing specialized tokens (DIAGNOSTICS_BOT_KEY, CI_HEALTH_KEY)

4. **Phase 4**: Implement token rotation and monitoring

## Testing the Fix

After updating AAR_TOKEN permissions, test:

```bash

# Test actions API access

gh api repos/theangrygamershowproductions/DevOnboarder/actions/runs -f per_page=1

# Test AAR system

make aar-generate WORKFLOW_ID=17464386031

```bash

## Security Notes

- Fine-grained tokens are scoped to specific repositories

- Principle of least privilege: only grant minimum required permissions

- Regular token rotation recommended (quarterly)

- Monitor token usage in security audit logs
