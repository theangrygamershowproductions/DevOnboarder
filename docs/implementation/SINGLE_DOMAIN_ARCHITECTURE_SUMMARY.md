---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: implementation-implementation
status: active
tags:

- documentation

title: Single Domain Architecture Summary
updated_at: '2025-09-12'
visibility: internal
---

# Single Domain Architecture Implementation Summary

## Overview

Successfully migrated DevOnboarder from multi-subdomain architecture to single-domain path-based routing using `dev.theangrygamershow.com`.

## Architecture Changes

### Before (Multi-Subdomain)

- `auth.dev.theangrygamershow.com` → Auth Service

- `api.dev.theangrygamershow.com` → XP API Service

- `discord.dev.theangrygamershow.com` → Discord Integration

- `dashboard.dev.theangrygamershow.com` → Dashboard Service

- `dev.theangrygamershow.com` → Frontend

### After (Single Domain + Path-Based)

- `dev.theangrygamershow.com/auth` → Auth Service

- `dev.theangrygamershow.com/api` → XP API Service

- `dev.theangrygamershow.com/discord` → Discord Integration

- `dev.theangrygamershow.com/dashboard` → Dashboard Service

- `dev.theangrygamershow.com/` → Frontend (root)

## Files Modified

### 1. Cloudflare Tunnel Configuration

**File**: `cloudflared/config.yml`

```yaml
ingress:
  - hostname: dev.theangrygamershow.com

    service: http://traefik:80
    originRequest:
      httpHostHeader: dev.theangrygamershow.com
  - service: http_status:404

```

**Key Changes**:

- Simplified to single hostname ingress rule

- All traffic routes to `traefik:80`

- Traefik handles internal path-based routing

### 2. Docker Compose Service Routing

**File**: `docker-compose.dev.yaml`

**Service Routing Configuration**:

```yaml

# Auth Service (Priority 100)

- "traefik.http.routers.auth-dev.rule=PathPrefix(`/auth`)"

- "traefik.http.routers.auth-dev.middlewares=stripprefix-auth@file,cors-header@file"

# XP API Service (Priority 100)

- "traefik.http.routers.xp-dev.rule=PathPrefix(`/api`)"

- "traefik.http.routers.xp-dev.middlewares=stripprefix-api@file,cors-header@file"

# Discord Integration Service (Priority 100)

- "traefik.http.routers.discord-dev.rule=PathPrefix(`/discord`)"

- "traefik.http.routers.discord-dev.middlewares=stripprefix-discord@file,cors-header@file"

# Dashboard Service (Priority 100)

- "traefik.http.routers.dashboard-dev.rule=PathPrefix(`/dashboard`)"

- "traefik.http.routers.dashboard-dev.middlewares=stripprefix-dashboard@file,cors-header@file"

# Frontend (Priority 50 - Lower to catch remaining requests)

- "traefik.http.routers.frontend-dev.rule=Host(`dev.theangrygamershow.com`)"

- "traefik.http.routers.frontend-dev.middlewares=cors-header@file"

```

### 3. Traefik Middleware Configuration

**File**: `traefik/dev/dynamic.yml`

**Path Stripping Middleware**:

```yaml
http:
  middlewares:
    stripprefix-auth:
      stripPrefix:
        prefixes:
          - "/auth"

    stripprefix-api:
      stripPrefix:
        prefixes:
          - "/api"

    stripprefix-discord:
      stripPrefix:
        prefixes:
          - "/discord"

    stripprefix-dashboard:
      stripPrefix:
        prefixes:
          - "/dashboard"

```

**CORS Middleware** (unchanged):

```yaml
    cors-header:
      headers:
        accessControlAllowOriginList:
          - "https://dev.theangrygamershow.com"

        accessControlAllowMethods:
          - "GET"

          - "POST"

          - "PUT"

          - "DELETE"

          - "OPTIONS"

        accessControlAllowHeaders:
          - "Content-Type"

          - "Authorization"

        accessControlAllowCredentials: true

```

