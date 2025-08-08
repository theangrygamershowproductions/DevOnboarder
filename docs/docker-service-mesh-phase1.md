# Docker Service Mesh Phase 1: Tiered Network Architecture

## Implementation Overview

This document outlines the Docker Service Mesh Phase 1 implementation, establishing a semantic three-tier network architecture that provides security boundaries and clear service communication patterns.

## Network Architecture

### Tier 1: auth_tier

**Purpose**: Authentication and authorization services

**Services**:

- auth-service (Port 8002)
- Database (Port 5432) - Shared with data_tier for auth data

**Security**: High isolation, controls access to all other tiers

### Tier 2: api_tier

**Purpose**: API services and business logic

**Services**:

- backend (XP API - Port 8001)
- discord-integration (Port 8081)
- dashboard-service (Port 8003)

**Security**: Medium isolation, cannot directly access data_tier

### Tier 3: data_tier

**Purpose**: Data persistence and storage

**Services**:

- db (PostgreSQL - Port 5432)

**Security**: Highest isolation, only accessible via auth_tier

### Edge Services (External Access)

**Purpose**: External facing services

**Services**:

- traefik (Reverse Proxy)
- frontend (React App - Port 3000)
- cloudflare-tunnel (External connectivity)

## Network Communication Rules

1. **auth_tier** ↔ **data_tier**: Direct access allowed
2. **api_tier** → **auth_tier**: Authentication requests only
3. **api_tier** ❌ **data_tier**: No direct access (must go through auth_tier)
4. **Edge** → **api_tier**: External requests via reverse proxy
5. **Edge** → **auth_tier**: Authentication flows only

## Access Patterns

### Local Development Access (Default)

**✅ WORKING - Local Access:**

- `http://localhost` - Frontend via Traefik (Priority 1)
- `http://localhost/auth` - Auth service via path routing (Priority 100)
- `http://localhost/discord` - Discord integration via path routing (Priority 100)
- `http://localhost/dashboard` - Dashboard service via path routing (Priority 100)
- `http://localhost:8090` - Traefik dashboard
- Direct service ports for debugging (health checks only)

**🔧 Local Architecture Benefits:**

- No external dependencies (no tunnel/domain setup required)
- Immediate development startup with `docker compose up`
- Path-based routing eliminates subdomain complexity
- Resource efficient - single stack handles all routing

### External Production Access (Optional)

**🌐 EXTERNAL ACCESS (Via Cloudflare Tunnel):**

- `auth.theangrygamershow.com` - Auth service (Priority 200)
- `discord.theangrygamershow.com` - Discord integration (Priority 200)
- `dashboard.theangrygamershow.com` - Dashboard service (Priority 200)
- `theangrygamershow.com` - Main frontend (Priority 200)

**🔧 External Access Activation:**

```bash
# Activate Cloudflare tunnel for external access
docker compose --profile tunnel up -d cloudflare-tunnel

# Verify tunnel health
docker compose logs cloudflare-tunnel
```

#### Important: Dual Routing System

The configuration uses **priority-based routing** where:

- **Host-based routes** (Priority 200) take precedence for external domains
- **Path-based routes** (Priority 100) handle local development
- This prevents conflicts and allows both access patterns simultaneously

### Resource Considerations

**Why Single Stack is Recommended:**

- Running dual stacks (local + external) causes resource overhead
- Docker networks can conflict with duplicate service names
- Single stack with dual routing covers both use cases efficiently
- Local development covers 95% of daily workflow needs

## Implementation Benefits

- **Security**: Clear network boundaries prevent unauthorized data access
- **Observability**: Network-level tracking of service communication
- **Scalability**: Independent scaling of service tiers
- **Maintenance**: Easier debugging with semantic network names
- **Compliance**: Network-level audit trails for security requirements

## Success Criteria

- ✅ All services operational in correct network tiers
- ✅ Service communication follows tier rules
- ✅ Health checks pass for all services
- ✅ Network contracts enforceable via validation scripts
- ✅ Zero disruption to existing functionality

## Files Modified

- `docker-compose.dev.yaml` - Updated with tiered networks
- `docker-compose.prod.yaml` - Updated with tiered networks
- `scripts/validate_network_contracts.sh` - New validation script
- `scripts/test_service_mesh.sh` - New testing script

## Rollback Plan

If issues arise, rollback involves:

1. Restore single `devonboarder_network` configuration
2. Remove tiered network references
3. Restart services with original networking

Network changes are backwards compatible and non-breaking.
