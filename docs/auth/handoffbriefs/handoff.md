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
# 🧾 Handoff Brief – TAG Auth Server
<!-- PATCHED v0.2.9 docs/auth/handoff.md — Use .env.development -->

This document serves as a quick handoff summary for continuing development on the Discord OAuth backend for **The Angry Gamer Show Productions**.

---

## 📦 Project Context

**Component:** `auth-server`  
**Type:** Discord OAuth2 token exchange + session issuing backend  
**Environment:** `.env.development` is used for all token secrets, role IDs, and server config  
**Current Version:** `1.1.0`  
**Docs Repo:**  
https://dev.azure.com/theangrygamer/The%20Angry%20Gamer%20Show%20Productions/_git/Documentation  
`/auth/frontend-session-access-guide.md` contains frontend integration notes.

---

## 🔐 Core Flow (Already Working)

- POST `/api/auth/discord/token` (also aliased as `/api/discord/exchange`)
  - Exchange `code` for access token
  - Fetch:
    - Discord user profile (`/users/@me`)
    - All guilds
    - Member object for **ADMIN_SERVER_GUILD_ID**
  - Extract user roles from admin server only
  - Map user access:
    - `isAdmin`
    - `isVerified`
    - `verificationType` ("administrator", "government", etc.)
    - `verificationStatus` ("pending", "approved", "rejected")
  - Return user object + signed JWT

---

## 🧠 Role Mapping Rules

| Role Purpose              | Role ID               |
|---------------------------|------------------------|
| Master Admin (Chad)       | `1358962069369651210` |
| Admin Role (elevated)     | `1362657572301308055` |
| Moderator Role            | `1362164095134073044` |
| Verified User (base)      | `1358962492193247323` |
| Verified Member (site)    | `1362162321807507598` |
| Government                | `1358961935583940659` |
| Military                  | `1358961996699009205` |
| Education                 | `1358962034301079624` |
| Verified Gov (approved)   | `1362653825210650815` |
| Verified Mil (approved)   | `1362162595955609680` |
| Verified Edu (approved)   | `1362654034804084968` |

- ✅ A user is considered `isAdmin` if they have the `OWNER` or `ADMIN` role
- ✅ A user is `isVerified` if they have both `VERIFIED_USER` and `VERIFIED_MEMBER`
- ✅ `verificationType` is auto-assigned from roles OR passed via body (`code + verificationType`)
- ✅ All sessions are returned as JWTs and can be decoded using `verifyJwt()` in `/utils/jwt.ts`

---

## ✅ Complete

- `/api/auth/discord/token` (main auth route)
- `src/routes/discord/exchange.ts` is the heart of the flow
- `resolveUserAccess()` correctly checks roles
- Debug log routes are active (`/api/debug/user`, `/api/debug/headers`, `/api/debug/ip`)
- JWT signing is working + scoped
- Session hook has full admin + verification context

---

## 🧪 Next Steps

- [ ] Integrate with protected frontend routes via `useSession()`
- [ ] Add database-backed verification state in `/verification/status`
- [ ] Consider splitting routes into `/public` and `/secure`
- [ ] Expand admin/moderator permissions
- [ ] Optional: add Discord permission scope check validation (enforce proper login scope)

---

Created by ChatGPT for handoff continuity  
Session: April 18, 2025  