### 4. Environment Variables

**Development Environment** (`.env.dev`):

```bash

# Single domain for all services

FRONTEND_URL=https://dev.theangrygamershow.com
AUTH_SERVICE_URL=https://dev.theangrygamershow.com/auth
XP_API_URL=https://dev.theangrygamershow.com/api
DISCORD_INTEGRATION_URL=https://dev.theangrygamershow.com/discord
DASHBOARD_SERVICE_URL=https://dev.theangrygamershow.com/dashboard

```

**Frontend Environment Variables**:

```bash
VITE_AUTH_URL=https://dev.theangrygamershow.com/auth
VITE_XP_API_URL=https://dev.theangrygamershow.com/api
VITE_DISCORD_INTEGRATION_URL=https://dev.theangrygamershow.com/discord
VITE_DASHBOARD_URL=https://dev.theangrygamershow.com/dashboard

```

## DNS Configuration Changes

### Single CNAME Record Required

```dns
dev CNAME points-to-cloudflare-tunnel-id.cfargotunnel.com

```

All services now accessible via single domain with path routing.

### Remove Old Subdomain Records

- `auth.dev`

- `api.dev`

- `discord.dev`

- `dashboard.dev`

These DNS records are no longer needed with single-domain architecture.

## Benefits Achieved

### 1. CORS Simplification

- Single origin: `https://dev.theangrygamershow.com`

- No cross-subdomain cookie/session issues

- Simplified security policies

### 2. DNS Management

- One CNAME record instead of five separate subdomain records

- Easier DNS provider management

- Reduced DNS propagation complexity

### 3. SSL/TLS Efficiency

- Single certificate covers all service endpoints

- Reduced SSL handshake overhead

- Simplified certificate management

### 4. Development Experience

- Clearer URL structure: `/auth`, `/api`, `/discord`, `/dashboard`

- No subdomain routing complexity

- Easier local development and testing

**Example URL paths**:

```text
https://dev.theangrygamershow.com/auth/login/discord
https://dev.theangrygamershow.com/api/user/level
https://dev.theangrygamershow.com/discord/oauth/callback
https://dev.theangrygamershow.com/dashboard/scripts/execute
https://dev.theangrygamershow.com/ (Frontend root)

```

## Testing Validation

### Validate Tunnel Configuration

```bash

# Test Cloudflare tunnel connectivity

cloudflared tunnel info devonboarder-dev

# Verify service routing

curl -I https://dev.theangrygamershow.com/auth/health
curl -I https://dev.theangrygamershow.com/api/health
curl -I https://dev.theangrygamershow.com/discord/health
curl -I https://dev.theangrygamershow.com/dashboard/health

```

### Local Development

```bash

# Start development environment

make up-dev

# Test local routing (if using local Traefik)

curl http://localhost/auth/health
curl http://localhost/api/health
curl http://localhost/discord/health
curl http://localhost/dashboard/health

# Frontend should be accessible at root

curl http://localhost/

```

**Service Health Check Results**: All services responding correctly on single domain with path-based routing.

## Rollback Plan

If issues arise, rollback involves:

1. Reverting `cloudflared/config.yml` to multi-hostname configuration

2. Reverting `docker-compose.dev.yaml` Traefik labels to subdomain routing

3. Reverting `traefik/dev/dynamic.yml` middleware configuration

4. Reverting environment variables to subdomain URLs

5. Restoring DNS subdomain records

## Implementation Status

**Completed Components**:

- Cloudflare tunnel single-domain configuration

- Docker Compose path-based routing setup

- Traefik middleware configuration for path stripping

- Environment variable updates for single domain

- DNS simplification to single CNAME record

**Testing Status**:

- DNS record update (requires Cloudflare access)

- End-to-end service connectivity validation

- CORS functionality with single domain

**Deployment Notes**:

- Frontend application testing with new path-based API endpoints

- Discord OAuth redirect URI updates to single domain paths

- Database connection validation across all services
