# Integrating with TAGS

The TAGS stack uses dedicated Compose files to coordinate each service.
Minimal templates are now provided under `archive/`:

```
archive/docker-compose.tags.dev.yaml
archive/docker-compose.tags.prod.yaml
```

Copy the appropriate file to the repository root and update the service names,
image tags and environment variables to match your deployment. If your team
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

```
IS_ALPHA_USER=true
IS_FOUNDER=true
```

With these flags set, the API exposes the `/alpha` and `/founder` endpoints described in
[docs/env.md](env.md). Use the TAGS Compose files to run a fully integrated environment
with shared authentication across all services.
