---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Test suite execution guide and development testing requirements
document_type: guide
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags:
- guide
- testing
- pytest
- development
title: Test Suite Guide
updated_at: '2025-09-12'
visibility: internal
---

# Running the Test Suite

Install the project and its development requirements before executing the tests
so Python can resolve all imports. **These commands must run before invoking
`pytest`.**

```bash

pip install -e .[test]

```

Then run `pytest` from the repository root with coverage enabled.
Artifacts should stay inside the `logs/` directory:

```bash
COVERAGE_FILE=logs/.coverage pytest \
    --cache-dir=logs/.pytest_cache \
    --cov=src \
    --cov-report=xml:logs/coverage.xml \
    --cov-fail-under=95 \
    --junitxml=test-results/pytest-results.xml

```

After tests, clean up residual files to avoid root pollution:

```bash
bash scripts/clean_pytest_artifacts.sh

```

Use `make test` to run the linter and all test suites at once.

CI requires every suite to maintain **95%** code coverage.

When running in CI, pytest writes results to `test-results/pytest-results.xml`.

Run JavaScript coverage from the `bot/` and `frontend/` directories:

```bash
npm run coverage

```
