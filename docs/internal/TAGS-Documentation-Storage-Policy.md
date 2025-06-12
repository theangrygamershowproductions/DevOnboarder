---
project: "TAGS"
module: "Documentation"
phase: "Internal Tooling"
tags: ["docs", "internal"]
updated: "26 May 2025 18:22 (EST)"
version: "v1.0.0"
-----------------

# TAGS: Documentation Storage Policy

---

## 📚 Purpose

Define the official storage and archival policy for all documentation and project files within The Angry Gamer Show Productions (TAGS) to reduce redundancy, eliminate version sprawl, and ensure clean, reliable documentation workflows.

---

## 📦 What This Policy Covers

* Markdown documentation
* Environment files (`.env`, secrets)
* ZIP exports, backups, or `.bak`/`.old` files
* Docs embedded in PDFs, screenshots, or Office formats

---

## ❌ What NOT To Do

| Type                             | Why It’s Prohibited                                |
| -------------------------------- | -------------------------------------------------- |
| `.zip` backups of docs           | Creates stale, redundant archives; not versioned   |
| `.old`, `.bak`, or `_copy` files | Git handles version control better                 |
| Untracked `.env` variants        | Encourages shadow config and secrets mismanagement |
| Exporting live docs to PDF       | Locks formatting and creates sync issues           |

---

## ✅ Official Sources of Truth

| Type            | Source Location                            |
| --------------- | ------------------------------------------ |
| Canonical Docs  | `/Documentation/internal/` (Canvas + Git)  |
| Live Drafting   | Canvas documents (Canvas naming enforced)  |
| Version Control | GitHub / Azure DevOps source control repos |
| Secure Secrets  | `.env`, Docker Secrets, or host key vault  |

All versions and updates should originate from **Canvas or Git**, and changes are reflected in:

* Operational Alignment Plan
* Docs Index
* Changelogs

---

## 🧰 When ZIPs *Are* Allowed

| Condition                        | Must Also…                      |
| -------------------------------- | ------------------------------- |
| Deliverables for external client | Match release tag + changelog   |
| Legal backup or grant archive    | Include full version metadata   |
| Offline/Airgapped deployments    | Be mirrored to a live repo ASAP |

---

## 🔒 File Naming & Hygiene

* Do **not** store version numbers in filenames (e.g., `README_v2_FINAL.md` ❌)
* Keep a single copy of all doc types per module
* Always update timestamps and version fields in headers
* All `.env`, `secrets/`, and configs must be ignored by `.gitignore`

---

## 🧠 Cultural Expectation

This isn’t just about space — it’s about discipline, clarity, and long-term operational integrity.

> “We don’t hoard backups. We maintain living systems.”

---

**Maintainer:** Chad Reesey
**Policy Author:** Mr. Potato (AI Assistant)
