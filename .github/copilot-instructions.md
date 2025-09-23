# GitHub Copilot Instructions for DevOnboarder

## Project Overview

DevOnboarder is a multi-service onboarding automation platform with FastAPI backend, Discord bot, React frontend, and PostgreSQL database. Services are orchestrated via Docker Compose with Traefik reverse proxy.

**Philosophy**: "Work quietly and reliably" - extensive automation and quality gates ensure stability.

## ⚠️ CRITICAL: Development Prerequisites

**ALWAYS activate virtual environment first:**

```bash
source .venv/bin/activate  # Required before ANY Python work
```

**Run QC validation before commits:**

```bash
./scripts/qc_pre_push.sh  # 95% quality threshold validation
```

**Use safe commit wrapper:**

```bash
./scripts/safe_commit.sh "feat(component): description"  # NEVER use git commit directly
```

## Architecture Patterns

### Service Structure

- **Backend**: FastAPI services in `src/` with consistent patterns
- **Bot**: TypeScript Discord.js bot in `bot/` with ES modules
- **Frontend**: React + Vite in `frontend/`
- **Database**: PostgreSQL with SQLAlchemy models

### FastAPI Service Pattern

```python
# src/xp/api/__init__.py - Standard service creation
def create_app() -> FastAPI:
    app = FastAPI()
    cors_origins = get_cors_origins()  # From src/utils/cors.py

    app.add_middleware(CORSMiddleware, allow_origins=cors_origins, ...)
    app.add_middleware(_SecurityHeadersMiddleware)  # From starlette

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    app.include_router(router)
    return app
```

### Discord Bot Pattern

```typescript
// bot/src/main.ts - Multi-guild routing
const guildId = interaction.guild?.id;
const isDevEnvironment = guildId === "1386935663139749998";
const isProdEnvironment = guildId === "1065367728992571444";
```

## Critical Policies & Conventions

### ⚠️ ZERO TOLERANCE: Terminal Output

**NEVER use these patterns - they cause immediate hanging:**

```bash
# ❌ FORBIDDEN - Causes hanging
echo "✅ Success"                    # Emojis
echo "Status: $VAR"                 # Variable expansion in echo
echo -e "Line1\nLine2"               # Multi-line echo
echo "$(command)"                  # Command substitution in echo
cat << 'EOF'...EOF                 # Here-doc syntax

# ✅ REQUIRED - Safe patterns
echo "Task completed successfully"
printf "Status: %s\n" "$VAR"
```

### UTC Timestamp Standardization

```python
# ✅ CORRECT - Use centralized utilities
from src.utils.timestamps import get_utc_display_timestamp, get_utc_timestamp

timestamp = get_utc_display_timestamp()  # "2025-09-21 19:06:26 UTC"
api_timestamp = get_utc_timestamp()      # "2025-09-21T19:06:26Z"

# ❌ FORBIDDEN - Causes diagnostic synchronization issues
datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")  # Wrong - uses local time
```

### Centralized Logging

```bash
# MANDATORY: All scripts log to centralized location
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
```

### Enhanced Potato Policy

**Protected sensitive files - NEVER expose:**

- `Potato.md` - SSH keys and setup
- `*.env` - Environment variables
- `*.pem`, `*.key` - Private keys

**Validation:** `.gitignore`, `.dockerignore`, `.codespell-ignore` must contain "Potato" entries

## Development Workflow

### Environment Setup

```bash
# 1. Feature branch from main
git checkout main && git pull
git checkout -b feat/descriptive-feature-name

# 2. Virtual environment (MANDATORY)
source .venv/bin/activate

# 3. Install dependencies
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

# 4. QC validation (MANDATORY)
./scripts/qc_pre_push.sh
```

### Testing Requirements

- **Backend**: 96%+ coverage with `python -m pytest --cov=src`
- **Bot**: 100% coverage with `npm run coverage --prefix bot`
- **Frontend**: 100% statements, 98.43%+ branches

### Commit Standards

**Conventional format required:**

```markdown
TYPE(scope): description

Types: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, SECURITY, BUILD
Examples:
- feat(auth): add JWT validation endpoint
- fix(bot): resolve Discord connection timeout
- chore(ci): update workflow dependencies
```

## Service Integration Patterns Overview

### Authentication Flow

1. Frontend redirects to auth service `/login/discord`
2. Auth service exchanges code for Discord token
3. JWT issued with user session data
4. Frontend stores JWT in localStorage

### Cross-Service Communication

```python
# XP service depends on auth service
@router.post("/api/user/contribute")
def contribute(data: dict, current_user = Depends(auth_service.get_current_user)):
    # Implementation uses authenticated user
```

### Docker Service Ports

- Auth Service: 8002
- XP API: 8001
- Discord Integration: 8081
- Dashboard: 8003
- Frontend: 8081 (dev server)

## Quality Gates & Automation

### QC Validation (8 Metrics)

1. YAML linting
2. Python linting (Ruff)
3. Python formatting (Black)
4. Type checking (MyPy)
5. Test coverage (95%+)
6. Documentation quality (Vale)
7. Commit message format
8. Security scanning (Bandit)

### Automation Scripts Overview

**100+ scripts in `scripts/` covering:**

- CI health monitoring (`monitor_ci_health.sh`)
- Quality control (`qc_pre_push.sh`)
- Token management (`enhanced_token_loader.sh`)
- Environment sync (`smart_env_sync.sh`)
- AAR system (`generate_aar.py`)

### AAR (After Action Report) Quick Start

```bash
make aar-setup                    # Initialize AAR system
make aar-generate WORKFLOW_ID=123 # Generate failure analysis
make aar-generate WORKFLOW_ID=123 CREATE_ISSUE=true  # + GitHub issue
```

## Common Patterns & Gotchas

### Import Patterns

```python
# ✅ PREFERRED - Centralized utilities
from src.utils.timestamps import get_utc_display_timestamp

# ✅ LEGITIMATE - Direct imports for specific operations
from datetime import datetime  # For fromtimestamp(), type hints

# ❌ AVOIDED - Direct datetime for timestamp generation
from datetime import datetime, timezone
```

### Standalone Script Pattern

```python
# Scripts that may run outside DevOnboarder environment
try:
    from src.utils.timestamps import get_utc_display_timestamp
except ImportError:
    sys.path.insert(0, str(Path(__file__).parent.parent / "src"))
    from utils.timestamps import get_utc_display_timestamp
```

### Jest Configuration (Bot)

```json
// bot/package.json - Critical timeout setting
{
  "jest": {
    "testTimeout": 30000,  // Prevents CI hangs
    "preset": "ts-jest/presets/default-esm",
    "extensionsToTreatAsEsm": [".ts"],
    "transform": {
      "^.+\\.ts$": ["ts-jest", {"useESM": true}]
    }
  }
}
```

### ES Module Requirements (Bot)

```typescript
// bot/src/commands/verify.ts - .js extensions required even for .ts files
import { command as profileCommand } from './profile.js';  // .js required
```

## Validation & Debugging

### Environment Consistency

```bash
# Check environment synchronization
bash scripts/smart_env_sync.sh --validate-only

# Security audit
bash scripts/env_security_audit.sh
```

### Service Health Checks

```bash
# Individual services
devonboarder-api        # XP API (port 8001)
devonboarder-auth       # Auth service (port 8002)
devonboarder-integration # Discord integration (port 8081)

# Docker orchestration
make deps && make up     # Full environment
docker compose logs <service>  # Service debugging
```

### CI Troubleshooting

```bash
# Enhanced test execution with logging
bash scripts/run_tests_with_logging.sh

# Log management
bash scripts/manage_logs.sh list
bash scripts/manage_logs.sh clean  # Remove logs >7 days
```

## Integration Points

### Discord OAuth Flow

Frontend → Auth Service → Discord API → JWT → Frontend localStorage

### XP/Gamification System

User contributions → XP events → Level calculation → API responses

### Multi-Environment Routing

Bot automatically detects guild ID for dev/prod environment switching

## Emergency Commands

### When Tests Fail

```bash
# Dependency hints
bash scripts/run_tests.sh

# Clean pytest artifacts
bash scripts/clean_pytest_artifacts.sh
```

### When Commits Fail

```bash
# Safe commit with automatic fixes
./scripts/safe_commit.sh "fix: resolve commit issues"
```

### When Environment is Broken

```bash
# Complete environment reset
make clean && make deps && make up
```

---

**Last Updated**: 2025-09-23
**Coverage**: Backend 96%+, Bot 100%, Frontend 100%
**Services**: Auth (8002), XP (8001), Discord Integration (8081), Dashboard (8003)
**Architecture**: FastAPI + Discord.js + React + PostgreSQL + Traefik

### CRITICAL VIOLATIONS THAT CAUSE HANGING

```bash

# ❌ FORBIDDEN - WILL CAUSE IMMEDIATE HANGING

echo "✅ Task completed"              # Emojis cause hanging

echo "🚀 Deployment successful"       # Unicode causes hanging

echo "📋 Checklist: $(get_items)"    # Command substitution in echo

echo -e "Line1\nLine2\nLine3"        # Multi-line escape sequences

cat << 'EOF'                         # Here-doc patterns

Multi-line content
EOF

# ❌ FORBIDDEN - Variable expansion in echo

echo "Status: $STATUS_VAR"           # Variable expansion causes hanging

echo "Files: ${FILE_COUNT}"          # Variable expansion causes hanging

echo "Result: $(command_output)"     # Command substitution causes hanging

```

