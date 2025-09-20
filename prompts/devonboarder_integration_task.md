---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Task prompt for DevOnboarder TAGS integration with condensed setup instructions
document_type: prompt
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags:

- prompt

- integration

- tags

- setup

title: DevOnboarder TAGS Integration Task
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder TAGS Integration Task

Follow these steps when adding DevOnboarder to the TAGS stack. They mirror the docs under `docs/tags_integration.md` but are condensed for Codex to generate QA tasks.

## Key environment variables

- `IS_ALPHA_USER=true`

- `IS_FOUNDER=true`

- `AUTH_URL` – base URL for the auth service

- `API_BASE_URL` – base URL for the XP API

- `CHECK_HEADERS_URL` – endpoint checked by `scripts/check_headers.py`

- `VITE_AUTH_URL` and `VITE_API_URL` – frontend URLs

## Compose commands

```bash
docker compose -f docker-compose.tags.dev.yaml --env-file .env.dev up -d

# To stop

docker compose -f docker-compose.tags.dev.yaml down

```

## Diagnostics

After the stack is running, run:

```bash
python -m diagnostics

```

Check container status with `docker compose ps` and view logs with `docker compose logs <service>` if diagnostics report failures.
