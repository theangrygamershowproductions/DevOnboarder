---
project: "TAGS"
module: "Documentation"
phase: "Governance"
tags: ["azure", "devops", "area-paths", "iterations", "roles"]
updated: "29 May 2025 13:52 (EST)"
version: "v1.0.0"
-----------------

# Azure DevOps Area and Iteration Model

This document defines the canonical structure for area paths and iteration planning across all modules of *The Angry Gamer Show Productions* (TAGS) within Azure DevOps. It supports scalable planning, premium role segmentation, and feature tiering.

---

# 🔖 Area Path Structure

## Root: `The Angry Gamer Show Productions`

```markdown
TAGS - Auth
TAGS - Commander
├── Experimental
│   └── Incubation
├── Free Features
├── Management Features
└── Premium Features
TAGS - Documentation
TAGS - Internal Tooling
└── Design Pipeline
TAGS - WebApp
├── Free Features
├── Management Features
└── Premium Features
```

### ✅ Canonical Area Path Rules

* **All feature work items** must be tied to a `TAGS - <Module>` root area.
* **Sub-areas** define tiered access or dev classification (e.g., Free, Premium, Experimental).
* **Do not create non-prefixed module areas** (e.g., avoid "WebApp" by itself).

---

## 🗂️ Area Path Purposes

| Area Path                     | Purpose                                                    |
| ----------------------------- | ---------------------------------------------------------- |
| `TAGS - <Module>`             | Root for all backlog & board filters per team              |
| `Free Features`               | Open-source or general access commands/tools               |
| `Management Features`         | Admin-only tools (mod queues, audit logs, server controls) |
| `Premium Features`            | Role-gated, monetized, or subscription-tier features       |
| `Experimental` → `Incubation` | R\&D tools or modules in alpha/dev sandbox                 |

---

## 🧭 Iteration Naming Convention

### Example: `Phase 10: Premium Feature Rollout`

```markdown
TAGS → Iterations → Phase <#>: <Theme>
```

* Use sequential `Phase` numbers.
* Use concise, descriptive rollout themes.
* Optional: include sub-iterations if needed (`Phase 10 → Sprint 1`).

---

## 🏷️ Tagging Standards

Tags should be used for cross-cutting concerns:

| Tag Name       | Usage                                         |
| -------------- | --------------------------------------------- |
| `tier:free`    | Feature is part of free tier                  |
| `tier:premium` | Feature is gated behind premium               |
| `feature:xyz`  | Specific feature label (e.g., webhook, oauth) |
| `module:xyz`   | Module label (e.g., commander, webapp)        |

---

## 📌 Best Practices

* Use `area paths` for structural scope and team routing.
* Use `tags` for filtering, tiering, and cross-module reporting.
* Align each `TAGS -` area to its corresponding **Azure DevOps Team**.
* Review unused or orphaned areas every quarter.

---

## 📥 Onboarding Guidance

* All new work items must be assigned to a valid `TAGS -` area path.
* Follow iteration themes and file under correct tier (Free, Premium, etc).
* All new team members should review this document and link it in their DevOps project favorites.

---
