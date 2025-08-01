# GitHub Copilot Instructions for DevOnboarder

## Project Overview

DevOnboarder is a comprehensive onboarding automation platform with multi-service architecture designed to "work quietly and reliably." The project follows a trunk-based workflow with strict quality standards and extensive automation.

**Project Philosophy**: _"This project wasn't built to impress — it was built to work. Quietly. Reliably. And in service of those who need it."_

## ⚠️ CRITICAL: Virtual Environment Requirements

### NEVER INSTALL TO SYSTEM - ALWAYS USE VIRTUAL ENVIRONMENTS

This project REQUIRES isolated environments for ALL tooling:

## 🥔 Enhanced Potato Policy

DevOnboarder implements a unique **Enhanced Potato Policy** - an automated security mechanism that protects sensitive files from accidental exposure. This is a core architectural feature that affects all development work:

**Protected Patterns**:

- `Potato.md` - SSH keys, setup instructions
- `*.env` - Environment variables
- `*.pem`, `*.key` - Private keys and certificates
- `secrets.yaml/yml` - Configuration secrets

**Enforcement Points**:

- `.gitignore`, `.dockerignore`, `.codespell-ignore` must contain "Potato" entries
- Pre-commit hooks via `scripts/check_potato_ignore.sh`
- CI validation in `potato-policy-focused.yml` workflow
- Automatic violation reporting and issue creation

**Developer Impact**: Any attempt to remove "Potato" entries or expose sensitive files will fail CI and require project lead approval with changelog documentation.

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

- **Backend**: Python 3.12 + FastAPI + SQLAlchemy (Port 8001)
- **Discord Bot**: TypeScript + Discord.js (Port 8002) - **DevOnboader#3613** (ID: 1397063993213849672)
- **Frontend**: React + Vite + TypeScript (Port 8081)
- **Auth Service**: FastAPI + JWT + Discord OAuth (Port 8002)
- **XP System**: Gamification API with user levels and contributions tracking
- **Database**: PostgreSQL (production), SQLite (development)

### Service Discovery Pattern

All FastAPI services follow a consistent pattern for health checks and CORS:

```python
# Standard service creation pattern (src/llama2_agile_helper/api.py, src/xp/api/__init__.py)
def create_app() -> FastAPI:
    app = FastAPI()
    cors_origins = get_cors_origins()  # From utils.cors

    class _SecurityHeadersMiddleware(BaseHTTPMiddleware):
        async def dispatch(self, request, call_next):
            resp = await call_next(request)
            resp.headers.setdefault("X-Content-Type-Options", "nosniff")
            return resp

    app.add_middleware(CORSMiddleware, allow_origins=cors_origins, ...)
    app.add_middleware(_SecurityHeadersMiddleware)

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}
```

### Multi-Environment Setup

- **Development**: `TAGS: DevOnboarder` (Guild ID: 1386935663139749998)
- **Production**: `TAGS: C2C` (Guild ID: 1065367728992571444)

### Service Integration Pattern

All services follow the same FastAPI pattern:

- **Health checks**: `/health` endpoint returning `{"status": "ok"}`
- **CORS middleware**: Configured via `get_cors_origins()` utility
- **Security headers**: Custom middleware adds `X-Content-Type-Options: nosniff`
- **JWT authentication**: Shared auth service for user sessions

```python
# Standard service creation pattern
def create_app() -> FastAPI:
    app = FastAPI()
    cors_origins = get_cors_origins()

    app.add_middleware(CORSMiddleware, allow_origins=cors_origins, ...)
    app.add_middleware(_SecurityHeadersMiddleware)

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}
```

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

- **Trunk-based development**: All work branches from `main`, short-lived feature branches
- **Pull request requirement**: All changes via PR with review
- **Branch cleanup**: Delete feature branches after merge
- **95% test coverage minimum** across all services
- **Virtual environment enforcement**: All tooling in isolated environments

### 3. Code Quality Requirements

### ⚠️ CRITICAL: Linting Rule Policy

**NEVER modify linting configuration files without explicit human approval**:

