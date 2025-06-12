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
File: MERGE_CHECKLIST.md
Purpose: Pre-merge checklist for pull requests
Updated: 04 Jun 2025 03:00 (EST)
Version: v1.1.0
-->

# Merge Checklist

Ensure the following before merging a pull request:

- [ ] Patch headers updated where needed
- [ ] `CHANGELOG.md` entry added
- [ ] `black .` runs without errors
- [ ] `pytest` passes
- [ ] `npm run lint` and `npm run test:unit` succeed (from `frontend/`)
- [ ] Commit messages follow the guidelines in `docs/Git/Git.md`
- [ ] Branch rebased on `development` with no merge conflicts
- [ ] CI workflow reports all checks as successful
- [ ] PR description completed using the standard template
- [ ] At least one maintainer approval

Only merge after all items are checked off.
