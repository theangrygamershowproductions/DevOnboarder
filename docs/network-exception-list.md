---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: network-exception-list.md-docs
status: active
tags:
- documentation
title: Network Exception List
updated_at: '2025-09-12'
visibility: internal
---

# Required Network Exceptions

The following external domains must be reachable for normal setup and CI tasks.
Each entry references where the domain appears in the documentation or scripts.

- `github.com` – used throughout the docs for cloning and fetching dependencies.

  The `sersoft-gmbh/setup-gh-cli-action` action downloads the CLI from
  `cli.github.com`. See `docs/git-guidelines.md` line 80.

- `download.docker.com` – Docker packages are pulled from this repository. See `docs/ubuntu-setup.md` lines 8‑13.

- `deb.nodesource.com` – Node.js 22 installer script comes from this domain. See `docs/ubuntu-setup.md` lines 18‑19.

- `nodejs.org` – pre‑commit downloads Node.js here if it is missing. See `docs/network-troubleshooting.md` lines 26‑35.

- `vale.sh` – Vale installation instructions link to this domain. See `docs/doc-quality-onboarding.md` line 26.

- `api.languagetool.org` and `languagetool.org` – used by LanguageTool. See

  `docs/network-troubleshooting.md` lines 10‑16 and `docs/doc-quality-onboarding.md` line 44.

- `dev.languagetool.org` – documentation for running a local LanguageTool server. See `docs/README.md` line 182.

- `quay.io` – Docker image for a local LanguageTool server. See `docs/doc-quality-onboarding.md` lines 39‑41.

- `ghcr.io` – container image for Codex universal setup. See

  `scripts/setup-env.sh` lines 17‑20 and `docker-compose.codex.yml` line 3.

- `img.shields.io` – coverage badge fetched during CI. See `scripts/update_coverage_badge.py` line 33.

These domains may require explicit firewall or proxy exceptions in restricted environments.

Remember to update this list whenever new scripts or docs mention additional
domains so firewalls stay correctly configured.
