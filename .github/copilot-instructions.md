# GitHub Copilot Instructions for DevOnboarder

## Project Overview

DevOnboarder is a comprehensive onboarding automation platform with multi-service architecture designed to "work quietly and reliably." The project follows a trunk-based workflow with strict quality standards and extensive automation.

**Project Philosophy**: _"This project wasn't built to impress — it was built to work. Quietly. Reliably. And in service of those who need it."_

## ⚠️ CRITICAL: Virtual Environment Requirements

**NEVER INSTALL TO SYSTEM - ALWAYS USE VIRTUAL ENVIRONMENTS**

This project REQUIRES isolated environments for ALL tooling:

### Mandatory Environment Usage
- **Python**: ALWAYS use `.venv` virtual environment
- **Node.js**: ALWAYS use project-local `node_modules` 
- **Development**: ALWAYS use devcontainers or Docker
- **CI/CD**: ALWAYS runs in isolated containers

### Commands Must Use Virtual Environment Context
```bash
# ✅ CORRECT - Virtual environment usage
source .venv/bin/activate
pip install -e .[test]
python -m pytest
python -m black .
python -m openapi_spec_validator src/devonboarder/openapi.json

# ❌ WRONG - System installation
sudo pip install package
pip install --user package
black .  # (if not in venv)
```

### Why This Matters
- **Reproducible builds**: Same environment everywhere
- **Security**: No system pollution with project dependencies
- **Reliability**: Exact version control across team
- **CI compatibility**: Matches production environment
- **Multi-project safety**: No conflicts between projects

### Developer Setup Requirements
```bash
# Required first step for ALL development
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows

# Then install project
pip install -e .[test]
```

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

### 1. Environment First - ALWAYS

**Before ANY development work:**
```bash
# 1. Activate virtual environment
source .venv/bin/activate

# 2. Verify you're in venv
which python  # Should show .venv path
which pip     # Should show .venv path

# 3. Install dependencies
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend
```

### 2. Workflow Standards

-   **Trunk-based development**: All work branches from `main`, short-lived feature branches
-   **Pull request requirement**: All changes via PR with review
-   **Branch cleanup**: Delete feature branches after merge
-   **95% test coverage minimum** across all services
-   **Virtual environment enforcement**: All tooling in isolated environments

### 3. Code Quality Requirements

#### Python Standards

-   **Python version**: 3.12 (enforced via `.tool-versions`)
-   **Virtual environment**: MANDATORY - all Python tools via `.venv`
-   **Linting**: `python -m ruff` with line-length=88, target-version="py312"
-   **Testing**: `python -m pytest` with coverage requirements
-   **Formatting**: `python -m black` for code formatting
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
-   **Package management**: `npm ci` for reproducible installs
-   **Testing**: Jest for bot, Vitest for frontend
-   **ESLint + Prettier**: Enforced formatting
-   **100% coverage** for bot service

### 4. Testing Requirements

#### Coverage Thresholds

-   **Python backend**: 96%+ (enforced in CI)
-   **TypeScript bot**: 100% (enforced in CI)
-   **React frontend**: 100% statements, 98.43%+ branches

#### Test Commands (Virtual Environment Required)

```bash
# CRITICAL: Install dependencies first in virtual environment
source .venv/bin/activate  # Activate venv
pip install -e .[test]     # Install Python deps
npm ci --prefix bot        # Install bot deps
npm ci --prefix frontend   # Install frontend deps

# Run tests with coverage
python -m pytest --cov=src --cov-fail-under=95
npm run coverage --prefix bot
npm run coverage --prefix frontend
```

### 5. Commit Message Standards

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
├── .venv/                     # Python virtual environment (NEVER commit)
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
-   `.tool-versions`: Environment version requirements

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

### Virtual Environment in CI

All CI commands use proper virtual environment context:

```yaml
# Example GitHub Actions step
- name: Run Python tests
  run: |
    source .venv/bin/activate
    python -m pytest --cov=src --cov-fail-under=95

- name: Validate OpenAPI
  run: |
    source .venv/bin/activate
    python -m openapi_spec_validator src/devonboarder/openapi.json
```

### Error Handling Requirements

-   **GitHub CLI availability**: Always check with fallbacks
-   **Variable initialization**: Initialize all variables early
-   **Exit codes**: Proper error propagation in shell scripts
-   **Virtual environment checks**: Verify environment before tool execution

