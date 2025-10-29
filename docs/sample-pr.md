---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: sample-pr.md-docs
status: active
tags: 
title: "Sample Pr"

updated_at: 2025-10-27
visibility: internal
---

# Sample Pull Request

This guide demonstrates a minimal documentation update using the project workflow.

1. Create a branch from `main`:

    ```bash
    git checkout -b feature/sample-pr
    ```

2. Make a small change, such as adding this file.

3. Run the pre-PR checks:

    ```bash
    pip install -e .
    pip install -r requirements-dev.txt
    ruff check .
    pytest --cov=src --cov-fail-under=95
    ```

    - run `bash scripts/check_docs.sh`

    - add a changelog entry in `docs/CHANGELOG.md`

    - see [.github/pull_request_template.md](../.github/pull_request_template.md) for the full checklist

4. Commit your work and open a pull request using `.github/pull_request_template.md`.

Use this example as a reference when submitting your first contribution.
