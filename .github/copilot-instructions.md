# GitHub Copilot Instructions for DevOnboarder

## Project Overview

DevOnboarder is a comprehensive onboarding automation platform with multi-service architecture designed to "work quietly and reliably." The project follows a trunk-based workflow with strict quality standards and extensive automation.

**Project Philosophy**: _"This project wasn't built to impress — it was built to work. Quietly. Reliably. And in service of those who need it."_

## Architecture & Technology Stack

### Core Services

-   **Backend**: Python 3.12 + FastAPI + SQLAlchemy (Port 8001)
-   **Discord Bot**: TypeScript + Discord.js (Port 8002) - **DevOnboader#3613** (ID: 1397063993213849672)
-   **Frontend**: React + Vite + TypeScript (Port 8081)
-   **Auth Service**: FastAPI + JWT + Discord OAuth (Port 8002)
-   **Database**: PostgreSQL (production), SQLite (development)

### Multi-Environment Setup

-   **Development**: `TAGS: DevOnboarder` (Guild ID: 1386935663139749998)
-   **Production**: `TAGS: C2C` (Guild ID: 1065367728992571444)

## Development Guidelines

### 1. Workflow Standards

-   **Trunk-based development**: All work branches from `main`, short-lived feature branches
-   **Pull request requirement**: All changes via PR with review
-   **Branch cleanup**: Delete feature branches after merge
-   **95% test coverage minimum** across all services

### 2. Code Quality Requirements

#### Python Standards

-   **Python version**: 3.12 (enforced via `.tool-versions`)
-   **Linting**: ruff with line-length=88, target-version="py312"
-   **Testing**: pytest with coverage requirements
-   **Type hints**: Required for all functions
-   **Docstrings**: Required for all public functions (use NumPy style)

```python
def greet(name: str) -> str:
    """Return a friendly greeting.

    Parameters
    ----------
    name:
        The name to greet.

    Returns
    -------
    str
        A greeting string.
    """
    return f"Hello, {name}!"
```

#### TypeScript Standards

-   **Node.js version**: 22 (enforced via `.tool-versions`)
-   **Testing**: Jest for bot, Vitest for frontend
-   **ESLint + Prettier**: Enforced formatting
-   **100% coverage** for bot service

### 3. Testing Requirements

#### Coverage Thresholds

-   **Python backend**: 96%+ (enforced in CI)
-   **TypeScript bot**: 100% (enforced in CI)
-   **React frontend**: 100% statements, 98.43%+ branches

#### Test Commands

```bash
# Install dependencies first (CRITICAL)
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

# Run tests with coverage
pytest --cov=src --cov-fail-under=95
npm run coverage --prefix bot
npm run coverage --prefix frontend
```

### 4. Commit Message Standards

**MANDATORY**: Use imperative mood, be descriptive and concise

**Good Examples**:

-   `Add user authentication endpoint with JWT validation`
-   `Fix Discord bot connection timeout handling`
-   `Update documentation for multi-environment setup`

**Bad Examples**:

-   `update` / `fix` / `misc` / `Applying previous commit`

## File Structure & Conventions

### Directory Layout

```
├── src/devonboarder/          # Python backend application
├── bot/                       # Discord bot (TypeScript)
├── frontend/                  # React application
├── auth/                      # Authentication service
├── tests/                     # Test suites
├── docs/                      # Documentation
├── scripts/                   # Automation scripts
├── .github/workflows/         # GitHub Actions (22+ workflows)
├── config/                    # Configuration files
└── plugins/                   # Optional Python extensions
```

### Key Configuration Files

-   `pyproject.toml`: Python dependencies and tools config
-   `package.json`: Node.js dependencies (bot & frontend)
-   `docker-compose.ci.yaml`: CI pipeline configuration
-   `config/devonboarder.config.yml`: Application configuration

## Service Integration Patterns

### 1. API Conventions

-   **Health checks**: All services expose `/health` endpoint
-   **Authentication**: JWT tokens issued by auth service
-   **CORS**: Properly configured for frontend integration
-   **Documentation**: FastAPI auto-generated docs required

### 2. Discord Bot Patterns

-   **Multi-guild support**: Automatic environment routing
-   **Commands**: `/verify`, `/dependency_inventory`, `/qa_checklist`, `/onboard`
-   **Role-based access**: Comprehensive permission model
-   **Management**: Use `npm run invite|status|test-guilds|dev`

### 3. Database Patterns

-   **Migrations**: Alembic for schema changes
-   **Models**: SQLAlchemy with proper relationships
-   **Connection**: Environment-specific (SQLite dev, PostgreSQL prod)

## CI/CD & Automation

### GitHub Actions Workflows

