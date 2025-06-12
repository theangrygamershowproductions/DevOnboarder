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
<!-- PATCHED v0.3.0 scripts/README.md — Document utility scripts -->

# Scripts

Utility scripts for development and CI.

- `create-env.sh` - copy `.env.example` to `.env.development` and infrastructure `.env`
- `openai_smoke.py` - quick API key validation against `https://api.openai.com`
- `rotate-secret.sh` - rotate a GitHub repository secret using the `gh` CLI
- `check-quota.py` - fail build if OpenAI usage exceeds 80% of monthly budget
