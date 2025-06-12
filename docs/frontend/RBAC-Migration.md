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
<!-- PATCHED v0.1.0 docs/frontend/RBAC-Migration.md — outline RBAC migration strategy -->
# 📘 Role-Based Access Control (RBAC) Migration Strategy

## ✅ Current State

Access control is currently managed via:
- Discord server roles assigned to users within a single guild
- Static `.env` environment variables that map those roles to permissions
- Session payloads returned from the backend (JWT) containing the user role data
- Frontend enforcement through `useSession()` and `ProtectedRoute.tsx`

## 🔒 Justification for Deferral

| Reason | Explanation |
|--------|-------------|
| 🔁 Static roles are manageable | Only a fixed set of roles are required at this stage of development |
| 🧪 System is functional | All RBAC enforcement requirements are currently met using Discord roles and env vars |
| 🧠 Prioritize core feature work | Phases 8–11 focus on admin panels, events, and merch systems |
| 🔧 Backend schema required | A DB-based RBAC model would need backend support and endpoint restructuring |
| ⚠️ Avoid early complexity | Reduces risk of delays and scope creep in near-term deliverables |

## 📅 Migration Plan (Post-Phase 11)

### Phase 12: RBAC Database Foundation
- Create `roles` and `permissions` tables
- Link users to roles via relational mapping (e.g., `user_roles`, `role_permissions`)
- Sync Discord roles on login or cron job
- Refactor `.env` role usage to pull from database

### Phase 13: Admin UI & Role Management
- Build Admin UI for managing roles, permissions, and Discord mappings
- Enable per-route access via role flags in the database
- Provide optional override for manually assigned roles

### Phase 14: Role-Based Feature Access
- Tie store sections, dashboards, and tools to specific roles (e.g., `donors`, `military`)
- Add dynamic feature toggles in the admin panel by role tier

## 🛠️ Recommended Databases

| Use Case | DB Type | Engine | Notes |
|----------|---------|--------|-------|
| Role mappings | Relational | PostgreSQL / MySQL | Strong schema, support for joins |
| Role metadata | Document | MongoDB | Full Discord guild/role snapshots |
| Session cache | In-memory | Redis | Used for token/session management |
| Role audit logs | Relational | PostgreSQL | Write-once log entries with timestamps |

## 📌 Summary

- 🕒 No immediate migration is necessary
- ✅ Current setup is stable for current roadmap
- 📈 Migration will support scale, auditing, and UI control in V3
- 📂 Will align with broader database planning across the stack

---

_Last updated: April 2025_

Would you like to link this document to `PERMISSIONS_MANAGEMENT.md` or create a dashboard-level visibility flag for Phase 12 planning?

