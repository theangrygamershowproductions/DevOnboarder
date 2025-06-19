---
title: Laramie Blueprint
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
