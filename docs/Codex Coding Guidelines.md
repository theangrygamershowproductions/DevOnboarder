---
project: "TAGS"
module: "DevSecOps"
phase: "Codex Setup"
tags: ["codex", "scaffold", "guidelines", "devonboarder"]
updated: "09 June 2025 20:35 (EST)"
version: "v0.4.0"
-----------------

# Codex Coding Guidelines — DevOnboarder & CI Scaffold

> **Purpose**
> Provide a single, enforceable rule-set and boiler-plate that Codex (Copilot-X), DevOnboarder, CI runners, and human contributors must follow.
Every rule here is wired into the scaffold
so violations surface automatically at commit time or in CI.

---

## 1  Language & Runtime Matrix

| Stack      | Version  | Enforcement                                                                                    |
| ---------- | -------- | ---------------------------------------------------------------------------------------------- |
| **Python** | **3.13** | • `.python-version` + `pyproject.toml` + `tox.ini`  <br>• CI job asserts `python -V` = 3.13.* |
| **Node**   | **22**   | • `.nvmrc`  <br>• `package.json → engines`  <br>• `actions/setup-node@v4 node-version: 22`     |

---

## 2  Code-style Rules (all languages)

* **Line length:** 79 chars hard wrap.
* **Python f-strings:** break long strings with *adjacent literal concatenation* only.
* **Lint stack:**
  * Python → `flake8` + `flake8-implicit-str-concat` (config in `.flake8`).
  * JS/TS → `eslint` (Node 22 parser, TS 5.x).
* **Mandatory Pre-Commit Hooks:** defined in `.pre-commit-config.yaml`; installed locally by `DevOnboarder` and executed in CI.

---

## 3  Commit & History Policy

| Rule                              | Detail                                                                                                                                | Tooling Enforcement                                                                |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| **No history rewrites**           | Never `amend`, `rebase --force`, or `push --force` to shared branches.                                                                | Branch protection denies non-fast-forward pushes.                                  |
| **Follow-up commits for fixes**   | If you need to correct a bad commit message or minor metadata, make an *empty* or small follow-up commit referencing the original SHA. | PR template reminds author; message-lint allows `fix/docs/chore: follow-up` types. |
| **Signed & Conventional commits** | All commits must be GPG-signed and follow `<type>(<scope>): <msg>` format.                                                            | `commitlint` & `git config commit.gpgsign true`.                                   |

> **Codex instruction:** *Never request `git commit --amend` or `git rebase -i`.  Generate a new commit instead.*

### Example follow-up commit

```bash
# no code changes needed
git commit --allow-empty -m "docs(changelog): follow-up to 4a1b2c3 – clarify message"
```

---

## 4  CI Workflow Outline (GitHub)

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: 'pnpm'
      - name: Install Python 3.13
        uses: actions/setup-python@v5
        with:
          python-version: '3.13'
      - run: pip install -r .codex/requirements-lint.txt pre-commit
      - run: pre-commit run --all-files
      - run: ./scripts/setup-dev.sh --offline
      - run: pytest -q
```

Codex’s offline runner mirrors this layout but uses a Docker image that already contains Python 3.13 and Node 22.

---

## 5  DevOnboarder Scaffold Checklist

* Copy `.nvmrc`, `.python-version`, `.pre-commit-config.yaml`, `.flake8`, `.editorconfig`.
* Install hooks (`pre-commit install`) and ensure Node 22 via `nvm use`.
* Generate `.env-manifest.yml` and append any new secrets.

---

## 6  Reference Docs

* **Env Vars manifest:** see *TAGS : codex_env_vars.md*.
* **Branch & team mapping:** see *TAGS : Team → Repo Mapping.md* (TBD).

---

*End of Guidelines*
