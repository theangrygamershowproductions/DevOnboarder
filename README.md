---
title: "DevOnboarder"

description: "Multi-service on-boarding automation platform with Discord bot, web interface, and comprehensive CI/CD pipeline designed to work quietly and reliably."
document_type: "documentation"
tags: ["devonboarder", "platform", "automation", "onboarding", "discord", "ci-cd"]
project: "DevOnboarder"
author: "DevOnboarder Team"
consolidation_priority: "P3"
similarity_group: "ci-automation"
content_uniqueness_score: 4
merge_candidate: false
---

# DevOnboarder

## 🔧 **Project Statement**

> _"This project wasn't built to impress — it was built to work. Quietly.
> Reliably. And in service of those who need it."_

_Designed to automate onboarding, reduce friction, and support developers building from the ground up._

![Coverage](coverage.svg)
[![CI](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/ci.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/ci.yml)
[![Auto Fix](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/auto-fix.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/auto-fix.yml)
[![🥔 Potato Policy](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/potato-policy-focused.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/potato-policy-focused.yml)
[![📚 Documentation Quality](https://img.shields.io/badge/docs-certified-brightgreen?style=flat&logo=markdown)](docs/public/documentation-quality-certification.md)

## 🎯 **Project Management Framework**

DevOnboarder uses a comprehensive three-project structure for optimal organization and tracking:

### **[📋 Team Planning](https://github.com/orgs/theangrygamershowproductions/projects/4/views/1)** - MVP Execution

6-week MVP delivery with detailed task management

| Phase | Timeline | Milestone | Status |
|-------|----------|-----------|---------|
| **Phase 1** | Weeks 1-2 | [Foundation Stabilization](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1088) | ✅ Complete |
| **Phase 2** | Weeks 3-4 | [Terminal Output Compliance](milestones/2025-09/2025-09-19-infrastructure-phase2-terminal-output-compliance-complete.md) | ✅ Complete |
| **Phase 3** | Weeks 5-6 | [Monitoring & Automation Framework](https://github.com/theangrygamershowproductions/DevOnboarder/pull/1545) | ✅ Complete |

### **[🚀 Feature Release](https://github.com/orgs/theangrygamershowproductions/projects/5/views/1)** - Service Coordination

Multi-service integration and release management

- Cross-service integration testing and deployment

- [Staged Task Framework](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1091) implementation

- Quality gate enforcement and service health monitoring

### **[🗺️ Roadmap](https://github.com/orgs/theangrygamershowproductions/projects/6/views/1)** - Strategic Planning

Long-term platform evolution and strategic initiatives

- [Strategic Repository Splitting](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1092) (Post-MVP)

- [Platform Evolution & Scaling](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1093) (12-month vision)

- Technology roadmap and architectural evolution

**Quick Links**: [Current Sprint](https://github.com/orgs/theangrygamershowproductions/projects/4/views/1) • [Strategic Split Plan](codex/mvp/strategic_repository_splitting_plan.md) • [MVP Documentation](codex/mvp/)

---

## 📋 **Script Framework Organization Initiative**

DevOnboarder implements a hybrid migration strategy for organizing 250+ scripts into framework-based directories while maintaining system stability and team productivity.

### **Strategic Approach**

**Hybrid Migration Model**: Instead of disruptive script relocation, this initiative:

- ✅ **Preserves critical infrastructure** in existing `scripts/` directory
- ✅ **Copies low-risk scripts** to framework directories for gradual adoption
- ✅ **Maintains 100% backward compatibility** during transition
- ✅ **Enables incremental team adoption** of new framework structure

### **Migration Timeline**

| Version | Scope | Scripts | Risk Level | Target |
|---------|-------|---------|------------|---------|
| **1.x+1** | Low-Risk Migration | 75+ scripts | ✅ Low | 30% framework organization |
| **1.x+2** | Medium-Risk Migration | 50+ scripts | ⚠️ Medium | 50% framework organization |
| **1.x+3** | Integration Migration | 60+ scripts | ⚠️ Medium | 75% framework organization |
| **2.x.x** | Critical Infrastructure | 45+ scripts | 🔴 High | 90%+ framework organization |

### **Key Benefits**

- **🛡️ Risk Mitigation**: Small, manageable changes per version with rollback capabilities
- **👥 Team Adoption**: Gradual learning curve with clear documentation per phase
- **📊 Issue Tracking**: Clear progress visibility through GitHub issues and milestones
- **✅ Quality Assurance**: 95%+ quality threshold maintained throughout migration

### **Framework Structure**

```text
frameworks/
├── friction-prevention/        # Developer experience optimization
├── security-validation/        # Security and compliance validation
├── ci-cd-enhancement/         # Continuous integration improvements
├── environment-management/    # Environment and configuration management
├── documentation-automation/  # Documentation and reporting automation
└── utility-core/             # Common utilities and shared components
```

**Related Issues**: [#1506](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1506) (Main Initiative) • [#1526](https://github.com/theangrygamershowproductions/DevOnboarder/issues/1526) (Master Tracking) • [Framework Migration Roadmap](FRAMEWORK_MIGRATION_ROADMAP.md) • [Hybrid Migration Strategy](HYBRID_MIGRATION_APPROACH.md)

---

DevOnboarder demonstrates a trunk‑based workflow with Docker‑based services for rapid onboarding.

See [docs/README.md](docs/README.md) for full setup instructions and workflow guidelines.

**📚 Documentation**: DevOnboarder uses modular documentation for improved navigation - see [docs/MODULAR_DOCUMENTATION_INDEX.md](docs/MODULAR_DOCUMENTATION_INDEX.md) for the complete guide to all specialized modules.

## Why This Project Exists

The short version: everything broke, then got rebuilt.
The full recovery story lives in [docs/origin.md](docs/origin.md).

## 🧪 Quickstart for Devs

1. Clone the repo:

   ```bash
   git clone https://github.com/theangrygamershowproductions/DevOnboarder.git && cd DevOnboarder
   ```

2. Set up environment:

   ```bash
   # Create and activate virtual environment

   python -m venv .venv
   source .venv/bin/activate

   # Install dependencies

   pip install -e .[test]

   # Optional: Install DevOnboarder .zshrc integration for CLI shortcuts

   # See docs/cli-shortcuts.md for full shell integration guide

   ```

3. Run locally:

   ```bash
   docker compose up -d
   ```

4. **Optional**: Enable CLI shortcuts:

   ```bash
   # If you have DevOnboarder .zshrc integration:

   devonboarder-activate  # Auto-setup environment

   gh-dashboard          # View comprehensive status

   gh-ci-health         # Quick CI check

   ```

5. Run tests:

   ```bash
   ./scripts/run_tests.sh
   ```

6. You're live 🎉 – Check [docs/README.md](docs/README.md) for full agent + CI logic.

### Common Issues

- **Bot container shows "unhealthy"**: See [Discord Bot Health Check Fix](docs/troubleshooting/DISCORD_BOT_HEALTH_CHECK_FIX.md)

- **Permission denied errors**: Check [Docker Container Health Troubleshooting](docs/troubleshooting/DOCKER_CONTAINER_HEALTH_TROUBLESHOOTING.md)

- **Automerge hangs indefinitely**: See [Automerge Hanging Diagnosis](docs/troubleshooting/AUTOMERGE_HANGING_INDEFINITELY.md)

- **MyPy passes locally but fails in CI**: See [CI MyPy Type Stubs](docs/troubleshooting/CI_MYPY_TYPE_STUBS.md)

- **General setup issues**: Review [docs/README.md](docs/README.md) troubleshooting section

## 🔄 PR-to-Issue Automation

DevOnboarder includes **automatic issue creation and linking** when Pull Requests are opened, providing comprehensive tracking throughout the development lifecycle.

**How it works:**

- **Automatic Creation**: When PRs are opened, tracking issues are automatically created

- **Cross-Linking**: Issues and PRs are linked with comments for easy navigation

- **Progress Tracking**: Issues include development checklists and acceptance criteria

- **Automatic Closure**: Issues are automatically closed when PRs are merged

- **Comprehensive Labeling**: Automatic type detection and label application

See [docs/pr-issue-automation.md](docs/pr-issue-automation.md) for complete documentation.

## Trunk-Based Workflow

<!-- markdownlint-disable MD030 -->

- All stable code lives in the `main` branch.

- Short-lived branches are created off `main` for each change.

- Changes are merged back into `main` via pull requests after review.

- Feature branches are deleted after they are merged to keep history clean.

## 🥔 Security: Potato Policy

DevOnboarder implements an **Enhanced Potato Policy** - an automated security mechanism that protects sensitive configuration files from accidental exposure.

The policy ensures sensitive files (SSH keys, secrets, environment configs) are **never committed**, **never included in Docker builds**, and **never exposed in CI artifacts**.

**Protected Files:**

- `Potato.md` - SSH keys, setup instructions

- `*.env` - Environment variables

- `*.pem`, `*.key` - Private keys and certificates

- `secrets.yaml/yml` - Configuration secrets

**How it works:**

- 🔍 **Auto-detection**: CI automatically scans `.gitignore`, `.dockerignore`, and `.codespell-ignore`

- ➕ **Auto-correction**: Missing entries are automatically added

- 🚨 **Enforcement**: Builds fail if violations are detected, forcing manual review

- 📝 **Violation Reporting**: Automatic GitHub issue creation for audit trail

- 📊 **Audit Reports**: Generated for transparency and compliance

- ✅ **Compliance**: [![🥔 Potato Policy](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/potato-policy-focused.yml/badge.svg)](https://github.com/theangrygamershowproductions/DevOnboarder/actions/workflows/potato-policy-focused.yml)

This acts as a **"canary in the repository"** - any attempt to expose sensitive files is immediately caught, blocked, and reported.

> **🥔 Potato Policy Certified**
> Built with scars. Hardened with automation.

## Directory Overview

<!-- markdownlint-disable MD030 -->

- `config/` – Configuration files, including `devonboarder.config.yml`.

  See [Configuration Management Policy](docs/CONFIGURATION_MANAGEMENT_POLICY.md) for permanent vs temporary file distinctions.

- `scripts/` – Helper scripts for bootstrapping and environment setup.

  See [docs/tools-dashboard.md](docs/tools-dashboard.md) for comprehensive maintenance tools reference.

- `.devcontainer/` – Contains `devcontainer.json` which builds the VS Code development container,

  forwards port `3000`, and runs `scripts/setup-env.sh`.

- `archive/docker-compose.dev.yaml` – Archived compose file for local development using `.env.dev`.

- `docker-compose.ci.yaml` – Compose file used by the CI pipeline.

- `archive/docker-compose.prod.yaml` – Archived compose file for production using `.env.prod`.

- `archive/docker-compose.yml` – Archived base compose file for generic deployments.

- `archive/docker-compose.codex.yml` – Archived compose file for Codex runs.

- `archive/docker-compose.override.yaml` – Archived overrides for the base compose file.

- `bot/` – Discord bot **DevOnboader#3613** (ID: 1397063993213849672) written in TypeScript. Provides slash commands like `/verify`, `/dependency_inventory`, and `/qa_checklist`. This bot runs on its own and is not tied to Codex agents or CI workflows. Serves two environments: TAGS: DevOnboarder (dev) and TAGS: C2C (prod).

  See [docs/bot-types.md](docs/bot-types.md) for details on how the Discord bot differs from Codex agents.

- `frontend/` – Vite-based React application.

- `auth/` – Environment files for the authentication service.

- `plugins/` – Optional Python packages that extend functionality.

- `config/devonboarder.config.yml` – Config for the `devonboarder` tool.

- `.env.example` – Sample variables shared across services.

- `docs/CHANGELOG.md` – Project history and notable updates.

```html
<!-- markdownlint-restore -->

```

## Language Versions

DevOnboarder requires specific language versions for development consistency:

| Language | Version | Required For |
| -------- | ------- | ------------ |

| Python   | 3.12    | Backend services, testing, CI/CD |
| Node.js  | 22      | Discord bot, frontend development |

Install the required runtimes with `mise install` (or `asdf install`) to match the versions defined in `.tool-versions`.

**Note**: While DevOnboarder can run in broader containerized environments that include additional languages, core development requires only Python 3.12 and Node.js 22 as specified in `.tool-versions`.

## Available Make Targets

DevOnboarder includes several Makefile targets for common development tasks:

### Core Development

- `make deps` - Build Docker containers for all services

- `make up` - Start all services with Docker Compose

- `make test` - Run comprehensive test suite with coverage validation

- `make openapi` - Generate OpenAPI specification

### AAR (After Action Report) System

- `make aar-env-template` - Create/update .env file with AAR environment variables

- `make aar-setup` - Complete AAR system setup with token validation

- `make aar-check` - Validate AAR system status and configuration

- `make aar-validate` - Check AAR templates for markdown compliance

- `make aar-generate WORKFLOW_ID=12345` - Generate AAR for specific workflow run

- `make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true` - Generate AAR and create GitHub issue

### AAR System Features

The AAR system provides automated CI failure analysis and reporting:

- **Token Management**: Follows DevOnboarder No Default Token Policy v1.0

- **Environment Loading**: Automatically loads `.env` variables

- **Compliance Validation**: Ensures markdown standards (MD007, MD009, MD022, MD032)

- **GitHub Integration**: Creates issues for CI failures when tokens are configured

- **Offline Mode**: Generates reports without tokens for local analysis

For complete AAR documentation, see [`docs/AAR_MAKEFILE_INTEGRATION.md`](docs/AAR_MAKEFILE_INTEGRATION.md).

## Discord Bot Integration

Our Discord bot **DevOnboader#3613** (ID: 1397063993213849672) provides automated onboarding workflows and developer assistance. The bot serves two environments:

- **Development**: `TAGS: DevOnboarder` (Guild ID: 1386935663139749998)

- **Production**: `TAGS: C2C` (Guild ID: 1065367728992571444)

### Bot Features

- Automated role assignment for new members

- Developer verification workflows

- Command-based project assistance

- Integration with backend API services

- Multi-environment guild management

- Real-time service status monitoring

### Bot Commands

- `/onboard` - Start the onboarding process

- `/verify` - Verify developer credentials

- `/dependency_inventory` - Check project dependencies

- `/qa_checklist` - Display quality assurance checklist

- `/help` - Display available commands

- `/status` - Check bot and service status

### Management Commands

- `npm run invite` - Generate bot invite links

- `npm run status` - Check bot service status

- `npm run test-guilds` - Test guild connectivity

- `npm run dev` - Start development bot instance

The bot automatically connects to both guild environments and provides consistent functionality across development and production workflows.

## Documentation and Onboarding

Workflow documentation lives under the [docs/](docs/) directory. New contributors should:

1. Read [docs/README.md](docs/README.md) for development tips and setup details.

2. Follow [docs/git-guidelines.md](docs/git-guidelines.md) for branch and commit policies.

3. Use [.github/pull_request_template.md](.github/pull_request_template.md) when opening a pull request.

4. Run `bash scripts/install_commit_msg_hook.sh`

   or see [CONTRIBUTING.md](CONTRIBUTING.md) to install the commit-msg hook.

5. **CRITICAL**: Review [docs/TERMINAL_OUTPUT_VIOLATIONS.md](docs/TERMINAL_OUTPUT_VIOLATIONS.md) for terminal output policy (ZERO TOLERANCE for emojis in workflows).

6. Review [docs/pr-issue-automation.md](docs/pr-issue-automation.md) for automatic PR tracking and issue lifecycle management.

7. Verify merges with [docs/merge-checklist.md](docs/merge-checklist.md).

8. Track community members in [FOUNDERS.md](FOUNDERS.md) and [ALPHA_TESTERS.md](ALPHA_TESTERS.md).

9. Update all relevant READMEs when new roles are added to the GitHub organization.

10. Review [docs/alpha/README.md](docs/alpha/README.md) if you are an early tester.

11. See [docs/founders/README.md](docs/founders/README.md) for Founder's Circle guidelines.

12. Follow our [emails/style-guide.md](emails/style-guide.md) when crafting invitations.

13. Review our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) to learn our community expectations.

14. Check [docs/sample-pr.md](docs/sample-pr.md) for a small example update.

15. Review [docs/first-pr-guide.md](docs/first-pr-guide.md) for a full pull request walkthrough.

16. View the [docs/architecture.svg](docs/architecture.svg) diagram for an overview of our services.

17. Run `./scripts/check_docs.sh` to lint documentation with **Vale**.

    - The script automatically downloads Vale if it isn't installed and

      prints a warning if the download fails. See
      [docs/README.md#documentation-quality-checks](docs/README.md#documentation-quality-checks)
      for more details.
    - LanguageTool checks are optional; start a local server and set

      `LANGUAGETOOL_URL` to enable them.

18. Install the Vale CLI (version 3.12.0+) with `brew install vale` on macOS or

    `choco install vale` on Windows. You can also download it from the
    [Vale releases page](https://github.com/errata-ai/vale/releases).
    If the binary isn't in your `PATH`, set the `VALE_BINARY` environment variable
    and install the optional test dependencies with `pip install .[test]` so the
    documentation checks work locally.

19. Browse the [agents overview](agents/index.md) for individual service specs.

    Codex reads the machine‑readable list in `.codex/agents/index.json` to
    coordinate automation across these agents.

20. Review [.codex/Agents.md](.codex/Agents.md) for agent YAML header requirements and centralized notifications.

21. See [docs/ONBOARDING.md#sending-notifications](docs/ONBOARDING.md#sending-notifications) for how to send human updates.

22. Keep the sentinel word `Potato` and the file `Potato.md` listed in `.gitignore`,

    `.dockerignore`, and `.codespell-ignore`.
    See [AGENTS.md](AGENTS.md) for the full policy. Both pre-commit and CI run `scripts/check_potato_ignore.sh`
    to confirm the entries exist. Do not remove them without approval.
    For the security philosophy and origin story, see [docs/potato-policy-aar.md](docs/potato-policy-aar.md).

23. Review the [builder ethics dossier](docs/builder_ethics_dossier.md)

    outlining contributor ethics and a simple template.

24. Prefix a commit message with `[no-ci]` to skip the CI workflow on direct pushes. Pull requests always run CI. See

    [AGENTS.md](AGENTS.md) for details.

25. See [docs/network-exception-list.md](docs/network-exception-list.md)

    for required firewall domains. Run
    `scripts/show_network_exceptions.sh` to print them.

26. See [docs/ci-failure-issues.md](docs/ci-failure-issues.md)

    if CI automation fails to create or close `ci-failure` issues.

27. Review [docs/assessments/engineer_assessment_work_items.md](docs/assessments/engineer_assessment_work_items.md)

    and open an issue with the
    [Engineer Assessment template](.github/ISSUE_TEMPLATE/assessment.md)
    during onboarding reviews to ensure new features meet the checklist.

28. Read [docs/ecosystem.md](docs/ecosystem.md) for an overview of how the

    services interact inside the TAGS stack.

29. See [docs/tags_integration.md](docs/tags_integration.md) for TAGS setup

    steps and feature flag usage.

30. Review [docs/checklists/continuous-improvement.md](docs/checklists/continuous-improvement.md) for periodic retrospective tasks.

31. See [docs/tools-dashboard.md](docs/tools-dashboard.md) for comprehensive maintenance, cleanup, and diagnostic tools reference.

These files expand on the steps listed in the Quickstart section.

## Local Development

Build the development container defined in `.devcontainer/devcontainer.json`:

```bash
devcontainer dev --workspace-folder . --config .devcontainer/devcontainer.json

```

Alternatively, you can run the Docker Compose setup directly.
This starts the auth, bot (DevOnboader#3613), XP API, frontend, and database services using
environment variables from `.env.dev`.
Copy each `*.env.example` to `.env` inside its service directory before starting.
The `frontend/` directory hosts a Vite-based React app.
Run `npm install` (or `pnpm install`) in that folder to install dependencies,
commit the generated lockfile, and then start the development server with `npm run dev`:

```bash
docker compose -f archive/docker-compose.dev.yaml --env-file .env.dev up

```

To experiment with the user-facing API outside Docker, run:

```bash
devonboarder-api

```

The API server listens on `http://localhost:8001`.
Test the endpoints with:

```bash
curl http://localhost:8001/api/user/onboarding-status
curl http://localhost:8001/api/user/level

```

For authentication and user management, run:

```bash
devonboarder-auth

```

The auth service listens on `http://localhost:8002`.

To link Discord accounts and fetch roles separately, run:

```bash
devonboarder-integration

```

This service listens on `http://localhost:8081`.

The CI pipeline uses `docker-compose.ci.yaml` to start the Postgres database during tests.
Workflows rely on the preinstalled GitHub CLI or the `sersoft-gmbh/setup-gh-cli-action` action.

## Codex Runs

Codex uses its own compose file. Export your credentials and start the runner:

```bash
GITHUB_TOKEN=<token> OPENAI_API_KEY=<key> \
  docker compose -f archive/docker-compose.codex.yml up

```

The container reads `codex.ci.yml` and `codex.automation.bundle.json` from the
project root.

## Plugins

The package automatically loads modules found under the top-level `plugins/`
directory. Each plugin lives in its own subfolder with an `__init__.py` file.
Importing :mod:`devonboarder` populates `devonboarder.PLUGINS` with the
discovered modules. Enable a plugin by adding a new package under
`plugins/` and providing any initialization logic in its `register`
function.

## Production Deployment

Deploy the production stack with the dedicated compose file and `.env.prod`:

```bash
docker compose -f archive/docker-compose.prod.yaml --env-file .env.prod up -d

```

## Quickstart

1. Install Docker and Docker Compose. Run `mise install` to install the Python and Node.js versions defined in `.tool-versions`.

2. Run `bash scripts/bootstrap.sh` to create `.env.dev` and install dependencies.

   The script installs the frontend and bot packages so `npm ci --prefix bot` and
   `npm ci --prefix frontend` are only needed if you skip this step.
   For a manual setup, run `bash scripts/dev_setup.sh` to install Python and Node
   dependencies and set up pre-commit hooks.

3. Run `bash scripts/generate-secrets.sh` so `.env.dev` matches the secrets CI uses.

4. Copy each `*.env.example` to `.env` inside its service directory.

5. Build the containers with `make deps` and start them with `make up`.

6. Set up AAR (After Action Report) system for CI failure analysis:

   ```bash
   make aar-env-template  # Create/update .env with AAR tokens

   # Edit .env to set your GitHub tokens

   make aar-setup         # Complete AAR system setup

   make aar-check         # Validate AAR system status

   ```

7. Apply database migrations using `bash scripts/run_migrations.sh`.

8. Run `python -m diagnostics` to verify required packages load, services are

   healthy, and environment variables match the examples.

9. Install the project **before** running tests. Use editable mode so `pytest` can import the `devonboarder` package.

   Install Node.js packages with `npm ci` in each subdirectory:

    ```bash
    pip install -e .[test]  # or `pip install -r requirements.txt` if present

    ruff check .
    pytest --cov=src --cov-fail-under=95
    npm ci --prefix bot && npm run coverage --prefix bot
    npm ci --prefix frontend && npm run coverage --prefix frontend
    ```

    Set `OFFLINE_BADGE=1` if `img.shields.io` is unreachable to skip the badge
    update.
    **Note:** both installs must finish before running `pytest` or the tests may

    fail with `ModuleNotFoundError`. See
    [tests/README.md](tests/README.md) for details.

## 🔍 Quality Control Requirements

**95% Quality Threshold**: All changes must pass comprehensive QC validation before merging.

### Pre-Push Quality Control

Before every commit and push, run our QC validation:

```bash

# Activate virtual environment (MANDATORY)

source .venv/bin/activate

# Run comprehensive QC checks

./scripts/qc_pre_push.sh

# Only push if 95% threshold is met

git push

```

### QC Validation Checklist

The QC script validates 8 critical quality metrics:

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

### Coverage Requirements

- **Backend Python**: 96%+ coverage (enforced in CI)

- **TypeScript Bot**: 100% coverage (enforced in CI)

- **React Frontend**: 100% statements, 98.43%+ branches

### Quality Enforcement

- **CI Pipeline**: Automatically enforces 95% threshold

- **PR Validation**: Required for all pull requests

- **Agent Guidelines**: GitHub Copilot follows QC standards

- **Failure Guidance**: Specific fix commands provided on failures

For complete QC documentation, see [`docs/quality-control-95-rule.md`](docs/quality-control-95-rule.md).

## Testing and Development Continuation

1. Run `./scripts/run_tests.sh` to install dependencies and execute all tests.

   This wrapper prints helpful hints when packages are missing. See
   [docs/troubleshooting.md](docs/troubleshooting.md) if any failures occur.

2. Install git hooks with `pre-commit install` so lint checks run automatically.

3. The CI workflow enforces a minimum of **95% code coverage** for all projects

   (frontend, bot, and backend). Pull requests will fail if any test suite drops
   below this threshold. Current coverage: Backend 96%+, Bot 100%, Frontend 100%.

Licensed under the MIT License. See `LICENSE.md` for details.

## Found DevOnboarder useful?

If this project helped speed up onboarding, save time, or avoid headaches,
please [⭐ star the repo](https://github.com/theangrygamershowproductions/DevOnboarder)
or [open an issue](https://github.com/theangrygamershowproductions/DevOnboarder/issues)
with your feedback. Your input directly shapes future improvements.

## License

This project is licensed under the MIT License. See LICENSE.md.

## Auto-Fixer Tools

DevOnboarder includes comprehensive auto-fixer tools for maintaining code quality:

```bash

# Fix all file types

make autofix

# Fix specific file types

make autofix-markdown
make autofix-shell
make autofix-python

# QC with auto-fixing

./scripts/qc_with_autofix.sh --fix

```

See [docs/tools/auto-fixers.md](docs/tools/auto-fixers.md) for complete documentation.
