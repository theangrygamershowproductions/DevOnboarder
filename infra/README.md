---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Infrastructure blueprints and deployment documentation for DevOnboarder stack
document_type: overview
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags:

- overview

- infrastructure

- deployment

- blueprints

title: Infrastructure Documentation
updated_at: '2025-09-12'
visibility: internal
---

# Infrastructure

This directory contains infrastructure blueprints and deployment notes.
Each blueprint explains how to spin up a stack using the compose files in
the repository. Deployments rely on environment variables provided via a
`.env` file.

## Running the Stack

1. Copy `.env.example` to an environment file for your target environment,

   for example `.env.dev` for local development or `.env.prod` for production.

2. Edit the variables to match your setup (`DATABASE_URL`, `REDIS_URL`, and so

   on).

3. Start the services with the matching compose file:

    ```bash
    # Local development

    docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d

    # Production deployment

    docker compose -f docker-compose.prod.yaml --env-file .env.prod up -d
    ```

4. When finished, shut down the stack with `docker compose down`.

Refer to the individual blueprints for environment specific notes.
