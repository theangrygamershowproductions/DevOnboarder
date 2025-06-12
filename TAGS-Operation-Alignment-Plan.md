---
project: "TAGS"
module: "Operation Alignment Plan"
phase: "MVP"
tags: ["operations", "workflow", "patch"]
updated: "10 June 2025 02:15 (EST)"
version: "v0.0.1"
---

# Operation Alignment Plan – MVP

<!-- PATCHED v0.0.1 TAGS-Operation-Alignment-Plan.md — add YAML header -->
<!--
Project: DevOnboarder
File: TAGS-Operation-Alignment-Plan.md
Purpose: Defines development workflow and source control standards
Updated: 30 May 2025 18:45 (EST)
Version: v1.0.0
-->

## 🔁 Development Workflow Standardization

### Source Control
- All changes go through pull requests (PRs) with semantic commit messages.
- Branch naming convention: `feature/<module>`, `bugfix/<module>`, `hotfix/<module>`
- PRs must link to Azure DevOps or GitHub work items.

### File Versioning
- Patch headers in each file (e.g., `v1.0.2`) updated per change
- Each PR includes a change log entry

### Git Standards
- Commit: max 79 characters per line
- Use semantic commit messages in the `<type>(<scope>): <subject>` format
  (see `docs/Git/Git.md`)
- Document structure and standards saved in `Git.md`

### PR Template
- Refer to [TAGS: PR Template](./TAGS-PR-Template.md)
- Version: v1.0.0 — Last updated: 26 May 2025 17:48 (EST)