## Security & Best Practices

### Security Requirements

-   **No system installation**: All tools in virtual environments
-   **No remote code execution**: Prohibited `curl | sh` patterns
-   **Secret management**: Use GitHub Actions secrets
-   **Token security**: Secure Discord bot token storage
-   **HTTPS enforcement**: All production endpoints
-   **Input validation**: Sanitize all user inputs

### Documentation Standards

-   **Vale linting**: `python -m vale docs/` (in virtual environment)
-   **README updates**: Update for all major changes
-   **Changelog**: Maintain `docs/CHANGELOG.md`
-   **API docs**: Keep OpenAPI specs current

## Common Integration Points

### 1. Adding New Features

1. **Setup environment**: `source .venv/bin/activate`
2. Create feature branch from `main`
3. Install dependencies: `pip install -e .[test]`
4. Implement with tests (maintain coverage)
5. Update documentation
6. Test in development environment
7. Submit PR with template checklist
8. Ensure CI passes before merge

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

-   [ ] **Virtual environment activated** and dependencies installed
-   [ ] All tests pass with required coverage
-   [ ] Linting passes (`python -m ruff`, ESLint for TypeScript)
-   [ ] Documentation updated and passes Vale
-   [ ] No secrets or sensitive data in commits
-   [ ] Commit message follows imperative mood standard

### PR Review Checklist

-   [ ] **Virtual environment setup documented** in PR if needed
-   [ ] Coverage does not decrease
-   [ ] All CI checks pass
-   [ ] Documentation is clear and accurate
-   [ ] Security best practices followed
-   [ ] Multi-environment considerations addressed
-   [ ] Breaking changes properly documented

## Plugin Development

### Creating Plugins (Virtual Environment Required)

```python
# plugins/example_plugin/__init__.py
"""Example plugin for DevOnboarder."""

def initialize():
    """Plugin initialization function."""
    return {"name": "example", "version": "1.0.0"}
```

Plugins are automatically discovered from the `plugins/` directory.

**Development Setup**:
```bash
source .venv/bin/activate
pip install -e .[test]
python -m pytest plugins/example_plugin/
```

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

1. **ModuleNotFoundError**: 
   - ✅ **Solution**: `source .venv/bin/activate && pip install -e .[test]`
   - ❌ **NOT**: Install to system Python

2. **Command not found (black, pytest, etc.)**:
   - ✅ **Solution**: Use `python -m command` syntax in virtual environment
   - ❌ **NOT**: Install globally with `pip install --user`

3. **Coverage failures**: Check test quality, not just quantity

4. **Discord connection issues**: Verify token and guild permissions

5. **CI failures**: Check GitHub CLI availability and error handling

### Debugging Tools (Virtual Environment Context)

-   `python -m diagnostics`: Verify packages and environment
-   `npm run status --prefix bot`: Check bot connectivity
-   `python -m vale docs/`: Validate documentation
-   Coverage reports: Generated by test commands

## Agent-Specific Guidelines

### For Code Generation

-   **ALWAYS assume virtual environment context** in examples
-   Follow established patterns in existing codebase
-   Maintain the project's "quiet reliability" philosophy
-   Prioritize error handling and edge cases
-   Include comprehensive tests with new code
-   **Use `python -m module` syntax** for all Python tools

### For Refactoring

-   Preserve existing API contracts
-   Maintain or improve test coverage
-   Update documentation for any public interface changes
-   Consider multi-environment implications
-   **Ensure virtual environment compatibility**

### For Bug Fixes

-   Write regression tests first
-   Document root cause in commit message
-   Consider if fix affects other services
-   Update troubleshooting documentation if needed
-   **Test in clean virtual environment**

### Critical Reminders for Agents

1. **NEVER suggest system installation** of Python packages
2. **ALWAYS use `python -m module` syntax** for tools
3. **ALWAYS verify virtual environment activation** in examples
4. **ALWAYS include virtual environment setup** in instructions
5. **REMEMBER**: This project runs in containers/venvs, not host systems

---

**Last Updated**: Based on current codebase analysis  
**Coverage Status**: Backend 96%+, Bot 100%, Frontend 100%  
**Active Environments**: Development + Production Discord integration  
**Review Required**: Follow PR template and maintain quality standards  
**Virtual Environment**: MANDATORY for all development and tooling
