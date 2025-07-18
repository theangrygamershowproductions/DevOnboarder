# Continuous Integration Workflow

The `ci.yml` workflow runs on every push and pull request. It sets up Python
3.12 and Node.js 20 before building the containers and executing the test
suites.

## Concurrency

A concurrency group of `${{ github.workflow }}-${{ github.ref }}` cancels
in-progress runs when a new commit pushes to the same branch. This prevents
stale jobs from consuming minutes.

## Documentation Filter

The workflow runs `dorny/paths-filter` before other jobs. When the filter
detects that only files under `docs/` or Markdown files were modified, the
remaining jobs do not run. This keeps documentation-only pull requests fast.

## Minimal Checks

A `validate-yaml` job always runs first and lints the workflow files with
`ibiqlik/action-yamllint`. This step executes even when the documentation filter
skips the heavier test job or when a commit message contains `[no-ci]`.
It also uploads a `yamllint.log` artifact containing the full lint output.

## Skipping the Test Job

Pushes can opt out of the main test job by including `[no-ci]` anywhere in the
commit message. Pull requests ignore this marker and run the full workflow.

## Caching

The job caches several directories to speed up subsequent runs:

- `~/.cache/pip` for Python packages
- `frontend/node_modules` and `bot/node_modules` for JavaScript dependencies
- `~/.cache/ms-playwright` for Playwright browsers

Cache keys include the runner OS, language version, and the related lock files
so mismatched dependencies do not restore.

## Coverage Requirements

Both Python and JavaScript tests must maintain at least **95%** coverage. The
workflow fails if any suite drops below this threshold. Coverage reports are
uploaded as artifacts, and pull requests receive a summary comment generated by
`scripts/post_coverage_comment.py`.

## GitHub CLI

Workflows rely on the GitHub CLI that comes preinstalled in the container image
or set it up with the `ksivamuthu/actions-setup-gh-cli` action. Each job prints
the install path and version with `which gh && gh --version` so the logs show
exactly which binary is in use.

## Formatting

The job runs `black --check .` after installing development requirements. Formatting issues cause the build to fail.

## Codex Auto-Fixes

Codex's `monitor-ci` task watches this workflow. When a lint step fails, the bot
runs `ruff --fix` and `pre-commit run --files` on the affected files. If the
patch applies cleanly, Codex commits the changes. Otherwise it opens a pull
request titled **"chore: auto-fix lint errors via Codex"** summarizing the
adjustments.

## Environment Variable Audit

After `.env.dev` is generated, the workflow runs `scripts/audit_env_vars.sh`.
The script compares the generated environment file to the example files and
fails if any variables are missing or extra. The step writes `env_audit.json`
so the `secrets-alignment.yml` workflow can reuse the results. When the audit
fails, the CI failure issue automation records the details so maintainers can
investigate.

The `secrets-alignment.yml` workflow runs when the audit step fails or on a
daily schedule. It reruns the environment audit and opens an issue using the
Secret Alignment template if variables are missing or extra.

After the Black formatting check, CI runs `python scripts/check_env_docs.py`.
This script compares the environment variable table in `agents/index.md` with
the example `.env` files. Any differences cause the job to fail so the
documentation stays in sync with the environment configuration.

The `env-doc-alignment.yml` workflow runs when this step fails. It reruns
`check_env_docs.py`, parses the missing variables from the output, and opens a
Secret Alignment issue with the commit SHA. The issue lists the missing
variables so maintainers know which entries to add to `agents/index.md`.

## Security Scans

After the environment checks, the job runs three dependency audits:

- `pip-audit` runs immediately after the development requirements install. An
  exit code of `1` indicates vulnerable dependencies and fails the job. Other
  non-zero codes usually mean the tool couldn't download the vulnerability database. In that case the step logs `pip-audit failed. See [docs/offline-setup.md](offline-setup.md) for offline instructions.` and
  continues to the next audit.
- `bandit -r src -ll` scans the Python code for vulnerabilities.
- `npm audit --audit-level=high` runs in both `frontend/` and `bot/`.

Any reported high severity issues cause the workflow to fail. The detailed
results appear in the job log, which is uploaded as a CI artifact so
maintainers can review the findings.

## Codex CI Monitoring

Codex watches the CI workflow using `codex.ci.yml`. When a job fails due to lint
errors, the `monitor-ci` task attempts an automatic fix by running `ruff --fix`
and `pre-commit run --files` on the affected files. If the patch applies safely,
Codex commits the change and reruns the build; otherwise it opens a pull
request.