- `.markdownlint.json` - Markdown formatting standards
- `.eslintrc*` - JavaScript/TypeScript linting rules
- `.ruff.toml`/`pyproject.toml` - Python linting configuration
- `.prettierrc*` - Code formatting rules
- Any other linting/formatting configuration files

**Policy Enforcement**:

- **Fix content issues** in files to meet existing standards
- **Do NOT suggest** changing linting rules to avoid errors
- **Assume all linting rules** are intentionally configured
- **Only modify configs** when explicitly requested by a human

**Rationale**: Linting rules represent established project quality standards and governance decisions. Changing rules to avoid fixing legitimate issues undermines code quality consistency.

### ⚠️ CRITICAL: CI Hygiene & Artifact Management

**Root Artifact Guard System**: DevOnboarder enforces strict artifact hygiene to prevent repository pollution:

**Protected Root Directory**:

- **NEVER** create artifacts in repository root (`./`)
- **ALL** test/build outputs must go to designated directories:
    - `logs/` - Coverage files, test results, Vale output
    - `.venv/` - Python virtual environment
    - `frontend/node_modules/` - Frontend dependencies only
    - `bot/node_modules/` - Bot dependencies only

**Enforcement Mechanism**:

```bash
# Root Artifact Guard runs on every commit
bash scripts/enforce_output_location.sh

# Automatically blocks commits with violations:
# ❌ ./pytest-of-* directories in root
# ❌ ./.coverage* files in root (should be logs/)
# ❌ ./vale-results.json in root (should be logs/)
# ❌ ./node_modules in root (should be frontend/bot/)
# ❌ ./test.db or cache files in root
```

**CI Triage Guard Framework**: Comprehensive automation monitors and maintains CI health:

- **22+ GitHub Actions workflows** provide complete automation coverage
- **Auto-fixing**: Automatic formatting via `auto-fix.yml` workflow
- **Failure tracking**: `codex.ci.yml` opens issues for persistent failures
- **Permissions validation**: `validate-permissions.yml` enforces bot policies
- **Documentation quality**: Automated Vale and markdownlint enforcement
- **Security monitoring**: Continuous dependency and security audits

**Node Modules Hygiene Standard**:

```bash
# ✅ CORRECT - Install in service directories
cd frontend && npm ci
cd bot && npm ci

# ❌ WRONG - Never install in repository root
npm ci  # Creates ./node_modules/ - BLOCKED by Root Artifact Guard
```

#### Python Standards

- **Python version**: 3.12 (enforced via `.tool-versions`)
- **Virtual environment**: MANDATORY - all Python tools via `.venv`
- **Linting**: `python -m ruff` with line-length=88, target-version="py312"
- **Testing**: `python -m pytest` with coverage requirements
- **Formatting**: `python -m black` for code formatting
- **Type hints**: Required for all functions
- **Docstrings**: Required for all public functions (use NumPy style)

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

- **Node.js version**: 22 (enforced via `.tool-versions`)
- **Package management**: `npm ci` for reproducible installs
- **Testing**: Jest for bot, Vitest for frontend
- **ESLint + Prettier**: Enforced formatting
- **100% coverage** for bot service

### 4. Testing Requirements

#### Coverage Thresholds

- **Python backend**: 96%+ (enforced in CI)
- **TypeScript bot**: 100% (enforced in CI)
- **React frontend**: 100% statements, 98.43%+ branches

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

**Test Pattern**: The `scripts/run_tests.sh` automatically detects `ModuleNotFoundError` and provides installation hints if dependencies are missing.

**Enhanced Test Execution**:

```bash
# Standard test runner (CI compatible)
bash scripts/run_tests.sh

# Enhanced test runner with persistent logging
bash scripts/run_tests_with_logging.sh

# Clean pytest artifacts (enforced by Root Artifact Guard)
bash scripts/clean_pytest_artifacts.sh
```

**Log Management Framework**:

```bash
# Comprehensive log management system
bash scripts/manage_logs.sh list      # List all log files
bash scripts/manage_logs.sh clean     # Clean logs older than 7 days
bash scripts/manage_logs.sh archive   # Archive current logs
bash scripts/manage_logs.sh purge     # Remove all logs (with confirmation)
```

### 5. Commit Message Standards

**MANDATORY**: Use conventional commit format: `<TYPE>(<scope>): <subject>`

