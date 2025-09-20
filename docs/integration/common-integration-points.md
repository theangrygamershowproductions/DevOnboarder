---
author: TAGS Engineering

codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Feature addition workflows, bot command development, API endpoint patterns,
  and integration examples
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:

- service-integration-patterns.md

- development-workflow.md

similarity_group: integration-standards
source: .github/copilot-instructions.md
status: active
tags:

- devonboarder

- integration-points

- feature-development

- api-endpoints

- workflows

title: DevOnboarder Common Integration Points
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Common Integration Points

## 1. Adding New Features

1. **Setup environment**: `source .venv/bin/activate`

2. Create feature branch from `main`

3. Install dependencies: `pip install -e .[test]`

4. Implement with tests (maintain coverage)

5. Update documentation

6. Test in development environment

7. Submit PR with template checklist

8. Ensure CI passes before merge

## Key CLI Commands

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

## 2. Bot Command Development

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

## 3. Frontend Integration Patterns

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

## 4. API Endpoint Development

```python

# FastAPI endpoint with proper documentation

@app.get("/api/user/status", response_model=UserStatus)
async def get_user_status(user_id: int) -> UserStatus:
    """Get user onboarding status.

    Returns user's current onboarding progress and level.
    """
    # Implementation with proper error handling

```

## 5. Key Integration Points

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