### SAFE PATTERNS - MANDATORY USAGE

```bash

# ✅ REQUIRED - Individual echo commands with plain ASCII only

echo "Task completed successfully"
echo "Deployment finished"
echo "Processing file"
echo "Operation complete"

# ✅ REQUIRED - Variable handling with printf

printf "Status: %s\n" "$STATUS_VAR"
printf "Files processed: %d\n" "$FILE_COUNT"

# ✅ REQUIRED - Store command output first, then echo

RESULT=$(command_here)
echo "Command completed"
printf "Result: %s\n" "$RESULT"

```

### ENFORCEMENT INFRASTRUCTURE

**Validation Framework:**

- **Script**: `scripts/validate_terminal_output.sh` - Detects all violations

- **Summary**: `scripts/validation_summary.sh` - Clean reporting format

- **Pre-commit**: Blocks commits with terminal violations

- **CI Enforcement**: Multiple workflows validate terminal output

**Phased Cleanup System:**

- **Task Plan**: `codex/tasks/terminal-output-cleanup-phases.md`

- **Phase 1**: Critical Infrastructure (≤20 violations target)

- **Phase 2**: Build & Deployment (≤12 violations target)

- **Phase 3**: Monitoring & Automation (≤6 violations target)

- **Phase 4**: Documentation & Policy (0 violations target)

**Progress Tracking:**

- Started: 32 violations (August 2025)

- Current: 22 violations (31% reduction achieved)

- Target: 0 violations

- **Current Phase**: Phase 2 (Terminal Output Compliance & Deployment Visibility) - targeting ≤10 violations

- **Active Plan**: `codex/tasks/phase2_terminal_output_compliance.md` (Canonical Phase 2)

- **Branch Context**: `phase2/devonboarder-readiness`

### AGENT REQUIREMENTS - MANDATORY COMPLIANCE

**For ALL AI agents working on DevOnboarder:**

1. **NEVER use emojis or Unicode** in any terminal output commands

2. **NEVER use variable expansion** in echo statements (`echo "$VAR"`)

3. **NEVER use command substitution** in echo statements (`echo "$(cmd)"`)

4. **NEVER use multi-line echo** or here-doc syntax

5. **ALWAYS use individual echo commands** with plain ASCII text only

6. **ALWAYS use printf for variables**: `printf "text: %s\n" "$VAR"`

7. **NEVER use --no-verify flag** with git commit (ZERO TOLERANCE POLICY)

8. **ALWAYS use safe commit wrapper**: `./scripts/safe_commit.sh "message"`

9. **REMEMBER**: Terminal hanging is a CRITICAL FAILURE in DevOnboarder

10. **REMEMBER**: Bypassing quality gates with --no-verify is FORBIDDEN

**Policy Documentation:**

- **Comprehensive Guide**: `docs/TERMINAL_OUTPUT_VIOLATIONS.md`

- **AI Override Instructions**: `docs/AI_AGENT_TERMINAL_OVERRIDE.md`

- **Troubleshooting**: `docs/MARKDOWN_LINTING_TROUBLESHOOTING.md`

- **Coverage Challenge Lessons**: `docs/COVERAGE_CHALLENGE_LESSONS_LEARNED.md`

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

**Validation Commands**:

```bash

# Check Potato Policy compliance

bash scripts/check_potato_ignore.sh

# Generate security audit report

bash scripts/generate_potato_report.sh

# Enforce policy across all ignore files

bash scripts/potato_policy_enforce.sh

```

**What Gets Protected**:

- SSH keys and certificates in `Potato.md`

- Database credentials in environment files

- API tokens and webhooks configurations

- Any file matching protected patterns

**Enforcement Points Detail**:

- **Pre-commit**: `scripts/check_potato_ignore.sh` validates ignore files

- **CI/CD**: `potato-policy-focused.yml` workflow enforces compliance

- **Docker builds**: `.dockerignore` prevents sensitive files in images

- **Spell checking**: `.codespell-ignore` prevents exposure via docs

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

### TAGS Stack Integration

DevOnboarder is part of the TAGS platform with orchestrated microservices:

| Service             | Description                               | Port |
| ------------------- | ----------------------------------------- | ---- |

| Auth Server         | Provides Discord OAuth and JWT issuance   | 8002 |
| XP API              | Tracks onboarding progress and experience | 8001 |
| Integration Service | Handles Discord role syncing              | 8081 |
| Dashboard Service   | CI troubleshooting and script execution   | 8003 |
| DevOnboarder Server | Greeting and status endpoints             | 8000 |

All services depend on shared PostgreSQL database (port 5432) and use consistent patterns.

### Core Services

- **Backend**: Python 3.12 + FastAPI + SQLAlchemy (Port 8001)

- **Discord Bot**: TypeScript + Discord.js (Port 8002) - **DevOnboader#3613** (ID: 1397063993213849672)

- **Frontend**: React + Vite + TypeScript (Port 8081)

- **Auth Service**: FastAPI + JWT + Discord OAuth (Port 8002)

- **XP System**: Gamification API with user levels and contributions tracking

- **Dashboard Service**: FastAPI script execution and CI troubleshooting (Port 8003)

- **Discord Integration**: OAuth linking and role management (Port 8081)

- **Feedback Service**: User feedback collection and analytics

- **Database**: PostgreSQL (production), SQLite (development)

### Multi-Environment Setup

- **Development**: `TAGS: DevOnboarder` (Guild ID: 1386935663139749998)

- **Production**: `TAGS: C2C` (Guild ID: 1065367728992571444)

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

### Language Version Requirements

DevOnboarder enforces specific language versions via `.tool-versions`:

- **Python**: 3.12 (MANDATORY - tests only run on 3.12)

- **Node.js**: 22

- **Ruby**: 3.2.3, **Rust**: 1.88.0, **Go**: 1.24.4

- **Bun**: 1.2.14, **Java**: 21, **Swift**: 6.1

Install with `mise install` or `asdf install` to match exactly.

## Development Guidelines

### 1. Environment First - ALWAYS

**Before ANY development work:**

```bash

# 1. Create feature branch from main

git checkout main
git pull origin main
git checkout -b feat/descriptive-feature-name

# 2. Activate virtual environment

source .venv/bin/activate

# 3. Verify you're in venv

which python  # Should show .venv path

which pip     # Should show .venv path

# 4. Install dependencies

pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

# 5. CRITICAL: Run QC validation before any work

./scripts/qc_pre_push.sh  # 95% quality threshold

```

### 2. UTC Timestamp Standards - MANDATORY

**CRITICAL INFRASTRUCTURE REQUIREMENT**: All timestamp usage MUST follow UTC standards to maintain diagnostic accuracy across DevOnboarder automation.

**Root Cause**: Inconsistent datetime.now() usage claiming "UTC" but using local time caused critical diagnostic "whack" behavior and 3-minute discrepancies with GitHub API timestamps.

**Required Patterns**:

```python

# ✅ CORRECT - Use standardized UTC utilities

from src.utils.timestamps import get_utc_display_timestamp, get_utc_timestamp

# For display and logging (replaces datetime.now().strftime(...UTC...))
timestamp = get_utc_display_timestamp()  # "2025-09-21 19:06:26 UTC"

# For GitHub API compatibility
api_timestamp = get_utc_timestamp()  # "2025-09-21T19:06:26Z"

# For GitHub API timestamp parsing
github_time = parse_github_timestamp("2025-09-21T19:06:26Z")

# ❌ FORBIDDEN - Misleading patterns that caused infrastructure issues

timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")  # WRONG - uses local time
api_call_time = datetime.now().isoformat()  # WRONG - timezone naive

```

**Agent Requirements**:

- **ALWAYS use src.utils.timestamps utilities** for all timestamp operations
- **NEVER use datetime.now() with "UTC" labels** - causes diagnostic synchronization issues
- **VALIDATE with QC system** - scripts/qc_pre_push.sh includes UTC compliance check
- **REMEMBER**: Timestamp accuracy is critical for DevOnboarder's 50+ automation scripts

### 3. Import Pattern Guidelines - MANDATORY

**CRITICAL ARCHITECTURAL REQUIREMENT**: Follow centralized utility patterns to eliminate code duplication and ensure consistency across DevOnboarder automation.

**Centralized vs Direct Import Decision Matrix**:

```python

# ✅ PREFERRED - Centralized timestamp functions
from src.utils.timestamps import get_utc_display_timestamp, get_utc_timestamp, get_local_timestamp_for_filename

# ✅ LEGITIMATE - Specific datetime operations only
from datetime import datetime  # For fromtimestamp(), fromisoformat(), type annotations

# ❌ AVOIDED - Direct datetime for new timestamp generation
from datetime import datetime, timezone  # Use centralized functions instead

```

**Standalone Script Pattern** (for scripts that may run outside DevOnboarder environment):

```python

# MANDATORY pattern for standalone execution capability
try:
    from src.utils.timestamps import get_utc_display_timestamp
except ImportError:
    # Add repository root to path for standalone execution
    sys.path.insert(0, str(Path(__file__).parent.parent / "src"))
    try:
        from utils.timestamps import get_utc_display_timestamp
    except ImportError:
        from utils.timestamp_fallback import get_utc_display_timestamp

```

**Agent Requirements**:

