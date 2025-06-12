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
# `.env` Role Reference: TAG C2C and Community Access Alignment

This document serves as a reference map for all role-related environment variables used to determine Discord-based access across The Angry Gamer Show platform.

---

## 🔒 Admin Guild (TAG C2C) Roles
> Based on `ADMIN_SERVER_GUILD_ID`

| Env Var | Description | Maps To Flag |
|---------|-------------|----------------|
| `OWNER_ROLE_ID` | Full platform owner (typically Reesey275) | `isAdminGuildOwner` |
| `ADMINISTRATOR_ROLE_ID` | Admin role in TAG C2C | `isAdminGuildAdministrator` |
| `MODERATOR_ROLE_ID` | Moderator role in TAG C2C | `isAdminGuildModerator` |
| `VERIFIED_MEMBER_ROLE_ID` | Verified users within the Admin Guild | `isAdminGuildVerifiedMember` |
| *(inferred)* | All users in the Admin Guild | `isAdminGuildMember` |

---

## ✅ Verification System (Global Scope)

| Env Var | Description | Maps To Flag |
|---------|-------------|----------------|
| `VERIFIED_USER_ROLE_ID` | Verified user (grants general platform access) | `isVerifiedUser` |
| `GOVERNMENT_ROLE_ID` | Pending government verification | - |
| `MILITARY_ROLE_ID` | Pending military verification | - |
| `EDUCATION_ROLE_ID` | Pending education verification | - |
| `VERIFIED_GOVERNMENT_ROLE_ID` | Approved government verification | - (sets status) |
| `VERIFIED_MILITARY_ROLE_ID` | Approved military verification | - (sets status) |
| `VERIFIED_EDUCATION_ROLE_ID` | Approved education verification | - (sets status) |

> `isVerifiedUser` and `isVerifiedMember` will be separate logical flags in the payload.

---

## 🌐 Community Guild Role Support *(Future Implementation)*
> Based on `COMMUNITY_DISCORD_GUILD_IDS`

| Role Concept | Purpose | Future Flag |
|--------------|---------|-------------|
| Guild Owner | Lead for a community guild | `isCommunityGuildOwner` |
| Guild Admin | Admin within a community server | `isCommunityGuildAdministrator` |
| Guild Manager | Community contact/support lead | `isCommunityGuildManager` |
| Guild Moderator | Mod-level access | `isCommunityGuildModerator` |
| Verified Member | Approved member within guild | `isCommunityGuildVerifiedMember` |
| General Member | Anyone in the guild | `isCommunityGuildMember` |
| Guild Membership | In any guild in `DISCORD_GUILD_IDS` | `isCommunityGuild` |

> ⚠️ These roles should not be hardcoded. Instead, define guild → role mappings in the DB or config UI later.

---

## 🏗️ Future Reserved Roles

| Env Var | Purpose | Status |
|---------|---------|--------|
| `SUBSCRIBER_ROLE_ID` | For premium users | Reserved |
| `DONOR_ROLE_ID` | Donation reward access | Reserved |
| `STREAMER_ROLE_ID` | Streamer group access | Reserved |
| `STREAMER_VERIFICATION_ROLE_ID` | For streamer badge flow | Reserved |

---

## 🔧 Sample `.env` Snippet (For Reference Only)
```env
ADMIN_SERVER_GUILD_ID=1065367728992571444

OWNER_ROLE_ID=1358962069369651210
ADMINISTRATOR_ROLE_ID=1362657572301308055
MODERATOR_ROLE_ID=1362164095134073044
VERIFIED_MEMBER_ROLE_ID=1362162321807507598

VERIFIED_USER_ROLE_ID=1358962492193247323
GOVERNMENT_ROLE_ID=1358961935583940659
MILITARY_ROLE_ID=1358961996699009205
EDUCATION_ROLE_ID=1358962034301079624
VERIFIED_GOVERNMENT_ROLE_ID=1362653825210650815
VERIFIED_MILITARY_ROLE_ID=1362162595955609680
VERIFIED_EDUCATION_ROLE_ID=1362654034804084968

# COMMUNITY DISCORDS
DISCORD_GUILD_IDS=997603496637513928,1065367728992571444,1334643874844643389
```

---

For all future guilds, add role mappings via the admin UI rather than expanding the `.env` to avoid redeploy friction and improve scalability.

