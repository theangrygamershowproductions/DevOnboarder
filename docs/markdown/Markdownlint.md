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
# Markdownlint Configuration Instructions

Overview
This guide explains how to configure markdownlint v0.37.4 for the project, ensuringconsistent Markdown formatting in VSCode and CI/CD pipelines. A .markdownlint.json filecustomizes linting rules to reduce errors and align with project needs.
Why Use .markdownlint.json?

Ensures consistent Markdown formatting (e.g., no bare URLs, single blank lines).
Reduces linting errors in VSCode for files like README.md and DEVELOPER.md.
Simplifies contributor onboarding by defining clear formatting rules.
Supports automation in CI/CD workflows.

Setup Instructions

Create .markdownlint.json:
nano .markdownlint.json

Add the following configuration:
{
  "default": true,
  "MD012": true,
  "MD013": {
    "line_length": 80,
    "code_block_line_length": 120,
    "strict": false
  },
  "MD033": {
    "allowed_elements": []
  },
  "MD034": true,
  "MD041": true
}

Verify Permissions:
chmod 644 .markdownlint.json

Add to .gitignore (optional):If the config is project-specific and not meant to be shared, add:
echo ".markdownlint.json" >> .gitignore

Test Linting:Install markdownlint-cli:
npm install -g markdownlint-cli@0.37.4

Run:
markdownlint README.md DEVELOPER.md CHANGELOG.md
pre-commit run --all-files

VSCode Integration:

Install the markdownlint extension (DavidAnson.vscode-markdownlint).
Open Markdown files; check the Problems panel (Ctrl+Shift+M).
The .markdownlint.json is automatically detected.
For full VS Code configuration, see [../.vscode-integrations/README.md](../../.vscode-integrations/README.md).

Customization

Disable Line Length (MD013):For long URLs or commands, set:"MD013": false

Allow HTML (MD033):For specific HTML tags, add:"MD033": { "allowed_elements": ["xaiArtifact"] }

CI/CD Integration
Add to GitHub Actions:
name: Lint Markdown
on: [push]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install -g markdownlint-cli@0.37.4
      - run: markdownlint README.md DEVELOPER.md CHANGELOG.md

Troubleshooting

Errors Persist: Check .markdownlint.json syntax:cat .markdownlint.json

VSCode Issues: Verify extension settings:cat .vscode/settings.json
Linting Errors: Check for conflicting rules in .markdownlint.json.
Linting Errors in CI/CD: Ensure markdownlint-cli is installed and configured correctly.
