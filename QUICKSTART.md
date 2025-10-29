---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: docs-
status: active
tags: 
title: Quickstart

updated_at: 2025-10-27
visibility: internal
---

# Quickstart

Follow these steps to get the DevOnboarder stack running in minutes.

1. **Clone the repo**

   ```bash

   git clone https://github.com/theangrygamershowproductions/DevOnboarder.git && cd DevOnboarder
   ```

2. **Copy example environment variables**

   ```bash

   cp .env.example .env
   cp auth/.env.example auth/.env
   cp bot/.env.example bot/.env
   cp frontend/src/.env.example frontend/src/.env
   ```

3. **Start the services**

   ```bash

   docker compose up -d
   ```

4. **Run tests to verify the setup**

   ```bash

   ./scripts/run_tests.sh
   ```

If the tests pass, you're ready to develop. See [docs/README.md](docs/README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) for full documentation.
