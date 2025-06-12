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
# 📦 Phase 7 Continuation Handoff – TAG Auth Server
<!-- PATCHED v0.2.9 docs/auth/handoff-phase7-cont.md — Use .env.development -->

This document serves as a continuation of the Phase 7 handoff for the Discord OAuth backend powering **The Angry Gamer Show Productions**. It captures the extended work done to finalize JWT strict typing, align ESLint security constraints, and prepare the system for Phase 8 deliverables.

---

## ✅ ESLint Compliance Finalized

| Rule Category                          | Resolution Method                     | Status   |
|----------------------------------------|----------------------------------------|----------|
| `@typescript-eslint/no-unsafe-call`    | Fully narrowed imported JWT functions | ✅ Done  |
| `@typescript-eslint/no-unsafe-return`  | Clean return types in `signJwt`, `verifyJwt` | ✅ Done  |
| `@typescript-eslint/no-unsafe-assignment` | Explicit type casting and imports   | ✅ Done  |
| `@typescript-eslint/no-unsafe-member-access` | Proper access via typed module    | ✅ Done  |
| `@typescript-eslint/consistent-type-imports` | Removed inline `import()` annotations | ✅ Done  |
| `@typescript-eslint/no-base-to-string` | Structured error formatting           | ✅ Done  |

**Primary Fix Location:** `src/utils/jwt.ts`

---

## 🔐 Updated JWT Utility Highlights

| Method        | Description                                   |
|---------------|-----------------------------------------------|
| `signJwt()`   | Dynamically imports `jsonwebtoken`, signs typed payload |
| `verifyJwt()` | Verifies token and returns a `SessionPayload`  |
| `getEnv()`    | Runtime-validated `.env` accessor             |

- Dynamic import of `jsonwebtoken` narrowed via `typeof import()`
- Unsafe access replaced with `SignFn` and `VerifyFn` types
- ESLint rules cleared for strict mode compliance

---

## 🔧 `validate.ts` Refactor Summary

- Wrapped request handler now typed as:
  ```ts
  (req: Request<..., z.infer<T>>, res: Response, next: NextFunction) => unknown | Promise<unknown>
  ```
- `async` aware
- Catches and forwards handler errors with `next(err)`
- Compatible with Zod schema type inference

**Usage Examples:** `exchangeDiscordCode`, `requestVerification`, `getVerificationStatus`

---

## 🧩 Role Mapping Reference (Aligned with `auth/User_Role_Matrix.md`)

| Flag                | Source Roles                                           |
|---------------------|--------------------------------------------------------|
| `isAdmin`           | `OWNER`, `ADMINISTRATOR`, `MODERATOR`                  |
| `isVerified`        | `VERIFIED_USER`, `VERIFIED_MEMBER`                    |
| `verificationType`  | One of `VERIFIED_GOVERNMENT`, `VERIFIED_MILITARY`, `VERIFIED_EDUCATION` |
| `verificationStatus`| Set to `pending`, `approved`, or `rejected`          |

Role ID mappings are sourced from `.env.development` as validated by `resolveUserAccess()`.

---

## 📁 Code Anchors for Next Developers

| File                         | Purpose                                      |
|------------------------------|----------------------------------------------|
| `src/utils/jwt.ts`          | Cleaned JWT signer/verifier (ESLint safe)    |
| `src/utils/validate.ts`     | Async-safe request validator using Zod       |
| `src/routes/discord/exchange.ts` | Primary auth entrypoint                    |
| `src/middleware/validateJwt.ts` | JWT validation middleware                  |
| `src/middleware/guards.ts`  | Role-based route protections                 |

---

## 📌 Ready for Phase 8

| Feature                                     | Implementation Route         |
|---------------------------------------------|-------------------------------|
| `/api/auth/user` refresh on session boot    | Sync with `useSession()` hook |
| `/verification/status` backed by database   | Replace `pending` stub logic  |
| `/verification/request` DB persistence      | Store request metadata        |
| Role-based frontend gating (UI side)        | `isAdmin`, `isVerified`, etc. |

---

## 🧠 Notes

