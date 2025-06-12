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
# Permissions Management
<!-- PATCHED v0.2.9 docs/frontend/permission-management.md — Use .env.development -->

This document outlines the role-based access control (RBAC) logic used within the Angry Gamer platform.

---

## 🎮 Discord Guild & Role Overview

All permission checks are enforced via Discord Role IDs assigned within the **Admin Discord Server**:

```
VITE_ADMIN_SERVER_GUILD_ID=1065367728992571444
```

---

## ⚖️ Role Definitions & Access

### 🔑 Admins
```
VITE_ADMIN_ROLE_ID=1358962069369651210
```
- Full access to platform
- Admin Dashboard (`/admin`)

### 🧑‍💼 Moderators
```
VITE_MODERATOR_ROLE_ID=1362164095134073044
```
- Access to future moderation dashboards
  - `/forum-moderation`
  - `/website-moderation`
  - `/forum-analytics`

### 🔑 Verified Users
```
VITE_VERIFIED_USER_ROLE_ID=1358962492193247323
```
- General login-required access
- Community access
- Tournaments access (`/tournaments`)

### 🌟 Verified Members
```
VITE_VERIFIED_MEMBER_ROLE_ID=1362162321807507598
```
- Access to perks, discounts, reward claims
- Community Store (`/community-store`)
- Future member-only content areas

### 👮️ Military / Government / Education
```
VITE_MILITARY_ROLE_ID=1358961996699009205
VITE_GOVERNMENT_ROLE_ID=1358961935583940659
VITE_EDUCATION_ROLE_ID=1358962034301079624
```
- For verified categorization
- Future segmented store/content access (V3)

### 👀 Verified Military Role
```
VITE_VERIFIED_MILITARY_ROLE_ID=1362162595955609680
```
- Access to military-verified content (planned)

### 🎥 Streamers
```
VITE_STREAMER_ROLE_ID=your_streamer_role_id_here
```
- Access to:
  - `/streamers`
  - `/streamer-profile`
  - `/streamer-analytics`

### 🔍 Streamer Verification Reviewers
```
VITE_STREAMER_VERIFICATION_ROLE_ID=your_streamer_verification_role_id_here
```
- Access to `/streamer-verification` review panel

### 🌟 Donors & Subscribers
```
VITE_DONOR_ROLE_ID=your_donor_role_id_here
VITE_SUBSCRIBER_ROLE_ID=your_subscriber_role_id_here
```
- Access to donor-exclusive or subscriber-specific areas (future Phase V3)

---

## ⚖️ How Permissions Are Evaluated

- All permission logic is based on `user.guilds[].roles[]`
- The user must belong to the **ADMIN_SERVER_GUILD_ID** and hold the correct role ID
- `ProtectedRoute.tsx` handles the logic based on the `requireRoleId`, `requireAdmin`, or `requireVerified` flags.

---

## ✏️ How to Add a New Role

1. Create the Role in Discord Admin Server
2. Copy the Role ID from Discord Developer Tools
3. Add the Role ID to `.env.development` and `.env.example`
4. Use the role in `App.tsx` route protection:
```tsx
<Route
  path="/exclusive-page"
  element={<ProtectedRoute requireRoleId={YOUR_NEW_ROLE_ID}><ExclusivePage /></ProtectedRoute>}
/>
```

---

## ⚠️ Future Expansion Notes

- Phase V3 will include dynamic store access based on role
- Automated role syncing via Discord OAuth scope expansion
- Admin UI to manage route-role mappings
