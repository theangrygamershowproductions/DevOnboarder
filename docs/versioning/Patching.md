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
# TAG Patch Versioning & Change Annotation Guidelines

## 📌 Purpose

To establish a consistent and readable convention for file-level version tracking across all TAG projects. This helps developers quickly identify what was changed, why it was changed, and when, without relying solely on Git history or global release versions.

---

## 🔖 Patch Header Format

Each modified file should begin with a patch comment that follows this exact format:

```plaintext
// PATCHED vX.Y.Z src/path/to/file.ts — Brief description of what this patch changes or fixes

```

### ✅ Example

```plaintext
// PATCHED v0.0.6 src/hooks/useSession.ts — Adds debug logging to session initialization and storage parsing
```

### 🔧 Rules

* Always insert the patch comment **above the first import statement**.
* Leave **exactly one blank line** between the patch comment and the first line of code.
* Only update this header if the file was modified in a meaningful way.
* Keep the description short but specific.

---

## 🚫 What Not to Do

* ❌ Do not bulk-update all files to the same patch version unless the change was truly repo-wide (e.g., TypeScript upgrade).
* ❌ Do not use vague messages like `"misc fixes"` — be descriptive.
* ❌ Do not omit the `src/...` path — this is required for traceability.

---

## 🧠 Why This Matters

* Ensures **granular traceability** of file-level changes.
* Reduces clutter and noise in Git history.
* Aids QA and debugging by quickly identifying recently patched files.

---

## ✅ Suggested Commit Message Format

```plaintext
PATCH v0.0.6 — commit message example
```

If multiple files were affected, list the core change:

```plaintext
PATCH v0.0.7 — commit message example
```

---

## 📂 Optional Global Version Tracking

For higher-level version tracking (e.g., full `tag-webapp` releases), maintain a `VERSION.md` or tag versions via GitHub releases. This is **complementary** to per-file patching.

---

## 🛠 Automation Ideas (Optional)

* A CLI tool or VSCode snippet for inserting patch headers
* Pre-commit hooks that validate format
* Script to audit and lint patch comment consistency

---

## 🔚 Summary

Patch headers are lightweight, human-readable, and serve as the first source of truth for file change history.
Use them consistently. Use them clearly. Keep your patches clean.

> "A well-documented patch is one less bug waiting to happen."
> — TAG Dev Team
