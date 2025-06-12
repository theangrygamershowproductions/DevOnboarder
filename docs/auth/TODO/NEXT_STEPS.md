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
# 🚀 Post-Release TODO — Auth Server (The Angry Gamer Show)

This file contains the technical debt and enhancement checklist to revisit after Version 1 is released.

---
<!-- PATCHED v0.2.9 docs/auth/TODO/NEXT_STEPS.md — Mark completed items -->

## 🗂 Environment Improvements

- [x] Create `.env.frontend.dev` for Vite
- [x] Add `vite.config.ts` with `envPrefix` and dev mode support
- [x] Add `docker-compose.override.yaml` for local dev tuning
- [x] Add `Makefile` or `npm run dev:docker` script for easier startup

---

## 🛡 Security & Maintenance

- [ ] Add runtime `.env` schema validation with `zod`, `envsafe`, or `envalid`
- [x] Move all `DISCORD_` secrets into secure Docker secrets for production
- [x] Lock down CORS further for `auth.thenagrygamershow.com`

---

## 🧠 Notes

> These improvements are intentionally deferred until after v1 is released to avoid increasing technical complexity and delaying launch.

Focus for now: **stability, security, and shipping MVP.**