**Required Format**:

- `TYPE`: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, CI (uppercase)
- `scope`: Optional component (bot, frontend, auth, ci, etc.)
- `subject`: Imperative mood, descriptive and concise

**Good Examples**:

- `FEAT(auth): add user authentication endpoint with JWT validation`
- `FIX(bot): resolve Discord connection timeout handling`
- `DOCS(setup): update multi-environment configuration guide`
- `CHORE(ci): ensure latest GitHub CLI binary is used`

**Bad Examples**:

- `update` / `fix` / `misc` / `Applying previous commit`
- `Add feature` (missing TYPE format)

**Validation**: Enforced by `scripts/check_commit_messages.sh` in CI

## File Structure & Conventions

### Directory Layout

```text
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

- `pyproject.toml`: Python dependencies and tools config
- `package.json`: Node.js dependencies (bot & frontend)
- `docker-compose.ci.yaml`: CI pipeline configuration
- `config/devonboarder.config.yml`: Application configuration
- `.tool-versions`: Environment version requirements

## Service Integration Patterns

### 1. API Conventions

- **Health checks**: All services expose `/health` endpoint
- **Authentication**: JWT tokens issued by auth service
- **CORS**: Properly configured for frontend integration
- **Documentation**: FastAPI auto-generated docs required

### 2. Discord Bot Patterns

- **Multi-guild support**: Automatic environment routing
- **Commands**: `/verify`, `/dependency_inventory`, `/qa_checklist`, `/onboard`
- **Role-based access**: Comprehensive permission model
- **Management**: Use `npm run invite|status|test-guilds|dev`
- **Environment detection**: Guild ID-based routing in bot code

```typescript
// Multi-environment routing example
const guildId = interaction.guild?.id;
const isDevEnvironment = guildId === "1386935663139749998";
const isProdEnvironment = guildId === "1065367728992571444";
```

- **Startup logging**: Bot provides detailed environment info on startup
- **ESLint v9+ flat config**: Use `eslint.config.js` format, not legacy `.eslintrc`

### 3. Database Patterns

- **Migrations**: Alembic for schema changes
- **Models**: SQLAlchemy with proper relationships
- **Connection**: Environment-specific (SQLite dev, PostgreSQL prod)

## CI/CD & Automation

### GitHub Actions Workflows

- **ci.yml**: Main test pipeline with 95% coverage enforcement
- **pr-automation.yml**: PR automation framework
- **auto-fix.yml**: Automated fixes and formatting
- **ci-health.yml**: CI pipeline monitoring
- **security-audit.yml**: Security scanning
- **potato-policy-focused.yml**: Enhanced Potato Policy enforcement
- **validate-permissions.yml**: Bot permissions validation
- **documentation-quality.yml**: Automated Vale and markdownlint
- **env-doc-alignment.yml**: Environment variable documentation sync
- **branch-cleanup.yml**: Automated branch maintenance
- **ci-monitor.yml**: Continuous CI health monitoring
- **markdownlint.yml**: Dedicated markdown style enforcement
- **review-known-errors.yml**: Pattern recognition for recurring issues

### Critical Scripts

- `scripts/automate_pr_process.sh`: PR automation
- `scripts/pr_decision_engine.sh`: Strategic decision engine
- `scripts/assess_pr_health.sh`: PR health assessment
- `scripts/run_tests.sh`: Comprehensive test runner
- `scripts/check_potato_ignore.sh`: Potato Policy enforcement
- `scripts/generate_potato_report.sh`: Security audit reporting
- `scripts/check_commit_messages.sh`: Commit message validation
- `scripts/enforce_output_location.sh`: Root Artifact Guard enforcement
- `scripts/clean_pytest_artifacts.sh`: Comprehensive artifact cleanup
- `scripts/manage_logs.sh`: Advanced log management system

### Automation Ecosystem

DevOnboarder includes 100+ automation scripts in `scripts/` covering:

- **CI Health Monitoring**: `monitor_ci_health.sh`, `analyze_ci_patterns.sh`
- **Security Auditing**: `potato_policy_enforce.sh`, `security_audit.sh`
- **Environment Management**: `setup-env.sh`, `check_dependencies.sh`
- **Issue Management**: `close_resolved_issues.sh`, `batch_close_ci_noise.sh`
- **Quality Assurance**: `validate_pr_checklist.sh`, `standards_enforcement_assessment.sh`
- **Artifact Management**: `clean_pytest_artifacts.sh`, `enforce_output_location.sh`
- **Log Management**: `run_tests_with_logging.sh`, `manage_logs.sh`

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

- **GitHub CLI availability**: Always check with fallbacks
- **Variable initialization**: Initialize all variables early
- **Exit codes**: Proper error propagation in shell scripts
- **Virtual environment checks**: Verify environment before tool execution
- **Root Artifact Guard**: Automatic pollution detection and blocking
- **CI Triage Guard**: Pattern recognition for recurring CI failures
- **Automated issue creation**: For persistent failures via `codex.ci.yml`
- **Log persistence**: Enhanced logging via `run_tests_with_logging.sh`

## Security & Best Practices

### Security Requirements

- **No system installation**: All tools in virtual environments
- **No remote code execution**: Prohibited `curl | sh` patterns
- **Secret management**: Use GitHub Actions secrets
- **Token security**: Secure Discord bot token storage
- **CI token hierarchy**: CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN
- **Fine-grained tokens**: Prefer GitHub fine-grained tokens for security
- **HTTPS enforcement**: All production endpoints
- **Input validation**: Sanitize all user inputs

### Documentation Standards

- **Vale linting**: `python -m vale docs/` (in virtual environment)
- **README updates**: Update for all major changes
- **Changelog**: Maintain `docs/CHANGELOG.md`
- **API docs**: Keep OpenAPI specs current

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

// Bot startup pattern with environment detection
console.log("🤖 DevOnboarder Discord Bot Starting...");
console.log(`   Environment: ${ENVIRONMENT}`);
console.log(`   Guild ID: ${process.env.DISCORD_GUILD_ID}`);
console.log(`   Bot Ready: ${DISCORD_BOT_READY}`);
```

