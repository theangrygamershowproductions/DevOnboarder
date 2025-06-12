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
# 🎮 Frontend Authentication Flow — The Angry Gamer Show

This document outlines the frontend logic and responsibilities related to user authentication via Discord OAuth2.

---

## 🔐 Purpose

The frontend initiates the Discord OAuth login flow, processes authentication callbacks, handles user role logic, and manages local user state.

---

## 🧭 Main Responsibilities

| Area                         | What It Does |
|------------------------------|--------------|
| **Discord Login**            | Redirects users to Discord’s OAuth screen with proper scopes |
| **Callback Handling**        | Receives the `?code=...` from Discord and sends it to the auth server |
| **User Storage**             | Stores user info in `localStorage` after successful auth |
| **Role Detection**           | Determines if user is an admin or verified based on roles from Discord guild |
| **Verification Flow**        | Supports starting role-based verification (government, military, education) |
| **Error Handling**           | Displays toast notifications and fallback UI if login fails or is canceled |

---

## 🧩 Key Files/Functions

| File/Module                      | Purpose |
|----------------------------------|---------|
| `src/lib/auth/discord.ts`        | Main logic for initiating login, handling the callback, and verifying roles |
| `src/types/discord.ts`           | Contains the `VerificationType` enum and type definitions for users |
| `initiateDiscordAuth(type?)`     | Launches Discord login flow, optionally tagging a verification type |
| `handleDiscordCallback(code)`    | Exchanges code for token + user data via the backend |
| `checkUserAdminStatus(user)`     | Determines if user has the admin role from your guild |
| `checkUserVerificationStatus()`  | Checks if user is verified and what type |
| `verifyAdminAccess()`            | Used for gated routes to check admin access locally |
| `discordAuthUrl`                 | Properly formatted Discord login URL with safe scopes |

---

## 🔄 Current Flow (Happy Path)

1. User clicks **“Sign in with Discord”**
2. Redirected to Discord OAuth screen (with scopes: `identify email guilds guilds.members.read`)
3. On approval, Discord redirects to:

   ```
   https://test.thenagrygamershow.com/auth/discord/callback?code=...
   ```

4. Frontend sends code to backend:

   ```
   POST https://auth.thenagrygamershow.com/api/discord/exchange
   ```

5. Backend responds with structured user object
6. Frontend:
   - Stores user data in `localStorage`
   - Shows success toast
   - Redirects user back to their previous page or `/`

---

## 🚧 In Progress / Roadmap

| Feature                        | Status |
|--------------------------------|--------|
| Handle Discord cancel (`access_denied`) | ✅ Working (UI shows clear message) |
| Auto-redirect on cancel        | 🔜 Planned for next iteration |
| CORS fix on backend            | 🔧 In progress |
| ID.me verification integration | 🛣️ Future roadmap |

---

## 📍 Notes

- Do **not** use `mode: 'no-cors'` — CORS must be resolved by the backend.
- Discord OAuth scopes must be separated by `+` not `%20`.
- Always validate and store user role info securely via the backend.

