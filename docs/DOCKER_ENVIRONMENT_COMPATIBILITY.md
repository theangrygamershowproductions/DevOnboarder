---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Docker Compose V2 compatibility issues and solutions for DevOnboarder"

document_type: troubleshooting
merge_candidate: false
project: DevOnboarder
similarity_group: DOCKER_ENVIRONMENT_COMPATIBILITY.md-docs
status: active
tags: 
title: "Docker Environment Compatibility"

updated_at: 2025-10-27
visibility: internal
---

# Docker Environment Compatibility Guide

## Docker Compose V2 vs Legacy Compatibility

**Issue**: DevOnboarder scripts may fail with "docker-compose command not found" even when Docker is properly installed.

**Root Cause**: Modern Docker installations use Docker Compose V2 with `docker compose` syntax, but legacy scripts may use `docker-compose` command.

### Environment Detection

```bash
Test command availability:

```bash

# Check Docker Compose availability

docker compose version 2>/dev/null || echo "Modern Docker Compose not available"
which docker-compose 2>/dev/null || echo "Legacy docker-compose not found"

```

Alternative detection:

```bash

# Environment detection for scripts

if command -v docker compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "Error: Neither docker compose nor docker-compose available"
    exit 1
fi

```

### Quick Resolution

**For WSL/Linux environments with Docker Desktop**:

1. **Enable WSL Integration** (Recommended):

   - Open Docker Desktop  Settings  Resources  WSL Integration

   - Enable integration with your WSL distro

   - Apply & Restart Docker Desktop

1. **Install Legacy Compatibility**:

   ```bash
   # Install docker-compose binary for legacy script compatibility

   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod x /usr/local/bin/docker-compose
   ```

1. **Manual Testing with Modern Syntax**:

   ```bash
   # Use modern Docker Compose syntax directly

   docker compose -f docker-compose.dev.yaml --profile tunnel up -d
   docker compose -f docker-compose.dev.yaml ps
   docker compose -f docker-compose.dev.yaml logs cloudflare-tunnel
   ```

### DevOnboarder Script Compatibility

**Current Status**: DevOnboarder scripts use legacy `docker-compose` syntax for broad compatibility.

**Modern Syntax Migration**: Scripts should be updated to use `docker compose` for consistency with Docker Compose V2.

### Environment Validation

```bash

# Verify Docker environment before running DevOnboarder scripts

docker --version                    # Docker Engine version

docker compose version             # Docker Compose V2

docker-compose --version 2>/dev/null || echo "Legacy docker-compose not available"

# Test DevOnboarder Docker configuration

docker compose -f docker-compose.dev.yaml config --quiet

```

### Troubleshooting

**Symptom**: "The command 'docker-compose' could not be found"
**Solution**: Follow one of the resolution methods above

**Symptom**: Scripts fail with Docker available
**Diagnosis**: Check if scripts use `docker-compose` vs `docker compose`

**WSL-Specific**: Ensure Docker Desktop WSL integration is enabled for your distro

---

**Related**: See `CLOUDFLARE_TUNNEL_PHASE2_COMPLETE.md` for specific tunnel deployment requirements
