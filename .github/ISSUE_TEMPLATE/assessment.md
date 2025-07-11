---
name: Engineer Assessment
about: Checklist for evaluating DevOnboarder contributions
title: "[Assessment]"
labels: ["onboarding"]
---

Use this issue to track an engineer assessment. Check off items as they are completed.

### 1. Code Quality & Architecture
- [ ] Review code for modularity, separation of concerns, error handling, and clarity.
- [ ] Check adherence to `/docs/git-guidelines.md` in commit history and PRs.
- [ ] Validate use of ESLint, Prettier, and type safety (see `bot/package.json`, CI outputs).

### 2. Testing & CI/CD
- [ ] Confirm ≥95% test coverage and quality for critical paths.
- [ ] Ensure CI/CD blocks merges on test/coverage failures.

### 3. Documentation
- [ ] Audit docs and confirm Vale checks pass.
- [ ] Update changelog and guides for all major changes.

### 4. Project Alignment & Roadmap
- [ ] Map progress to the strategic rollup and verify Codex/Discord workflows exist.
- [ ] Assess project goals against adoption and feedback.

### 5. Community & Transparency
- [ ] Update Ethics Dossier, FOUNDERS, and ALPHA_TESTERS lists.
- [ ] Promote the repo and encourage external feedback.

### 6. Operational Readiness
- [ ] Test setup with provided scripts and validate production/staging configs.
- [ ] Document any onboarding or operational pain points.

### 7. Codex/Discord Automation
- [ ] Test `/qa_checklist` and other bot commands.
- [ ] Record at least one Codex E2E prompt in `docs/codex-e2e-report.md`.

### 8. Community Adoption & Feedback
- [ ] Ensure contribution guide is clear and request user feedback.
- [ ] Act on feedback to improve onboarding and structure.
