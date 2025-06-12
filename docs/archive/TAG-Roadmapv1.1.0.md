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
# 🗺️ TAG Auth Server – Phase Roadmap (v1.1.0)

**Domain:** https://auth.thenagrygamershow.com  
**Date:** April 18, 2025  
**Maintained by:** TAGS Auth Dev Team

---

## ✅ Completed Phases

### ✅ Phase 1: Discord OAuth Integration
- `/api/discord/exchange` endpoint exchanges `code` for tokens
- Fetches user profile, guilds, and roles from Discord

---

### ✅ Phase 2: Role Resolution & Access Flags
- `resolveUserAccess()` computes:
  - `isAdmin`
  - `isVerified`
  - `verificationType`
  - `verificationStatus`

---

### ✅ Phase 3: JWT Session Token Handling
- JWT tokens issued on login
- `signJwt()` and `verifyJwt()` in place
- Stateless session stored client-side

---

### ✅ Phase 4: Frontend Session Hook
- `useSession()` consumes and tracks:
  - `user`, `auth_token`
  - Access flags (`isAdmin`, `isVerified`, etc.)
  - Refresh via `/api/auth/user`

---

### ✅ Phase 5: Protected Routes + Guards
- Middleware: `validateJwt`, `requireVerified`, `requireAdmin`
- Routes:
  - `GET /api/auth/user`
  - `GET /api/auth/verify`
  - `GET /api/auth/admin/ping`

---

### ✅ Phase 6: Stubbed Verification Flow
- Routes created:
  - `POST /api/verification/request`
  - `GET /api/verification/status`
- Currently return hardcoded `"pending"`

---

### ✅ Phase 7: Session Security & ESLint Compliance
- All session flow hardened with ESLint rules
- JWT typing completed
- Secure imports and handler validation using `Zod`

---

## 🟡 In Progress

### 🚧 Phase 8: Verification DB Integration
- Replace stubbed verification routes with database logic
- Store verification requests
- Allow role-based auto-approval or manual processing

---

### 🚧 Phase 9: Security Hardening
- Add required JWT claims (`aud`, `exp`, `sub`, etc.)
- Enforce HSTS headers, HTTPS via Traefik
- Enable rate limiting and IP logging
- Follow `Security-Baseline-Checklist.md`

---

## 🟥 Upcoming Work

### 🔜 Phase 10: Admin Panel + Verification Queue
- Admin UI to view + approve/reject verifications
- Moderator override flow

---

### 🔜 Phase 11: ID.me Identity Verification
- Add support for external OAuth via ID.me
- Set verified roles based on response

---

## 📅 Phase Table Summary

| Phase | Feature                                | Status        |
|-------|----------------------------------------|---------------|
| 1     | Discord OAuth Exchange                 | ✅ Complete    |
| 2     | Role Mapping + Access Flags            | ✅ Complete    |
| 3     | JWT Token Handling                     | ✅ Complete    |
| 4     | Frontend Session Hook                  | ✅ Complete    |
| 5     | Role-Based Protected Routes            | ✅ Complete    |
| 6     | Verification Request Stub              | ✅ Complete    |
| 7     | Session Hardening + ESLint Compliance  | ✅ Complete    |
| 8     | Verification DB Integration            | 🟡 In Progress |
| 9     | Security Hardening (Checklist)         | 🟡 In Progress |
| 10    | Admin Panel + Verification Queue       | 🟥 Not Started |
| 11    | ID.me Identity Verification Support    | 🟥 Not Started |

---

**Generated on:** April 18, 2025  
**Contact:** auth@thenagrygamershow.com
