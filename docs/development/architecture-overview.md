---
author: "TAGS Engineering"
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: 2025-09-11
description: "Comprehensive architecture guide covering TAGS stack integration, multi-service"

document_type: standards
merge_candidate: false
project: core-instructions
related_modules: 
similarity_group: architecture-design
source: .github/copilot-instructions.md
status: active
tags: 
title: "DevOnboarder Architecture Overview"

updated_at: 2025-10-27
visibility: internal
---

# DevOnboarder Architecture Overview

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

## Core Services

- **Backend**: Python 3.12  FastAPI  SQLAlchemy (Port 8001)

- **Discord Bot**: TypeScript  Discord.js (Port 8002) - **DevOnboader#3613** (ID: 1397063993213849672)

- **Frontend**: React  Vite  TypeScript (Port 8081)

- **Auth Service**: FastAPI  JWT  Discord OAuth (Port 8002)

- **XP System**: Gamification API with user levels and contributions tracking

- **Dashboard Service**: FastAPI script execution and CI troubleshooting (Port 8003)

- **Discord Integration**: OAuth linking and role management (Port 8081)

- **Feedback Service**: User feedback collection and analytics

- **Database**: PostgreSQL (production), SQLite (development)

## Multi-Environment Setup

- **Development**: `TAGS: DevOnboarder` (Guild ID: 1386935663139749998)

- **Production**: `TAGS: C2C` (Guild ID: 1065367728992571444)

## Service Discovery Pattern

All FastAPI services follow a consistent pattern for health checks and CORS:

```python

# Standard service creation pattern (src/llama2_agile_helper/api.py, src/xp/api/__init__.py)

def create_app()  FastAPI:
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
    def health()  dict[str, str]:
        return {"status": "ok"}

```

## Language Version Requirements

DevOnboarder enforces specific language versions via `.tool-versions`:

- **Python**: 3.12 (MANDATORY - tests only run on 3.12)

- **Node.js**: 22

- **Ruby**: 3.2.3, **Rust**: 1.88.0, **Go**: 1.24.4

- **Bun**: 1.2.14, **Java**: 21, **Swift**: 6.1

Install with `mise install` or `asdf install` to match exactly.
