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
# 📦 CHANGELOG
<!-- markdownlint-disable MD024 -->
<!-- markdownlint-disable MD036 -->

> This changelog tracks all notable changes to the `TAGS Commander` bot.

---

## [v1.0.2] – 2025-05-21

### Added

- `auto_roles.py`, `welcome_embed.py`, `reaction_verify.py`, and `form_onboarding.py` onboarding modules
- Invite tracking logic via `invite_tracker.py` with role assignment audit
- Modular onboarding system via `setup_modules()` with feature flag toggles
- `feature_flags.py` now reads from `features.json`

### Changed

- Converted all onboarding logic into isolated, toggleable modules
- Introduced shared onboarding utility functions (`utils.py`)
- Added consistent file headers and enforced max 79-character lines throughout
- Markdown formatting and lint cleanup in documentation and READMEs

### Fixed

- Guarded `invite.uses` comparisons against `None` values in `invite_tracker.py`
- Resolved missing docstrings in modules and bot entrypoints

### Timeline Note

- 📈 Phases 1–7 completed significantly ahead of schedule
- Updated `onboarding_phase_plan.md` to reflect progress vs. estimate

---

## [v1.0.1] – 2025-05-20

### Added

- Slash command support for Discord `/ping`, `/verifyme`, and `/roles`
- `slash_roles()` shows aligned TAGS role structure with emoji identifiers
- Complete refactoring to match 79-character max line length standard
- Docstrings added to all commands and event handlers
- Debug logging enabled for `discord.http`

### Changed

- Renamed internal role variable in `slash_roles()` to `tags_roles`
- Renamed `roles` prefix command internal variable to `guild_roles`
- Updated `assign_role` and `remove_role` to use `Optional[discord.Member]`
- Applied consistent formatting style across all functions

### Fixed

- SyntaxError in multiline string in `slash_roles`
- Type-hint conflict and linting issues with optional command arguments
- Role shadowing warning between prefix and slash commands
- Removed unused import `app_commands`

---

## [v1.0.0] – 2025-05-18

### Added

- Initial bot implementation with prefix commands:
  - `!hello`
  - `!serverinfo`
  - `!roles`
  - `!assign_role`
  - `!remove_role`
  - `!set_timezone`
  - `!show_time`
- TimezoneManager background task scheduler

---

_Last updated: 21 May 2025 08:20 (EDT)_
