# DevOnboarder Agent Guidelines

## 📋 Overview

This document provides agent-specific guidelines for working with the DevOnboarder project. **All agents must first consult the main [TAGS AGENTS.md](../../AGENTS.md) for ecosystem-wide guidelines** before applying these project-specific rules.

## 🔗 Documentation Hierarchy

```
TAGS Ecosystem (Main Entry Point)
├── AGENTS.md (Ecosystem-wide guidelines)
├── .github/copilot-instructions.md (GitHub Copilot specific)
└── ecosystem/DevOnboarder/
    └── AGENTS.md (Project-specific guidelines) ← You are here
        ├── Inherits from TAGS/AGENTS.md
        ├── DevOnboarder-specific tooling
        └── Project conventions
```

## 🛠️ DevOnboarder-Specific Tools

### Git Management (Inherited + Enhanced)

**Standard TAGS Git Tools:**
```bash
~/TAGS/shared/scripts/git_status_check.sh --quiet            # Daily status check
~/TAGS/shared/scripts/git_sync_verification.sh --fix         # Auto-fix sync issues
```

**DevOnboarder-Specific Git Workflow:**
```bash
# DevOnboarder requires feature branches only
git checkout -b feat/descriptive-name

# Use safe_commit for all commits (mandatory)
./scripts/safe_commit.sh "FEAT(component): description"

# Quality gates: 95% coverage required
./scripts/qc_pre_push.sh
```

### Quality Control (Enhanced)

**DevOnboarder Quality Standards:**
- **Backend Coverage**: 96% minimum (pytest)
- **Bot Coverage**: 100% minimum (Jest)
- **Frontend Coverage**: 100% minimum (Vitest)
- **Architecture**: FastAPI + Discord.js + React + PostgreSQL + Traefik

**Quality Commands:**
```bash
# Full QC suite
./scripts/qc_pre_push.sh

# Component-specific testing
make test-backend     # Backend tests
make test-bot        # Bot tests
make test-frontend   # Frontend tests
```

### Environment Management

**Virtual Environment (Mandatory):**
```bash
# Always activate before working
source .venv/bin/activate

# DevOnboarder uses Poetry for dependency management
poetry install --dry-run  # Check dependencies
poetry update            # Update dependencies
```

## 🤖 Agent Registry

DevOnboarder uses a comprehensive agent registry system:

**Agent Documentation Location:**
- `.codex/agents/` - Individual agent files
- `.codex/Agents.md` - Agent policy documentation
- `.codex/index.json` - Agent registry index

**Key Agents:**
- `ai-mentor.md` - AI assistance and mentoring
- `code_quality_agent.md` - Code quality enforcement
- `dev-orchestrator.md` - Development orchestration
- `diagnostics-bot.md` - System diagnostics

## 🔐 Security & Authentication

**Token Hierarchy (Priority Matrix):**
1. `AAR_BOT_TOKEN` - Highest privilege (DevOnboarder automation)
2. `CI_ISSUE_AUTOMATION_TOKEN` - General automation
3. `CI_BOT_TOKEN` - CI operations
4. `GITHUB_TOKEN` - Default fallback

**Bitwarden Organization:** `6afacda6-0633-431f-964e-b2f6006cef2c`
**Project:** `cicd-automation`, `runtime-services`, `maintainer-access`

## 📊 Monitoring & Metrics

**Automated Monitoring:**
```bash
# CI health monitoring
./scripts/monitor_ci_health.sh

# Token expiry monitoring
./scripts/monitor_token_expiry.sh

# Coverage analysis
./scripts/analyze_coverage.sh
```

## 🚀 Deployment Architecture

**Service Structure:**
- **Backend**: FastAPI (Port 8001)
- **Auth Service**: Discord OAuth + JWT (Port 8002)
- **Bot Service**: Discord.js TypeScript (Port 8081)
- **Frontend**: React + Vite (Port 8081 dev)

**Docker Services:**
```bash
# Development environment
docker-compose -f docker-compose.dev.yaml up

# Production environment
docker-compose -f docker-compose.prod.yaml up
```

## 📝 Commit Standards

**Mandatory Format:**
```
TYPE(scope): brief description

- Detailed bullet points explaining changes
- Each bullet starts with uppercase action verb
- Technical details and impact described
```

**Valid Examples:**
```bash
FEAT(auth): implement Discord OAuth integration
- ADD OAuth2 flow with PKCE security
- UPDATE user session management
- FIX token refresh issues

REFACTOR(api): optimize database queries
- REDUCE query execution time by 40%
- ADD database indexes for performance
- UPDATE API response caching
```

## 🔄 Integration Points

**TAGS Ecosystem Integration:**
- Inherits all TAGS-wide tools and conventions
- Uses shared scripts from `~/TAGS/shared/`
- Follows TAGS color utilities and environment setup
- Integrates with TAGS monitoring and logging systems

**Cross-Project Dependencies:**
- `core-instructions` - Shared development patterns
- `AI-CI-Toolkit` - CI/CD automation tools
- `tags-mcp-servers` - MCP server configurations

**Related Agent Documentation:**
- [AI-CI-Toolkit Agents](../AI-CI-Toolkit/AGENTS.md) - CI/CD automation
- [core-instructions Agents](../core-instructions/AGENTS.md) - Documentation patterns
- [Website Agents](../website/AGENTS.md) - Business integration

## 🆘 Emergency Procedures

**Environment Reset:**
```bash
# Complete DevOnboarder reset
make clean && make deps && make up

# Clean Python artifacts
./scripts/clean_pytest_artifacts.sh
```

**CI Failure Recovery:**
```bash
# Analyze CI failures
./scripts/analyze_ci_failures.sh

# Emergency deployment
./scripts/emergency_deploy.sh
```

## 📚 Additional Resources

**Primary Documentation:**
- [Main TAGS AGENTS.md](../../AGENTS.md) - Ecosystem guidelines
- [DevOnboarder README.md](../README.md) - Project overview
- [Contributing Guide](../CONTRIBUTING.md) - Development workflow

**Agent-Specific Resources:**
- [.codex/Agents.md](../.codex/Agents.md) - Codex agent policies
- [Agent Index](../.codex/agents/index.json) - Available agents
- [Automation Tasks](../.codex/automation-tasks.md) - Task automation

---

**Last Updated:** 2025-01-15
**Inherits From:** TAGS/AGENTS.md v2.1
**Project:** DevOnboarder
**Contact:** DevOnboarder Development Team</content>
<parameter name="filePath">/home/potato/TAGS/ecosystem/DevOnboarder/AGENTS.md