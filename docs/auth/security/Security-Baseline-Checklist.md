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
# 🛡️ Security Baseline Checklist

This checklist defines the **minimum security controls** required before any code, service, or infrastructure component is considered production-ready within The Angry Gamer Show Productions.

Use this as a gating mechanism for deployments, feature releases (such as JWT introduction), and security reviews.

---

## 🔐 Authentication & Token Management
| Requirement                                               | Status |
|-----------------------------------------------------------|--------|
| OAuth2 flow implemented (e.g., Discord)                   | ⬜      |
| JWT tokens are signed and short-lived (`exp`, `iat`)      | ⬜      |
| JWT includes `aud`, `iss`, and `sub` claims               | ⬜      |
| Access tokens are never stored in localStorage            | ⬜      |
| Token revocation or rotation strategy defined             | ⬜      |
| Rate limiting enabled on all auth endpoints               | ⬜      |

---

## 🌐 Network & Transport Security
| Requirement                                               | Status |
|-----------------------------------------------------------|--------|
| HTTPS enforced on all services (Traefik reverse proxy)    | ⬜      |
| TLS 1.2 or higher configured                              | ⬜      |
| HSTS headers set and tested                               | ⬜      |
| Express `trust proxy` enabled for accurate IP logging     | ⬜      |

---

## 🧑‍💻 Application & Code Controls
| Requirement                                               | Status |
|-----------------------------------------------------------|--------|
| ESLint security rules applied                             | ⬜      |
| `npm audit` or `snyk test` integrated into workflow       | ⬜      |
| `scripts/run-all-scans.sh` produces logs           | ⬜      |
| Secrets never committed to Git                            | ⬜      |
| Git secrets scanned with TruffleHog or GitLeaks           | ⬜      |

---

## 🐳 Infrastructure & Environment
| Requirement                                               | Status |
|-----------------------------------------------------------|--------|
| `.env` files excluded from version control                | ⬜      |
| Docker containers run as non-root users                   | ⬜      |
| Environment secrets injected securely                     | ⬜      |
| Volumes properly isolated (no shared secrets or mounts)   | ⬜      |

---

## 🧪 Testing, Auditing & CI/CD
| Requirement                                               | Status |
|-----------------------------------------------------------|--------|
| Static analysis (ESLint) executed on commit/PR            | ⬜      |
| Dependency scans (npm audit/Snyk) on each PR              | ⬜      |
| `run-all-scans.sh` invoked via CI or pre-merge hook       | ⬜      |
| Penetration test plan reviewed quarterly                  | ⬜      |
| Findings logged to `security/reports/YYYY-MM-DD/`         | ⬜      |

---

> **Maintained by:** ISSO – The Angry Gamer Show Productions  
> **Review Cycle:** Updated quarterly or with any major release
