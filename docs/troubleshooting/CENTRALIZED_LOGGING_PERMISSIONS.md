---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
updated_at: 2025-10-27
---

# Centralized Logging Permissions Guide

## Overview

DevOnboarder implements a centralized logging policy requiring all logs to be stored under the `logs/` directory. This document explains the permission requirements for Docker containers writing to centralized log locations.

## Permission Architecture

### Container User Context

Docker containers in DevOnboarder run as non-root users for security:

- **Bot Container**: Runs as `botuser` (UID 1001, GID 1001)

- **Host User**: Typically `creesey` (UID 1000, GID 1000)

### Directory Ownership Requirements

For containers to write to centralized logs, directories must have correct ownership:

```bash

# Main logs directory (host user)

logs/                    # Owner: creesey:creesey (1000:1000)

# Service-specific subdirectories (container user)

logs/bot/               # Owner: 1001:1001 (bot container)

logs/auth/              # Owner: 1000:1000 (auth service)

logs/backend/           # Owner: 1000:1000 (backend service)

```

## Setup Commands

### Creating Bot Log Directory

```bash

# Create directory with correct ownership

mkdir -p logs/bot
sudo chown 1001:1001 logs/bot

# Verify ownership

ls -la logs/ | grep bot

# Should show: drwxr-xr-x  2  1001  docker  4096  Aug  7 03:49 bot

```

### Docker Compose Volume Mounts

```yaml

# Correct volume mount for centralized logging

services:
  bot:
    volumes:
      - ./logs/bot:/app/logs  # Maps to container's /app/logs

```

## Common Issues

### Permission Denied Errors

**Symptom**: Container fails to write logs with "Permission denied"

**Cause**: Directory owned by wrong user (host UID 1000 vs container UID 1001)

**Solution**:

```bash

# Fix ownership for bot logs

sudo chown 1001:1001 logs/bot

# For other services (auth, backend - they run as host user)

sudo chown 1000:1000 logs/auth logs/backend

```

### Health Check Failures

**Symptom**: Bot container shows "unhealthy" status

**Cause**: Health check script cannot write to logs directory

**Solution**: Verify log directory permissions and ownership as above

## Migration from Service-Specific Logs

When migrating from `bot/logs/` to `logs/bot/`:

1. **Create centralized directory with correct ownership**:

   ```bash
   mkdir -p logs/bot
   sudo chown 1001:1001 logs/bot
   ```

2. **Update Docker Compose volume mount**:

   ```yaml
   # Before

   - ./bot/logs:/app/logs

   # After

   - ./logs/bot:/app/logs

   ```

3. **Copy existing log files (if needed)**:

   ```bash
   sudo cp bot/logs/* logs/bot/

   sudo chown 1001:1001 logs/bot/*
   ```

4. **Remove old directory**:

   ```bash
   sudo rm -rf bot/logs
   ```

5. **Restart container**:

   ```bash
   docker compose restart bot
   ```

## Verification

### Check Container Health

```bash
docker compose ps bot

# Should show: Up X minutes (healthy)

```

### Check Log File Creation

```bash
ls -la logs/bot/

# Should show files owned by 1001:docker

```

### Check Health Check File

```bash
cat logs/bot/.health-check

# Should show recent timestamp

```

## Security Considerations

- **Non-root containers**: All services run as non-root users

- **Minimal permissions**: Containers only have access to their specific log directories

- **Host isolation**: Container users cannot access host system files

- **Log rotation**: Centralized logs enable proper log rotation and archival

## Troubleshooting Commands

```bash

# Check container user

docker exec devonboarder-bot-dev id

# Output: uid=1001(botuser) gid=1001(botuser)

# Check mounted directory permissions

docker exec devonboarder-bot-dev ls -la /app/

# Should show logs directory accessible to botuser

# Test health check manually

docker exec devonboarder-bot-dev node /app/health-check.js
echo $?  # Should be 0 for success

```

## Related Documentation

- [Docker Container Health Troubleshooting](DOCKER_CONTAINER_HEALTH_TROUBLESHOOTING.md)

- [Discord Bot Health Check Fix](DISCORD_BOT_HEALTH_CHECK_FIX.md)

- DevOnboarder Centralized Logging Policy (see `.github/copilot-instructions.md`)

---

**Last Updated**: August 7, 2025

**Author**: DevOnboarder Project
**Version**: 1.0.0
