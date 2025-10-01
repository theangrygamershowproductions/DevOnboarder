# GitHub Copilot Instructions for DevOnboarder

## Project Overview

DevOnboarder is a multi-service onboarding automation platform with FastAPI bac### Development Workflow

### Environment Setup

```bash
# 1. Feature branch from main (MANDATORY)
git checkout main && git pull
git checkout -b feat/descriptive-feature-name

# 2. Virtual environment (MANDATORY - enforced by safe commit wrapper)
source .venv/bin/activate

# 3. Install dependencies
pip install -e .[test]
npm ci --prefix bot
npm ci --prefix frontend

# 4. QC validation (MANDATORY - enforced by safe commit wrapper)
./scripts/qc_pre_push.sh  # 95% quality threshold validation

# 5. Safe commits only (MANDATORY - comprehensive validation)
./scripts/safe_commit.sh "FEAT(component): description"
```eact frontend, and PostgreSQL database. Services are orchestrated via Docker Compose with Traefik reverse proxy.

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

**Use safe commit wrapper (MANDATORY - includes comprehensive validation):**

```bash
./scripts/safe_commit.sh "feat(component): description"  # NEVER use git commit directly
```

**Safe commit wrapper now enforces:**

- ✅ Branch protection (prevents main branch commits)
- ✅ Commit message format validation (uppercase TYPE required)
- ✅ Mandatory QC validation (95% quality threshold)
- ✅ Terminal output compliance (ZERO TOLERANCE policy)
- ✅ Forbidden file detection (`Potato.md`, `*.env`, `*.pem`, `*.key`)
- ✅ Emoji usage detection in committed files
- ✅ Virtual environment activation verification

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

### Error Prevention Patterns

**Automated validations enforced by safe commit wrapper:**

- **Forbidden File Detection**: Prevents commits of sensitive files:
    - `Potato.md` (SSH keys and setup)
    - `*.env` (environment variables)
    - `*.pem`, `*.key` (private keys)
    - `auth.db` (authentication database)

- **Emoji Usage Detection**: ZERO TOLERANCE policy enforcement:
    - Scans all committed files (`.md`, `.txt`, `.sh`, `.py`) for emoji usage
    - Blocks commits containing forbidden emojis

- **Terminal Output Validation**: Prevents forbidden echo patterns in scripts:
    - Emojis in echo statements
    - Variable expansion in echo (`echo "$VAR"`)
    - Command substitution in echo (`echo "$(cmd)"`)
    - Multi-line echo with `-e` flag

- **Branch Protection**: Prevents direct commits to `main` branch entirely

### Enhanced Potato Policy

**Protected sensitive files - NEVER expose:**

- `Potato.md` - SSH keys and setup
- `*.env` - Environment variables
- `*.pem`, `*.key` - Private keys

**Validation:** `.gitignore`, `.dockerignore`, `.codespell-ignore` must contain "Potato" entries

## Development Workflow

### Development Environment Setup

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

**Conventional format required (ENFORCED by safe commit wrapper):**

```markdown
TYPE(scope): description

Types: FEAT, FIX, DOCS, STYLE, REFACTOR, TEST, CHORE, SECURITY, BUILD, REVERT, PERF, CI, OPS, WIP, INIT, TAG, POLICY, HOTFIX, CLEANUP

Examples:
- FEAT(auth): add JWT validation endpoint
- FIX(bot): resolve Discord connection timeout
- CHORE(ci): update workflow dependencies
- PERF(auth): optimize JWT token validation
- CI(actions): add automated dependency updates
- CLEANUP(deps): remove unused dependencies

**Critical Notes:**
- TYPE must be UPPERCASE (e.g., FEAT, not feat)
- Scope is mandatory (e.g., (auth), (ci))
- Safe commit wrapper validates format before allowing commits

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
    "extensionsToTreatAsEsm": [".ts]",
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

### Environment Validation

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

# When safe commit wrapper blocks commits
./scripts/safe_commit.sh --help  # See validation requirements
source .venv/bin/activate        # Ensure virtual environment
./scripts/qc_pre_push.sh         # Run QC validation manually
```

### Enhanced Error Prevention

```bash
# When terminal output validation fails
printf "Status: %s\n" "$VAR"      # Use printf instead of echo
echo "Task completed successfully"  # Plain echo without variables/emojis
```

### When Environment is Broken

```bash
# Complete environment reset
make clean && make deps && make up
```

---

**Last Updated**: 2025-09-30
**Coverage**: Backend 96%+, Bot 100%, Frontend 100%
**Services**: Auth (8002), XP (8001), Discord Integration (8081), Dashboard (8003)
**Architecture**: FastAPI + Discord.js + React + PostgreSQL + Traefik

**Virtual Environment**: MANDATORY for all development and tooling
**Safe Commit Wrapper**: ENFORCED - Comprehensive validation and error prevention
**Artifact Hygiene**: Root Artifact Guard enforces zero tolerance for pollution
