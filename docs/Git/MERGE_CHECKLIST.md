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
# 🔀 Repo Security Merge Checklist

This checklist helps track the successful integration of the shared `security/` directory and associated documentation into all project repositories under The Angry Gamer Show Productions.

---

## 📋 Integration Items

- [x] SECURITY_POLICY.md
- [x] threat-model.md
- [x] penetration-test-plan.md
- [x] run-all-scans.sh
- [ ] CI/CD pipeline hooks (optional/next phase)

---

## 📁 Merge Tracker

| Repo Name     | Local Path       | Maintainer   | Merged to `dev`? | Notes                             |
|---------------|------------------|--------------|-------------------|------------------------------------|
| Frontend      | `./frontend/`    | Chad         | ✅ Yes             | Tools tested, merged to dev        |
| Auth Service  | `./auth/`        | Chad         | ✅ Yes             | Fully integrated                   |
| Admin UI      | `./admin-ui/`    | TBD          | ⬜ No              | Not yet reviewed                   |
| Docs          | `./docs/`        | Chad         | ✅ Yes             | Host for shared policy references  |
| Main Project  | `./`             | Chad         | ✅ Yes             | Source of truth for security setup |

---

## 📝 Action Items

- [ ] Confirm tool execution (`run-all-scans.sh`) works in each repo
- [ ] Begin wiring scan scripts into CI/CD flows (GitHub Actions, Azure Pipelines)
- [ ] Add Snyk configuration if applicable
- [ ] Begin first cycle of monthly manual scans

---

Maintained by: **Information System Security Officer (ISSO)**  
Last updated: {{DATE}}
