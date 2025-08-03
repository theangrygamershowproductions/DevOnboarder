---
name: Engineer Assessment
about: Checklist for evaluating DevOnboarder contributions
title: "[Assessment]"
labels: ''
assignees: ''

---

Use this issue to track an engineer assessment. Check off items as they are completed.

### 1. Code Quality & Architecture

- [ ] Review code for modularity, separation of concerns, error handling, and clarity.
- [ ] Check adherence to `/docs/git-guidelines.md` in commit history and PRs.
- [ ] Validate use of ESLint, Prettier, and type safety (see `bot/package.json`, CI outputs).
- [ ] Confirm all commit messages follow the conventional commit format.

### 2. Testing & CI/CD

- [ ] Confirm ≥95% test coverage and quality for critical paths.
- [ ] Ensure CI/CD blocks merges on test/coverage failures.
- [ ] Verify all test/build outputs are in designated directories (logs/, .venv/, frontend/node_modules/, bot/node_modules/).
- [ ] Confirm all test commands use the virtual environment context.

### 3. Documentation

- [ ] Audit docs and confirm Vale and markdownlint checks pass.
- [ ] Update changelog and guides for all major changes.
- [ ] Ensure no sensitive information or secrets are present in documentation.

### 4. Security & Policy Compliance

- [ ] Validate Potato Policy compliance (protected patterns in ignore files, no sensitive files committed).
- [ ] Confirm Root Artifact Guard passes (no artifacts in repository root).
- [ ] Ensure no system-level installs or global dependencies are introduced.

### 5. Project Alignment & Roadmap

- [ ] Map progress to the strategic rollup and verify Codex/Discord workflows exist.
- [ ] Assess project goals against adoption and feedback.

### 6. Community & Transparency

- [ ] Update Ethics Dossier, FOUNDERS, and ALPHA_TESTERS lists.
- [ ] Promote the repo and encourage external feedback.

### 7. Operational Readiness

- [ ] Test setup with provided scripts and validate production/staging configs.
- [ ] Document any onboarding or operational pain points.

### 8. Codex/Discord Automation

- [ ] Test `/qa_checklist` and other bot commands.
- [ ] Record at least one Codex E2E prompt in `docs/codex-e2e-report.md`.

### 9. Community Adoption & Feedback

- [ ] Ensure contribution guide is clear and request user feedback.
- [ ] Act on feedback to improve onboarding and structure.

### 10. Agent Documentation (if applicable)

- [ ] Confirm agent documentation includes required YAML frontmatter and passes schema validation.
- [ ] Ensure agent code is modular, well-documented, and adheres to the Potato Policy.
- [ ] Ensure agent code, tests, and logs meet project standards.
- [ ] Reference the [Agent Review Checklist](../../docs/checklists/agent-review-checklist.md) for full criteria if needed.
