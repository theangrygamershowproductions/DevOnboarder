---
project: "TAGS"
module: "Documentation"
phase: "Internal Tooling"
tags: ["docs", "internal"]
updated: "26 May 2025 17:50 (EST)"
version: "v1.0.0"
-----------------

# TAGS: CHANGELOG Template

---

## Purpose

Define a uniform structure for project `CHANGELOG.md` files to document all meaningful changes, support semantic versioning, and maintain traceability.

---

## Format Specification

```markdown
# CHANGELOG

## [v1.1.5] - 2025-05-26
### Added
- Added `mockRequest.ts` for middleware test simulation
- Added PR template with testing, patch, and changelog checks

### Changed
- Updated `.env` secrets policy with Docker secret mounts

### Fixed
- Resolved patch header misalignment in `resolveUserRoles.ts`

### Removed
- Deprecated `legacyMockUser.ts`

---
## [v1.1.4] - 2025-05-24
### Added
- Initialized `test/utils/mockSession.ts`
```

## Guidelines

* Newest entries at the top
* Each version uses: `Added`, `Changed`, `Fixed`, `Removed`
* Match file patch headers where applicable
* Timestamp: `YYYY-MM-DD`
* Link to PRs or work items where applicable

---

**Usage:** Place in root of each repository as `CHANGELOG.md`

**Maintainer:** Chad Reesey
