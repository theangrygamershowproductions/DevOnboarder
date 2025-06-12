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
<!-- PATCHED v0.1.36 frontend/README.md — Document local setup -->

# Frontend

This directory contains the React application powered by Vite. It will interact with the authentication service for login and session handling.

## Build

Run `pnpm build` from this directory to create the production bundle. The command compiles Tailwind CSS via PostCSS and outputs the assets to `dist/`.

## Local Development

1. Copy `.env.frontend.dev` to `.env` and adjust values as needed.
2. Install dependencies with `pnpm install`.
3. Start the Vite server:

```bash
pnpm dev
```

## Build for Production

```bash
pnpm build
```

## Lint and Unit Tests

```bash
pnpm lint
pnpm test:unit
```
