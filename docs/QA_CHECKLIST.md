# QA Checklist

Use this checklist alongside the [git guidelines](git-guidelines.md) and the [pull request template](pull_request_template.md).

## Code Quality
- [ ] Lint, type, and security checks succeed
- [ ] Commit messages follow our conventions
- [ ] Pre-commit hooks are installed and run

## Testing
- [ ] All test suites pass
- [ ] Coverage does not decrease
- [ ] OpenAPI and migration checks succeed

## Documentation
- [ ] `bash scripts/check_docs.sh` runs without errors
- [ ] Vale installed (`vale --version`)
- [ ] New docs are clear and free of grammar issues
- [ ] Environment variables documented in `agents/index.md`

## Deployment and Environment
- [ ] `.env.example` matches documented variables
- [ ] CORS and security headers validated
- [ ] No secrets or sensitive data in commits

## Plugin System
- [ ] Plugins under `plugins/` register with `devonboarder.PLUGINS`
- [ ] Plugin documentation updated

## Additional Checks
- [ ] Changelog entry added
- [ ] README and other relevant docs updated
- [ ] Codex did **not** introduce direct commits to `main`