-   **ci.yml**: Main test pipeline with 95% coverage enforcement
-   **pr-automation.yml**: PR automation framework
-   **auto-fix.yml**: Automated fixes and formatting
-   **ci-health.yml**: CI pipeline monitoring
-   **security-audit.yml**: Security scanning

### Critical Scripts

-   `scripts/automate_pr_process.sh`: PR automation
-   `scripts/pr_decision_engine.sh`: Strategic decision engine
-   `scripts/assess_pr_health.sh`: PR health assessment
-   `scripts/run_tests.sh`: Comprehensive test runner

### Error Handling Requirements

-   **GitHub CLI availability**: Always check with fallbacks
-   **Variable initialization**: Initialize all variables early
-   **Exit codes**: Proper error propagation in shell scripts

## Security & Best Practices

### Security Requirements

-   **No remote code execution**: Prohibited `curl | sh` patterns
-   **Secret management**: Use GitHub Actions secrets
-   **Token security**: Secure Discord bot token storage
-   **HTTPS enforcement**: All production endpoints
-   **Input validation**: Sanitize all user inputs

### Documentation Standards

-   **Vale linting**: All Markdown must pass `scripts/check_docs.sh`
-   **README updates**: Update for all major changes
-   **Changelog**: Maintain `docs/CHANGELOG.md`
-   **API docs**: Keep OpenAPI specs current

## Common Integration Points

### 1. Adding New Features

1. Create feature branch from `main`
2. Implement with tests (maintain coverage)
3. Update documentation
4. Test in development environment
5. Submit PR with template checklist
6. Ensure CI passes before merge

### 2. Bot Command Development

```typescript
// Multi-environment routing example
const guildId = interaction.guild?.id;
const isDevEnvironment = guildId === "1386935663139749998";
const isProdEnvironment = guildId === "1065367728992571444";
```

### 3. API Endpoint Development

```python
# FastAPI endpoint with proper documentation
@app.get("/api/user/status", response_model=UserStatus)
async def get_user_status(user_id: int) -> UserStatus:
    """Get user onboarding status.

    Returns user's current onboarding progress and level.
    """
    # Implementation with proper error handling
```

## Quality Assurance Checklist

### Pre-Commit Requirements

-   [ ] All tests pass with required coverage
-   [ ] Linting passes (ruff for Python, ESLint for TypeScript)
-   [ ] Documentation updated and passes Vale
-   [ ] No secrets or sensitive data in commits
-   [ ] Commit message follows imperative mood standard

### PR Review Checklist

-   [ ] Coverage does not decrease
-   [ ] All CI checks pass
-   [ ] Documentation is clear and accurate
-   [ ] Security best practices followed
-   [ ] Multi-environment considerations addressed
-   [ ] Breaking changes properly documented

## Plugin Development

### Creating Plugins

```python
# plugins/example_plugin/__init__.py
"""Example plugin for DevOnboarder."""

def initialize():
    """Plugin initialization function."""
    return {"name": "example", "version": "1.0.0"}
```

Plugins are automatically discovered from the `plugins/` directory.

## Environment Variables

### Required Variables

-   `DISCORD_TOKEN`: Bot authentication token
-   `DATABASE_URL`: Database connection string
-   `JWT_SECRET`: Token signing secret
-   `IS_ALPHA_USER` / `IS_FOUNDER`: Feature flag access

### Development vs Production

-   Use `.env.dev` for development
-   Environment-specific Discord guild routing
-   Different database backends (SQLite vs PostgreSQL)

## Troubleshooting

### Common Issues

1. **ModuleNotFoundError**: Run `pip install -e .[test]` before tests
2. **Coverage failures**: Check test quality, not just quantity
3. **Discord connection issues**: Verify token and guild permissions
4. **CI failures**: Check GitHub CLI availability and error handling

### Debugging Tools

-   `python -m diagnostics`: Verify packages and environment
-   `npm run status --prefix bot`: Check bot connectivity
-   `scripts/check_docs.sh`: Validate documentation
-   Coverage reports: Generated by test commands

## Agent-Specific Guidelines

### For Code Generation

-   Follow established patterns in existing codebase
-   Maintain the project's "quiet reliability" philosophy
-   Prioritize error handling and edge cases
-   Include comprehensive tests with new code

### For Refactoring

-   Preserve existing API contracts
-   Maintain or improve test coverage
-   Update documentation for any public interface changes
-   Consider multi-environment implications

### For Bug Fixes

-   Write regression tests first
-   Document root cause in commit message
-   Consider if fix affects other services
-   Update troubleshooting documentation if needed

---

**Last Updated**: Based on current codebase analysis  
**Coverage Status**: Backend 96%+, Bot 100%, Frontend 100%  
**Active Environments**: Development + Production Discord integration  
**Review Required**: Follow PR template and maintain quality standards
