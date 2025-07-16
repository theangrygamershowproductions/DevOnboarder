# QA Checklist

Use this checklist alongside the [git guidelines](git-guidelines.md) and the [pull request template](../.github/pull_request_template.md).

## Architecture & Code Quality
- [ ] Lint, type, and security checks succeed
- [ ] Commit messages follow our conventions
- [ ] Pre-commit hooks are installed and run
- [ ] Shell scripts pass `shellcheck`

## CI/CD & Test Coverage
- [ ] All test suites pass
- [ ] Coverage does not decrease
- [ ] OpenAPI and migration checks succeed

## Documentation
- [ ] `bash scripts/check_docs.sh` runs without errors
- [ ] Vale installed (`vale --version`)
- [ ] New docs are clear and free of grammar issues
- [ ] Environment variables documented in `agents/index.md`
- [ ] `TAGS_MODE` and related flags explained

## Deployment and Environment
- [ ] `.env.example` matches documented variables
- [ ] CORS and security headers validated
- [ ] No secrets or sensitive data in commits
- [ ] TAGS compose files or overrides present

## Plugin System
- [ ] Plugins under `plugins/` register with `devonboarder.PLUGINS`
- [ ] Plugin documentation updated

## Additional Checks
- [ ] Changelog entry added
- [ ] README and other relevant docs updated
- [ ] Codex did **not** introduce direct commits to `main`

## Codex Integration
- [ ] Codex tasks run clean
- [ ] Dashboard shows no blocks
- [ ] Bot comments resolved

## Discord Integration
- [ ] Bot commands tested
- [ ] OAuth flow verified
- [ ] Roles mapped

## Ethics
- [ ] Follows builder ethics dossier
- [ ] No coercive UX
- [ ] Privacy notices visible

## Ecosystem Integration
- [ ] API contracts aligned
- [ ] ENV vars consistent
- [ ] Inter-service tests pass

## Operational Readiness
- [ ] Staging healthchecks pass
- [ ] Alerts verified
- [ ] Error logs reviewed
- [ ] Diagnostics run against TAGS stack when applicable

## Project Management
- [ ] PR links to issue or task
- [ ] Acceptance criteria met
- [ ] Board updated

## Community
- [ ] Contributor guide referenced
- [ ] Code of Conduct linked
- [ ] Feedback channels open
