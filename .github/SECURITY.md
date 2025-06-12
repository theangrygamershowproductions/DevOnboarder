---
<!-- PATCHED v0.1.1 .github/SECURITY.md — wrap long lines -->

project: "DevOnboarder"
module: "Security"
phase: "MVP"
tags: \["security", "policy", "disclosure", "hardening", "github"]
updated: "03 June 2025 20:33 (EST)"
version: "v1.0.0"
-----------------

# Security Policy – DevOnboarder

The DevOnboarder project takes security seriously. This policy outlines the
process for reporting vulnerabilities, defines what is in scope,
and details our proactive security approach.

---

# 📬 Reporting a Vulnerability

If you discover a vulnerability, please **report it confidentially**:

* **Email:**
  [security@theangrygamershow.com](mailto:security@theangrygamershow.com)
* **Subject line:** `[SECURITY] Vulnerability Report`
* **Include:**

  * Detailed description of the issue
  * Steps to reproduce (PoC if applicable)
  * Affected files, endpoints, or components

We **do not support public disclosure** until we have issued a fix.

---

## 🕒 Disclosure Timeline

We aim to follow these response times:

| Phase               | Timeline               |
| ------------------- | ---------------------- |
| Acknowledgement     | Within 72 hours        |
| Investigation Start | Within 5 business days |
| Fix Released        | As soon as verified    |

Critical vulnerabilities may result in accelerated patch releases.

---

## ✅ In Scope

The following areas are within scope for security research and reports:

* Discord OAuth token handling (`/auth/`)
* JWT generation/validation logic
* Session and role-based access control
* Codex `evaluate.py` (if evaluating untrusted input)
* Backend APIs in `auth/` and `infrastructure/`

---

## ❌ Out of Scope

The following are **not eligible** for vulnerability disclosures:

* Typos or non-exploitable bugs
* Outdated or unused files in `archive/`
* Third-party dependencies (please report upstream)

---

## 🛡 Hardening Practices

We maintain internal policies and test plans, including:

* [x] Internal threat modeling: `docs/auth/security/threat-model.md`
* [x] Penetration testing: `docs/auth/security/penetration-test-plan.md`
* [x] Role enforcement policy: `docs/auth/User_Role_Matrix.md`
* [x] Secure key and secret storage practices
  (see `internal/TAGS-Secrets-Security-Policy.md`)

---

## 🔐 GitHub Repository Protections

We enforce the following:

* `SECURITY.md` in place (this file)
* `MERGE_CHECKLIST.md` required in all PRs
* GitHub Code Scanning and Secret Scanning enabled
* `.env.example` shared — real `.env` files are never committed

---

## 🔄 Updates

This policy is reviewed quarterly. Last update: **03 June 2025**.

Thank you for helping us keep DevOnboarder secure.

> "Security is not a patch — it's a process."
> — TAGS Security Team
---
