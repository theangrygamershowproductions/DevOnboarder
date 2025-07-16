# Sample Pull Request

This guide demonstrates a minimal documentation update using the project workflow.

1. Create a branch from `main`:
   ```bash
   git checkout -b feature/sample-pr
   ```
2. Make a small change, such as adding this file.
3. Run the pre-PR checks:
   ```bash
   pip install -e .
   pip install -r requirements-dev.txt
   ruff check .
   pytest --cov=src --cov-fail-under=95
   ```

   * run `bash scripts/check_docs.sh`
   * add a changelog entry in `docs/CHANGELOG.md`
   * see [.github/pull_request_template.md](../.github/pull_request_template.md) for the full checklist
4. Commit your work and open a pull request using `.github/pull_request_template.md`.

Use this example as a reference when submitting your first contribution.
