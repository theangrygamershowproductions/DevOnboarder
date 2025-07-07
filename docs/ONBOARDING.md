# Project Onboarding Guide

This page collects helpful tips for new contributors. Follow [docs/README.md](README.md) for a complete development setup.

## Requesting a Codex QA Assessment

* **To trigger a full QA sweep:** Simply comment

  ```sh
  @codex run full-qa
  ```

  on any Pull Request or GitHub Issue.
* **What this does:** Codex will analyze CI logs, code quality, test coverage, lint results, and documentation checks. It will reply with a **detailed checklist** of all issues it finds—each with actionable tasks you can assign, discuss, or address.
* **Note:** You must resolve all critical issues before merging, per project policy.
* The CI workflow enforces a minimum of **95% code coverage** across the frontend, bot, and backend projects. Pull requests will fail if any suite drops below this threshold.

### Sample Codex QA Response

After you comment `@codex run full-qa`, Codex replies directly to your comment with a checklist like:

### What happens next?

After you comment `@codex run full-qa`, Codex replies directly to your comment with a checklist similar to:

```markdown
- ❌ Lint: 3 Python files have PEP8 errors (see ruff logs)
 - ❌ Test: 1 backend test failed (see test-results/pytest-results.xml)
- ⚠️ Docs: 12 Vale/LanguageTool warnings (docs/README.md)
- ⚠️ Security: 1 dependency flagged by pip-audit
- ✅ All workflows run with correct tool versions
```

Each line links to the CI logs or artifacts so you can jump straight to the problem.

Codex posts this checklist as a reply to your `@codex run full-qa` comment. If you see `⚠️ Docs: Lint skipped`, the documentation step failed (usually due to network issues). You may merge if all other checks pass, but run `bash scripts/check_docs.sh` locally when possible.

For more help, see [Network troubleshooting](network-troubleshooting.md) and the Codex FAQ.

**Troubleshooting:**
If Codex does not respond, make sure:

* Codex bot is installed and has permission to comment and create issues.
* Workflow files (such as `.github/workflows/codex.ci.yml`) include `full-qa` as a supported command.

`pytest.ini` sets `pythonpath=src` so tests can locate `devonboarder`.
Install the project in editable mode before running the tests to ensure
all dependencies are available:

```bash
pip install -e .
pip install -r requirements-dev.txt
```

If Vale or LanguageTool cannot run due to network errors, Codex marks the documentation step as a "⚠️ Docs: Lint skipped" warning. You can still merge if all other required checks pass, but please run docs checks locally later to catch formatting errors.

### Optional Easter Egg (for fun!)

You could add:

> Want to know the secret identity of Potato?
> Try commenting `@codex who-is-potato` in any issue for a surprise!

Codex will reply with a short, Potato-themed message on the same thread. The bot rotates through a few quirky facts, so feel free to try again later for a different response!
