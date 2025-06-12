---
project: "TAGS"
module: "Documentation Tools"
phase: "Maintenance Automation"
tags: ["metadata", "markdown", "indexing", "automation"]
updated: "12 June 2025 09:33 (EST)"
version: "v1.2.6"
author: "Chad Allan Reesey (Mr. Potato)"
email: "education@thenagrygamershow.com"
description: "Manages indexing and metadata injection for project documentation."
---

# Documentation Tools – Maintenance Automation
<!-- markdownlint-disable-file MD041 -->

---

project: "TAGS"
module: "Agents"
phase: "MVP"
tags: \["codex", "openai", "ci", "agents", "automation", "documentation", "observability", "metrics", "security", "kill-switch", "license-compliance", "prompt-templates", "capability-addons"]
updated: "08 June 2025 04:00 (EST)"
version: "v1.5.2"
author: "Chad Allan Reesey"
email: "[potato@thenagrygamershow.com](mailto:potato@thenagrygamershow.com)"
----------------------------------------------------------------------------

Agents Documentation – MVP
==========================

Agents are automated entities that execute repeatable workflows, enforce
standards, and keep the **DevOnboarder** stack humming. Every Agent is
version‑controlled, peer‑reviewed, observable, cost‑capped, and
**human‑override‑able**—so our automation never becomes "automagic
chaos." This file is the *single source of truth* for Agent behaviour,
policy **and live configuration**.  When it eventually grows unwieldy we
will factor sections into sub‑modules, but for Phase MVP we keep it all
here so nothing slips through the cracks.

---

📋 Overview
==========================

* **Codex Evaluator Agent** – scores challenge submissions.
* **CI/CD Build Agent** – lints, tests, deploys.
* **Security Scan Agent** – nightly vulnerability scans.
* **License Scan Agent** – blocks non‑permissive licenses.
* **Documentation Sync Agent** – keeps docs up‑to‑date.
* **AuthAgent** – handles signup / JWT.
* **ChallengeAgent** – orchestrates evaluator.
* **ReportingAgent** – aggregates dashboard data.
* **NotificationAgent** – emails + in‑app pings.

---

Defined Runtime Agents
==========================

| Agent                 | Responsibilities                                                              |
| --------------------- | ----------------------------------------------------------------------------- |
| **AuthAgent**         | User signup, login, JWT issuance, password hashing, role assignment           |
| **ChallengeAgent**    | Receives challenge submissions, validates via Codex‑evaluator, records scores |
| **ReportingAgent**    | Aggregates user progress data, produces dashboards, sends notifications       |
| **NotificationAgent** | Sends email and in‑app notifications (e.g., “You passed the SQL challenge!”)  |

---

🌐 Global Conventions
==========================

| Convention                                                                    | Purpose                               |
| ----------------------------------------------------------------------------- | ------------------------------------- |
| **Code style**: 79‑char lines, PEP 257 docstrings, adjacent `f"" f""` strings | Ensures Codex output merges cleanly.  |
| **Markdown**: inline math `$x^2$`, block math `$$x$$`, no KaTeX               | Matches accessibility preference.     |
| **File headers**: version, updated, author                                    | Lets Codex stamp generated files.     |
| **Commit template**: semantic, per‑file semver bump                           | Aligns with per‑file versioning plan. |

---

🛠 Codex Quick‑Start
==========================

1. **API key** – `OPENAI_API_KEY` lives in `.env.development` (see `scripts/create-env.sh`).

2. **Model pin** – use `--model gpt-4o-mini-2025-05-15` for deterministic output.

3. **Local use**

   ```bash
   codex --model gpt-4o-mini-2025-05-15 --quiet "Generate FastAPI route /status"
   ```

4. **Dev‑container** auto‑injects `${localEnv:OPENAI_API_KEY}`.

5. **CI usage** – workflow `codex.yaml` runs Codex in Docker image `codex-ci` with `--approval-mode auto-edit --deny-shell wildcards --deny-shell destructive --quiet`.

6. **Smoke test** – `python scripts/openai_smoke.py` fails build on auth or quota issues.

7. **Kill‑switch** – set repo secret `CANCEL_CODEX=true` *or* add PR label `no-codex` to abort jobs immediately.

---

🔗 Allowed Codex Modes
==========================

| Mode        | When to use             | Guardrails                          |
| ----------- | ----------------------- | ----------------------------------- |
| `suggest`   | Small fixes             | Manual commit required              |
| `auto-edit` | Boilerplate/refactor    | Feature branches only, CI must pass |
| `full-auto` | **Forbidden on** `main` | Opens PR, human review required     |

---

🔒 Security & Compliance Checklist
==========================

