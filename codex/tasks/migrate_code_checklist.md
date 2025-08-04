---

title: Checklist - Migrate Code to Extracted Repos
project: DevOnboarder
codex\_scope: repo\_split\_phase1
codex\_role: project\_maintainer
codex\_type: task\_checklist
status: draft
created\_at: 2025-08-03
tags:

* codex-task
* code-migration
* repo-split

---

## Objective

Move relevant source code from the main DevOnboarder monorepo to the newly created `devonboarder-frontend` and `devonboarder-discordbot` repositories.

## Checklist

### 🗂️ Frontend Code Migration

* [ ] Move `src/`, `routes/`, `components/`, and UI-related files to `devonboarder-frontend`
* [ ] Ensure all environment variables used in `.env` are documented in `.env.example`
* [ ] Copy `package.json`, `tsconfig.json`, `vite.config.ts` and related frontend build files
* [ ] Verify all static assets (e.g., images, fonts) are correctly migrated

### 🤖 Discord Bot Code Migration

* [ ] Move `bot/`, `discord/`, and any `cogs/` or command modules to `devonboarder-discordbot`
* [ ] Re-validate `discord.py`, `hikari`, or `nextcord` dependency versions
* [ ] Port over logging config, runtime triggers, and bot start logic
* [ ] Include Codex Agent interfaces if embedded in bot

### 🔁 Repo Cleanup and Validation

* [ ] Remove duplicated code from `devonboarder` core repo *after* validation
* [ ] Ensure `README.md` in each new repo reflects new structure
* [ ] Verify both repos pass linting and CI locally before first push

---

Prepared by: Project Maintainer
Date: 2025-08-03
