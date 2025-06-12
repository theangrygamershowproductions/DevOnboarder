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
# 🔐 TAG Auth Server — Developer Handoff Handbook
<!-- PATCHED v0.2.9 docs/auth/DeveloperHandOffHandbook.md — Use .env.development -->

**Project Name:** TAG Auth Server
**Owner:** The Angry Gamer Show Productions
**Last Updated:** 3 May 2025

---

## 📦 Project Overview

* **Language:** Node.js (ESM)
* **Environment:** Dockerized (dev & prod)
* **Auth Method:** Discord OAuth2
* **Frontend Domain:** [https://test.thenagrygamershow.com](https://test.thenagrygamershow.com)
* **Backend Domain:** [https://auth.thenagrygamershow.com](https://auth.thenagrygamershow.com)
* **Reverse Proxy:** Traefik v3

---

## ⚙️ OAuth2 Integration

**Discord OAuth App:**

* **Client ID:** `1357922808897732738`
* **Redirect URI:** `https://test.thenagrygamershow.com/auth/discord/callback`
* **Scopes Required:** `identify`, `email`, `guilds`, `guilds.members.read`

**Routes:**

* `POST /api/auth/discord/token` – Handles code exchange
* `POST /api/verification/request` – Submits user verification intent
* `GET /api/verification/status` – Fetches user verification status

---

## 🧱 Project Layout

```
📁 auth/
├── Dockerfile.dev
├── Dockerfile.prod
├── docker-compose.dev.yaml
├── docker-compose.prod.yaml
├── .env.development
├── .env.prod
├── src/
│   ├── index.ts
│   ├── utils/
│   │   ├── loadEnv.ts
│   │   ├── discord.ts
│   │   └── jwt.ts
│   ├── middleware/
│   │   ├── validateJwt.ts
│   │   └── guards.ts
│   └── routes/
│       ├── auth.routes.ts
│       ├── discord/exchange.ts
│       ├── verification/request.ts
│       ├── verification/status.ts
│       └── debug/
```

---

## 🧩 Environment Variables

These are injected via Docker Compose or loaded dynamically from disk:

```env
NODE_ENV=development | production
PORT=4000

DISCORD_CLIENT_ID=1357922808897732738
DISCORD_CLIENT_SECRET=your_secret_here
DISCORD_REDIRECT_URI=https://test.thenagrygamershow.com/auth/discord/callback

JWT_SECRET=your_jwt_secret
JWT_ALGORITHM=HS256
JWT_EXPIRATION=3600
```

Also includes:

* Admin and verification role IDs
* Guild IDs for access control

---

## 🐳 Docker & Compose

### Development (`docker-compose.dev.yaml`)

* Uses `Dockerfile.dev`
* Volume mounts for live editing
* Traefik route: `auth.thenagrygamershow.com`
* Loads `.env.development`

### Production (`docker-compose.prod.yaml`)

* Uses `Dockerfile.prod` with `node:22-alpine`
* Injects `.env.prod`
* Includes `npm run prod` as command

---

## 🔒 Session Storage

**Frontend localStorage:**

* `auth_token` – JWT from backend
* `user` – Parsed payload (ID, email, roles, guilds, etc.)

### Verification Fields

* `isVerified`: boolean
* `verificationType`: gov / mil / edu / null
* `verificationStatus`: pending / approved / denied

---

## 🔍 Debugging Notes

* First Discord OAuth code **must be used once only**.
* If reloaded or reused → `invalid_grant` from Discord.
* Token exchange must happen within \~60 seconds of login.

### Frontend Fix (Applied):

* Removes `?code=...` from URL after first use
* Prevents double submission of the code to backend

---

## ✅ Testing Completed

| Area                               | Status                             |
| ---------------------------------- | ---------------------------------- |
| Discord token exchange             | ✅ Confirmed via Postman & frontend |
| JWT issuance & structure           | ✅ Validated against localStorage   |
| Traefik routing                    | ✅ Resolves to correct services     |
| Role-based flags (admin, verified) | ✅ Working with proper mappings     |

---

## 🧠 Next Steps (Post-Handoff)

1. 🔐 Restrict `/api/debug/*` in production using NODE\_ENV guard
2. 🧠 Add database-backed dynamic role resolution (Phase 3)
3. 🔁 Expand frontend to support verification submission flow
4. 🧪 Add integration tests for `/auth → /token → /verify`

---

## 🔗 Maintainers & Handoff

If you’re taking over this service:

* Start with `.env.development` and `docker-compose.dev.yaml`
* Test a live Discord login cycle to verify token flow
* Use DevTools to inspect localStorage state
* Run `docker logs auth-server` to observe backend logs

Happy hacking! 🎮
