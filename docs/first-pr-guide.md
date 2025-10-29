---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: first-pr-guide.md-docs
status: active
tags: 
title: "First Pr Guide"

updated_at: 2025-10-27
visibility: internal
---

# First PR Walkthrough

![Contribute in 10 minutes](https://example.com/first-pr.gif)

This short guide shows how to make your first contribution.
It assumes you have already set up Docker, Node.js and Python as described in the main README.

1. **Clone the repository**

    ```bash

    git clone https://github.com/your-username/DevOnboarder.git
    cd DevOnboarder
    ```

2. **Install the commit message hook** so your commits pass CI checks.

    ```bash
    bash scripts/install_commit_msg_hook.sh
    ```

3. **Install git hooks** so lint and test checks run before each commit.

    ```bash
    pre-commit install
    ```

4. **Understand DevOnboarder Quality Standards**:

    - **Terminal Output Policy**: No emojis or command substitution in workflows (causes system hanging)

    - **Markdown Linting**: Follow MD022 (heading spacing) and MD032 (list spacing) rules

    - **Pre-commit Enforcement**: All policies validated before code reaches CI

    Review [docs/TERMINAL_OUTPUT_VIOLATIONS.md](TERMINAL_OUTPUT_VIOLATIONS.md) for details.

5. **Create a branch** from `main` for your change.

    ```bash
    git checkout -b feature/my-first-change
    ```

6. **Run the checks**. The helper script installs requirements and runs the linters and tests with coverage.

    ```bash
    bash scripts/run_tests.sh
    ```

    If any step fails, fix the issues and re-run the script until everything passes.

7. **Commit and push** your work.

    ```bash
    git add .
    git commit -m "FEAT: add my first contribution"
    git push origin feature/my-first-change
    ```

8. **Open a pull request** on GitHub and fill out the template. CI must pass before the PR can be merged.

Refer to `docs/sample-pr.md` for a minimal example and `docs/git-guidelines.md` for commit message conventions.