- **ALWAYS use centralized utilities** for timestamp generation, logging, and common operations
- **AVOID direct datetime imports** unless for legitimate operations (fromtimestamp, parsing, type hints)
- **FOLLOW standalone script pattern** for any script that may run outside virtual environment
- **DOCUMENT architectural decisions** when creating new utility patterns

### 4. AI Code Review Integration - MANDATORY

**CRITICAL PROCESS REQUIREMENT**: Systematically address all AI feedback (GitHub Copilot inline comments) to improve code architecture and eliminate technical debt.

**Copilot Feedback Resolution Process**:

1. **Comprehensive Review**: Use `scripts/check_pr_inline_comments.sh` to extract all Copilot feedback
2. **Systematic Resolution**: Address ALL comments, including "missed" ones - they often reveal deeper architectural issues
3. **Root Cause Analysis**: Don't just fix symptoms - understand why duplication or issues occurred
4. **Documentation Update**: Add guidelines to prevent similar issues in future development

**Types of Copilot Feedback and Response Patterns**:

```python

# Code Duplication Feedback → Centralized Utilities
# Before: Multiple scripts with identical patterns
# After: Centralized module with fallback support

# Import Pattern Feedback → Architectural Guidelines
# Before: Inconsistent import approaches
# After: Clear guidelines with examples in copilot-instructions.md

# Error Handling Feedback → Validation-Driven Resolution
# Before: Ad-hoc error handling
# After: Use DevOnboarder's diagnostic scripts and patterns

```

**Agent Requirements**:

- **NEVER ignore Copilot feedback** - treat as architectural improvement opportunities
- **ADDRESS all comments systematically** - including ones discovered later in the process
- **CREATE centralized solutions** for duplicated patterns identified by AI
- **UPDATE documentation** to prevent future similar issues
- **REMEMBER**: AI feedback often reveals deeper architectural issues beyond surface fixes

### Essential Quick Start Commands

```bash

# Complete development setup (Docker-based)

make deps && make up              # Build and start all services

make test                         # Run comprehensive test suite

# Individual service testing (helpful for debugging)

devonboarder-api         # Start main API (port 8001)

devonboarder-auth        # Start auth service (port 8002)

devonboarder-integration # Start Discord integration (port 8081)

# Quality control (MANDATORY before commits)

./scripts/qc_pre_push.sh         # 95% quality validation (8 metrics)

./scripts/safe_commit.sh "message"  # Safe commit wrapper (NEVER use git commit directly)

# Test execution with enhanced logging

./scripts/run_tests.sh           # Standard test runner with hints

./scripts/run_tests_with_logging.sh  # Enhanced logging for CI troubleshooting

```

**Branch Naming Conventions:**

- `feat/feature-description` - New features

- `fix/bug-description` - Bug fixes

- `docs/update-description` - Documentation changes

- `refactor/component-name` - Code refactoring

- `test/test-description` - Test improvements

- `chore/maintenance-task` - Maintenance tasks

**Essential Development Commands**:

```bash

# Complete development setup

make deps && make up              # Build and start all services

make test                         # Run comprehensive test suite

make aar-setup                    # Set up CI failure analysis system

# Individual service testing (helpful for multi-service debugging)

devonboarder-api         # Start main API (port 8001)

devonboarder-auth        # Start auth service (port 8002)

devonboarder-integration # Start Discord integration (port 8081)

# Quality control (MANDATORY before push)

./scripts/qc_pre_push.sh         # Validates 8 quality metrics (95% threshold)

./scripts/safe_commit.sh "message"  # NEVER use git commit directly

# Test execution with enhanced capabilities

./scripts/run_tests.sh           # Standard test runner with dependency hints

./scripts/run_tests_with_logging.sh  # Enhanced logging for troubleshooting

# Documentation quality control

./scripts/qc_docs.sh             # Check all documentation formatting

./scripts/qc_docs.sh --fix       # Fix markdown formatting issues

# Docker-based multi-service debugging

docker compose -f docker-compose.dev.yaml ps    # Check service health

docker compose -f docker-compose.dev.yaml logs <service>  # Service logs

bash scripts/smart_env_sync.sh --validate-only  # Environment consistency

# Optional CLI shortcuts (if .zshrc integration enabled)

devonboarder-activate            # Auto-setup environment

gh-dashboard                     # View comprehensive status

gh-ci-health                     # Quick CI check

```

### 2. Centralized Logging Policy - MANDATORY

**ALL logging MUST use the centralized `logs/` directory. NO EXCEPTIONS.**

This is a **CRITICAL INFRASTRUCTURE REQUIREMENT** enforced by CI/CD pipelines:

```bash

# MANDATORY: All scripts create logs in centralized location

mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# MANDATORY: All workflows use centralized logging

command 2>&1 | tee logs/step-name.log

```

**Policy Enforcement**:

- **Pre-commit validation**: `scripts/validate_log_centralization.sh`

- **CI enforcement**: Root Artifact Guard blocks scattered logs

- **Documentation**: `docs/standards/centralized-logging-policy.md`

**Violation Severity**: CRITICAL - Blocks all commits and CI runs

### 3. Terminal Output Best Practices - MANDATORY

#### CRITICAL PRIORITY: Terminal output rules are ENFORCED with ZERO TOLERANCE for violations

**ABSOLUTE REQUIREMENTS for terminal output to prevent hanging:**

```bash

# ✅ CORRECT - Simple text only (MANDATORY)

echo "Task completed successfully"
echo "Files processed: 5"
echo "Next steps: Review and commit"

# ✅ CORRECT - Plain ASCII characters only

echo "Status: Implementation complete"
echo "Result: All tests passing"
echo "Action: Ready for deployment"

# ❌ FORBIDDEN - These WILL cause terminal hanging

echo "✅ Multi-line output here"        # Emojis cause hanging

echo "📋 Works with emojis"             # Unicode causes hanging

echo "🎯 No escaping issues"            # Special chars cause hanging

echo "Multi-line
output that
hangs terminal"                         # Multi-line causes hanging

cat << 'EOF'                            # Here-doc causes hanging

This also hangs terminals
EOF

echo -e "Line1\nLine2\nLine3"          # Escape sequences cause hanging

```

**ZERO TOLERANCE ENFORCEMENT POLICY**:

- **NEVER use emojis or Unicode characters** - CAUSES IMMEDIATE TERMINAL HANGING

- **NEVER use multi-line echo** - Causes terminal hanging in DevOnboarder environment

- **NEVER use here-doc syntax** - Also causes terminal hanging issues

- **NEVER use echo -e with \n** - Unreliable and can hang

- **NEVER use special characters** - Stick to plain ASCII text only

- **ALWAYS use individual echo commands** - Only reliable method tested

- **ALWAYS use plain text only** - No formatting, emojis, or Unicode

**CRITICAL CHARACTER RESTRICTIONS**:

- ❌ **NO EMOJIS**: ✅, ❌, 🎯, 🚀, 📋, 🔍, 📝, 💡, ⚠️, etc.

- ❌ **NO UNICODE**: Special symbols, arrows, bullets, etc.

- ❌ **NO SPECIAL FORMATTING**: Colors, bold, underline, etc.

- ✅ **ONLY ASCII**: Letters, numbers, basic punctuation (. , : ; - _ )

**Safe Usage Patterns**:

```bash

# Status summaries (SAFE - plain text only)

echo "Task completed successfully"
echo "Files processed: 5"
echo "Next steps: Review and commit"

# Error reporting (SAFE - plain text only)

echo "Operation failed"
echo "Check logs in: logs/error.log"
echo "Resolution: Fix configuration"

# Multi-step progress (SAFE - plain text only)

echo "Starting deployment process"
echo "Building application"
echo "Running tests"
echo "Deployment complete"

```

**MANDATORY Agent Requirements**:

- All AI agents MUST use individual echo commands with plain text only

- Any multi-line output MUST be broken into separate plain text echo statements

- NO emojis, Unicode, or special characters allowed in terminal output

- Terminal hanging is considered a CRITICAL FAILURE in DevOnboarder

- This policy is enforced with ZERO TOLERANCE to maintain system reliability

- Violations will cause immediate cancellation of commands

### 4. Workflow Standards

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

### ⚠️ MANDATORY: Markdown Standards Compliance

**ALL markdown content MUST comply with project linting rules before creation**:

- **MD022**: Headings surrounded by blank lines (before and after)

- **MD032**: Lists surrounded by blank lines (before and after)

- **MD031**: Fenced code blocks surrounded by blank lines (before and after)

- **MD007**: Proper list indentation (4 spaces for nested items)

- **MD009**: No trailing spaces (except 2 for line breaks)

**Pre-Creation Requirements**:

1. Review existing compliant markdown in the repository

2. Follow established spacing and formatting patterns

3. Never create content that will fail markdownlint validation

4. Treat linting rules as requirements, not post-creation fixes

**Example Compliant Format**:

```markdown

## Section Title

Paragraph text with proper spacing.

- List item with blank line above

- Second list item

    - Nested item with 4-space indentation

    - Another nested item

Another paragraph after blank line.

### Subsection

More content following the same pattern.

```

**Process Violation**: Creating non-compliant markdown that requires post-creation fixes violates the "quiet reliability" philosophy and wastes development cycles. Pre-commit hooks will block commits with markdown violations.

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

# Automatically blocks commits with violations

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

#### ⚠️ CRITICAL: 95% Quality Control Rule

**ALL changes must pass comprehensive QC validation before merging**:

