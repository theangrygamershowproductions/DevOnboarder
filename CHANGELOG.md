# Changelog

All notable changes to DevOnboarder project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- DevOnboarder root planning documents (PLAN.md, TODO.md, roadmap.md)
- Feature planning pack structure under `docs/features/`
- Time Tracking Metrics feature planning pack (docs/features/time-tracking-metrics/)
  - Architecture and design decisions (PLAN.md)
  - Phase 6-10 implementation backlog (TODO.md)
  - Version roadmap v0.1 → v3.0 (roadmap.md)
  - v0.1 baseline decision locks (120s idle, Mode A aggregates, separate versioning)
- Cross-linking in README.md pointing to feature planning packs

### Changed

- Restructured planning documentation: repo-root docs describe platform, feature planning in nested packs
- PLAN.md now describes DevOnboarder platform execution focus, not individual features
- TODO.md now describes core platform backlog, with links to feature backlogs

### Planning

- Time Tracking Metrics phases 6–10: extension + API + dashboards + team analytics + public profiles
- v4.0 (2026-Q2+): Cross-IDE support, advanced observability, RBAC

## [0.0.0] - Pre-Release

### Infrastructure

- DevOnboarder core QA framework (95%+ test coverage)
- FastAPI + Discord.js + React + PostgreSQL architecture
- Docker Compose orchestration with Traefik reverse proxy
- Markdown-based planning documentation system

---

## Changelog Discipline

**Update Cadence:**

- Add entries to [Unreleased] section as features/fixes are completed
- On release: Create version section with completed items
- Format: Use ISO 8601 dates (YYYY-MM-DD)
- Linking: Reference issue numbers (#1234), commit SHAs (abc123d), and PR references

**Categories:**

- **Added:** New features
- **Changed:** Changes to existing functionality
- **Deprecated:** Soon-to-be removed features
- **Removed:** Removed features
- **Fixed:** Bug fixes
- **Security:** Security fixes and improvements
- **Planning:** Work planned for future phases (not yet in code)

**Example Entry:**

```markdown
### Fixed
- MD032 markdown linting errors in planning docs (#1234)

### Security
- Upgraded dependencies for CVE-2025-XXXXX patch
```
