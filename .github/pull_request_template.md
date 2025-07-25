# PR Review Checklist

## Documentation & QA Checklist

Refer to [doc-quality-onboarding.md](../docs/doc-quality-onboarding.md) for setup instructions.

- Review [docs/QA_CHECKLIST.md](../docs/QA_CHECKLIST.md) for manual QA steps.

- [ ] All Python and JS dependencies installed (`pip install .[test]`, `npm ci` if needed)
- [ ] Vale is installed locally (`vale --version`)
- [ ] All Markdown docs pass checks (`bash scripts/check_docs.sh`)
- [ ] All new or updated docs are clear, concise, and free of grammar issues
- [ ] pytest and other test suites pass
- [ ] Pre-commit hooks installed (`pre-commit install`)
- [ ] If doc checks failed, issues are resolved before requesting review

## Code Checklist

- [ ] All code passes automated lint, type, test, and security checks
- [ ] OpenAPI, contract, and migration checks pass
- [ ] All FastAPI endpoints include docstrings and documentation
- [ ] CORS and security headers validated
- [ ] No secrets or sensitive data are present in commits
- [ ] Did Codex introduce any direct commits to `main`?
- [ ] Are all Codex changes covered by tests and docs?
- [ ] Coverage does not decrease (see CI summary)
- [ ] This PR updates `.codex/automation-tasks.md`. I have reviewed the automation impact and notified reviewers.

_Reviewer Sign-Off_

- [ ] I confirm all checklist items are complete.

## Continuous Improvement Checklist

- [ ] `docs/checklists/continuous-improvement.md` reviewed and all items checked
- [ ] Relevant retrospective updated under `docs/checklists/retros/`
