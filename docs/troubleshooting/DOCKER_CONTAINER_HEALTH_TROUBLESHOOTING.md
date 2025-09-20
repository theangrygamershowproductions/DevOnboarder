---
consolidation_priority: P3

content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
---

# Docker Container Health Check Troubleshooting

## Overview

This guide covers common issues with Docker container health checks in DevOnboarder, particularly focusing on Discord bot containers that don't expose HTTP endpoints and permission-related problems with volume mounts.

## Common Symptoms

### 1. Container Shows as "Unhealthy"

**Symptom**: `docker compose ps` shows container status as `Up X seconds (unhealthy)`

**Example**:

```bash
NAME                   IMAGE              COMMAND                  SERVICE   CREATED       STATUS
devonboarder-bot-dev   devonboarder-bot   "docker-entrypoint.s…"   bot       2 hours ago   Up 30 seconds (unhealthy)

```

### 2. Container Restarts Continuously

**Symptom**: Container status shows `Restarting (X) Y seconds ago`

**Example**:

```bash
NAME                   IMAGE              COMMAND                  SERVICE   CREATED       STATUS
devonboarder-bot-dev   devonboarder-bot   "docker-entrypoint.s…"   bot       2 hours ago   Restarting (2) 15 seconds ago

```

## Root Causes and Solutions

### Issue 1: Incorrect Health Check for Non-HTTP Services

#### HTTP Health Check Root Cause

Using HTTP-based health checks (`curl`) for services that don't expose HTTP endpoints, such as Discord bots.

#### HTTP Health Check Symptoms

- Health check logs show: `curl: (7) Failed to connect to localhost port 8080: Connection refused`

- Container marked as unhealthy despite functional operation

#### HTTP Health Check Resolution Steps

Create a custom health check script appropriate for the service type.

**For Discord Bot (Node.js/TypeScript)**:

**Step 1: Create health check script** (`bot/health-check.js`):

```javascript
#!/usr/bin/env node

// Simple health check for Discord bot
// Returns exit code 0 if healthy, 1 if not

import fs from 'fs';
import path from 'path';

try {
    // Check if the main process is running by looking for the PID
    // In a container, if we reach this script, Node.js is running

    // Also check if we can write to logs (basic functionality test)
    const logDir = path.join(process.cwd(), 'logs');

    // Try to create logs directory if it doesn't exist
    if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
    }

    // Write a health check timestamp
    const healthFile = path.join(logDir, '.health-check');
    fs.writeFileSync(healthFile, new Date().toISOString());

    // If we got here, the bot process is running and can write files
    process.exit(0);
} catch (error) {
    console.error('Health check failed:', error.message);
    process.exit(1);
}

```

**Step 2: Update docker-compose.yml**:

```yaml
healthcheck:
  test: ["CMD", "node", "/app/health-check.js"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 60s

```

**Step 3: Mount the health check file**:

```yaml
volumes:
  - ./bot/health-check.js:/app/health-check.js:ro

```

**Step 4: Rebuild the container** to include the health check file:

```bash
docker compose -f docker-compose.dev.yaml build bot
docker compose -f docker-compose.dev.yaml up bot -d

```

### Issue 2: File Permission Mismatches with Volume Mounts

#### Permission Root Cause

Host file ownership doesn't match container user expectations, causing permission denied errors.

#### Permission Error Symptoms

- TypeScript compilation errors: `EACCES: permission denied, open '/app/dist/...`

- Health check failures: `EACCES: permission denied, open '/app/logs/.health-check'`

- Container restart loops

#### Diagnosis Steps

**Step 1: Check container user**:

```bash
docker run --rm your-image id

# Output: uid=1001(botuser) gid=1001(botuser) groups=1001(botuser)

```

**Step 2: Check host file ownership**:

```bash
ls -la bot/dist/

# Output: drwxr-xr-x 5 creesey creesey 4096 Aug 6 03:56 .

```

**Step 3: Identify mismatch**: Host files owned by 1000:1000, container expects 1001:1001

#### Permission Resolution Steps

**Fix file ownership** to match container user:

```bash

# Check container user ID

CONTAINER_UID=$(docker run --rm your-image id -u)
CONTAINER_GID=$(docker run --rm your-image id -g)

# Fix ownership of mounted directories

sudo chown -R $CONTAINER_UID:$CONTAINER_GID bot/dist/
sudo chown -R $CONTAINER_UID:$CONTAINER_GID logs/
sudo chown $CONTAINER_UID:$CONTAINER_GID bot/health-check.js

```

