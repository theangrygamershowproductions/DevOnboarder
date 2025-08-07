# Single Domain Architecture Documentation

## Overview

The DevOnboarder application has been updated to use a **single domain architecture** with dedicated subdomains for each service. This replaces the previous path-based routing system.

## Architecture

### Domain Structure

All services are accessible via subdomains of `theangrygamershow.com`:

- **Frontend/App**: `https://dev.theangrygamershow.com`
- **Authentication Service**: `https://auth.theangrygamershow.com`
- **API Service**: `https://api.theangrygamershow.com`
- **Discord Integration**: `https://discord.theangrygamershow.com`
- **Dashboard Service**: `https://dashboard.theangrygamershow.com`

### Key Benefits

1. **Clean URLs**: Each service has its own dedicated subdomain
2. **Better SSL/TLS Support**: Cloudflare Universal SSL works seamlessly with subdomains
3. **Improved CORS Handling**: Cleaner cross-origin resource sharing configuration
4. **Service Isolation**: Each service can be independently scaled and maintained
5. **Professional Appearance**: More enterprise-ready URL structure

## Technical Implementation

### Traefik Configuration

The system uses **dual routing** to maintain backward compatibility

1. **Host-based routing** (Primary): Routes requests based on subdomain

   ```yaml
   - "traefik.http.routers.auth-host.rule=Host(`auth.theangrygamershow.com`)"
   - "traefik.http.routers.auth-host.priority=200"
   ```

2. **Path-based routing** (Legacy): Maintains compatibility for local development

   ```yaml
   - "traefik.http.routers.auth-dev.rule=PathPrefix(`/auth`)"
   - "traefik.http.routers.auth-dev.priority=100"
   ```

### Cloudflare Tunnel Setup

The Cloudflare tunnel configuration (`config/cloudflare/tunnel-config.yml`) routes all subdomains through Traefik:

```yaml
ingress:
  - hostname: dev.theangrygamershow.com
    service: http://traefik:80
  - hostname: auth.theangrygamershow.com
    service: http://traefik:80
  - hostname: api.theangrygamershow.com
    service: http://traefik:80
  - hostname: discord.theangrygamershow.com
    service: http://traefik:80
  - hostname: dashboard.theangrygamershow.com
    service: http://traefik:80
```

### Environment Configuration

Frontend environment variables have been updated to use the new subdomain architecture:

```bash
VITE_AUTH_URL=https://auth.theangrygamershow.com
VITE_API_URL=https://api.theangrygamershow.com
VITE_FEEDBACK_URL=https://api.theangrygamershow.com
VITE_DISCORD_INTEGRATION_URL=https://discord.theangrygamershow.com
VITE_DASHBOARD_URL=https://dashboard.theangrygamershow.com
```

### CORS Configuration

Updated CORS settings in `traefik/dynamic.yml`:

```yaml
accessControlAllowOriginList:
  - "http://localhost:3000"
  - "https://dev.theangrygamershow.com"
  - "https://auth.theangrygamershow.com"
  - "https://api.theangrygamershow.com"
  - "https://discord.theangrygamershow.com"
  - "https://dashboard.theangrygamershow.com"
```

## Service Endpoints

### Authentication Service (`auth.theangrygamershow.com`)

- Health check: `GET /health`
- Login endpoints: `GET /login/discord`, `GET /login/discord/callback`
- User endpoints: `GET /api/user`, `POST /api/logout`

### API Service (`api.theangrygamershow.com`)

- Health check: `GET /health`
- User management: `GET /api/users`, `POST /api/users`
- Experience points: `GET /api/xp`, `POST /api/xp`

### Discord Integration (`discord.theangrygamershow.com`)

- Health check: `GET /health`
- Bot commands and webhooks

### Dashboard Service (`dashboard.theangrygamershow.com`)

- Health check: `GET /health`
- Admin dashboard interface

### Frontend (`dev.theangrygamershow.com`)

- Main application interface
- React-based SPA

## Deployment Process

### 1. Start Services

```bash
docker compose -f docker-compose.dev.yaml up -d
```

### 2. Start Cloudflare Tunnel

```bash
docker start devonboarder-tunnel-dev
```

### 3. Verify Routing

Check that all services respond correctly:

```bash
curl -s https://auth.theangrygamershow.com/health
curl -s https://api.theangrygamershow.com/health
curl -s https://discord.theangrygamershow.com/health
curl -s https://dashboard.theangrygamershow.com/health
```

## Troubleshooting

### Common Issues

1. **502 Bad Gateway**: Check if Traefik container is running and services are healthy
2. **DNS Resolution**: Verify Cloudflare tunnel is connected and routing correctly
3. **CORS Errors**: Ensure all domains are listed in the CORS configuration

### Debugging Commands

```bash
# Check Traefik router rules
curl -s http://localhost:8090/api/http/routers | jq '.[].rule'

# Check service health
docker compose -f docker-compose.dev.yaml ps

# View Cloudflare tunnel logs
docker logs devonboarder-tunnel-dev

# Check Traefik logs
docker logs devonboarder-traefik-dev
```

## Migration Notes

### What Changed

- URL structure: From `domain.com/service` to `service.domain.com`
- Environment variables updated to use new subdomain URLs
- Traefik configuration enhanced with host-based routing
- CORS configuration updated for new domains

### Backward Compatibility

- Path-based routing still works for local development
- Both routing methods coexist with different priorities
- Legacy URLs continue to function during transition period

## Security Considerations

1. **SSL/TLS**: All subdomains are covered by Cloudflare Universal SSL
2. **CORS**: Strict origin checking prevents unauthorized cross-domain requests
3. **Service Isolation**: Each service operates in its own domain space
4. **Tunnel Security**: All traffic flows through encrypted Cloudflare tunnel

---

**Last Updated**: August 6, 2025
**Version**: 1.0
**Author**: DevOnboarder Team
