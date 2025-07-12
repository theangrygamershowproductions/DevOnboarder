# CI Environment Variables

This page summarizes variables referenced in GitHub Actions workflows. Use these
values when running CI jobs locally or configuring new workflows.

| Variable | Where to set | Required scopes | Purpose | Notes |
| -------- | ------------ | --------------- | ------- | ----- |
| `GITHUB_TOKEN` | Auto-injected by GitHub | Determined by `permissions` in the
  workflow | Authenticate API requests and push commits during CI | Provided
  automatically; expires after each job |
| `GH_TOKEN` | GitHub Actions secret or local environment | `issues: write`,
  `pull_requests: write` if used for cross-repo operations | Token consumed by
  the GitHub CLI to comment on PRs and manage issues | Usually set to `${{ secrets.GITHUB_TOKEN }}` in workflows |
| `CI_ISSUE_TOKEN` | GitHub Actions secret | `issues: write` | Token used to open rate-limit issues in `ci-monitor.yml` | Optional; falls back to `GITHUB_TOKEN` when unset |
| `NPM_TOKEN` | GitHub Actions secret | `publish` (npm) | Authenticate `npm
  publish` when releasing packages | Not currently used but reserved for future
  publishing steps |
| `VALE_VERSION` | Workflow `env` block or local environment | n/a | Choose the
  Vale linter version for docs checks | Defaults to `3.12.0` |
| `TRIVY_VERSION` | Workflow `env` block | n/a | Selects the Trivy version for
  container scanning | Defaults to `0.47.0` |
| `AUTH_URL` | Workflow `env` block | n/a | Base URL for auth service during E2E
  tests | Set to `http://localhost:8002` in CI |
| `CHECK_HEADERS_URL` | Workflow `env` block | n/a | Endpoint checked by
  `scripts/check_headers.py` | Defaults to the auth user endpoint |
| `GITHUB_SERVER_URL` | Auto-injected by GitHub | n/a | Hostname for the current
  GitHub instance | Used by `post_coverage_comment.py` |
| `GITHUB_REPOSITORY` | Auto-injected by GitHub | n/a | `owner/repo` string
  identifying the project | Used by `post_coverage_comment.py` |
| `GITHUB_RUN_ID` | Auto-injected by GitHub | n/a | Unique ID for the workflow
  run | Used when generating coverage links |

