---
similarity_group: api-api
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
updated_at: 2025-10-27
---
# API Documentation

## Service APIs

### Authentication Service (Port 8002)

- **Health Check**: `GET /health`
- **Discord Login**: `GET /login/discord`
- **JWT Validation**: `POST /validate`

### XP API Service (Port 8001)

- **Health Check**: `GET /health`
- **User Contribution**: `POST /api/user/contribute`
- **XP Calculation**: `GET /api/user/xp`

### Discord Integration (Port 8081)

- **Bot Health**: `GET /health`
- **Discord Events**: WebSocket integration
- **Multi-guild Routing**: Dev/Prod environment detection

## API Contracts

See [Service API Contracts](../service-api-contracts.md) for detailed specifications.

## Authentication Flow

1. Frontend redirects to auth service `/login/discord`
2. Auth service exchanges code for Discord token
3. JWT issued with user session data
4. Frontend stores JWT in localStorage

## Cross-Service Communication

```python
# XP service depends on auth service
@router.post("/api/user/contribute")
def contribute(data: dict, current_user = Depends(auth_service.get_current_user)):
    # Implementation uses authenticated user
```

## OpenAPI Documentation

See [OpenAPI Specification](../openapi.md) for interactive API documentation.
