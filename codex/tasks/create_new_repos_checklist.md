---
title: Checklist - Create New Repositories

project: DevOnboarder
codex_scope: repo-split-phase1
codex_role: project_maintainer
codex_type: task_checklist
status: draft
created_at: 2025-08-03
tags:
  - codex-task

  - repository-creation

  - phase1

---

## Objective

Create and initialize two standalone repositories from the main DevOnboarder monorepo: one for the frontend app and one for the Discord bot.

## Checklist

### 📦 Repository Creation

* [ ] Create `devonboarder-frontend` GitHub repository under TAGS org

* [ ] Create `devonboarder-discordbot` GitHub repository under TAGS org

* [ ] Add standard README, LICENSE, and `.gitignore` files to each

* [ ] Apply branch protection and enable required CI checks (e.g., `main`, `dev` branches)

### 🔐 Secrets and CI/CD

* [ ] Configure GitHub Secrets: `CODENAME_BOT_TOKEN`, `DISCORD_BOT_TOKEN`, `FRONTEND_DEPLOY_KEY`, etc.

* [ ] Re-create GitHub Actions workflows (`ci.yml`, `deploy.yml`, etc.)

* [ ] Validate `.venv` or Node.js dependencies as appropriate

### 🔧 Repo Metadata

* [ ] Populate `docs/README.md` with repo-specific instructions

* [ ] Include metadata block with Codex scope and routing roles

* [ ] Link back to core DevOnboarder orchestration if needed

---

Prepared by: DevOps Lead

Date: 2025-08-03
