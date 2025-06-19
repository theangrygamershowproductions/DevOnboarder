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
   # This starts the application along with Postgres (service `db`) and Redis.

   # Production deployment
   docker compose -f docker-compose.yml -f docker-compose.override.yaml \
     --env-file .env.prod up -d
   ```

4. When finished, shut down the stack with `docker compose down`.

Refer to the individual blueprints for environment specific notes.
