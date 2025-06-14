---
title: Aurora Blueprint
---

This blueprint describes the production deployment that relies on
**AWS Aurora** for the backing database. Use the `docker-compose.yml`
file together with `docker-compose.override.yaml` when deploying this
environment. Ensure the application containers can reach the Aurora
cluster through the configured security groups and that backups are
enabled for disaster recovery.
