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
✅ Deferred and noted for Phase 8. I’ll pass this on to the frontend:

---

### 📣 Frontend Team Note – Phase 8 Adjustment

The backend has implemented the `/api/auth/user` route to support session rehydration using the decoded JWT payload (`req.user`). When you begin Phase 8, please:

- Update the session logic to **call `/api/auth/user`** during app boot or refresh
- Replace reliance on `localStorage.user` with fresh data from the server
- Ensure `auth_token` is still stored locally to authenticate the refresh request

This will help keep user roles, verification status, and permissions in sync with Discord changes.

Let me know when you’re ready to scope out Phase 8 and we’ll prepare the full plan.

### 🔄 Phase 8 Scope