### 3. Frontend Integration Patterns

```typescript
// OAuth callback handling
useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");
    const path = window.location.pathname;

    if (!stored && path === "/login/discord/callback" && code) {
        fetch(`${authUrl}/login/discord/callback?code=${code}`)
            .then((r) => r.json())
            .then((data) => {
                localStorage.setItem("jwt", data.token);
                setToken(data.token);
            });
    }
}, [authUrl]);
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

### 4. Key Integration Points

**Discord OAuth Flow**:

1. Frontend redirects to `/login/discord` on auth service
2. Auth service exchanges code for Discord token via OAuth
3. User roles fetched from Discord API with timeout handling
4. JWT issued with user session data
5. Frontend stores JWT in localStorage for API calls

**Cross-Service Communication**:

- All services share database via `DATABASE_URL`
- Auth service validates JWTs for protected endpoints
- XP API depends on auth service's `get_current_user()` function
- Bot uses `BOT_JWT` for backend API communication

**XP/Gamification System**:

```python
# XP API pattern (src/xp/api/__init__.py)
@router.get("/api/user/level")
def user_level(username: str, db: Session = Depends(auth_service.get_db)):
    user = db.query(auth_service.User).filter_by(username=username).first()
    xp_total = sum(evt.xp for evt in user.events)
    level = xp_total // 100 + 1
    return {"level": level}

@router.post("/api/user/contribute")
def contribute(data: dict, current_user = Depends(auth_service.get_current_user)):
    # Award XP for contributions
