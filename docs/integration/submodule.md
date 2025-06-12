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
<!-- PATCHED v0.2.28 docs/integration/submodule.md — document submodule usage -->

<!--
Project: DevOnboarder
File: docs/integration/submodule.md
Purpose: Guide for using Git submodules for frontend and backend
Updated: 16 Aug 2025 00:00 (EST)
Version: v1.0.0
-->

# Submodule Integration Guide

This repository can include the `frontend` and `backend` projects as Git
submodules. Submodules let you track external repositories within this
one while keeping their history separate.

## Adding the Submodules

```sh
git submodule add https://github.com/your-org/frontend.git frontend
git submodule add https://github.com/your-org/backend.git backend
```

After cloning the parent repository run:

```sh
git submodule update --init --recursive
```

## Updating Submodules

To pull the latest commits from each remote branch and update the checked
out paths:

```sh
git submodule update --remote frontend
git submodule update --remote backend
```

Commit the resulting changes to record the new submodule references.
