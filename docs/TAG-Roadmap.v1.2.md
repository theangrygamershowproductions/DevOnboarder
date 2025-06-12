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
# 🗺️ TAG-Roadmap.v1.2.0.md

**Project:** The Angry Gamer Show Productions — Secure Auth Platform  
**Version:** v1.2.0  
**Prepared By:** Chad Reesey  
**Last Updated:** 23 April 2025 21:52 (EST)

---

## 📌 Phase Breakdown & Objectives

| Phase | Title                                   | Goals                                                                                   | Timeline              |
|-------|------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------|
| 1     | Project Initiation & HR Setup            | Establish company identity, HR policy, NDA, project scope                              | Feb 22–Feb 28, 2025   |
| 2     | OAuth Backend Architecture               | Set up Discord OAuth2, exchange flow, and JWT generation                               | Mar 1–Mar 14, 2025    |
| 3     | Docker & Infrastructure Setup            | Containerize backend, enable persistent storage, set up proxy                          | Mar 4–Mar 20, 2025    |
| 4     | Frontend & Auth Integration              | Build Vite+React frontend, connect OAuth exchange, enable session storage              | Mar 21–Apr 5, 2025    |
| 5     | Role Mapping & Security Layers           | Add `.env` role mapping, create role flags, integrate guards                           | Apr 6–Apr 12, 2025    |
| 6     | Session Token Handling + Middleware      | Validate JWTs, useSession() hook, token refresh logic                                  | Apr 13–Apr 18, 2025   |
| 7     | Debug & Patch Alignment                  | Patch roles, debug `/auth/user`, align with frontend                                   | Apr 19–Apr 22, 2025   |
| 8     | Mod Tools                                | Create admin panels, moderation routes, role filters, scaffold `/api/admin` endpoints | Apr 23–Apr 26, 2025   |
| 9     | Verification Workflows (DB-backed)       | Accept and store user verification requests, protect verified routes                   | Apr 27–May 3, 2025    |
| 10    | Scam Defense Simulation + Reports        | Educational trap sites, user submissions, feedback system                              | May 4–May 12, 2025    |
| 11    | Streamer & Influencer Integration        | Creator sign-up flow, Discord role onboarding, social links                            | May 13–May 20, 2025   |
| 12    | Subscription + Billing Models            | Setup Stripe/PayPal integrations, create sub plans                                     | May 21–May 30, 2025   |
| 13    | Public Launch Prep + QA Testing          | Internal testing, documentation, staging domain review                                 | May 31–Jun 10, 2025   |
| 14    | Open Beta & Feedback Loop                | Public beta launch, bug reporting, iteration feedback                                  | Jun 11–Jun 25, 2025   |

---

## 🧩 Milestone Tags
- `v1.0.0` → OAuth exchange stable + JWT working
- `v1.1.0` → Frontend aligned with backend session management
- `v1.1.5` → `/auth/user` refresh route complete + debugging
- `v1.2.0` → Roadmap realignment + Phase 8–14 planning (this doc)

---

## 🧠 Notes
- Feature flags may be used for toggling access (`ALLOW_GUILD_MEMBER_ACCESS`)
- Future version `v1.3.0` will include data persistence and analytics dashboard
- All routes are semantically versioned (PATCH format: `vX.Y.Z` per file)

