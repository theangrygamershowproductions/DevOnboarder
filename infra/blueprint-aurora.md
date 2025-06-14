---
title: Aurora Blueprint
---

This blueprint describes the production deployment that relies on
**AWS Aurora** for the backing database. Use the `docker-compose.yml`
file together with `docker-compose.override.yaml` when deploying this
environment. Ensure the application containers can reach the Aurora
cluster through the configured security groups and that backups are
enabled for disaster recovery.

The service expects the `DATABASE_URL` environment variable to point to
the Aurora cluster's writer endpoint. Aurora is configured for multi-AZ
failover and nightly snapshot backups retained for 30 days.
