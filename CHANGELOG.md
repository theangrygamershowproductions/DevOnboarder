# Changelog

All notable changes to DevOnboarder project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Time Tracking Metrics planning artifacts (PLAN.md, TODO.md, roadmap.md, README.md)
- Decision point locks for v0.1 baseline (coding-only, 120s idle, Mode A aggregates, separate versioning)
- Phase 6-10 implementation roadmap and phased backlog

### Planning

- v0.1 baseline: Core time tracking metrics with VS Code extension + backend API
- v0.5 release: Analytics dashboard + team visibility controls
- v1.0 release: Production hardening + performance optimization
- v2.0+ release: Cross-IDE support + ecosystem expansion

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
