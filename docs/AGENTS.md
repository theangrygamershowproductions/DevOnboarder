---

project: "DevOnboarder"
module: "Codex"
phase: "MVP"
tags: ["codex", "agents", "automation", "regeneration", "devops"]
updated: "05 July 2025 00:00 (EST)"
version: "v1.0.1"
-----------------
<!-- PATCHED v0.5.9 docs/AGENTS.md — Document Codex CI agent -->

# Agents – DevOnboarder

This document outlines the autonomous and semi-autonomous agents that operate
within the DevOnboarder ecosystem.
These agents are responsible for code generation, validation,
 setup automation, and project infrastructure tasks.

---

# 🤖 Codex Regeneration Agent

## Role

Codex acts as a **code generation engine**,
transforming structured documentation
and specifications into clean, optimized application code.
Rather than auditing internal codebases,
Codex is used to generate new implementations

that conform to the latest standards.

### Purpose

* Regenerate modules using instructions and constraints
* Avoid legacy or inconsistent internal logic
* Maintain a high standard of clarity and maintainability

### Inputs

* `frontend/frontend-auth-flow.md`
* `auth/User_Role_Matrix.md`
* `frontend/frontend-session-role-guide.md`
* `TAGS-Roadmap.v1.2.md`
* All contents within `docs/`, `auth/`, and `frontend/`

### Outputs

* `auth/` - Authentication service and routes
* `frontend/` - React+Vite interface scaffold
* `challenges/` - Structured challenge definitions

Codex operates as a documentation-aware transformer, not an evaluator.

---

## 🧪 Evaluation Agent

### File: `codex/evaluate.py`

* Validates challenge submissions against template rubrics
* Used for developer onboarding, role-based challenge access
* Accepts CLI or API-style inputs via `--challenge` and `--submission`

---

## 🔧 Automation Agents

### `scripts/setup-dev.sh`

* Automates setup of Python venv and frontend/backend dependencies
* Ensures consistent runtime environment across local and containerized builds

### Git Hook Agents (Planned)

* Pre-commit: Format enforcement (Prettier/ESLint, Black)
* Pre-push: Test runner and lint check

### Codex CI Agent

* Location: `.github/workflows/codex.yaml`
* Builds `Dockerfile.codex` and runs Codex tasks in CI
* Documented in [docs/codex.md](./codex.md)

---

## Coding Standards

Agents generating code must follow the same style guides as human contributors.
Key points:

* **Python** code is formatted with `black` and validated with `pytest`.
* **Frontend** code adheres to ESLint and Prettier rules.
* Include patch headers at the top of modified files when applicable.

## Commit Message Expectations

Automated commits must use concise semantic messages, following
[Git.md](./Git.md) and `TAGS-Operation-Alignment-Plan.md`:

* Start with a type prefix such as `docs:`, `feat:`, or `fix:`.
* Keep the first line under 79 characters.
* Summarize the change in plain language.
* Optionally include the patch version when relevant (`PATCH v0.1.4`).

## Contribution Process

Automated commits follow the standard pull request workflow:

1. Open a PR referencing the relevant work item.
2. Update `CHANGELOG.md` with a summary of the change.
3. Ensure all tests pass before requesting review.

## Recommended Workflow

1. Create a short-lived branch from `main`.
2. Make changes using documentation as the source of truth.
3. Add patch headers to any updated files.
4. Run linters and tests (`black`, `pytest`, ESLint, Prettier).
5. Update `CHANGELOG.md` with a brief summary.
6. Commit using the guidelines above.
7. Push the branch and open a pull request with the PR template.

## Agent Interaction with the Repository

Agents use documentation as their source of truth and interact via PRs only.
They:

* Read from `docs/`, `auth/`, and `frontend/` directories as inputs.
* Submit changes through pull requests for human review.
* Avoid referencing unpublished or proprietary code not in this repository.

## 📌 Notes

* No legacy internal code is uploaded or used as input for Codex.
* All generated code is traceable to documentation sources.
* Feedback loops may be integrated post-MVP to enhance Codex output quality.

*Last updated: 05 July 2025 00:00 (EST)*
