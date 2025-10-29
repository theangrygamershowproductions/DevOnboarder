---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Local development deployment blueprint with setup and configuration instructions"

document_type: guide
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags: 
title: "Laramie Development Blueprint"

updated_at: 2025-10-27
visibility: internal
---

This blueprint sets up a local development stack.

1. Run `scripts/setup-env.sh` to install dependencies.

2. Copy `.env.example` to `.env.dev` and adjust the variables. A typical

   development file might contain:

    ```bash
    APP_ENV=development
    REDIS_URL=redis://localhost:6379/0
    LOG_LEVEL=DEBUG
    ```

3. Start the stack with:

    ```bash
    docker compose -f docker-compose.dev.yaml --env-file .env.dev up -d
    ```

    The stack exposes Postgres on port `5432` and serves the frontend on port `3000`.

Application data is stored in local volumes under the `./data` directory.
Stop everything with `docker compose down` when finished.
