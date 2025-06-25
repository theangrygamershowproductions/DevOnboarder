# Project Onboarding Guide

This page collects helpful tips for new contributors. Follow [docs/README.md](README.md) for a complete development setup.

## Requesting a Full QA Sweep

Codex can run a comprehensive quality assessment of the repository. To trigger this check, comment on a pull request or issue with:

```text
@codex run full-qa
```

Codex will parse CI results, run additional analysis, and create tasks for any failures it finds. Merges are blocked until critical issues from the sweep are resolved.
