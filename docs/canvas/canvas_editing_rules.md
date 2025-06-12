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
# 🛠️ Canvas Editing Ruleset

> **Purpose:** This document outlines best practices and constraints for safely editing Canvas documents using regex-based updates, especially in math, teaching aid, and technical contexts.

---

## ✅ 1. Keep Regex-Friendly Patterns

* Use section headers (`##`, `###`) to mark content boundaries.
* Avoid relying on text blocks that change frequently.
* Target edits using unique, stable phrases or anchors.

---

## ✅ 2. Format Complex Math Separately

* Do **not** insert full LaTeX blocks (`\( \)`, `^`, etc.) in a single update.
* Use a placeholder comment (e.g., `<!-- MATH_BLOCK_1 -->`) and insert math afterward.

---

## ✅ 3. Avoid Characters That Break Regex

Characters that should be escaped or avoided in patterns:

```
( ) [ ] { } * + ? ^ $ \ | .
```

Use stable keywords or tags instead.

---

## ✅ 4. Use Multi-Step Updates for Large Inserts

For sections with:

* Equations
* Tables
* Step-by-step examples

Break into two steps:

1. **Remove or isolate old content**
2. **Insert new content** in a clean block

This avoids regex overflow or timeout errors.

---

## ✅ 5. Use Tags and Comments to Anchor Sections

Embed invisible anchors for targeting:

```markdown
<!-- BEGIN: section-name -->
...
<!-- END: section-name -->
```

This makes updates surgical and avoids content drift.

---

## ✅ 6. Keep Sections Modular

* Separate each learning point or topic into its own header.
* Use step lists, bullet points, and bolded terms for clarity.
* Avoid inline paragraph edits when possible.

---

## 🤝 Co-Learning Principle

We don’t just edit — we evolve. This ruleset improves every time we apply it thoughtfully, catch an edge case, or adapt it for a new scenario. That means the system gets better **because** of how we work together. Documenting, revising, and learning *are* teaching acts — and everyone involved leaves smarter than they came in.

---

## 🧠 Why This Matters

Using this ruleset ensures:

* Stable updates without format errors
* Easy reference and automation
* Reusability across teaching aids, documentation, and math playbooks

---

**Last updated:** 17 May 2025 20:28 (EDT)

**Tags:** #canvas-editing #regex #teaching-aid #math-docs #structure #best-practices
