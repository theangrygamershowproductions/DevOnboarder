# 🛠️ Onboarding: Documentation Quality Checks & Contribution Guide

## 🚀 Quickstart for Contributors

Welcome to the project! To keep our docs clear and professional, we run two tools:

* **Vale** – style and terminology checks
* **LanguageTool** – grammar and spelling

**You must pass both checks before pushing or opening a PR.**

---

### Step 1: Install All Dev Requirements

```bash
pip install -r requirements-dev.txt
```

---

### Step 2: Install Vale

* On macOS: `brew install vale`
* On Windows: `choco install vale`
* Or see [Vale Installation Docs](https://vale.sh/docs/installation/) for other platforms
* If the script cannot download Vale automatically, manually download `vale_3.4.2_Linux_64-bit.tar.gz` from the [releases page](https://github.com/errata-ai/vale/releases), extract the `vale` binary, and set `VALE_BINARY` to its path.
* **The project uses Vale 3.4.2. CI installs this version automatically**, but you still need it locally to run the checks before committing.

---

### Step 3: (Optional) Set Up Local LanguageTool Server

By default the project uses the public LanguageTool API, but CI or firewalls may block it. For local use or when offline:

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

Set this environment variable in your shell or profile for all checks.

---

### Step 4: Run Documentation Quality Checks

Before every push or PR, run:

```bash
bash scripts/check_docs.sh
```

This generates `vale-results.json` for machine-readable output, which CI stores as an artifact.

CI also saves `pytest-results.xml` when running the test suite. You can download
both artifacts from the **Artifacts** section of each GitHub Actions run to
review Vale output and debug failing tests.

This will fail if Vale is missing, run both Vale and LanguageTool, and print issues by file, line, and column.

CI also uploads `pytest-results.xml` when the test suite runs in GitHub Actions. Visit a workflow run, open the **Artifacts** drop-down, and download the file to review which tests failed and why.

---

### Step 5: Pre‑commit Integration (Recommended)

Install pre-commit hooks so documentation and code checks run automatically:

```bash
pre-commit install
```

The hooks run Black, Ruff, Prettier, Codespell, and our docs-quality script.
Codespell relies on `.codespell-ignore` for project-specific terms you want to
skip. The default list skips `DevOnboarder`, `nodeenv`, and `pyenv`.

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

### Troubleshooting

* **Vale not found:** install it as shown above or download the binary manually and set `VALE_BINARY` to its path.
* **Python errors:** ensure `pip install -r requirements-dev.txt` succeeded.
* **LanguageTool API issues:** run a local server and set `LANGUAGETOOL_URL` to its address.
* **pytest fails:** double-check that all dev dependencies are installed.

---

### More Info

* See [docs/CHANGELOG.md](CHANGELOG.md) for recent updates.
* For advanced configuration, check `.vale.ini` and `styles/DevOnboarder/`.
