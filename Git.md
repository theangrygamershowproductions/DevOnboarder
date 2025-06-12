---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!--
Project: DevOnboarder
File: Git.md
Purpose: Overview of repository structure and git standards
Updated: 30 May 2025 18:45 (EST)
Version: v1.0.0
-->

# Git Standards

This project follows the guidelines detailed in
[TAGS-Operation-Alignment-Plan.md](./TAGS-Operation-Alignment-Plan.md).

## Branching
- `feature/<module>` for new features
- `bugfix/<module>` for bug fixes
- `hotfix/<module>` for urgent fixes

## Commits
- Use semantic messages under 79 characters
- Prefix with `gitmoji` or tags such as `[PATCH]` or `[FEATURE]`

## Patches
- Add or update patch headers at the top of modified files
- Record each update in [CHANGELOG.md](./CHANGELOG.md)