```bash

# MANDATORY: Activate virtual environment first

source .venv/bin/activate

# Run comprehensive QC checks

./scripts/qc_pre_push.sh

# Only push if 95% threshold is met

git push

```

**QC Validation Checklist (8 Critical Metrics)**:

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

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

# Alternative: Use project test runner with hints

./scripts/run_tests.sh

# Quality Control: MANDATORY before push (95% threshold)

./scripts/qc_pre_push.sh

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

### 5. Pre-Commit Requirements - MANDATORY PROCESS

**CRITICAL**: ALL commits MUST follow this process to prevent CI failures and maintain "quiet reliability":

**MANDATORY PRE-COMMIT CHECKLIST**:

1. **Check commit message format FIRST** - Reference approved types before writing message

2. **ALWAYS use `scripts/safe_commit.sh`** - NEVER use `git commit` directly

3. **Verify format**: `<TYPE>(<scope>): <subject>` with approved TYPE

4. **Validate before staging** - Run relevant checks for changed files

**Approved Commit Types** (memorize these):

- **Standard**: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, SECURITY, BUILD

- **Extended**: PERF, CI, OPS, REVERT, WIP, INIT, TAG, POLICY, HOTFIX, CLEANUP

**FORBIDDEN Practices**:

- ❌ Using `git commit` directly (bypasses validation)

- ❌ Using unapproved types like `MERGE`, `UPDATE`, `MISC`

- ❌ Missing scope in commit messages

- ❌ Using `--no-verify` without explicit Potato Approval

### 6. Commit Message Standards

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

├── src/xp/                    # XP/gamification service

├── src/discord_integration/   # Discord OAuth and role management service

├── src/feedback_service/      # User feedback collection service

├── src/llama2_agile_helper/   # LLM integration service

├── src/routes/                # Additional API routes

├── src/utils/                 # Shared utilities (CORS, Discord, roles)

├── bot/                       # Discord bot (TypeScript)

├── frontend/                  # React application

├── auth/                      # Authentication service

├── tests/                     # Test suites

├── docs/                      # Documentation

├── scripts/                   # Automation scripts (100+ scripts)

├── .github/workflows/         # GitHub Actions (22+ workflows)

├── config/                    # Configuration files

├── codex/                     # Agent documentation and tasks

└── plugins/                   # Optional Python extensions

```

### Key Configuration Files

- `pyproject.toml`: Python dependencies and tools config

- `package.json`: Node.js dependencies (bot & frontend)

- `docker-compose.ci.yaml`: CI pipeline configuration

- `config/devonboarder.config.yml`: Application configuration

- `.tool-versions`: Environment version requirements (Python 3.12, Node.js 22)

- `.env.ci`: CI-specific environment variables (auto-generated)

- `schema/agent-schema.json`: JSON schema for agent validation

- `Makefile`: Development targets (deps, up, test, openapi, AAR system)

**CI Environment Pattern**:
The project uses `.env.ci` for CI-specific settings that differ from development:

```bash

# CI uses sanitized test values

DATABASE_URL=sqlite:///./test_devonboarder.db
DISCORD_BOT_TOKEN=ci_test_discord_bot_token_placeholder
CI=true
NODE_ENV=test
PYTHON_ENV=test

```

**Essential Development Tools**:

- **AAR (After Action Report) System**: Automated CI failure analysis with `make aar-*` commands

- **QC Pre-Push Script**: `./scripts/qc_pre_push.sh` validates 8 quality metrics (95% threshold)

- **CLI Shortcuts**: Optional `.zshrc` integration with `devonboarder-activate`, `gh-dashboard`

### Makefile Targets for Development

DevOnboarder provides sophisticated Make targets for streamlined development:

**Core Development**:

```bash
make deps                        # Build Docker containers for all services

make up                          # Start all services with Docker Compose

make test                        # Run comprehensive test suite with coverage validation

make openapi                     # Generate OpenAPI specification

```

**AAR (After Action Report) System**:

```bash
make aar-env-template            # Create/update .env file with AAR environment variables

make aar-setup                   # Complete AAR system setup with token validation

make aar-check                   # Validate AAR system status and configuration

make aar-validate                # Check AAR templates for markdown compliance

make aar-generate WORKFLOW_ID=12345                    # Generate AAR for specific workflow run

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true  # Generate AAR and create GitHub issue

```

**Auto-Fixer System**:

```bash
make autofix                     # Run all auto-fixers for code quality

make autofix-markdown            # Fix markdown files specifically

make autofix-shell               # Fix shell script formatting

make autofix-python              # Run Python formatters and linters

```

**Token Audit System**:

```bash
make audit-tokens                # Generate comprehensive token audit report

make audit-status                # Check token audit system status

make audit-clean                 # Clean old audit reports

```

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

- **audit-retro-actions.yml**: Retrospective action item auditing

- **dev-orchestrator.yml**: Development environment orchestration

- **prod-orchestrator.yml**: Production environment orchestration

- **staging-orchestrator.yml**: Staging environment orchestration

### Critical Scripts

- `scripts/automate_pr_process.sh`: PR automation

- `scripts/pr_decision_engine.sh`: Strategic decision engine

- `scripts/assess_pr_health.sh`: PR health assessment

- `scripts/check_pr_inline_comments.sh`: GitHub Copilot inline comments extraction

- `scripts/run_tests.sh`: Comprehensive test runner

- `scripts/check_potato_ignore.sh`: Potato Policy enforcement

- `scripts/generate_potato_report.sh`: Security audit reporting

- `scripts/check_commit_messages.sh`: Commit message validation

- `scripts/enforce_output_location.sh`: Root Artifact Guard enforcement

- `scripts/clean_pytest_artifacts.sh`: Comprehensive artifact cleanup

- `scripts/manage_logs.sh`: Advanced log management system

- `scripts/validate_agents.py`: Agent validation with JSON schema

- `scripts/validate-bot-permissions.sh`: Bot permission verification

- `scripts/qc_pre_push.sh`: 95% quality threshold validation (8 metrics)

### ⚠️ GPG Automation Framework - PRODUCTION READY

**DevOnboarder implements unified GPG signing across all automation workflows that create commits.**

**GPG Infrastructure**:

- **Priority Matrix Bot**: Key ID `9BA7DCDBF5D4DEDD` - For priority matrix synthesis automation

- **AAR Bot**: Key ID `99CA270AD84AE20C` - For AAR generation and portal automation

- **Unified approach**: All commit-making workflows use GPG signing for cryptographic verification

**CRITICAL SECURITY REQUIREMENT - Corporate Account Management**:

- **Secondary GitHub Account**: All bot/agent tokens MUST be managed through a secondary GitHub account

- **Corporate Ownership**: Account MUST be owned and managed within corporate structure (not personal accounts)

- **Example Implementation**: `developer@theangrygamershow.com` (scarabofthespudheap) - corporate-controlled account

- **Security Benefits**: Privilege separation, audit trails, emergency kill switch, compliance with corporate governance

- **Access Control**: Multi-factor authentication and corporate security policies required

- **Regular Review**: Periodic access audits as part of corporate security processes

**Framework Components**:

```bash

# GPG-enabled workflows (100% converted)

.github/workflows/priority-matrix-synthesis.yml    # Priority Matrix Bot GPG signing

.github/workflows/aar-automation.yml               # AAR Bot GPG signing

.github/workflows/aar-portal.yml                   # AAR Bot GPG signing

.github/workflows/test-gpg-framework.yml           # Framework validation testing

```

**Template-Based Development**:

- **Template**: `docs/templates/gpg-automation-workflow.yml` - Production-ready workflow template

- **Setup Scripts**: `scripts/setup_priority_matrix_bot_gpg_key.sh`, `scripts/setup_aar_bot_gpg_key.sh`

- **Documentation**: `docs/guides/gpg-automation-development.md` - Comprehensive development guide

**Security Features**:

- **Passphrase-free keys**: Designed for non-interactive automation

- **Base64 encoding**: Secure key storage in GitHub secrets

- **Non-interactive trust**: Automated GPG trust configuration

- **Token hierarchy**: Integrates with existing CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN pattern

**Agent Requirements for GPG Automation**:

- **ALWAYS use template patterns** when creating new automation workflows

- **ALWAYS apply terminal output policy** (printf instead of echo)

- **ALWAYS follow DevOnboarder quality standards** (shellcheck, yaml validation)

- **NEVER create commit-making workflows without GPG signing** - violates security standards

- **ALWAYS use corporate-managed secondary GitHub account** for bot/agent tokens

- **NEVER suggest using personal accounts** for automated system access

- **REMEMBER**: Framework is production-ready and battle-tested across 3 converted workflows

- **REMEMBER**: Corporate governance is MANDATORY for bot account management

**Quick Start for New Automation**:

```bash

# 1. Copy template for new workflow

cp docs/templates/gpg-automation-workflow.yml .github/workflows/new-automation.yml

# 2. Configure bot credentials (choose appropriate bot)

# For priority matrix work: Use Priority Matrix Bot credentials

# For AAR/reporting work: Use AAR Bot credentials

# 3. Apply DevOnboarder standards

# - Terminal output policy compliance

# - Token hierarchy integration

# - Comprehensive commit messaging

# 4. Test framework validation

# Run test-gpg-framework.yml workflow to validate setup

```

### AAR (After Action Report) System

DevOnboarder includes a comprehensive AAR system for automated CI failure analysis:

**Make Targets**:

```bash
make aar-env-template     # Create/update .env with AAR tokens

