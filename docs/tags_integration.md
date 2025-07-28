# Integrating with TAGS

The TAGS stack uses dedicated Compose files to coordinate each service.
Templates are tracked in the repository root and under `archive/`:

```yaml
docker-compose.tags.dev.yaml    # or archive/docker-compose.tags.dev.yaml
docker-compose.tags.prod.yaml   # or archive/docker-compose.tags.prod.yaml
```

Copies of these templates are provided in the repository root. If they are
missing, copy them from `archive/` and update the service names, image tags and
environment variables to match your deployment. If your team
maintains a central infrastructure repository, replace the templates with those
versions. Start a local stack with:

```bash
docker compose -f docker-compose.tags.dev.yaml up
```

Production deployments rely on `docker-compose.tags.prod.yaml`. Both files
extend the base `docker-compose.yml` and enable extra logging suitable for the
TAGS environment.

Feature flags control early access routes. Add the following settings to `.env.dev` when
running against the TAGS stack:

```bash
TAGS_MODE=true
IS_ALPHA_USER=true
IS_FOUNDER=true
```

`TAGS_MODE` tells the diagnostics script to verify the XP API and
feedback services in addition to the auth server.

With these flags set, the API exposes the `/alpha` and `/founder` endpoints described in
[docs/env.md](env.md). Use the TAGS Compose files to run a fully integrated environment
with shared authentication across all services.
