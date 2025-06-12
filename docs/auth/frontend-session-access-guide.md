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
# 🔐 Frontend Integration Guide: Session Roles & Access Logic

This document outlines how the frontend application should interpret and handle session payloads returned from the Discord OAuth backend, including admin access, verification types, and conditional UI behavior.

---

## ✅ Session Payload Structure (Example)

```ts
{
  id: "180876291711434752",
  username: "reesey275",
  email: "reesey275@gmail.com",
  avatar: "https://cdn.discordapp.com/avatars/...",
  isAdmin: true,
  isVerified: true,
  verificationType: "administrator", // one of: administrator | government | military | education | null
  verificationStatus: "approved",   // one of: approved | pending | rejected
  guilds: [
    {
      id: "1065367728992571444",
      name: "The Angry Gamer Show Developers",
      roles: ["1358962069369651210", "1358962492193247323", ...]
    },
    ...
  ]
}
```

---

## 🧠 Frontend Role Logic

### 🔐 `isAdmin`
Set to `true` if the user has either:
- `OWNER_ROLE_ID = 1358962069369651210` *(Primary Admin - Chad)*
 - `ADMINISTRATOR_ROLE_ID = 1362657572301308055` *(Trusted elevated roles)*

Use this to unlock:
- Admin panels
- Route protection for management tools

### ✅ `isVerified`
Set to `true` if the user has **both**:
- `VERIFIED_USER_ROLE_ID = 1358962492193247323`
- `VERIFIED_MEMBER_ROLE_ID = 1362162321807507598`

Use this to unlock:
- Member-only site features
- Access to protected pages / components

### 🛡️ `verificationType`
Returned as:
- `administrator` → Admin verified
- `government` / `military` / `education` → Self-declared
- `null` → Unverified or not selected

Use this for badge display, profile flagging, or auto-sorting verification requests.

### 📋 `verificationStatus`
Use to show banners, disable access, or display pending messages:
- `approved`
- `pending`
- `rejected`

---

## 🧭 Suggestions for Frontend Hook
In `useSession()`:

```ts
const isAdmin = user?.isAdmin;
const isVerified = user?.isVerified;
const verificationType = user?.verificationType;
const verificationStatus = user?.verificationStatus;
```

Conditionally render UI using:
```ts
if (isAdmin) { /* show admin tools */ }
if (!isVerified) { /* show request verification */ }
if (verificationStatus === "pending") { /* show yellow banner */ }
```

---

## 🔄 Session Refresh Support
The JWT includes all session flags.
- Consider calling `/api/auth/user` every N minutes to rehydrate
- This route is protected with JWT and returns the same session structure

---

## ✅ All Role IDs Used
```env
OWNER_ROLE_ID=1358962069369651210
ADMINISTRATOR_ROLE_ID=1362657572301308055
MODERATOR_ROLE_ID=1362164095134073044
VERIFIED_USER_ROLE_ID=1358962492193247323
VERIFIED_MEMBER_ROLE_ID=1362162321807507598
GOVERNMENT_ROLE_ID=1358961935583940659
MILITARY_ROLE_ID=1358961996699009205
EDUCATION_ROLE_ID=1358962034301079624
VERIFIED_GOVERNMENT_ROLE_ID=1362653825210650815
VERIFIED_MILITARY_ROLE_ID=1362162595955609680
VERIFIED_EDUCATION_ROLE_ID=1362654034804084968
```

---

## 🧪 Test Accounts
Admins can spoof login by assigning their test accounts the above roles in the Discord server `The Angry Gamer Show Developers (1065367728992571444)`.

Let us know if any role mappings need to be updated.
