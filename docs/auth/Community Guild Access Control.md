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
# Community Guild Access Control: Role Flag Roadmap

This document outlines the phased plan for implementing role-based access control for both the **Admin Guild (TAG C2C)** and **Community Guilds** in The Angry Gamer Show authentication and user management system.

---

## ✅ Phase 1: MVP Scope (Now)

### Tags Implemented:
| Flag | Purpose |
|------|---------|
| `isAdminGuildOwner` | User is the owner of the TAG C2C (Admin) Discord server |
| `isAdminGuildAdministrator` | Admin role within the Admin Guild |
| `isAdminGuildModerator` | Moderator role in the Admin Guild |
| `isAdminGuildVerifiedMember` | Verified members in the Admin Guild |
| `isAdminGuildMember` | All users in the Admin Guild |
| `isMember` | User is part of **any** COMMUNITY_DISCORD_GUILD_IDS (even with no roles) |

### Logic Source:
- All role checks performed from the `ADMIN_SERVER_GUILD_ID`
- Community guild membership is only checked via `guild.id` matching against `COMMUNITY_DISCORD_GUILD_IDS`
- Role resolution only includes Admin Guild roles for now

---

## 🧪 Phase 2: Planning for Community Roles (Deferred)

### Proposed Role Flags (Per Community Guild):
| Flag | Purpose |
|------|---------|
| `isCommunityGuild` | User is in **any** configured community guild |
| `isCommunityGuildOwner` | Owner of the specific community Discord guild |
| `isCommunityGuildManager` | Designated community contact / support admin |
| `isCommunityGuildAdministrator` | Elevated admin within that guild |
| `isCommunityGuildModerator` | Moderator-level access in the guild |
| `isCommunityGuildVerifiedMember` | Verified member of the guild |
| `isCommunityGuildMember` | Default member of the guild |

### Why Defer:
- Role IDs would need to be hardcoded per community → high maintenance
- New community onboarding would require `.env` changes & redeploy
- Better served by UI/UX tools later

---

## ✅ Phase 3: Dynamic Role Configuration via Web UI

### Key Features:
- Admin dashboard to configure roles per guild:
  - Upload role IDs
  - Set access flags dynamically
  - Save to database or config file
- Community guild onboarding wizard
- Secure UI panel for modifying guild-role mappings without `.env`

### Backend Enhancements:
- Introduce `getCommunityRoleMap(guildId: string)` API call
- Refactor `resolveUserAccess()` to query DB-configured roles
- Add per-guild permission metadata to `UserPayload`

---

## 📌 Recommendations
- ✅ Keep MVP clean: only support Admin Guild role logic and basic `isMember` flag
- ❌ Do not hardcode community guild role IDs in `.env`
- ✅ Build groundwork for a UI to manage dynamic role mappings
- 🔒 Use secure backend storage (DB or config repo) for guild role maps later

---

## 🚀 Outcome
This phased strategy allows us to:
- Deliver a secure MVP fast
- Avoid technical debt from role explosion
- Enable scalable, community-managed access control in future phases

