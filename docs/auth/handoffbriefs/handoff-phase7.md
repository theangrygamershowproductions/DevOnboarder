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
# 📦 Phase 7 Handoff – TAG Auth Server
<!-- PATCHED v0.2.9 docs/auth/handoff-phase7.md — Use .env.development -->

This handoff marks the completion of **Phase 7: Session Management & Access Control** of the Discord OAuth backend for **The Angry Gamer Show Productions**. It provides a clear status summary, implementation details, and next steps for developers picking up from here.

---

## ✅ Phase 7 Goals (Completed)

| Area       | Objective                                                             | Status   |
|------------|----------------------------------------------------------------------|----------|
| Backend    | Securely issue JWT upon successful Discord login                     | ✅ Done  |
| Backend    | `validateJwt` middleware validates token & populates `req.user`      | ✅ Done  |
| Backend    | Role-based access via `requireAdmin` / `requireVerified` guards      | ✅ Done  |
| Frontend   | `useSession()` consumes `user` and `token` from exchange response    | ✅ Done  |
| Shared     | `resolveUserAccess()` computes user role flags from Discord roles    | ✅ Done  |
| Shared     | Full ESLint v9+ integration & type safety enforcement                | ✅ Done  |

---

## 🔐 Key Endpoints

| Endpoint                     | Description                                   | Middleware              |
|------------------------------|-----------------------------------------------|-------------------------|
| `POST /api/discord/exchange`| OAuth token exchange, returns JWT + user      | —                       |
| `GET /api/auth/user`        | Returns session user from decoded JWT         | `validateJwt`           |
| `POST /api/auth/logout`     | Placeholder for stateless logout              | `validateJwt`           |
| `POST /api/verification/request` | Handles verification type request          | `validateJwt`           |
| `GET /api/verification/status`  | Returns `verificationStatus: "pending"`    | `validateJwt`           |

---

## 🧩 Auth Flow Overview

1. **Frontend** sends Discord OAuth `code` to backend
2. **Backend** exchanges code and fetches user + guilds + member
3. **Roles are resolved** using `.env`-driven role IDs
4. **Session object** with access flags is returned + signed as JWT
5. **Frontend** stores `user` + `auth_token` in `localStorage`

---

## 🧠 Role Flag Matrix (See `auth/User_Role_Matrix.md`)

| Flag              | Derived From                           |
|------------------|-----------------------------------------|
| `isAdmin`        | `OWNER_ROLE_ID`, `ADMINISTRATOR_ROLE_ID`, `MODERATOR_ROLE_ID` |
| `isVerified`     | Verified user + member roles            |
| `verificationType` | Verified government/military/education roles |
| `verificationStatus` | Derived from `verificationType` or future DB state |

---

## 🧰 Final Middleware Wiring

| Middleware         | Description                          |
|--------------------|--------------------------------------|
| `validateJwt`      | Parses & verifies JWT, adds `req.user` |
| `requireAdmin`     | Checks `req.user.isAdmin`             |
| `requireVerified`  | Checks `req.user.isVerified`          |

---

## 📁 Code Highlights

- **Main Auth Flow**: `src/routes/discord/exchange.ts`
- **Role Mapping**: `src/utils/resolveUserRoles.ts`
- **JWT Utility**: `src/utils/jwt.ts` (`signJwt`, `verifyJwt`)
- **Guards**: `src/middleware/guards.ts`
- **Session Enrichment**: `src/types/session.ts`

---

## 🧪 Phase 8 — Next Steps

| Task                                         | Owner / Suggested Role |
|----------------------------------------------|--------------------------|
| Integrate `/api/auth/user` into `useSession()` refresh | Frontend team          |
| Replace mock `verification/status` with DB lookup       | Backend Phase 8        |
| Store verification requests to database      | Backend Phase 8        |
| Harden logout & token invalidation logic     | Backend Phase 9+       |
| Begin frontend gating by `isAdmin`, `isVerified`, `verificationStatus` | Frontend team |

---

## 📄 Docs & Resources

- `README.md`: Backend overview, endpoint structure, env config
- `auth/User_Role_Matrix.md`: Role mapping table for all auth flags
- `Security-Baseline-Checklist.md`: Required security measures for production
- `.env.development`: All role ID mappings used in verification logic

---

## 🧠 Notes for Next Devs

- Use `tsx` + `nodemon` for local dev
- ESLint v9 is enforced with Flat Config
- All imports cleaned up (`import type`, no `.ts` suffixes)
- TypeScript 5.8+ with strict mode

---

**Maintained by**: TAGS Auth Dev Team  
**Session Closed**: Phase 7 – April 18, 2025  
**Contact**: `auth@thenagrygamershow.com`
