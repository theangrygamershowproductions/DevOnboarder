---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!-- PATCHED v0.1.46 docs/docker/Compose.md — Update Node image version -->

# Docker Compose Configuration

Docker Compose file for production environment using version 3.9.

## Services:
1. **traefik**:
   - Reverse proxy and load balancer using Traefik v3.0.
   - Configured with Docker provider and Let's Encrypt for automatic SSL certificates.
   - Uses the `leresolver` ACME configuration for certificate management.
   - Exposes ports 80 (HTTP) and 443 (HTTPS).
   - Includes a dashboard for monitoring.
   - Uses mounted volumes for the Docker socket and Let's Encrypt storage.

2. **whoami**:
   - A simple HTTP service for testing and debugging.
   - Accessible via the hostname `whoami.localhost` on the `web` entrypoint.
   - Configured with CORS middleware to allow cross-origin requests:
     - Allowed origins: `*`
     - Allowed methods: `GET, OPTIONS, PUT, POST, DELETE`
     - Allowed headers: `*`
     - Adds the `Vary` header for better caching behavior.

3. **auth**:
   - A Node.js service for Discord authentication.
   - Uses the Node.js 22 Alpine image.
   - Runs in development mode with `npm run dev`.
   - Accessible via `auth.localhost` with a path prefix `/api/auth/discord` on the `websecure` entrypoint.
   - Configured with TLS using Let's Encrypt and the `leresolver` ACME configuration.
   - Configured with `auth-cors` middleware for secure cross-origin requests:
     - Allowed origins: `https://app.localhost`
     - Allowed methods: `GET, POST, OPTIONS`
     - Allowed headers: `Origin, Content-Type, Accept, Authorization`
     - Allows credentials for secure requests.
     - Adds the `Vary` header for better caching behavior.
   - Discord and JWT secrets are injected using Docker secrets.
