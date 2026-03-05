# DevOnboarder Feature Initiatives

This directory contains planning documentation for major feature initiatives and extended functionality developed under the DevOnboarder platform.

## 🎯 Feature Packs

Each feature maintains its own planning directory with the complete 4-document system (PLAN.md, TODO.md, roadmap.md, + supporting docs).

### Active Feature Packs

#### Time Tracking Metrics

**Purpose**: TAGS-native developer productivity telemetry system with privacy-first, local-first design.

**Scope**: 
- **Phase 6** (Extension): VS Code extension for time tracking
- **Phase 7** (Backend): DevOnboarder API endpoints for telemetry collection and analysis

**Documentation**:
- [`time-tracking-metrics/PLAN.md`](time-tracking-metrics/PLAN.md) — Architecture, design decisions, system components
- [`time-tracking-metrics/TODO.md`](time-tracking-metrics/TODO.md) — Phase backlog (Phases 6-10) with acceptance criteria
- [`time-tracking-metrics/roadmap.md`](time-tracking-metrics/roadmap.md) — Version milestones (v0.1 → v3.0)

**Status**: Planning phase (PR #1965 under review)  
**Blocking Item**: Implementation gated behind merged planning PR  
**Target**: Phase 6 implementation Q2 2026+

**Repositories**:
- Planning: [DevOnboarder](../) (this repo)
- Extension: [time-tracking-metrics-vscode](https://github.com/theangrygamershowproductions/time-tracking-metrics-vscode) (pending Phase 6 bootstrap)

**Cross-Links**:
- ["🚀 Current Feature Initiatives" in DevOnboarder README](../../README.md#current-feature-initiatives)
- [Time Tracking Metrics in TAGS ecosystem roadmap](../../../../roadmap.md#devonboarder-initiatives)

---

## 📋 Navigation & Governance

### Adding New Features

When introducing a new feature initiative to DevOnboarder:

1. **Create directory** under `docs/features/feature-name/`
2. **Create 4-document set**:
   - `PLAN.md` — Detailed architecture and design decisions
   - `TODO.md` — Phase-based backlog with acceptance criteria
   - `roadmap.md` — Version milestones and strategic direction
   - Optional: Supporting docs (diagrams, decision logs, etc.)
3. **Link from parent** — Add entry to this README.md
4. **Update root docs** —Update `../ README.md`, `../PLAN.md`, `../roadmap.md` to reference feature pack
5. **Update ecosystem docs** — Update `../../../../PLAN.md` and `../../../../roadmap.md` for ecosystem visibility

### Single Source of Truth

Each feature pack is the **authoritative source** for its planning. Root-level DevOnboarder docs link to feature packs but do NOT duplicate planning content.

Root-level docs focus on:
- **PLAN.md** → Platform-wide initiatives list with feature pack links
- **TODO.md** → Platform backlog with cross-repo items
- **roadmap.md** → Platform version milestones and feature initiatives section

### Documentation Discipline

All feature planning must follow:
- **Hierarchy**: Ecosystem root → Platform root → Feature pack (3 tiers)
- **Linking**: Always link, never duplicate (avoid documentation drift)
- **Status Tracking**: Keep status indicators (✅, 🔄, ⏸️, 🟡) current
- **Phase Management**: Use consistent phase(s) naming across plans

---

## 🔗 Related Documents

**Parent Directory**: [DevOnboarder root docs](../)
- [README.md](../README.md) — Project overview with feature initiatives
- [PLAN.md](../PLAN.md) — Platform execution focus
- [TODO.md](../TODO.md) — Platform backlog
- [roadmap.md](../roadmap.md) — Platform version milestones

**Ecosystem Level**: [TAGS root docs](../../../../)
- [PLAN.md](../../../../PLAN.md) — Active work sessions including Time Tracking Metrics
- [TODO.md](../../../../TODO.md) — Cross-repo next actions
- [roadmap.md](../../../../roadmap.md) — Initiatives section with feature pack links

---

**Last Updated**: 2026-03-04  
**Purpose**: Feature planning index for DevOnboarder platform initiatives  
**Governance**: Single-source-of-truth linking; feature packs are authoritative