```

## Quality Assurance Checklist

### Pre-Commit Requirements

- [ ] **Virtual environment activated** and dependencies installed
- [ ] All tests pass with required coverage
- [ ] Linting passes (`python -m ruff`, ESLint for TypeScript)
- [ ] Documentation updated and passes Vale
- [ ] No secrets or sensitive data in commits
- [ ] Commit message follows imperative mood standard

### PR Review Checklist

- [ ] **Virtual environment setup documented** in PR if needed
- [ ] Coverage does not decrease
- [ ] All CI checks pass
- [ ] Documentation is clear and accurate
- [ ] Security best practices followed
- [ ] Multi-environment considerations addressed
- [ ] Breaking changes properly documented

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

- `DISCORD_TOKEN`: Bot authentication token
- `DATABASE_URL`: Database connection string
- `JWT_SECRET`: Token signing secret
- `IS_ALPHA_USER` / `IS_FOUNDER`: Feature flag access

### Development vs Production

- Use `.env.dev` for development
- Environment-specific Discord guild routing
- Different database backends (SQLite vs PostgreSQL)

## Troubleshooting

### ⚠️ MANDATORY: Standard Operating Procedure for ALL Issues

**BEFORE attempting any custom solutions, ALWAYS follow this SOP:**

```bash
# STEP 1: Use DevOnboarder log management system
bash scripts/manage_logs.sh list | grep -E "(precommit|test|ci)" | tail -10

# STEP 2: Use CI diagnostic framework
bash scripts/monitor_ci_health.sh

# STEP 3: Use enhanced test runner with logging
bash scripts/run_tests_with_logging.sh

# STEP 4: Check for repository pollution
bash scripts/enforce_output_location.sh

# STEP 5: Use comprehensive cleanup if needed
bash scripts/final_cleanup.sh
```

### DevOnboarder Diagnostic Tools - USE THESE FIRST

**Log Management System**:

```bash
bash scripts/manage_logs.sh list      # List all log files
bash scripts/manage_logs.sh clean     # Clean logs older than 7 days
bash scripts/manage_logs.sh archive   # Archive current logs
bash scripts/manage_logs.sh purge     # Remove all logs (with confirmation)
```

**CI Health Monitoring**:

```bash
bash scripts/monitor_ci_health.sh     # Check CI health status
bash scripts/analyze_ci_patterns.sh   # Analyze recurring failure patterns
python scripts/ci_failure_diagnoser.py # Generate comprehensive CI diagnostic report
```

**Test Execution Framework**:

```bash
bash scripts/run_tests_with_logging.sh # Enhanced test runner with persistent logging
bash scripts/run_tests.sh             # Standard test runner (CI compatible)
bash scripts/clean_pytest_artifacts.sh # Clean pytest artifacts
```

**Artifact Management**:

```bash
bash scripts/enforce_output_location.sh # Check for repository pollution
bash scripts/final_cleanup.sh          # Clean all artifacts comprehensively
```

**GitHub CLI Toolkit**:

```bash
bash scripts/check_github_status.sh    # Use GitHub workflow analysis tools
gh issue list --label "ci-failure" --state open # Check for CI-related issues
```

### ⚠️ CRITICAL: Always Use Existing Tools Before Custom Solutions

**DO NOT create custom debugging solutions when DevOnboarder has 100+ automation scripts specifically designed for troubleshooting. This is a core principle of the "quiet reliability" philosophy.**

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

6. **Pre-commit failures**: Use `bash scripts/manage_logs.sh list` to check logs first

7. **Test isolation issues**: Use `bash scripts/run_tests_with_logging.sh` for analysis

### Debugging Tools (Virtual Environment Context)

- `python -m diagnostics`: Verify packages and environment
- `npm run status --prefix bot`: Check bot connectivity
- `python -m vale docs/`: Validate documentation
- Coverage reports: Generated by test commands

### Enhanced Logging and CI Troubleshooting

**Test Execution with Persistent Logs**:

```bash
# Enhanced test runner with comprehensive logging
bash scripts/run_tests_with_logging.sh

# Standard test runner (CI compatible)
bash scripts/run_tests.sh
```

**Log Management**:

```bash
# List all log files and sizes
bash scripts/manage_logs.sh list

# Clean logs older than 7 days
bash scripts/manage_logs.sh clean

# Remove all logs (with confirmation)
bash scripts/manage_logs.sh purge

# Archive current logs
bash scripts/manage_logs.sh archive

