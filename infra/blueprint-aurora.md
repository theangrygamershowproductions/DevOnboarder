---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Production deployment blueprint using AWS Aurora database with Docker Compose"

document_type: guide
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags: 
title: "Aurora Deployment Blueprint"

updated_at: 2025-10-27
visibility: internal
---

This blueprint describes the production deployment that relies on

**AWS Aurora** for the backing database. Use `docker-compose.prod.yaml`

when deploying this environment. Ensure the application containers can
reach the Aurora cluster through the configured security groups and that
backups are enabled for disaster recovery.

1. Create a `.env.prod` file and set `DATABASE_URL` to the writer

   endpoint for your Aurora cluster:

    ```bash
    DATABASE_URL=postgres://dbuser:dbpass@aurora-writer.example.us-east-1.rds.amazonaws.com:5432/prod_db
    LOG_LEVEL=INFO
    ```

2. Deploy with:

    ```bash
    docker compose -f docker-compose.prod.yaml --env-file .env.prod up -d
    ```

The service expects the `DATABASE_URL` environment variable to point to
the Aurora cluster's writer endpoint. Aurora is configured for multi-AZ
failover and nightly snapshot backups retained for 30 days.
