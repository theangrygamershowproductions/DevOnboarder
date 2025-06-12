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
File: codex/README.md
Purpose: Codex evaluation logic
Updated: 17 Aug 2025 00:00 (EST)
Version: v1.0.0
-->
<!-- PATCHED v0.1.0 codex/README.md — Document policy injection helper -->

# Codex

Evaluation logic for onboarding challenges.

## Policy Injection Helper

Run `injectPolicies` to copy the standard LICENSE, NOTICE, and CLA files into
your repository. Pass `--owner "Example Co."` to replace the owner placeholder
and `--summary` to print how many files were added or skipped. Use
`--skip-policies` to disable the step entirely.

```ts
const summary = await copyPolicies('out/policies', 'Example Co.');
// { added: 3, skipped: 0 }
```