# Custom retention (3 days) with dry-run
bash scripts/manage_logs.sh --days 3 --dry-run clean
```

**Log Locations**:

- Test logs: `logs/test_run_TIMESTAMP.log`
- Coverage data: `logs/coverage_data_TIMESTAMP`
- CI diagnostics: `logs/ci_diagnostic_TIMESTAMP.log`
- All logs excluded from git via `.gitignore`

**When Terminal Output Fails**:

- Check `logs/test_run_*.log` for complete test output
- Use `bash scripts/run_tests_with_logging.sh` for persistent logging
- Review CI failure patterns in diagnostic logs
- Use Root Artifact Guard to identify pollution sources

### Enhanced CI Troubleshooting Framework

**CI Triage Guard System**: Automated detection and resolution of CI patterns:

```bash
# Check CI health status
bash scripts/monitor_ci_health.sh

# Analyze recurring failure patterns
bash scripts/analyze_ci_patterns.sh

# Generate comprehensive CI diagnostic report
bash scripts/ci_failure_diagnoser.py
```

**Root Artifact Guard Usage**:

```bash
# Check for repository pollution
bash scripts/enforce_output_location.sh

# Clean all artifacts comprehensively
bash scripts/final_cleanup.sh

# Verify clean state before commits
git status --short  # Should show only intended changes
```

**Automated Issue Management**:

- CI failures automatically create issues via `codex.ci.yml`
- Pattern recognition prevents duplicate issue creation
- Successful runs automatically close resolved issues
- Comprehensive logging preserves diagnostic information

## Agent-Specific Guidelines

### 🔒 Agent Role Enforcement

### 🚫 Agents May NOT

- Commit code using raw `git` or `subprocess.run(["git", ...])`
- Launch Codex orchestration (`codex_type: mcp_server`) without human-issued metadata
- Modify `.github/workflows/` or `.copilot-instructions.md` without approval
- Trigger MCP Server tasks without `.codex/agents/<role>.md` registration
- Execute infrastructure-affecting commands without explicit prompt context

### ✅ Agents MUST

- Route all GitHub interactions through the GitHub CLI (`gh`)
- Use registered Codex agent files with appropriate `codex_type`
- Validate Codex permissions via `.codex/bot-permissions.yaml`
- Respect Codex governance runtime constraints (`codex_runtime: true`)
- Log all automated actions through `scripts/log_agent_action.sh`

**Explicit restriction:**

> Claude and other Codex agents are prohibited from assuming orchestration roles (e.g., MCP Server behavior) unless registered in `.codex/agents/index.json` and activated via CI.

### 📌 GitHub CLI Enforcement

All repository interactions (issue creation, PRs, commenting, closing, etc.) **must** use the GitHub CLI (`gh`) or approved GitHub API scripts.

**Agents and humans must NEVER:**

- Use `git commit`, `git push`, or `curl -X POST` for GitHub API access
- Write to `.git/` via scripts or subprocess
- Circumvent `scripts/commit_with_checklist.sh`

Violations will trigger Root Artifact Guard and CI failure.

✅ Approved command examples:

- `gh pr create --title ...`
- `gh issue comment 123 --body ...`
- `bash scripts/commit_with_checklist.sh`

### 🚦 Codex MCP Server Activation Rules

**Codex orchestration must be explicitly registered and verified.**

Only tasks registered in `.codex/agents/index.json` and approved by `.codex/automation-tasks.md` may trigger MCP Server activation.

Unregistered use of:

- `codex_type: mcp_server`
- `pylanceRunCodeSnippet` labeled as server-level
- MCP triggers without approval

…will be rejected by `scripts/enforce_codex_permissions.sh`

### 🧩 Integration Instructions for Claude and Codex

Claude and all other Codex-linked agents must comply with the following runtime assumptions:

- You are operating inside a **restricted DevSecOps pipeline**.
- You are **not permitted to classify tasks**, elevate privileges, or spawn orchestration roles unless clearly instructed.
- **Default runtime** should always assume `codex_type: none`, `codex_role: assistant`, unless explicitly upgraded.

If any of the following conditions are met, escalate to human:

- Agent attempts orchestration spin-up without `.codex/agents/*` mapping
- Task includes raw Git access from Python, Bash, or pseudo-terminal subprocesses
- Any variation of `curl | sh` or `git commit` is proposed without checklist validation
- Claude attempts to re-route test automation via MCP Server logic

You must operate within GitHub CLI boundaries or registered agent triggers. All other routes are to be rejected, audited, and logged by `codex_runtime_guard.sh`.

### For Code Generation

- **ALWAYS assume virtual environment context** in examples
- Follow established patterns in existing codebase
- Maintain the project's "quiet reliability" philosophy
- Prioritize error handling and edge cases
- Include comprehensive tests with new code
- **Use `python -m module` syntax** for all Python tools

### For Refactoring

- Preserve existing API contracts
- Maintain or improve test coverage
- Update documentation for any public interface changes
- Consider multi-environment implications
- **Ensure virtual environment compatibility**

### For Bug Fixes

- Write regression tests first
- Document root cause in commit message
- Consider if fix affects other services
- Update troubleshooting documentation if needed
- **Test in clean virtual environment**

### Critical Reminders for Agents

1. **NEVER suggest system installation** of Python packages
2. **ALWAYS use `python -m module` syntax** for tools
3. **ALWAYS verify virtual environment activation** in examples
4. **ALWAYS include virtual environment setup** in instructions
5. **NEVER modify linting configuration files** without explicit human request
6. **ALWAYS use DevOnboarder diagnostic tools FIRST** before custom solutions
7. **ALWAYS follow the Standard Operating Procedure** for troubleshooting
8. **NEVER create ad-hoc debugging solutions** when comprehensive tooling exists
9. **NEVER use raw git commands** - use GitHub CLI (`gh`) or approved scripts
10. **NEVER assume orchestration roles** without `.codex/agents/` registration
11. **NEVER trigger MCP Server behavior** without explicit human metadata
12. **ALWAYS operate as `codex_type: none, codex_role: assistant`** by default
13. **REMEMBER**: This project runs in containers/venvs, not host systems
14. **RESPECT**: Root Artifact Guard and CI Triage Guard enforcement
15. **FOLLOW**: Node modules hygiene standards and placement requirements
16. **USE**: The 100+ automation scripts built specifically for troubleshooting
17. **ESCALATE**: To human if orchestration or infrastructure changes are requested

### ⚠️ CRITICAL: Tool Usage Priority

**ALWAYS use these tools in this order for ANY troubleshooting:**

1. **Check logs**: `bash scripts/manage_logs.sh list`
2. **CI health**: `bash scripts/monitor_ci_health.sh`
3. **Enhanced testing**: `bash scripts/run_tests_with_logging.sh`
4. **Artifact cleanup**: `bash scripts/enforce_output_location.sh`
5. **GitHub CLI**: `bash scripts/check_github_status.sh`

**Only after using ALL existing tools should you consider custom solutions.**

## Agent Documentation Standards

### Codex Agent Requirements

All agent documentation must include a `codex-agent` YAML header and be listed in `.codex/agents/index.json`:

```yaml
---
codex-agent: true
name: "agent-name"
type: "automation|orchestration|monitoring"
permissions: ["read", "write", "issues"]
description: "Brief description of agent purpose"
---
```

### Agent Integration Framework

- **Permissions**: Defined in `.codex/bot-permissions.yaml`
- **Discovery**: Listed in `.codex/agents/index.json`
- **Validation**: Checked by `scripts/validate-bot-permissions.sh`
- **Standards**: Documentation under `agents/` directory
- **Orchestration**: Coordinated via orchestrator agents

### CI Integration Patterns

```bash
# Agent validation in CI
bash scripts/validate-bot-permissions.sh

# List all bots and check permissions
python scripts/list-bots.py

# Environment variable documentation alignment
bash scripts/check_env_docs.py
```

---

**Last Updated**: 2025-08-01 (Enhanced with Agent Role Enforcement & GitHub CLI Framework)
**Coverage Status**: Backend 96%+, Bot 100%, Frontend 100%
**Active Environments**: Development + Production Discord integration
**CI Framework**: 22+ GitHub Actions workflows with comprehensive automation
**Security**: Enhanced Potato Policy + Root Artifact Guard + Agent Role Enforcement active
**Review Required**: Follow PR template and maintain quality standards
**Virtual Environment**: MANDATORY for all development and tooling
**Artifact Hygiene**: Root Artifact Guard enforces zero tolerance for pollution
**Agent Enforcement**: Codex MCP Server restrictions and GitHub CLI requirements enforced
