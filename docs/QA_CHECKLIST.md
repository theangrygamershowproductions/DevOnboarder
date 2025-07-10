# Documentation & QA Checklist

Use this list before requesting a review or when Codex posts a QA report.

- [ ] All Python and JS dependencies installed (`pip install -e .` or `pip install -r requirements.txt`, then `pip install -r requirements-dev.txt`; `npm ci` if needed)
- [ ] Vale is installed locally (`vale --version`)
- [ ] All Markdown docs pass checks (`bash scripts/check_docs.sh`)
- [ ] All new or updated docs are clear, concise, and free of grammar issues
- [ ] pytest and other test suites pass
- [ ] Pre-commit hooks installed (`pre-commit install`)
- [ ] If doc checks failed, issues are resolved before requesting review
- [ ] If pre-commit cannot download Node.js, review [Network troubleshooting](network-troubleshooting.md#pre-commit-nodeenv-ssl-errors)

# Checklist

- [ ] All code passes lint, type, and security checks
- [ ] All new ENV variables are documented in `agents/index.md`
- [ ] `.env.example` matches the table in `agents/index.md`
- [ ] OpenAPI/contract and migration checks pass
- [ ] All API endpoints have docstrings and documentation
- [ ] CORS and security headers validated
- [ ] No secrets or sensitive data are present in commits
- [ ] Codex did **not** introduce any direct commits to `main`
- [ ] Documentation passes `bash scripts/check_docs.sh`
- [ ] Are all Codex changes covered by tests and docs?
- [ ] Coverage does not decrease (see CI summary)
