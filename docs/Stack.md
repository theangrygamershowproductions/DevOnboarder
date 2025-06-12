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
# 🧱 Full Project Tech Stack Overview – The Angry Gamer Show
<!-- PATCHED v0.2.9 docs/Stack.md — Use .env.development -->

This document outlines the complete backend, frontend, and infrastructure stack for **The Angry Gamer Show** ecosystem.
It is broken down into core categories: **Backend**, **Frontend**, and **Network Infrastructure**.

---

## 🔧 Backend Stack – `auth.thenagrygamershow.com`

| Category        | Tool / Library                | Purpose |
|----------------|-------------------------------|---------|
| Server Runtime | `Node.js` + `Express.js`       | HTTP API server for Discord OAuth and auth logic |
| Auth Handling  | `jsonwebtoken`                | JWT creation + validation for session management |
| Schema Validation | `Zod`                       | Type-safe request validation for routes |
| Environment Config | `dotenv`, `loadEnv.ts`     | Loads `.env.development` or `.env.production` with role IDs, tokens, etc. |
| Role Resolution | Custom `resolveUserRoles.ts` | Assigns admin/community flags based on Discord roles |
| OAuth Integration | Native `fetch` + Discord API | Handles `code -> token`, guilds, user, member info |
| Rate Limiting  | `express-rate-limit`          | Prevents abuse of auth + verification endpoints |
| Logging & Patching | Console logs + Canvas       | Tracks all patches with semantic versioning by file |
| Debug Routes   | `/api/debug/*`                | Session/user/env debug for admin visibility |

### 🧪 Status

- Vite has been removed from backend — only Express + Node remain
- All Discord roles + guilds pulled dynamically via access token
- PATCH system active via Canvas to track versioned backend changes

---

## 🎨 Frontend Stack – `test.thenagrygamershow.com`

| Category        | Tool / Library            | Purpose |
|----------------|---------------------------|---------|
| Framework      | `React` + `Vite`          | SPA frontend application for login and UI/UX views |
| Language       | `TypeScript`              | Type safety across components, hooks, and services |
| Styling        | `Tailwind CSS`            | Utility-first responsive design |
| Component UI   | `shadcn/ui`               | Reusable UI component primitives |
| Session Hook   | `useSession.ts`           | Syncs frontend to session JWT + user state |
| Auth Flow      | Calls backend `/auth/discord/token` | Completes OAuth flow post-login |
| Role Gating    | UI visibility gated via `isAdmin`, `isVerified`, etc. ||
| Debug Utility  | Session viewer via debug panel ||

---

## 🌐 Network + Infrastructure

| Layer            | Tool / Config                   | Purpose |
|------------------|----------------------------------|---------|
| Reverse Proxy    | `Traefik` (Docker container)     | HTTPS routing, SSL termination, service-based routing |
| TLS/HTTPS Certs  | `cert.crt`, `cert.key`           | Custom TLS certs via TrueNAS (stored under `/mnt/Dev/certs`) |
| Container Orchestration | `Docker Compose`          | Containerization of backend (auth), frontend (vite), and Traefik proxy |
| Host Environment | `TrueNAS SCALE` (`192.168.0.199`) | On-prem deployment + storage + Docker management |
| Static DNS       | `*.thenagrygamershow.com`        | Public domain setup for routing frontend/backend traffic |
| Debug Tooling    | `/dashboard`, logs, `/debug/env` | Tracks routes, headers, JWTs, and CORS issues |

---

## 🔒 Authentication Flow Overview

1. User clicks Discord login (frontend)
2. Redirects to Discord OAuth URL
3. Discord returns a `code` to frontend → POST to `/api/discord/exchange`
4. Backend:
   - Exchanges code → access_token
   - Fetches user, guilds, member roles
   - Resolves admin flags (C2C), builds session payload
5. JWT issued → returned to frontend
6. Frontend stores session and displays gated content

---

## 📌 Notes for Contributors

- Only `ADMIN_SERVER_GUILD_ID` roles are currently evaluated
- Community guild roles (`isCommunityGuild*`) are scoped for future implementation (see `env.roles.md`)
- Use debug endpoints and `CHANGELOG.md` to verify session logic changes
- All code patches are tracked by semantic version using Canvas Patch System

---

## 📦 Last Updated: April 19, 2025