* `.env.example` includes `OPENAI_API_KEY` placeholder.
* Secrets in `.env.*` or GitHub Secrets only; rotate every **90 days** via `scripts/rotate-secret.sh`.
* Pre‑commit `detect-secrets` blocks committing keys.
* License Scan Agent runs `license-finder`; build fails on non‑permissive licenses.
* No untracked env files (`.env.local`, `.env.*.bak`).

---

💰 Cost Guardrail Hook
==========================

Script `scripts/check-quota.py` queries OpenAI usage. If spend ≥ **80 %** of the \$15 budget, Codex CI exits 1.

---

🔭 Observability'
==========================

* **Logs** – JSON on stdout; levels `debug`→`critical`.
* **Metrics** – Prometheus text at `:PORT/metrics`.
* **Trace IDs** – propagate `X‑Request‑ID`.
* **Retention** – 90 days hot in Loki, 1 year cold in S3 Glacier.

---

🩺 Health, SLA & Rollback
==========================

* **/healthz** – liveness; **/readyz** – dependency check.
* **SLA** – MTTR < 15 min; error budget 0.1 % / 30 min.
* **Auto‑rollback** – two failed CI runs disables the Agent.

---

🐞 Error Taxonomy
==========================

| Exit Code | Meaning                            | GitHub Check |
| --------- | ---------------------------------- | ------------ |
| `0`       | Success                            | ✅            |
| `42`      | `E_CONFIG` – bad env               | ⚠️           |
| `43`      | `E_DEPENDENCY` – external down     | ❌            |
| `44`      | `E_INTERNAL` – unhandled exception | ❌            |
| `45`      | `E_QUOTA` – cost cap               | ❌            |
| `46`      | `E_LICENSE` – forbidden license    | ❌            |

---

📈 Quality Gates
==========================

* **Coverage** – `pytest --cov --cov-fail-under=85`.
* **Hallucination guard** – Codex runs with shell‑deny flags.

---

👥 Ownership & Paging
==========================

| Agent            | Primary      | Backup      | Rotation |
| ---------------- | ------------ | ----------- | -------- |
| Codex Evaluator  | @chad        | @backup-dev | odd      |
| CI/CD Build      | @build‑lead  | @backup-dev | even     |
| Security/Licence | @sec‑lead    | @backup-sec | weekly   |
| Docs Sync        | @tech‑writer | @backup-dev | odd      |

---

🏗 Agent Template Reference
==========================

Directory `agents/agent_template/` provides a FastAPI skeleton with env‑loading, JSON logging, `/metrics`, `/healthz`, graceful shutdown, and pre‑commit hooks.

---

🗂 Agent Manifest Schema
==========================

```md
## Agent: <snake_case_id>

| Field        | Description                                                                    |
|--------------|--------------------------------------------------------------------------------|
| **Role**     | One‑sentence mission.                                                          |
| **Inputs**   | Data expected (files, tickets, etc.).                                          |
| **Outputs**  | Artefacts (code patch, markdown, Dockerfile, etc.).                            |
| **Tools**    | External helpers (Codex API, git, Docker CLI…).                                |
| **Process**  | Step‑by‑step algorithm or prompt chain.                                        |
| **Checks**   | Verification steps (pytest clean, eslint passes…).                             |
| **Escalation** | When to notify a human or upstream agent.                                    |
```

---

📝 Prompt Templates Library
==========================

````md
```prompt
<<PROMPT:generate_function>>
Write a new function called {{function_name}} that follows project style
and returns {{return_type}}.
```
````

* `generate_function`, `refactor_for_memory`, `explain_code`, `write_unit_tests`, `dockerize_service`.

---

🔧 Capability Add‑Ons
==========================

| Add‑on                   | Benefit                        | Quick start                      |
| ------------------------ | ------------------------------ | -------------------------------- |
| **Embedding lookup**     | Context‑aware prompts          | Create `embeddings/` + retriever |
| **Test harness trigger** | Auto‑pytest after Codex writes | Add GitHub Action endpoint       |
| **VS Code task**         | One‑click run                  | Document custom Task             |
| **Docker proxy**         | Offline/local Codex            | Provide `dev.Dockerfile`         |
| **CI/CD webhook**        | Launch agents from board state | Define webhook schema            |
| **Interactive CLI**      | `tags-agent <id>` wrapper      | Link to script in repo           |

---

🛠 Future Hooks
==========================

```md
<!-- ## Agent Marketplace (Phase 3)
Drop‑in plug‑in spec here. -->

<!-- ## Telemetry Dashboard
Grafana metrics dashboard spec. -->
```

---

📝 Summary
==========================

Agents automate DevOnboarder with accountability. **This single file** blends policy, live configuration, templates, and schemas so Codex‑powered workflows remain self‑documenting and auditable. As complexity grows, we’ll split into modules, but for MVP this monolith eliminates ambiguity.
