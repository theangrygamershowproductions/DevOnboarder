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
# 🎮 Project Scope & Timeline — The Angry Gamer Show Productions
<!-- PATCHED v0.2.9 docs/Project_Scope_and_Timeline.md — Use .env.development -->

---

## 🔭 Project Overview

The Angry Gamer Show Productions is a multi-phase development initiative focused on creating an interactive ecosystem for gamers, streamers, and content creators. The core systems include:

- 🌐 A **frontend web application** for account management and verification status
- 🔐 A **backend OAuth2 authentication server** for Discord login, role checks, and session issuing
- 🛡️ A **role-based access control system** using Discord roles for admin/mod gating
- 🧾 Identity verification via Discord roles and future ID.me OAuth support
- 🚀 Upcoming features: verification database, admin tools, and JWT session expansion

---

## 🧱 Project Architecture

**Backend Auth Server:**  
- Token exchange via `/api/discord/exchange`  
- Secure JWT issuing and session parsing via `validateJwt` middleware  
- Role flags: `isAdmin`, `isVerified`, `verificationType`, `verificationStatus`  
- All logic tied to environment-driven role IDs (see `.env.development` and `auth/User_Role_Matrix.md`)

**Frontend App:**  
- Uses `useSession()` to parse and persist session state  
- UI routes conditionally gated by role flags  
- Integrated with backend endpoints for login, verification, and session refresh

---

## 📘 Project Scope & Completed Phases

### ✅ Phase 1: Discord OAuth Integration
- Implemented `/api/discord/exchange` and aliased `/api/auth/discord/token`
- Fetches user profile, guilds, and member object
- Role parsing and session structure

### ✅ Phase 2: Verification Flag System
- Adds `verificationType` and `verificationStatus`
- Mapped roles from `.env` for GOV/MIL/EDU flags
- Response payload expanded and documented

### ✅ Phase 3: JWT Issuing
- Secure token signing with `signJwt`
- JWT includes strict type payload with expiration
- `validateJwt` parses tokens and populates `req.user`

### ✅ Phase 4: Role-Based Route Protection
- `requireAdmin` and `requireVerified` middleware implemented
- Guarded `/api/auth/admin/ping` and `/api/auth/verify`

### ✅ Phase 5: Frontend Session Integration
- `useSession()` consumes `auth_token` and `user` from login
- Session state includes admin and verification status
- Auto-refresh and interval sync planned for production

### ✅ Phase 6: ESLint Type-Safety + Security Baseline
- Refactored JWT logic to remove unsafe TypeScript access
- Security Baseline Checklist added (see `Security-Baseline-Checklist.md`)

### ✅ Phase 7: Session Gating & Verification Stub
- `/api/auth/user` returns session info
- `/api/verification/status` returns `pending`
- `/api/verification/request` logs request with type
- Phase 7 Handoff docs prepared

### 🔄 Phase 8: Database-backed Verification
- SQLite table `verification_requests` created
- `/api/verification/request` persists to DB
- `/api/verification/status` reads latest record

---

## 📅 Project Timeline

| Phase | Description                                   | Status     | ETA              |
|-------|-----------------------------------------------|------------|------------------|
| 1     | Discord Auth Core + Role Mapping              | ✅ Done     | Q1 2025          |
| 2     | Identity Verification Support (GOV/MIL/EDU)   | ✅ Done     | Q2 2025          |
| 3     | JWT Token Signing & Session Payload           | ✅ Done     | Q2 2025          |
| 4     | Route Guards: Admin + Verified Checks         | ✅ Done     | Q2 2025          |
| 5     | Frontend Integration with `useSession()`      | ✅ Done     | Q2 2025          |
| 6     | Security Baseline (ESLint + Controls)         | ✅ Done     | Q2 2025          |
| 7     | Session Extension & Verification Request Stub | ✅ Done     | Mid-April 2025   |
| 8     | Database-backed Verification Flow             | 🔄 Started  | Late April 2025  |
| 9     | Token Invalidation + Logout Flow              | ⏳ Planned  | May 2025         |
| 10    | Admin Panel + Role Manager (Internal UI)      | ⏳ Planned  | Q3 2025          |

---

-## 🧪 Next Steps

- [ ] Add full `POST /logout` token invalidation
- [ ] Harden session expiration and refresh logic
- [ ] Phase 10: Scaffold admin interface for badge + role editing
- [ ] Final production hardening and open beta launch

---

📄 **Updated:** April 19, 2025
🧠 Maintainer: TAGS Dev Team — `auth@thenagrygamershow.com`