make aar-setup           # Complete AAR system setup with validation

make aar-check           # Validate AAR system status and configuration

make aar-validate        # Check AAR templates for markdown compliance

make aar-generate WORKFLOW_ID=12345                    # Generate AAR for workflow

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true  # Generate AAR + GitHub issue

```

**AAR Features**:

- **Token Management**: Follows DevOnboarder No Default Token Policy v1.0

- **Environment Loading**: Automatically loads `.env` variables

- **Compliance Validation**: Ensures markdown standards (MD007, MD009, MD022, MD032)

- **GitHub Integration**: Creates issues for CI failures when tokens configured

- **Offline Mode**: Generates reports without tokens for local analysis

- **Workflow Analysis**: Detailed failure analysis with logs and context

### Automation Ecosystem

DevOnboarder includes 100+ automation scripts in `scripts/` covering:

- **CI Health Monitoring**: `monitor_ci_health.sh`, `analyze_ci_patterns.sh`

- **Security Auditing**: `potato_policy_enforce.sh`, `security_audit.sh`

- **Environment Management**: `setup-env.sh`, `check_dependencies.sh`

- **Issue Management**: `close_resolved_issues.sh`, `batch_close_ci_noise.sh`

- **Quality Assurance**: `validate_pr_checklist.sh`, `standards_enforcement_assessment.sh`

- **Artifact Management**: `clean_pytest_artifacts.sh`, `enforce_output_location.sh`

- **Log Management**: `run_tests_with_logging.sh`, `manage_logs.sh`

- **Agent Validation**: `validate_agents.py`, `validate-bot-permissions.sh`

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

### Environment Variable Security Model

**CRITICAL**: DevOnboarder implements centralized environment variable management with security boundaries:

- **Source of Truth**: `.env` file contains all configuration (GITIGNORED)

- **Synchronization**: Use `bash scripts/smart_env_sync.sh --sync-all` to propagate changes

- **Security Boundaries**: Production secrets NEVER in committed files

- **CI Protection**: `.env.ci` uses test/mock values only

- **Audit System**: `bash scripts/env_security_audit.sh` for continuous validation

**Security Model**:

- `.env` - Source of truth (GITIGNORED)

- `.env.dev` - Development config (GITIGNORED)

- `.env.prod` - Production config (GITIGNORED)

- `.env.ci` - CI test config (COMMITTED with test values)

**Agent Requirements**:

- NEVER suggest manual editing of multiple environment files

- ALWAYS use centralized synchronization system

- ALWAYS validate security boundaries before file modifications

- REMEMBER: Production secrets in CI files is CRITICAL security violation

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

### Key CLI Commands

```bash

# Service APIs (individual service testing)

devonboarder-api         # Start main API (port 8001)

devonboarder-auth        # Start auth service (port 8002)

devonboarder-integration # Start Discord integration (port 8081)

# Development workflow

./scripts/run_tests.sh           # Test runner with dependency hints

./scripts/qc_pre_push.sh         # 95% quality validation

python -m diagnostics           # Verify environment and services

# Optional CLI shortcuts (if enabled)

devonboarder-activate   # Auto-setup environment

gh-dashboard           # View comprehensive status

gh-ci-health          # Quick CI check

```

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

**Jest Configuration Pattern**:

```typescript
// Jest configuration pattern for all tests
// In bot/package.json, always include:
"jest": {
    "preset": "ts-jest",
    "testEnvironment": "node",
    "testTimeout": 30000,  // CRITICAL: Prevents CI hangs
    "collectCoverage": true
}

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

**Service Port Assignments**:

- **Auth Service**: Port 8002 (`src/devonboarder/auth_service.py`)

- **XP Service**: Port 8001 (`src/xp/api/__init__.py`)

- **Discord Integration**: Port 8081 (`src/discord_integration/api.py`)

- **Dashboard Service**: Port 8003 (`src/devonboarder/dashboard_service.py`)

- **Frontend**: Port 8081 (React dev server)

- **Bot**: No HTTP server (Discord client only)

## Quality Assurance Checklist

### Pre-Commit Requirements

- [ ] **Virtual environment activated** and dependencies installed

- [ ] All tests pass with required coverage

- [ ] **Jest timeout configured in bot/package.json** (if working with bot)

- [ ] Linting passes (`python -m ruff`, ESLint for TypeScript)

- [ ] **Dependency PRs: Review breaking changes** (if dependency update)

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

### Common Issues

1. **ModuleNotFoundError**:

    - ✅ **Solution**: `source .venv/bin/activate && pip install -e .[test]`

    - ❌ **NOT**: Install to system Python

2. **Command not found (black, pytest, etc.)**:

    - ✅ **Solution**: Use `python -m command` syntax in virtual environment

    - ❌ **NOT**: Install globally with `pip install --user`

3. **MyPy passes locally but fails in CI**:

    - ✅ **Symptom**: "Library stubs not installed for 'requests' [import-untyped]"

    - ✅ **Solution**: Add missing `types-*` packages to `pyproject.toml` test dependencies

    - 📚 **Documentation**: `docs/troubleshooting/CI_MYPY_TYPE_STUBS.md`

    - ❌ **NOT**: Install type stubs only locally

4. **Automerge hangs indefinitely** (CRITICAL INFRASTRUCTURE ISSUE):

    - ✅ **Symptom**: All checks pass, automerge enabled, but PR shows "BLOCKED" indefinitely

    - ✅ **Root Cause**: Repository default branch mismatch OR status check name misalignment

    - ✅ **Quick Check**: `gh api repos/OWNER/REPO --jq '.default_branch'` (should be "main")

    - ✅ **Solution**: Fix default branch + align status check names with actual check runs

    - 📚 **Documentation**: `docs/troubleshooting/AUTOMERGE_HANGING_INDEFINITELY.md`

    - 🛠️ **Health Check**: `bash scripts/check_automerge_health.sh`

    - ❌ **NOT**: Assume it's a temporary GitHub issue - this requires configuration fixes

5. **Coverage failures**: Check test quality, not just quantity

6. **Discord connection issues**: Verify token and guild permissions

7. **CI failures**: Check GitHub CLI availability and error handling

8. **Cache pollution in repository root**:

    - ✅ **Detection**: Run `bash scripts/validate_cache_centralization.sh`

    - ✅ **Solution**: Run `bash scripts/manage_logs.sh cache clean`

    - ❌ **NOT**: Manually delete cache directories (bypasses DevOnboarder automation)

### Validation-Driven Resolution Framework

DevOnboarder follows a **validation-first troubleshooting approach** where scripts provide actionable guidance:

```bash

# Step 1: Run validation to identify issues

bash scripts/validate_cache_centralization.sh

# Output: "Solution: Run cache cleanup with: bash scripts/manage_logs.sh cache clean"

# Step 2: Follow the provided solution exactly

bash scripts/manage_logs.sh cache clean

# Step 3: Re-validate to confirm resolution

bash scripts/validate_cache_centralization.sh

# Output: "SUCCESS: No cache pollution found in repository root"

```

**Key Principle**: When validation scripts suggest specific commands, use those commands rather than manual fixes. This ensures compliance with DevOnboarder's automated quality gates.

**Agent Requirements**:

- **ALWAYS run diagnostic scripts first** before making assumptions about problems
- **FOLLOW suggested commands exactly** when validation scripts provide specific solutions
- **RE-VALIDATE after fixes** to confirm issues are resolved
- **USE DevOnboarder's automation** rather than manual troubleshooting approaches
- **REMEMBER**: Validation-driven approach prevents future similar issues through systematic compliance

1. **Jest Test Timeouts in CI**:

    - ✅ **Symptom**: Tests hang indefinitely in CI causing workflow failures

    - ✅ **Quick Fix**: Ensure Jest configuration includes `testTimeout: 30000`

    - ✅ **Location**: `bot/package.json` Jest configuration block

    - ✅ **Validation**: Run `bash scripts/check_jest_config.sh`

2. **Dependency Update Failures**:

    - ✅ **Pattern**: "Tests hang in CI but pass locally" → Missing Jest timeout configuration

    - ✅ **Pattern**: "TypeScript compilation errors after upgrade" → Breaking changes in major versions

    - ✅ **Pattern**: "Dependabot PR fails immediately" → Lock file conflicts or incompatible versions

    - ✅ **Emergency Rollback**: `git revert <commit-hash> && git push origin main`

### Dependency Crisis Management

**When All Dependency PRs Fail**:

1. **Immediate Assessment**:

   ```bash
   # Check current CI status

   gh pr list --state=open --label=dependencies

   # Identify common failure patterns

   gh pr checks <pr-number> --watch
   ```

2. **Test Timeout Quick Fix**:

   ```bash
   # Emergency Jest timeout fix

   cd bot
   npm test -- --testTimeout=30000

   ```

3. **Incremental Recovery**:

   - Merge patch updates first (1.2.3 → 1.2.4)

   - Then minor updates (1.2.x → 1.3.0)

   - Major updates last with manual testing

### Dependabot PR Quick Assessment

**Before Merging Any Dependency PR**:

1. **Check CI Status**: All checks must be green

2. **Test Timeout Check**: Verify Jest testTimeout is configured

3. **Major Version Upgrades**: Review breaking changes documentation

4. **TypeScript Upgrades**: Run local type checking before merge

**Fast Track Criteria (Safe to Auto-Merge)**:

