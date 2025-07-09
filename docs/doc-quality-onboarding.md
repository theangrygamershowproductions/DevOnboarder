# 🛠️ Onboarding: Documentation Quality Checks & Contribution Guide

## 🚀 Quickstart for Contributors

Welcome to the project! Documentation style is checked with **markdownlint** and
**Vale**. Grammar checks with **LanguageTool** are optional.

---

### Step 1: Install All Dev Requirements

```bash
pip install -e .  # or `pip install -r requirements.txt` if present
pip install -r requirements-dev.txt
npm install
```

`npm install` installs **markdownlint-cli2**, which `scripts/check_docs.sh` runs
before Vale to enforce Markdown style.

Run these commands **before executing tests or documentation checks** so Python
imports resolve correctly.

---

### Step 2: Install Vale

* On macOS: `brew install vale`
* On Windows: `choco install vale`
* Or see [Vale Installation Docs](https://vale.sh/docs/installation/) for other platforms
* If the script cannot download Vale automatically, manually download `vale_3.12.0_Linux_64-bit.tar.gz` from the [releases page](https://github.com/errata-ai/vale/releases), extract the `vale` binary, and set the `VALE_BINARY` environment variable to its full path when it's not in `PATH`.
* **The project uses Vale 3.12.0. CI installs this version automatically**, but you still need it locally to run the checks before committing.

Run `bash scripts/check_dependencies.sh` to confirm Vale and the Node test tools are installed.

---

### Step 3: (Optional) Set Up Local LanguageTool Server

By default the project uses the public LanguageTool API, but CI or firewalls may block it. Start a local server if you want to run grammar checks:

```bash
docker run -d -p 8010:8010 --name languagetool \
  quay.io/languagetool/languagetool:latest
export LANGUAGETOOL_URL="http://localhost:8010"
```

You can also download a LanguageTool release from <https://languagetool.org/download/> and run it with Java:

```bash
java -jar languagetool-server.jar --port 8010 &
export LANGUAGETOOL_URL="http://localhost:8010"
```

Set this environment variable in your shell or profile when you want LanguageTool checks.

---

### Step 4: Run Documentation Quality Checks

Before every push or PR, run:

```bash
bash scripts/check_docs.sh
```

This script runs `markdownlint-cli2` and Vale to lint all Markdown files. It
generates `vale-results.json` for machine-readable output, which CI stores as an
artifact.

CI also saves `test-results/pytest-results.xml` when running the test suite. You can download
both artifacts from the **Artifacts** section of each GitHub Actions run to
review Vale output and debug failing tests.

The script downloads Vale if it's missing and prints a notice when a LanguageTool server is required for grammar checks.

CI also uploads `test-results/pytest-results.xml` when the test suite runs in GitHub Actions. Visit a workflow run, open the **Artifacts** drop-down, and download the file to review which tests failed and why.

---

### Step 5: Pre‑commit Integration (Recommended)

Install pre-commit hooks so documentation and code checks run automatically:

```bash
pre-commit install
```

The hooks run Black, Ruff, Prettier, Codespell, markdownlint, and our
docs-quality script.
Codespell relies on `.codespell-ignore` for project-specific terms you want to
skip. The default list skips `DevOnboarder`, `nodeenv`, and `pyenv`.

## Coverage Requirement

All code must maintain at least **95%** test coverage to pass CI. Coverage is
enforced for Python, the frontend, and the bot packages. Run coverage commands
locally before opening a pull request to avoid CI failures.

### Vale Ignore Patterns & Codespell Hook

The project now defines ignore patterns in `.vale.ini` to skip fenced code
blocks, indented code, YAML frontmatter, and `auto-gen` sections. If a snippet
still triggers warnings, wrap it between `<!-- vale off -->` and `<!-- vale on -->`.

`.pre-commit-config.yaml` runs Vale and Codespell automatically once you execute
`pre-commit install`, so every commit is checked for style issues and typos.

---

### Batch‑Fixing Documentation

When many files share typos or inconsistent formatting, fix them in bulk:

```bash
codespell -w docs/
npx prettier -w "docs/**/*.md"
bash scripts/check_docs.sh
```

Check the results carefully and create **small, focused pull requests** so each
one is easy to review and merge without conflicts.

---

### Adding New Codespell Ignore Terms

If Codespell flags a project-specific word (for example, a brand or tool name),
append it to `.codespell-ignore` in the repository root. Add one term per line
and commit the change with your documentation update.

---

### Troubleshooting

* **Vale not found:** install it as shown above or download the binary manually and set `VALE_BINARY` to its path.
* **Python errors:** ensure `pip install -e .` (or `pip install -r requirements.txt`) and `pip install -r requirements-dev.txt` succeeded.
* **LanguageTool API issues:** run a local server and set `LANGUAGETOOL_URL` to its address if you want to run grammar checks.
* **pytest fails:** double-check that all dev dependencies and the project itself are installed.

### Known Limitations

- **LanguageTool Skips Large Files:**
  When a Markdown file exceeds LanguageTool's request size limit, grammar checks
  are skipped. Spelling and style are still enforced via Codespell and Vale.
  Run LanguageTool manually on smaller sections or split the file if you need a
  full grammar review.

- **Suppressing False Positives:**
  Add valid project terms to `.codespell-ignore` and use Vale suppression
  comments (`<!-- vale off -->` ... `<!-- vale on -->`) for persistent warnings
  in code blocks or technical docs.

### CI Policy

- **Spelling errors block merging.** Codespell runs in pre-commit and CI. Fix typos or add valid project terms to `.codespell-ignore`.
- **Formatting warnings do not block CI.** Vale emits GitHub warnings and LanguageTool runs only when configured. Address issues when touching the affected files.
- Large files skipped by LanguageTool are documented above; run it manually on sections if you want a full grammar review.

---

### More Info

* See [docs/CHANGELOG.md](CHANGELOG.md) for recent updates.
* For advanced configuration, check `.vale.ini` and `styles/DevOnboarder/`.
