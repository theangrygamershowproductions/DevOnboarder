---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: CLOUDFLARE_TUNNEL_GUIDE.md-docs
status: active
tags: 
title: "Cloudflare Tunnel Guide"

updated_at: 2025-10-27
visibility: internal
---

# Cloudflare Tunnel Configuration Guide

## Overview

DevOnboarder uses **Cloudflare Tunnel** for secure external access in production environments. The tunnel provides SSL termination, DDoS protection, and eliminates the need for port forwarding.

## Architecture Decision

###  Production (Primary Use Case)

- **Always enabled** in production for external access

- **Secure webhooks** for Discord, GitHub integrations

- **SSL/TLS termination** at Cloudflare edge

- **DDoS protection** and rate limiting

###  Development (Optional Testing)

- **Profile-gated** - only runs when explicitly requested

- **Testing external integrations** before production deployment

- **Webhook development** with real external endpoints

## Setup Instructions

### 1. Cloudflare Tunnel Creation

```bash

# Install cloudflared CLI

curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# Authenticate with Cloudflare

cloudflared tunnel login

# Create tunnel

cloudflared tunnel create devonboarder-prod

# This generates

# - Tunnel UUID

# - Credentials file (credentials.json)

```

### 2. Environment Variables

Add to `.env.prod`:

```bash

# Cloudflare Tunnel Configuration

TUNNEL_TOKEN=your_tunnel_token_here
TUNNEL_UUID=your_tunnel_uuid_here

```

Add to `.env.dev` (optional for development testing):

```bash

# Development tunnel (optional)

TUNNEL_TOKEN=your_dev_tunnel_token_here
TUNNEL_UUID=your_dev_tunnel_uuid_here

```

### 3. DNS Configuration

In Cloudflare dashboard, add CNAME records:

```text
devonboarder.your-domain.com  tunnel-uuid.cfargotunnel.com
api.devonboarder.your-domain.com  tunnel-uuid.cfargotunnel.com
auth.devonboarder.your-domain.com  tunnel-uuid.cfargotunnel.com
discord.devonboarder.your-domain.com  tunnel-uuid.cfargotunnel.com

```

## Usage

### Production Deployment

```bash

# Tunnel starts automatically with production stack

docker compose -f docker-compose.tags.prod.yaml up -d

```

### Development Testing (Optional)

```bash

# Start development with tunnel profile

docker compose -f docker-compose.dev.yaml --profile tunnel up -d

# Or start tunnel service separately

docker compose -f docker-compose.dev.yaml up cloudflared -d

```

## Traffic Flow

### Production Architecture

```text
External Request
  ↓
Cloudflare Edge (SSL/TLS termination)
  ↓
Cloudflare Tunnel (cloudflared container)
  ↓
Traefik Reverse Proxy (internal routing)
  ↓
FastAPI Services (auth, xp, discord, dashboard)

```

### Development Architecture (when tunnel enabled)

```text
External Request (optional)
  ↓
Cloudflare Tunnel (profile-gated)
  ↓
Traefik (localhost:8090)
  ↓
Development Services

```

## Benefits

### Security

- **No exposed ports** - all traffic via Cloudflare

- **DDoS protection** - Cloudflare edge filtering

- **SSL/TLS encryption** - End-to-end security

### Reliability

- **Global edge network** - Low latency worldwide

- **Automatic failover** - Built-in redundancy

- **Health monitoring** - Tunnel status monitoring

### Development

- **Webhook testing** - Real external endpoints for Discord/GitHub

- **SSL testing** - Production-like HTTPS environment

- **Integration validation** - Test OAuth callbacks with real domains

## Monitoring

### Health Checks

```bash

# Check tunnel status

docker logs devonboarder-cloudflared-prod

# Cloudflare dashboard

# Navigate to Zero Trust > Networks > Tunnels

```

### Debugging

```bash

# Tunnel logs

docker compose -f docker-compose.tags.prod.yaml logs cloudflared

# Test connectivity

curl -H "Host: devonboarder.your-domain.com" http://localhost/health

```

## Security Considerations

### Production Requirements

-  Always use credentials file (not inline tokens)

-  Rotate tunnel tokens regularly

-  Monitor tunnel access logs

-  Use Cloudflare Access for admin endpoints

### Development Safety

- 🔒 Use separate tunnel for development

- 🔒 Restrict development tunnel to specific IPs

- 🔒 Never use production credentials in development

- 🔒 Profile-gate to prevent accidental exposure

## Troubleshooting

### Common Issues

1. **Tunnel not connecting**

    - Verify TUNNEL_TOKEN is correct

    - Check network connectivity

    - Review cloudflared logs

2. **DNS resolution failed**

    - Confirm CNAME records in Cloudflare

    - Check tunnel UUID matches DNS

    - Wait for DNS propagation (up to 24 hours)

3. **Service unreachable**

    - Verify Traefik routing rules

    - Check internal service health

    - Confirm Docker network connectivity

### Debug Commands

```bash

# Test tunnel connectivity

cloudflared tunnel info devonboarder-prod

# Check service health via tunnel

curl https://devonboarder.your-domain.com/health

# Verify internal routing

docker exec devonboarder-cloudflared-prod curl http://devonboarder-traefik-dev/health

```
