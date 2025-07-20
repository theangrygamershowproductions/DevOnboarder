# CI Environment Variables

This page summarizes variables referenced in GitHub Actions workflows. Use these
values when running CI jobs locally or configuring new workflows.

| Variable | Where to set | Required scopes | Purpose | Notes |
| -------- | ------------ | --------------- | ------- | ----- |
| `AUTH_URL` | Workflow `env` block | n/a | Base URL for auth service during E2E tests | Set to `http://localhost:8002` in CI |
| `CHECK_HEADERS_URL` | Workflow `env` block | n/a | Endpoint checked by `scripts/check_headers.py` | Defaults to the auth user endpoint |
| `CI_BOT_USERNAME` | GitHub Actions variable | n/a | GitHub username used to assign CI failure issues | |
| `CI_BUILD_OPENAPI` | GitHub Actions secret | n/a | OpenAI service account key used in CI | Use instead of `OPENAI_API_KEY` whenever present |
| `CI_HELPER_AGENT_KEY` | GitHub Actions secret | n/a | Secret token for the CI Helper Agent | Used by `review-known-errors.yml` |
| `CI_ISSUE_TOKEN` | GitHub Actions secret | `issues: write` | Token used to open rate-limit issues in `ci-monitor.yml` | Optional; falls back to `GITHUB_TOKEN` when unset |
| `DEV_ORCHESTRATION_BOT_KEY` | GitHub Actions secret | n/a | Secret token for the dev orchestrator workflow | Passed as `ORCHESTRATION_KEY` |
| `ENV_VAR_MANAGER_KEY` | GitHub Actions secret | n/a | Token for the EnvVar Manager to open misalignment issues | Used by `secrets-alignment.yml` |
| `GH_TOKEN` | GitHub Actions secret or local environment | `issues: write`, `pull_requests: write` if used for cross-repo operations | Token consumed by the GitHub CLI to comment on PRs and manage issues | Usually set to `${{ secrets.GITHUB_TOKEN }}` in workflows |
| `GITHUB_REPOSITORY` | Auto-injected by GitHub | n/a | `owner/repo` string identifying the project | Used by `post_coverage_comment.py` |
| `GITHUB_RUN_ID` | Auto-injected by GitHub | n/a | Unique ID for the workflow run | Used when generating coverage links |
| `GITHUB_SERVER_URL` | Auto-injected by GitHub | n/a | Hostname for the current GitHub instance | Used by `post_coverage_comment.py` |
| `GITHUB_TOKEN` | Auto-injected by GitHub | Determined by `permissions` in the workflow | Authenticate API requests and push commits during CI | Provided automatically; expires after each job |
| `NPM_TOKEN` | GitHub Actions secret | `publish` (npm) | Authenticate `npm publish` when releasing packages | Not currently used but reserved for future publishing steps |
| `ONBOARDING_AGENT_KEY` | GitHub Actions secret | n/a | Secret token for the Onboarding Agent | Used by the onboarding-agent workflow |
| `PROD_ORCHESTRATION_BOT_KEY` | GitHub Actions secret | n/a | Secret token for the production orchestrator workflow | Passed as `ORCHESTRATION_KEY` |
| `STAGING_ORCHESTRATION_BOT_KEY` | GitHub Actions secret | n/a | Secret token for the staging orchestrator workflow | Passed as `ORCHESTRATION_KEY` |
| `TRIVY_VERSION` | Workflow `env` block | n/a | Selects the Trivy version for container scanning | Defaults to `0.47.0` |
| `VALE_VERSION` | Workflow `env` block or local environment | n/a | Choose the Vale linter version for docs checks | Defaults to `3.12.0` |
| `VALIDATE_PERMISSIONS_KEY` | GitHub Actions secret | `pull_requests: write` | Token used by `validate-permissions.yml` to comment on PRs | Optional; falls back to `${{ secrets.GITHUB_TOKEN }}` when unset |

