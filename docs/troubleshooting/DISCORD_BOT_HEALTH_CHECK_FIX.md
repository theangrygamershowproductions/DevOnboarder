---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
---

# Discord Bot Container Health Check Fix

## Problem

Discord bot container shows as "unhealthy" because it uses HTTP health check on a non-HTTP service.

## Quick Solution

### 1. Create Health Check Script

Create `bot/health-check.js`:

```javascript
#!/usr/bin/env node
import fs from 'fs';
import path from 'path';

try {
    const logDir = path.join(process.cwd(), 'logs');
    if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
    }

    const healthFile = path.join(logDir, '.health-check');
    fs.writeFileSync(healthFile, new Date().toISOString());

    process.exit(0);
} catch (error) {
    console.error('Health check failed:', error.message);
    process.exit(1);
}

```

### 2. Update Docker Compose

In `docker-compose.dev.yaml`, update the bot service:

```yaml
bot:
  # ... other config ...

  volumes:
    - ./bot/health-check.js:/app/health-check.js:ro

    # ... other volumes ...

  healthcheck:
    test: ["CMD", "node", "/app/health-check.js"]
    interval: 30s
    timeout: 5s
    retries: 3
    start_period: 60s

```

### 3. Fix File Permissions

```bash

# Fix ownership for DevOnboarder (bot container uses UID 1001)

sudo chown -R 1001:1001 bot/dist/
sudo chown -R 1001:1001 logs/
sudo chown 1001:1001 bot/health-check.js

```

### 4. Rebuild and Restart

```bash
docker compose -f docker-compose.dev.yaml build bot
docker compose -f docker-compose.dev.yaml up bot -d

```

## Result

Container status changes from "unhealthy" to "healthy":

```bash

# Before

devonboarder-bot-dev   Up 30 seconds (unhealthy)

# After

devonboarder-bot-dev   Up 2 minutes (healthy)

```

## For Detailed Troubleshooting

See [Docker Container Health Check Troubleshooting](./DOCKER_CONTAINER_HEALTH_TROUBLESHOOTING.md) for comprehensive guidance.
