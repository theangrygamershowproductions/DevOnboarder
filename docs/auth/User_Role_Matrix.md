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
# 🧩 User Role Matrix — The Angry Gamer Show Platform

This document outlines the **user role structure** used across the Discord Auth Backend, Frontend Session Handling, and Moderation Tools. It defines how different roles impact permissions and identity classification.

---

## 🔐 Authentication Flags

| Field               | Type                                      | Purpose                                                        |
|--------------------|-------------------------------------------|----------------------------------------------------------------|
| `isAdmin`          | `boolean`                                 | Grants elevated privileges (admin panel, moderator tools)      |
| `isVerified`       | `boolean`                                 | Grants basic access (authenticated, non-guest features)        |
| `verificationType` | `'government' \| 'military' \| 'education' \| null` | Describes the **identity trust level** of a user               |
| `verificationStatus` | `'pending' \| 'approved' \| 'rejected' \| 'none'` | Tracks state of verification (manual or role-based)            |

---

## 🎭 Role Mapping Matrix

| Discord Role Name     | Role ID (from `.env`)                 | Applied Field(s)                      |
|------------------------|----------------------------------------|----------------------------------------|
| `OWNER`                | `OWNER_ROLE_ID`                        | `isAdmin: true`                        |
| `ADMINISTRATOR`        | `ADMINISTRATOR_ROLE_ID`                | `isAdmin: true`                        |
| `MODERATOR`            | `MODERATOR_ROLE_ID`                    | `isAdmin: true`                        |
| `VERIFIED_USER`        | `VERIFIED_USER_ROLE_ID`                | `isVerified: true`                     |
| `VERIFIED_MEMBER`      | `VERIFIED_MEMBER_ROLE_ID`              | `isVerified: true`                     |
| `GOVERNMENT`           | `GOVERNMENT_ROLE_ID`                   | n/a (raw input only)                   |
| `MILITARY`             | `MILITARY_ROLE_ID`                     | n/a (raw input only)                   |
| `EDUCATION`            | `EDUCATION_ROLE_ID`                    | n/a (raw input only)                   |
| `VERIFIED_GOVERNMENT`  | `VERIFIED_GOVERNMENT_ROLE_ID`          | `verificationType: 'government'`      |
| `VERIFIED_MILITARY`    | `VERIFIED_MILITARY_ROLE_ID`            | `verificationType: 'military'`        |
| `VERIFIED_EDUCATION`   | `VERIFIED_EDUCATION_ROLE_ID`           | `verificationType: 'education'`       |

---

## ✅ Authorization Flow Summary

1. **User logs in via Discord OAuth**
2. Backend fetches user + member roles from admin server
3. Roles are checked to determine:
   - `isAdmin` → based on Owner/Admin/Moderator roles
   - `isVerified` → based on basic verification roles
   - `verificationType` → based on `VERIFIED_*` identity roles
4. A JWT is issued with all resolved flags
5. Frontend uses `useSession()` to expose these flags for access control

---

## 🧪 Sample User Response (Admin + Military Verified)
```json
{
  "id": "123456789",
  "username": "ChadReesey",
  "email": "reesey@example.com",
  "avatar": "https://cdn.discordapp.com/avatars/...",
  "isAdmin": true,
  "isVerified": true,
  "verificationType": "military",
  "verificationStatus": "approved",
  "guilds": [
    {
      "id": "1065367728992571444",
      "name": "The Angry Gamer Show Developers",
      "roles": [
        "1358962069369651210",  // OWNER
        "1358961996699009205",  // MILITARY
        "1362162595955609680"   // VERIFIED_MILITARY
      ]
    }
  ]
}
```

---

## 📌 Notes
- `verificationType` and `verificationStatus` are **not** tied to admin/mod roles.
- Admins may or may not have identity verification roles.
- Moderators and Admins should still verify separately if required by system policy.

---

Prepared by: TAGS Auth Dev Team
Date: April 18, 2025

