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
# 🗺️ TAG Auth Server – Phase Roadmap (v1.1.5)
# ✅ Backend Auth Server Overview  
**Project**: The Angry Gamer Show — OAuth & Role-Based Auth Server  
**Domain**: `https://auth.thenagrygamershow.com`  

---

## 🔐 Authentication & Session Endpoints

| Endpoint                     | Description                         | Middleware             |
|------------------------------|-------------------------------------|------------------------|
| `POST /api/discord/exchange`| Exchanges OAuth `code` for JWT + user | —                      |
| `GET /api/auth/user`        | Returns user from JWT (`req.user`)  | `validateJwt`          |
| `GET /api/auth/verify`      | Protected route for verified users  | `validateJwt`, `requireVerified` |
| `GET /api/auth/admin/ping`  | Admin-only route                    | `validateJwt`, `requireAdmin` |

---

## 🧱 Mounted Routes in `routes/index.ts`

| Prefix     | Linked Route File        |
|------------|--------------------------|
| `/auth`    | `auth.routes.ts`         |
| `/discord` | `discord.routes.ts`      |
| `/healthz` | `health.routes.ts`       |

---

## 🧰 Key Middleware

- `validateJwt.ts` → Verifies JWT, checks `iss`/`aud`, adds `req.user`
- `guards.ts`  
- `requireAdmin` → Checks `req.user.isAdmin === true`  
- `requireVerified` → Checks `req.user.isVerified === true`

---

## 📦 Shared Utilities

| File           | Purpose                            |
|----------------|------------------------------------|
| `jwt.ts`       | `signJwt()` and `verifyJwt()` with ESM compatibility |
| `validateJwt.ts` | Parses Bearer JWT and validates `iss`/`aud` |
| `guards.ts`    | Role-based route protection         |

---

## 💡 Tech + Dev Notes

- Built with `TypeScript`
- Using native `fetch` or `axios`
- Future-ready for:
  - ✅ ID.me integration (GOV/MIL/EDU)
  - ✅ Session token issuing (JWT)
  - ✅ WebSocket session sync
  - ✅ Admin dashboard access

---

===============================
📄 CHANGELOG – README.md
===============================

- v1.1.5 – April 18, 2025
  - Aligned with Auth Phase 8 roadmap
  - Documented all session, role, and verification flow endpoints
  - Verified matching middleware, JWT, and route structure

- v1.1.0 – April 14, 2025
  - Initial README refactor for OAuth flow, JWT, and guards

- v1.0.0 – April 10, 2025
  - Initial commit
  - Basic OAuth flow with Discord
  - JWT signing and verification
  - Basic role-based access control (RBAC)
  - Basic health check endpoint
  - Basic error handling middleware
  - Basic logging middleware
  - Basic rate limiting middleware
  - Basic CORS middleware
  - Basic security headers middleware
  - Basic request validation middleware
  - Basic response formatting middleware
  - Basic session management middleware
  - Basic user management middleware
  - Basic role management middleware
  - Basic permission management middleware
  - Basic audit logging middleware
  - Basic monitoring middleware
  - Basic alerting middleware
  - Basic metrics middleware
  - Basic documentation middleware
  - Basic testing middleware