- ESLint config uses **Flat Config + TypeScript strict mode**
- Development is run with `tsx` and `nodemon`
- No `.ts` suffixes or default imports allowed
- All dynamic imports type-narrowed to avoid unsafe assumptions

---

**Maintained by:** TAGS Auth Dev Team  
**Phase 7 Extension Complete:** April 18, 2025  
**Contact:** `auth@thenagrygamershow.com`


# 🔐 Auth Server — The Angry Gamer Show

This is the **OAuth authentication backend** for [The Angry Gamer Show](https://test.thenagrygamershow.com).  
It securely handles Discord OAuth2 token exchange, user verification, and role resolution, and will support **future verification via ID.me** (GOV, MIL, EDU).

---

## 🌐 Deployment Domains

| Purpose       | Domain                             |
|---------------|------------------------------------|
| Frontend App  | https://test.thenagrygamershow.com |
| Auth Server   | https://auth.thenagrygamershow.com |

---

## 🚀 Primary Responsibilities

- 🔄 Exchange Discord OAuth2 `code` for tokens (securely)
- 🧠 Fetch user identity, guilds, and member roles from Discord
- ✅ Return a structured user object to the frontend
- 🛡️ Check for admin/verified status via role IDs
- 🔜 Plan for expansion to ID.me verification system
- 🧾 **Debug-friendly JWT payload preview during token issuance** (since v1.1.5)

---

## 🔧 Endpoint Summary

### `POST /api/discord/exchange`

**Request:**

```json
{
  "code": "DISCORD_AUTH_CODE",
  "verificationType": "government" | "military" | "education" | null
}
```

**Response:**

```ts
interface DiscordAuthResponse {
  id: string;
  username: string;
  email: string;
  avatar: string;
  isAdmin: boolean;
  isVerified: boolean;
  verificationType: "government" | "military" | "education" | null;
  verificationStatus: "pending" | "approved" | "rejected";
  guilds: {
    id: string;
    name: string;
    roles: string[];
  }[];
}
```

---

## 🛠 Environment Variables

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

### `.env.example`

```env
# Discord OAuth Config
DISCORD_CLIENT_ID=your_client_id
DISCORD_CLIENT_SECRET=your_client_secret
DISCORD_REDIRECT_URI=https://test.thenagrygamershow.com/auth/discord/callback

# Guild and Role Configuration
ADMIN_SERVER_GUILD_ID=your_admin_guild_id
ADMIN_ROLE_ID=your_admin_role_id
VERIFIED_ROLE_ID=your_verified_role_id
GOVERNMENT_ROLE_ID=your_government_role_id
MILITARY_ROLE_ID=your_military_role_id
EDUCATION_ROLE_ID=your_education_role_id
```

---

## 📦 Tech Stack Recommendations

| Feature               | Suggested Tool                |
|------------------------|-------------------------------|
| Server Framework       | Express, Fastify, or Vite backend |
| HTTP Requests          | Native `fetch` or `axios`     |
| Type Safety            | `TypeScript`, `Zod`           |
| Token Handling         | `jsonwebtoken` (with debug preview from v1.1.5) |
| Rate Limiting          | `express-rate-limit`          |
| Logging                | `pino`, `winston`, or `bunyan`|

---

## ⚠️ Out of Scope

- ❌ Frontend routing or redirect handling
- ❌ Session persistence or database storage (for now)
- ❌ Storing Discord access tokens

---

## 🧪 Testing Guidance

Prepare test mocks to simulate:

- ✅ Valid OAuth code
- ❌ Invalid code or expired token
- 🧑‍💼 Admin role present
- 🧪 Verified role combinations
- 🚫 Missing guild membership

---

## 📅 Roadmap

- [x] Discord OAuth Token Exchange
- [x] User + Role Resolution
- [x] JWT signing & decoding + payload preview logging (v1.1.5)
- [ ] ID.me Verification Integration
- [ ] Secure JWT session issuing
- [ ] Role + Badge Mapping Service

---

## 🧠 Maintained by

**The Angry Gamer Show Dev Team**  
📧 Contact: `dev@thenagrygamershow.com`  
🔗 [thenagrygamershow.com](https://thenagrygamershow.com)