**For DevOnboarder specifically**:

```bash

# Bot container uses UID:GID 1001:1001

sudo chown -R 1001:1001 bot/dist/
sudo chown -R 1001:1001 logs/
sudo chown 1001:1001 bot/health-check.js

```

### Issue 3: ES Module vs CommonJS Syntax

#### Module System Root Cause

Health check script uses CommonJS syntax (`require`) in an ES module environment.

#### Module Error Symptoms

```text
ReferenceError: require is not defined in ES module scope
This file is being treated as an ES module because it has a '.js' file extension and '/app/package.json' contains "type": "module"

```

#### Module Resolution Steps

Use ES module syntax in health check scripts:

```javascript
// ❌ Wrong (CommonJS)
const fs = require('fs');
const path = require('path');

// ✅ Correct (ES Modules)
import fs from 'fs';
import path from 'path';

```

### Issue 4: Cloudflare Tunnel Health Check Configuration

#### Cloudflare Tunnel Root Cause

Default Cloudflare tunnel health check uses `cloudflared tunnel info` which requires origin certificate configuration that may not be available in container context.

#### Cloudflare Tunnel Symptoms

```text
Error locating origin cert: client didn't specify origincert path
Cannot determine default origin certificate path

```

#### Cloudflare Tunnel Solution

Use a simpler process-based health check instead of tunnel info command:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pgrep cloudflared || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s

```

This checks if the cloudflared process is running rather than trying to query tunnel status.

## Troubleshooting Workflow

### Step 1: Identify the Issue Type

```bash

# Check container status

docker compose ps

# Check recent logs

docker compose logs service-name --tail=20

# Test health check manually

docker exec container-name node /app/health-check.js

```

### Step 2: Diagnose Health Check Problems

```bash

# For HTTP services - test endpoint

docker exec container-name curl -f http://localhost:8080/health

# For custom scripts - run directly

docker exec container-name node /app/health-check.js

# Check file permissions

docker exec container-name ls -la /app/

```

### Step 3: Fix Permission Issues

```bash

# Check container user

docker exec container-name id

# Check host file ownership

ls -la mounted-directory/

# Fix ownership if needed

sudo chown -R container-uid:container-gid mounted-directory/

```

### Step 4: Restart and Verify

```bash

# Restart the service

docker compose restart service-name

# Wait for health check interval

sleep 60

# Verify healthy status

docker compose ps service-name

```

## Prevention Best Practices

### 1. Design Appropriate Health Checks

- **HTTP services**: Use `curl` or `wget` to test endpoints

- **Database services**: Use database-specific health commands

- **Non-HTTP services**: Create custom scripts that test core functionality

### 2. Handle File Permissions Correctly

- **Development**: Use volume mounts with correct ownership

- **Production**: Build files into the image to avoid permission issues

- **CI/CD**: Test with the same user ID as production containers

### 3. Container User Configuration

```dockerfile

# Create user with specific UID/GID for consistency

RUN useradd -u 1001 -g 1001 -m -s /bin/bash appuser
USER appuser

```

### 4. Volume Mount Best Practices

```yaml

# Mount specific files when possible

volumes:
  - ./app/src:/app/src

  - ./app/package.json:/app/package.json

# Avoid mounting entire directories that contain build artifacts

# ❌ Don't do this if it contains compiled files

# - ./app:/app

```

## Related Documentation

- [Docker Health Check Documentation](https://docs.docker.com/engine/reference/builder/#healthcheck)

- [DevOnboarder Multi-Service Architecture](../ARCHITECTURE.md)

- [Container Security Best Practices](./CONTAINER_SECURITY.md)

## Quick Reference Commands

```bash

# Check all container health status

docker compose ps

# Test health check manually

docker exec container-name health-check-command

# Fix common permission issues (DevOnboarder)

sudo chown -R 1001:1001 bot/dist/ logs/

# Restart specific service

docker compose restart service-name

# View health check logs

docker inspect container-name | grep -A 10 Health

```

## When to Seek Help

If you encounter issues not covered in this guide:

1. Check the [GitHub Issues](https://github.com/theangrygamershowproductions/DevOnboarder/issues) for similar problems

2. Create a new issue with:

    - Container status output (`docker compose ps`)

    - Recent logs (`docker compose logs service-name --tail=50`)

    - Health check test results

    - File permission information (`ls -la` output)

---

**Last Updated**: August 7, 2025

**Applies To**: DevOnboarder v1.0.0+
**Related Issues**: Discord Bot Health Check (#XXX)
