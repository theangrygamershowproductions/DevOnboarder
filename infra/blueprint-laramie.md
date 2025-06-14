---
title: Laramie Blueprint
---

This blueprint sets up a local development stack. Run
`scripts/setup-env.sh` to install dependencies and then start the
services with `docker compose -f docker-compose.dev.yaml up -d`.
Redis will be available on port `6379` for application use.

Application data is stored in local volumes under the `./data` directory.
Shut down the stack with `docker compose down` when finished.
