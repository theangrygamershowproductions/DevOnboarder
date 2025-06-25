# Summary

<!-- Provide a concise description of the change. Highlight major updates or new functionality. -->

# Linked Issues

<!-- List related issues. Use the `Closes #issue-number` syntax when applicable. -->

# Screenshots

<!-- Include before/after screenshots or GIFs if the change affects UI. -->

# Testing Steps

<!-- Detail how a reviewer can verify the change. Include any setup commands. -->

```bash
ruff check .
pytest -q
bash scripts/check_docs.sh
```

## Documentation & QA Checklist

Refer to [doc-quality-onboarding.md](doc-quality-onboarding.md) for setup steps.

- [ ] All Python and JS dependencies installed (`pip install -e .` and `pip install -r requirements-dev.txt`, `npm ci` if needed)
- [ ] Vale is installed locally (`vale --version`)
- [ ] All Markdown docs pass checks (`bash scripts/check_docs.sh`)
- [ ] All new or updated docs are clear, concise, and free of grammar issues
- [ ] pytest and other test suites pass
- [ ] Pre-commit hooks installed (`pre-commit install`)
- [ ] If doc checks failed, issues are resolved before requesting review
- [ ] If pre-commit cannot download Node.js, review [Network troubleshooting](network-troubleshooting.md#pre-commit-nodeenv-ssl-errors)

# Checklist

- [ ] All code passes lint, type, and security checks
- [ ] All new ENV variables are documented in `docs/Agents.md`
- [ ] `.env.example` matches the table in `docs/Agents.md`
- [ ] OpenAPI/contract and migration checks pass
- [ ] All API endpoints have docstrings and documentation
- [ ] CORS and security headers validated
- [ ] No secrets or sensitive data are present in commits
- [ ] Codex did **not** introduce any direct commits to `main`
- [ ] Documentation passes `bash scripts/check_docs.sh`
- [ ] Are all Codex changes covered by tests and docs?
- [ ] Coverage does not decrease (see Codecov status)

# Reviewer Sign-Off

- [ ] I, the reviewer, confirm the checklist above is complete.
