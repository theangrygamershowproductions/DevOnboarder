---
title: "codex_triage"
description: "Default safe triage agent for unlabeled PRs (no codegen)."
author: "TAGS Engineering"
version: "1.0.0"
created_at: "2025-08-09"
updated_at: "2025-08-09"
tags: ["triage"]
project: "DevOnboarder"
document_type: "agent"
status: "experimental"
visibility: "internal"
codex_scope: "tags"
codex_role: "triage"
codex_type: "system-agent"
codex_runtime: "ci"
---

# Codex Triage Agent

## Purpose

Default safe triage agent for unlabeled PRs that provides essential maintenance and organization without making code changes.

## Actions

- **Normalize labels**: Apply consistent labeling based on PR content
- **Post checklist**: Add relevant checklists for review process
- **Assign reviewers**: Suggest appropriate reviewers based on file changes
- **Status updates**: Provide status information and guidance

## Non-goals

- **Code changes**: This agent never modifies source code
- **Destructive actions**: No deletions or major structural changes
- **Automated merging**: Human approval always required

## Implementation

The triage agent focuses on organizing and preparing PRs for human review. It provides value through consistent labeling and helpful guidance without the risks associated with automated code generation.

### Key Functions

1. **Label Standardization**: Apply consistent labels based on:
   - File paths (`frontend/`, `bot/`, `docs/`, etc.)
   - Change types (`feat`, `fix`, `docs`, etc.)
   - Priority indicators

2. **Reviewer Assignment**: Suggest reviewers based on:
   - Code ownership patterns
   - Recent contribution history
   - Subject matter expertise

3. **Checklist Generation**: Add relevant checklists for:
   - Testing requirements
   - Documentation updates
   - Breaking change notifications

4. **Status Communication**: Provide clear status updates about:
   - CI requirements
   - Review progress
   - Merge readiness

## Safety Features

- **Read-only operations**: Agent can only read repository data
- **No merge permissions**: Cannot merge or close PRs
- **Audit trail**: All actions are logged and traceable
- **Human oversight**: All suggestions require human approval