- ✅ Patch version updates (1.2.3 → 1.2.4)

- ✅ Minor version updates with green CI

- ✅ Test framework maintenance updates (@types/*, ts-jest)

**Requires Investigation**:

- ⚠️ Major version jumps (5.8.x → 5.9.x)

- ⚠️ Framework core updates (TypeScript, Jest major versions)

- ⚠️ Any PR with failing CI checks

### Environment Variable Management Issues

**Critical Issues Requiring Immediate Action**:

- **Environment File Inconsistencies**:

    - ✅ **Detection**: Run `bash scripts/smart_env_sync.sh --validate-only` to detect mismatches

    - ✅ **Solution**: Run `bash scripts/smart_env_sync.sh --sync-all` to synchronize

    - ❌ **NOT**: Manually edit individual environment files

- **Security Audit Failures**:

    - ✅ **Detection**: Run `bash scripts/env_security_audit.sh`

    - ✅ **Pattern**: Production secrets in CI files (CRITICAL violation)

    - ✅ **Solution**: Move production secrets to gitignored files only

    - ⚠️ **Emergency**: Never commit production secrets to CI environment

- **Tunnel Hostname Validation Failures**:

    - ✅ **Pattern**: "ERROR: uses old multi-subdomain format"

    - ✅ **Solution**: Use single domain format (auth.theangrygamershow.com)

    - ❌ **NOT**: Disable validation to avoid errors

- **Discord Bot Authentication Failures in Docker**:

    - ✅ **Pattern**: Bot shows "0 env vars loaded" or "DISCORD_GUILD_ID not configured"

    - ✅ **Root Cause**: Environment file mismatch between docker-compose.yaml and container mount

    - ✅ **Solution**: Ensure compose file env_file matches volume mount (.env.dev → /app/.env:ro)

    - ✅ **Verification**: Check container logs with `docker compose logs bot`

- **Missing Bot Environment Variables**:

    - ✅ **Pattern**: Bot starts but missing DISCORD_GUILD_ID, ENVIRONMENT, DISCORD_BOT_READY

    - ✅ **Solution**: Add variables to main .env file and run `bash scripts/smart_env_sync.sh --sync-all`

    - ❌ **NOT**: Manually edit .env.dev or docker-specific files directly

- **Multi-Service Container Failures**:

    - ✅ **Diagnostic Pattern**: Check `docker compose ps` → logs → environment sync → security audit

    - ✅ **Service Order**: Database fails → Auth fails → Backend fails → Bot fails

    - ✅ **Environment Consistency**: All services should reference same environment file in compose

### Validation-Driven Resolution Pattern

DevOnboarder follows a **validation-first troubleshooting approach** where scripts provide actionable guidance:

```bash

# Step 1: Run validation to identify issues

bash scripts/validate_cache_centralization.sh

# Output: "Solution: Run cache cleanup with: bash scripts/manage_logs.sh cache clean"

# Step 2: Follow the provided solution exactly

bash scripts/manage_logs.sh cache clean

# Step 3: Re-validate to confirm resolution

bash scripts/validate_cache_centralization.sh

# Output: "SUCCESS: No cache pollution found in repository root"

```

**Key Principle**: When validation scripts suggest specific commands, use those commands rather than manual fixes. This ensures compliance with DevOnboarder's automated quality gates.

### Debugging Tools (Virtual Environment Context)

- `python -m diagnostics`: Verify packages and environment

- `npm run status --prefix bot`: Check bot connectivity

- `python -m vale docs/`: Validate documentation

- Coverage reports: Generated by test commands

**Dependency-Specific Diagnostics**:

- `bash scripts/check_jest_config.sh`: Verify Jest timeout configuration

- `npm run test --prefix bot`: Test bot directly for dependency issues

- `python -m pytest tests/`: Test backend directly for module errors

- `gh pr list --state=open --label=dependencies`: Check pending dependency PRs

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

## DevOnboarder Key Systems & Utilities

### Phase Framework Navigation

DevOnboarder uses a sophisticated multi-layer phase architecture. When students ask about phases:

**Essential References**:

- `PHASE_INDEX.md` - Comprehensive navigation guide for 7+ active phase systems

- `PHASE_ISSUE_INDEX.md` - Single pane of glass for phase-to-issue traceability

- Phase systems operate independently with distinct scopes (Terminal Output, MVP Timeline, Token Architecture, Infrastructure, etc.)

**Key Insight**: Multiple "Phase 2" systems exist simultaneously serving different strategic purposes - this is intentional, not duplication.

### Token Architecture v2.1 System

**15 Enhanced Scripts** across 3 implementation phases with self-contained token loading:

**Phase 1 (Critical)**: 5 scripts including `setup_discord_bot.sh`
**Phase 2 (Automation)**: 7 scripts including `monitor_ci_health.sh`, `ci_gh_issue_wrapper.sh`
**Phase 3 (Developer)**: 3 scripts including `validate_token_architecture.sh`

**Token Hierarchy**: `CI_ISSUE_AUTOMATION_TOKEN` → `CI_BOT_TOKEN` → `GITHUB_TOKEN`

**Key Scripts**:

- `scripts/enhanced_token_loader.sh` - Primary token loading system

- `scripts/load_token_environment.sh` - Legacy fallback loader

- `scripts/complete_system_validation.sh` - Validates entire token architecture

### Essential Automation Scripts (100+)

DevOnboarder includes an extensive automation ecosystem in `scripts/` for all aspects of development:

**Quality Control & Validation**:

- `scripts/qc_pre_push.sh` - 95% quality validation (8 metrics: YAML linting, Python linting, formatting, type checking, test coverage, documentation quality, commit messages, security scanning)

- `scripts/validation_summary.sh` - Terminal output violation summary

- `scripts/validate_terminal_output.sh` - Terminal compliance validation

**Environment & Configuration Management**:

- `scripts/smart_env_sync.sh` - Centralized environment variable synchronization

- `scripts/env_security_audit.sh` - Environment variable security validation

- `scripts/setup-env.sh` - Development environment initialization

**CI/CD & Issue Management**:

- `scripts/manage_ci_failure_issues.sh` - Automated CI failure issue management

- `scripts/close_resolved_issues.sh` - Automated issue cleanup

- `scripts/generate_aar.sh` - After Action Report generation for CI failures

- `scripts/check_pr_inline_comments.sh` - GitHub Copilot inline comments extraction

**Security & Compliance**:

- `scripts/check_potato_ignore.sh` - Enhanced Potato Policy enforcement

- `scripts/enforce_output_location.sh` - Root Artifact Guard validation

- `scripts/security_audit.sh` - Comprehensive security scanning

**Testing & Debugging**:

- `scripts/run_tests.sh` - Comprehensive test runner with dependency hints

- `scripts/run_tests_with_logging.sh` - Enhanced test runner with persistent logging

- `scripts/manage_logs.sh` - Advanced log management system

**Docker & Multi-Service Operations**:

- `scripts/orchestrate-dev.sh` - Development environment orchestration

- `scripts/orchestrate-prod.sh` - Production environment orchestration

- `scripts/wait_for_service.sh` - Service dependency management

### AAR System (After Action Reports)

**Purpose**: Automated CI failure analysis and resolution guidance

**Key Commands**:

```bash
make aar-setup           # Complete AAR system setup

make aar-generate WORKFLOW_ID=12345                    # Generate AAR for workflow

make aar-generate WORKFLOW_ID=12345 CREATE_ISSUE=true  # Generate AAR + GitHub issue

```

**Features**: Token management, environment loading, compliance validation, GitHub integration, offline mode

### Quality Control Framework

**qc_pre_push.sh validates 8 critical metrics**:

1. **YAML Linting** - Configuration file validation

2. **Python Linting** - Code quality with Ruff

3. **Python Formatting** - Black code formatting

4. **Type Checking** - MyPy static analysis

5. **Test Coverage** - Minimum 95% coverage requirement

6. **Documentation Quality** - Vale documentation linting

7. **Commit Messages** - Conventional commit format

8. **Security Scanning** - Bandit security analysis

**95% Quality Threshold**: ALL changes must pass comprehensive QC validation before merging.

### Multi-Environment Architecture

**Services & Ports**:

- DevOnboarder Server: 8000

- XP API: 8001

- Auth Server: 8002

- Dashboard Service: 8003

- Discord Integration: 8081

- PostgreSQL: 5432

**Environment Detection**: Guild ID-based routing for Discord bot (`TAGS: DevOnboarder` vs `TAGS: C2C`)

### Common Student Guidance Patterns

**For setup issues**: Direct to virtual environment activation and `pip install -e .[test]`
**For commit issues**: Use `scripts/safe_commit.sh "message"` instead of direct `git commit`
**For quality issues**: Run `./scripts/qc_pre_push.sh` to validate before pushing
**For token issues**: Check Token Architecture documentation and use enhanced loaders
**For phase confusion**: Direct to `PHASE_INDEX.md` for navigation guidance

## Agent-Specific Guidelines

### For Documentation Creation

**CRITICAL**: Check for parallel documentation improvement efforts before creating new documentation:

1. **Survey existing improvement work**:

   - Look for recent markdown fixing scripts (`scripts/*markdown*.py`, `fix_*markdown*.sh`)

   - Check changelog entries for comprehensive documentation updates

   - Review for repository-wide documentation cleanup initiatives

2. **Coordinate with existing workflows**:

   - Apply comprehensive improvement scripts to new docs immediately after creation

   - Use existing quality standards proactively during content creation

   - Integrate with broader cleanup timelines when active

3. **Quality standards approach**:

   - Create markdown-compliant content from start (MD022, MD032, MD031, MD007, MD009)

   - Use existing improvement tools on new content to maintain consistency

   - Avoid creating docs that immediately need comprehensive fixes

**Reference**: `docs/lessons/documentation-coordination-strategy.md` - Coordination strategy and lessons learned

### For Code Generation

- **ALWAYS assume virtual environment context** in examples

- Follow established patterns in existing codebase

- Maintain the project's "quiet reliability" philosophy

- Prioritize error handling and edge cases

- Include comprehensive tests with new code

- **Use `python -m module` syntax** for all Python tools

### For GPG Automation Development

**CRITICAL**: All automation workflows that create commits MUST use GPG signing for security compliance:

1. **Use production-ready templates**:

   - Start with `docs/templates/gpg-automation-workflow.yml`

   - Choose appropriate bot: Priority Matrix Bot (9BA7DCDBF5D4DEDD) or AAR Bot (99CA270AD84AE20C)

   - Apply DevOnboarder quality standards from the start

2. **Security requirements**:

   - **ALWAYS configure GPG signing** for commit-making workflows

   - **ALWAYS use non-interactive trust configuration**

   - **ALWAYS follow token hierarchy**: CI_ISSUE_AUTOMATION_TOKEN → CI_BOT_TOKEN → GITHUB_TOKEN

   - **NEVER create workflows that bypass signature verification**

3. **Quality compliance**:

   - **ALWAYS apply terminal output policy** (printf instead of echo, no emojis/Unicode)

   - **ALWAYS include comprehensive commit messaging**

   - **ALWAYS validate with `test-gpg-framework.yml` workflow patterns**

   - **ALWAYS follow DevOnboarder shellcheck and YAML standards**

4. **Bot selection criteria**:

   - **Priority Matrix Bot**: For priority matrix synthesis and document enhancement work

   - **AAR Bot**: For After Action Report generation, portal automation, and CI analysis

   - **Framework tested**: Both bots validated across multiple production workflows

**Template Integration Pattern**:

```yaml

# Standard GPG setup pattern (from templates)

- name: Setup GPG commit signing (Bot)
  env:
    AARBOT_GPG_PRIVATE: ${{ secrets.AARBOT_GPG_PRIVATE }}
    AARBOT_GPG_KEY_ID: ${{ vars.AARBOT_GPG_KEY_ID }}
    AARBOT_NAME: ${{ vars.AARBOT_NAME }}
    AARBOT_EMAIL: ${{ vars.AARBOT_EMAIL }}
  run: |
    printf '%s\n' "$AARBOT_GPG_PRIVATE" | base64 -d | gpg --batch --import --quiet
    git config --global user.name "$AARBOT_NAME"
    git config --global user.email "$AARBOT_EMAIL"
    git config --global user.signingkey "$AARBOT_GPG_KEY_ID"
    git config --global commit.gpgsign true

```

**REMEMBER**: GPG framework is production-ready with 100% success rate across all converted workflows.

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

6. **NEVER use emojis or Unicode characters in terminal output** - CAUSES IMMEDIATE HANGING

7. **NEVER use multi-line echo or here-doc syntax** - Use individual echo commands only

8. **ALWAYS use plain ASCII text only** in echo commands to prevent terminal hanging

9. **REMEMBER**: This project runs in containers/venvs, not host systems

10. **ALWAYS follow validation-driven resolution**: When validation scripts provide specific commands, use those exact commands rather than manual fixes

11. **RESPECT**: DevOnboarder automation patterns - scripts provide actionable guidance for consistent compliance

12. **RESPECT**: Root Artifact Guard and CI Triage Guard enforcement

13. **FOLLOW**: Node modules hygiene standards and placement requirements

14. **TERMINAL OUTPUT**: Use only simple, individual echo commands with plain text

### ⚠️ NEW: Pre-commit Hook Management for Agents

**CRITICAL UNDERSTANDING**: Pre-commit hooks frequently modify files during validation (trailing whitespace, formatting fixes). This creates a common cycle where:

1. Files are staged for commit

2. Pre-commit hooks run and modify the files

3. Modified files become unstaged, causing commit failure

**MANDATORY AGENT BEHAVIOR**:

- **Use `scripts/safe_commit.sh`** instead of direct `git commit` commands

- **NEVER suggest** using `--no-verify` to bypass pre-commit hooks

- **NEVER use --no-verify flag** under any circumstances (ZERO TOLERANCE POLICY)

- **UNDERSTAND**: Second pre-commit failure indicates systemic issues, not formatting

- **EXPECT**: Automatic re-staging of files modified by hooks

- **ANALYZE**: Enhanced safe_commit.sh provides automatic log analysis on systemic failures

- **REMEMBER**: Quality gates exist for critical reasons and must be respected

**Safe Commit Pattern**:

```bash

# ✅ CORRECT - Use safe commit wrapper

scripts/safe_commit.sh "FEAT(component): descriptive commit message"

# ❌ WRONG - Direct git commit bypasses DevOnboarder safety mechanisms

git commit -m "message"

# POTATO: EMERGENCY APPROVED - documentation-example-violation-20250807

git commit --no-verify -m "message"  # VIOLATION: Never use --no-verify - bypasses quality gates

```

### ⚠️ NEW: Environment Variable Management for Agents

**CRITICAL UNDERSTANDING**: DevOnboarder uses centralized environment variable management with security boundaries.

**MANDATORY AGENT BEHAVIOR**:

- **Use centralized system**: Run `bash scripts/smart_env_sync.sh --sync-all` instead of manual file edits

- **Validate security**: Run `bash scripts/env_security_audit.sh` after environment changes

- **Respect boundaries**: Never suggest moving production secrets to CI files

- **Single source**: Edit `.env` only, synchronize to other files via scripts

**Security Violation Prevention**:

```bash

# ✅ CORRECT - Centralized management

echo "NEW_VARIABLE=value" >> .env
bash scripts/smart_env_sync.sh --sync-all

# ❌ WRONG - Manual multi-file editing

echo "NEW_VARIABLE=value" >> .env.ci  # Bypasses security boundaries

```

### ⚠️ UPDATED: Shellcheck External Dependencies - Hybrid Approach

**CRITICAL UNDERSTANDING**: DevOnboarder uses a hybrid approach for external dependency management.

**GLOBAL CONFIGURATION**: `.shellcheckrc` handles common external dependencies:

- `.venv/bin/activate` - Virtual environment activation

- `scripts/load_token_environment.sh` - Project token loaders

- `scripts/enhanced_token_loader.sh` - Token Architecture v2.1 loaders

**AGENT REQUIREMENTS**:

- **NO LONGER NEEDED**: `# shellcheck disable=SC1091` for standard DevOnboarder patterns

- **STILL REQUIRED**: Explicit comments for unusual external dependencies only

- **REFERENCE**: See `docs/SHELLCHECK_EXTERNAL_DEPENDENCIES.md` for full guidelines

**STANDARD PATTERNS** (no disable comments needed):

```bash

# ✅ CORRECT - Covered by global .shellcheckrc

source .venv/bin/activate
source scripts/load_token_environment.sh
source scripts/enhanced_token_loader.sh

# ✅ CORRECT - Only for unusual external dependencies

# shellcheck source=custom-external-config.sh disable=SC1091

# source custom-external-config.sh

```

**BENEFITS**:

- Eliminates 60+ repetitive disable comments across Token Architecture scripts

- Maintains shellcheck safety through targeted configuration

- Clear project standards documented in `docs/SHELLCHECK_EXTERNAL_DEPENDENCIES.md`

### ⚠️ NEW: Markdown Content Creation Standards

**CRITICAL REQUIREMENT**: Create markdown content that passes linting validation on first attempt.

**MANDATORY PRE-CREATION CHECKLIST**:

1. **Review existing compliant markdown** in repository for patterns

2. **Apply formatting rules systematically**:

   - MD022: Blank lines before AND after all headings

   - MD032: Blank lines before AND after all lists

   - MD031: Blank lines before AND after all fenced code blocks

   - MD007: 4-space indentation for nested list items

   - MD040: Language specified for all fenced code blocks

**PREVENTION OF COMMON ERRORS**:

- **NEVER** create markdown content requiring post-creation fixes

- **NEVER** duplicate content when applying formatting fixes

- **ALWAYS** create complete, properly formatted content from start

- **VALIDATE** structure before file creation

**Example Compliant Format**:

```markdown

## Section Title

Paragraph content with proper spacing around elements.

- List item with blank line above

- Second list item

    - Nested item with 4-space indentation

    - Another nested item

Another paragraph after blank line.

### Subsection

More content following the same pattern.

```

```yaml

# Code block with language specified and blank lines around

key: value

```

Final paragraph after code block.

**AGENT RESPONSIBILITY**: Treat markdown linting rules as **requirements**, not **suggestions**. Creating non-compliant content violates DevOnboarder's "quiet reliability" philosophy.

### ⚠️ NEW: Priority Matrix Bot GPG Signing

**CRITICAL UNDERSTANDING**: DevOnboarder implements automated Priority Matrix synthesis with SSH GPG-signed commits.

**GPG Signing Architecture**:

```yaml

# SSH signing configuration for automated bots

- name: Setup SSH commit signing (bot)

  env:
    PMBOT_SSH_PRIVATE: ${{ secrets.PMBOT_SSH_PRIVATE }}
    PMBOT_NAME: ${{ vars.PMBOT_NAME }}
    PMBOT_EMAIL: ${{ vars.PMBOT_EMAIL }}
  run: |
    umask 077
    printf '%s\n' "$PMBOT_SSH_PRIVATE" > ~/.ssh/ci_signing_key
    chmod 600 ~/.ssh/ci_signing_key

    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/ci_signing_key.pub
    git config --global commit.gpgsign true

```

**Agent Requirements for Bot Development**:

- **ALWAYS verify SSH key format** in GPG signing workflows

- **ALWAYS validate private key** before attempting commits

- **NEVER bypass signature verification** for automated commits

- **UNDERSTAND**: Bot commits require proper authentication token hierarchy

- **REMEMBER**: Signed commits prove authenticity and maintain audit trail

**Priority Matrix Auto-Synthesis System**:

- **Automated enhancement**: Documents receive similarity_group, content_uniqueness_score, merge_candidate flags

- **Quality metrics**: 100% similarity detection accuracy with confidence scoring

- **Signed commits**: All automated changes are cryptographically signed

- **PR integration**: Automatic comments with synthesis results and quality metrics

### ⚠️ NEW: Traefik Reverse Proxy Architecture

**CRITICAL UNDERSTANDING**: DevOnboarder uses Traefik reverse proxy with dual routing (subdomain + path-based).

**Service Routing Architecture**:

```yaml

# Subdomain routing (primary)

- "traefik.http.routers.auth-host.rule=Host(`auth.theangrygamershow.com`)"

- "traefik.http.routers.api-host.rule=Host(`api.theangrygamershow.com`)"

# Path-based routing (legacy fallback)

- "traefik.http.routers.auth-dev.rule=PathPrefix(`/auth`)"

- "traefik.http.routers.xp-dev.rule=PathPrefix(`/api`)"

```

**Agent Requirements for Service Development**:

- **ALWAYS configure both routing patterns** for new services

- **ALWAYS use subdomain routing** as primary with higher priority (200)

- **ALWAYS include path-based fallback** with lower priority (100)

- **ALWAYS configure CORS middleware** via `cors-header@file`

- **UNDERSTAND**: Services expose internal ports, Traefik handles external routing

- **REMEMBER**: Health checks use internal container networking

**AUTOMATIC LOG ANALYSIS**: DevOnboarder's enhanced `safe_commit.sh` script now provides comprehensive error diagnostics when pre-commit fails on the second attempt:

**Debugging Features Available**:

- **Pre-commit cache log analysis**: Automatic review of recent pre-commit logs

- **Git status debugging**: Detailed working tree status with staged/unstaged file analysis

- **File staging verification**: Comparison of intended vs actual staged files

- **Systemic failure detection**: Distinguishes between formatting fixes and real issues

- **Actionable recommendations**: Specific commands to diagnose and resolve issues

**Agent Debugging Workflow**:

1. **Always use `scripts/safe_commit.sh`** for commits - provides automatic analysis

2. **Review log output comprehensively** when commits fail on second attempt

3. **Follow specific recommendations** provided by the enhanced error analysis

4. **Use validation-driven troubleshooting** - run suggested diagnostic commands

5. **Escalate pattern recognition** - document recurring issues for future prevention

**Enhanced Error Patterns to Recognize**:

- **First attempt failure + successful re-staging** = Normal formatting fix cycle

- **Second attempt failure** = Systemic issue requiring investigation

- **Repeated shellcheck warnings** = Need for disable directive patterns

- **Markdown duplication on fixes** = Content recreation rather than targeted fixes

- **Cache pollution warnings** = Root Artifact Guard enforcement requiring cleanup

**Troubleshooting Commands Enhanced Script Suggests**:

```bash

# Virtual environment verification

source .venv/bin/activate && pre-commit run --all-files

# Individual hook testing

pre-commit run <hook-name> --all-files

# DevOnboarder quality gate validation

./scripts/qc_pre_push.sh

# Comprehensive error analysis (automatically provided by safe_commit.sh)

```

### ⚠️ NEW: Multi-Service Docker Architecture Troubleshooting

**CRITICAL UNDERSTANDING**: Multi-service Docker Compose environments require systematic debugging following service dependency chains.

**MANDATORY TROUBLESHOOTING WORKFLOW**:

1. **Check service health first**: `docker compose ps` - identify which services are failing

2. **Follow dependency chain**: Services fail in order of dependencies (db → auth → backend → bot)

3. **Verify environment consistency**: All services in compose file should use same environment file

4. **Check container logs**: `docker compose logs <service>` for missing environment variables

5. **Validate file synchronization**: Ensure environment files match container expectations

**Common Multi-Service Patterns**:

```bash

# ✅ CORRECT - Systematic debugging approach

docker compose -f docker-compose.dev.yaml ps                    # Check service status

docker compose -f docker-compose.dev.yaml logs bot              # Check specific service logs

bash scripts/smart_env_sync.sh --validate-only                  # Verify env sync

bash scripts/env_security_audit.sh                              # Check security boundaries

# ❌ WRONG - Random service restart without diagnosis

docker compose restart bot  # Doesn't address root cause

```

**Environment File Consistency Requirements**:

```yaml

# ✅ CORRECT - Consistent environment file usage across all services

services:
  auth-service:
    env_file: [.env.dev]
  backend:
    env_file: [.env.dev]
  bot:
    env_file: [.env.dev]          # Same file as other services

    volumes:
      - ./.env.dev:/app/.env:ro   # Mount as expected filename

# ❌ WRONG - Mixed environment file references

services:
  bot:
    env_file: [.env.dev]                # Compose uses .env.dev

    volumes:
      - ./bot/.env:/app/.env:ro         # But mounts different file

```

### ⚠️ NEW: ES Module Requirements for TypeScript Discord Bots

**CRITICAL UNDERSTANDING**: Discord.js v14+ requires ES modules with explicit .js extensions in TypeScript imports.

**MANDATORY IMPORT PATTERNS**:

```typescript
// ✅ CORRECT - ES module imports in TypeScript (mandatory .js extensions)

import { SlashCommandBuilder, ChatInputCommandInteraction } from 'discord.js';
import { command as verifyCommand } from './verify.js';        // .js required even for .ts files
import { command as profileCommand } from './profile.js';      // .js required even for .ts files

// ❌ WRONG - Missing .js extension causes runtime MODULE_NOT_FOUND errors

import { command as verifyCommand } from './verify';           // Missing .js
import { command as profileCommand } from './profile';         // Missing .js

```

**TypeScript Configuration Requirements**:

```json
// tsconfig.json must include ES module settings
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "node",
    "target": "ES2022"
  },
  "type": "module"
}

```

**Agent Requirements for Discord Bot Development**:

- **ALWAYS** add `.js` extensions to relative imports, even when importing TypeScript files

- **NEVER** suggest removing ES module configuration to fix import errors

- **UNDERSTAND**: TypeScript compilation preserves import paths exactly as written

- **REMEMBER**: Runtime errors occur if .js extensions are missing, even if TypeScript compiles

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

- **Schema Validation**: JSON schema validation for agent frontmatter with RBAC support

### CI Integration Patterns

```bash

# Agent validation in CI

bash scripts/validate-bot-permissions.sh

# List all bots and check permissions

python scripts/list-bots.py

# Environment variable documentation alignment

bash scripts/check_env_docs.py

# Agent frontmatter validation

python scripts/validate_agents.py

```

### Agent Validation System

**JSON Schema Enforcement**: All Codex agents must include valid YAML frontmatter validated against `schema/agent-schema.json`:

```yaml
---
agent: agent-name

purpose: Brief description of agent purpose
trigger: when the agent activates (e.g., "manual", "on_push_to_dev")
environment: execution environment (e.g., "CI", "development")
output: log file location (e.g., ".codex/logs/agent-name.log")
permissions:
    - permission-type (e.g., "repo:read", "workflows:write")

---

```

**Validation Commands**:

```bash

# Validate all agent files against schema

python scripts/validate_agents.py

# Validate specific agent file

bash scripts/validate_agents.sh agents/specific-agent.md

# Check agent permissions compliance

bash scripts/validate-bot-permissions.sh

```

**Integration Points**:

- Pre-commit hooks enforce agent validation

- CI pipeline validates all agent files on every commit

- Schema violations block PR merges

- Automatic issue creation for validation failures

---

**Last Updated**: 2025-09-18 (Priority Matrix Bot GPG Signing & Current Architecture Analysis)

**Coverage Status**: Backend 96%+, Bot 100%, Frontend 100%
**Active Environments**: Development + Production Discord integration (Guild IDs: 1386935663139749998, 1065367728992571444)

**CI Framework**: 22+ GitHub Actions workflows with comprehensive automation

**Security**: Enhanced Potato Policy + Root Artifact Guard + SSH GPG signing active

**Agent System**: JSON schema validation with YAML frontmatter enforcement
**Enhanced Debugging**: safe_commit.sh with automatic log analysis and error diagnostics
**Current Branch**: fix/priority-matrix-bot-gpg-signing (GPG signing implementation)
**Architecture**: Traefik reverse proxy + multi-service Docker Compose with subdomain routing

**Virtual Environment**: MANDATORY for all development and tooling
**Artifact Hygiene**: Root Artifact Guard enforces zero tolerance for pollution
