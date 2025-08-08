# Environment-Specific URL Configuration

## Overview

DevOnboarder now uses environment-specific URL variables to cleanly handle different deployment scenarios without manual configuration switching.

## Environment Variables Pattern

Each service URL now has three variants based on deployment environment:

### Auth URLs

- `AUTH_URL_DEV=http://localhost` - Local development with Traefik routing
- `AUTH_URL_PROD=https://auth.theangrygamershow.com` - Production subdomain
- `AUTH_URL_CI=http://localhost:8002` - CI testing with direct ports

### Discord OAuth Redirect URIs

- `DISCORD_REDIRECT_URI_DEV=http://localhost/login/discord/callback` - Local Traefik routing
- `DISCORD_REDIRECT_URI_PROD=https://auth.theangrygamershow.com/login/discord/callback` - Production subdomain
- `DISCORD_REDIRECT_URI_CI=http://localhost:8002/login/discord/callback` - CI direct port

### Frontend URLs (Vite)

- `VITE_AUTH_URL_DEV=http://localhost` - Local development through Traefik
- `VITE_AUTH_URL_PROD=https://auth.theangrygamershow.com` - Production subdomain
- `VITE_AUTH_URL_CI=http://localhost:8002` - CI testing with direct ports

### CORS Origins

- `CORS_ALLOW_ORIGINS_DEV` - Localhost ports for development
- `CORS_ALLOW_ORIGINS_PROD` - Production subdomains
- `CORS_ALLOW_ORIGINS_CI` - CI localhost ports

## Usage

Each environment file (`.env.dev`, `.env.prod`, `.env.ci`) contains:

1. **Environment-specific variants** - All three URL variations for flexibility
2. **Current active values** - The actual variables used by services, set based on `APP_ENV`

## Environment Detection

The active URL is determined by the `APP_ENV` variable:

- `APP_ENV=development` → Uses `*_DEV` variants
- `APP_ENV=production` → Uses `*_PROD` variants
- `APP_ENV=ci` → Uses `*_CI` variants

## Benefits

✅ **No manual switching** - Environment files are self-contained
✅ **Clear configuration** - All URL variants visible in each file
✅ **Consistent patterns** - Same naming convention across all services
✅ **Easy deployment** - Just copy the appropriate `.env.*` file
✅ **CI compatibility** - Dedicated CI URLs for testing

## Migration from Previous Setup

**Before:**

```bash
# Manual switching required
AUTH_URL=https://auth.theangrygamershow.com  # Production
# AUTH_URL=http://localhost                  # Development (commented out)
```

**After:**

```bash
# All variants available
AUTH_URL_DEV=http://localhost
AUTH_URL_PROD=https://auth.theangrygamershow.com
AUTH_URL_CI=http://localhost:8002

# Active configuration based on APP_ENV
AUTH_URL=http://localhost  # (for development)
```

## File Structure

```text
├── .env.dev      # Development configuration (APP_ENV=development)
├── .env.prod     # Production configuration (APP_ENV=production)
├── .env.ci       # CI configuration (APP_ENV=ci)
└── .env.example  # Template with all environment-specific variables
```

## Traefik Routing Context

This pattern specifically addresses the DevOnboarder Docker + Traefik setup where:

- **Development**: Services accessed via `localhost` with Traefik routing to containers
- **Production**: Services accessed via dedicated subdomains
- **CI**: Services accessed via direct localhost ports for testing

The environment-specific URLs ensure proper routing in each context without manual configuration changes.
