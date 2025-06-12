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
# ✅ Frontend Auth Alignment Checklist (v1.1.0)
<!-- PATCHED v0.2.9 docs/frontend/frontend-auth-alignment-checklist.md — Use .env.development -->

This checklist tracks frontend tasks needed to fully align with the backend OAuth Auth Server v1.1.0 updates.

---

## 🔁 Phase 8: Session Refresh Integration

- [ ] Replace localStorage.user with dynamic refresh  
  Use GET /api/auth/user to pull the latest user data from the server.

- [ ] Store only auth_token in localStorage  
  Keep sensitive session data out of persistent storage.

- [ ] Update useSession() to use backend session  
  Load flags like isAdmin, isVerified, etc. from the refreshed session.

- [ ] Add fallback for expired or missing tokens  
  Show a login prompt or redirect if refresh fails.

---

## 🧠 Align Role-Based Access Flags in useSession()

- [ ] Expose isAdmin  
  True if user has OWNER or ADMINISTRATOR role.

- [ ] Expose isVerified  
  True if user has both VERIFIED_USER and VERIFIED_MEMBER roles.

- [ ] Expose verificationType  
  Used for showing badges like 'military', 'government', etc.

- [ ] Expose verificationStatus  
  Used to show 'pending', 'approved', or 'rejected' status in UI.

---

## 🛡️ Review Route Access Requirements

- [ ] /admin access  
  Must be gated behind OWNER or ADMINISTRATOR role flag.

- [ ] /tournaments access  
  Requires both VERIFIED_USER and VERIFIED_MEMBER.

- [ ] /streamers access  
  Depends on the VITE_STREAMER_ROLE_ID set in .env.

---

## 🎨 UI Enhancements Based on verificationStatus

- [ ] Yellow banner if pending  
  Show visual cue that verification is still under review.

- [ ] Red banner if rejected  
  Alert users that verification failed with next steps.

- [ ] Hide features if unverified  
  Disable gated components when not yet approved.

---

## 🔧 .env Role Mapping Validation

- [ ] Validate all role IDs in .env.development  
  Make sure the following roles are present:
  - [ ] OWNER_ROLE_ID
  - [ ] ADMINISTRATOR_ROLE_ID
  - [ ] MODERATOR_ROLE_ID
  - [ ] VERIFIED_USER_ROLE_ID
  - [ ] VERIFIED_MEMBER_ROLE_ID
  - [ ] GOVERNMENT_ROLE_ID
  - [ ] MILITARY_ROLE_ID
  - [ ] EDUCATION_ROLE_ID
  - [ ] VERIFIED_GOVERNMENT_ROLE_ID
  - [ ] VERIFIED_MILITARY_ROLE_ID
  - [ ] VERIFIED_EDUCATION_ROLE_ID
  - [ ] STREAMER_ROLE_ID ← Update this placeholder

---

## 🔜 Optional Prep (Future Phases)

- [ ] Scaffold /admin/verification route  
  This will become the moderation queue for verification.

- [ ] Protect with requireAdmin guard  
  Only admins/moderators should see/manage it.

- [ ] Design for DB-powered verification  
  Get ready to display status data once the backend DB is integrated.

---

Last Updated: April 18, 2025


# ✅ Frontend Auth Alignment Checklist (WebApp v0.0.4 / Auth v1.1.5)

This checklist tracks tasks needed to align the frontend with the updated backend Auth v1.1.5, focusing on session sync and enhanced debug visibility.

---

## 🔁 Phase 8: Session Refresh Integration

- [ ] On mount, check for `auth_token` in localStorage
- [ ] If present, call `GET /api/auth/user`
- [ ] Parse and hydrate session using returned payload
- [ ] Replace stored `user` blob with updated data
- [ ] Update UI immediately if role flags change

---

## 🧠 Align `useSession()` With Updated JWT Payload

- [ ] Update hook to parse:
  - [ ] `isAdmin`
  - [ ] `isVerified`
  - [ ] `verificationType` ("administrator", "government", etc.)
  - [ ] `verificationStatus` ("pending", "approved", "rejected")
- [ ] Add fallback UI or state for missing/invalid tokens

```ts
interface SessionUser {
  id: string;
  username: string;
  email: string;
  avatar: string;
  isAdmin: boolean;
  isVerified: boolean;
  verificationType: "administrator" | "government" | "military" | "education" | null;
  verificationStatus: "pending" | "approved" | "rejected";
}
```

---

## 🧪 Add Debug Route Access (Dev Only)

- [ ] Conditionally show `/debug` link for:
  - [ ] `isAdmin === true`
  - [ ] In dev mode (optional check with `import.meta.env.DEV`)

```tsx
{isAdmin && <Link to="/debug">Debug</Link>}
```

- [ ] Use the following debug routes when needed:
  - [ ] `/api/debug/user`
  - [ ] `/api/debug/headers`
  - [ ] `/api/debug/ip`

---

## 🔧 Adapt UI Based on Session Flags

| Flag                | Purpose                                       |
|---------------------|-----------------------------------------------|
| `isAdmin`           | Show admin panels, dashboards                 |
| `isVerified`        | Gate access to protected pages                |
| `verificationType`  | Render role-based UI (e.g., EDU/MIL badges)   |
| `verificationStatus`| Onboarding and alert banners (pending, etc.)  |

```ts
if (user.verificationStatus === "pending") {
  toast.info("Your verification is currently pending.");
}
```

---

## 📎 Token Scope & Payload Confirmed

- [x] OAuth scope: `identify guilds guilds.members.read email`
- [x] Discord member roles now loaded properly
- [x] `signJwt()` returns:
  ```json
  {
    "sub": "180876291711434752",
    "username": "reesey275",
    "isAdmin": true,
    "isVerified": true,
    "verificationType": "administrator",
    "verificationStatus": "approved"
  }
  ```

---

## ✅ Summary

- [ ] Refresh session using `/api/auth/user`
- [ ] Hydrate frontend with JWT payload
- [ ] Use `isAdmin`, `isVerified`, `verificationType`, `verificationStatus` for UI gates
- [ ] Limit debug tools to admins only

---

_Last updated: April 19, 2025_

