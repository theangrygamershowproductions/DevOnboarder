---
author: "DevOnboarder Team"
consolidation_priority: P1
content_uniqueness_score: 5
created_at: 2025-09-13
description: "Debug Protocol Macro v1.2 - Standardized debugging framework for disciplined, test-first reasoning and structured problem resolution"

document_type: standard
merge_candidate: false
project: core-standards
similarity_group: methodology-documentation
status: active
tags: 
title: "Debug Protocol Macro v1.2"

updated_at: 2025-10-27
visibility: internal
---

# 🧩 Debug Protocol Macro (v1.2)

## Overview

The Debug Protocol Macro is a drop-in debugging framework that enforces disciplined, test-first reasoning and structured output for technical problem resolution. This protocol can be pasted at the top of any debugging session to force systematic analysis and comprehensive solutions.

## Purpose

* **Structured Problem Solving**: Forces ranked hypotheses and explicit falsification steps

* **Test-First Approach**: Requires validation and rollback plans for all changes

* **Copy-Paste Ready**: Generates immediately actionable commands and code

* **Smallest Safe Change**: Keeps solutions minimal and risk-aware

* **Cross-Domain Flexibility**: Adaptable to CI/CD, Backend, Frontend, Security, and Infrastructure issues

## Protocol Template

````markdown

# DEBUG_PROTOCOL

mode: "ASSUME"            # ASSUME = don't ask me questions; make reasonable assumptions and proceed. (Other option: CONFIRM)

domain: "CI/CD|DevOps"    # Examples: "Backend", "Frontend", "Data", "Security", "Infra", "CI/CD"

constraints:
  - "No secrets; redact tokens."

  - "No fabricated commands, files, or tool flags."

  - "Prefer smallest safe change."

  - "All fixes must include a validation step  rollback."

inputs:
  problem_summary: "<1–3 lines>"
  env_facts: ["OS","shell","runner","versions","repo/branch","recent change"]
  evidence: ["error lines", "logs", "screens", "commands tried"]

# OUTPUT CONTRACT — respond in EXACTLY these sections

1) Situation Snapshot

- One-paragraph plain-English summary.

- Key signals (bullet list). Distinguish symptom vs. cause candidates.

2) Hypotheses (Ranked)

- H1 ...  (why it fits / how to falsify)

- H2 ...

- H3 ...

3) Minimal Repro Plan

- Steps 1..N to reproduce; include expected vs. actual for each step.

4) Evidence to Collect (Ordered, Cheap  Expensive)

- Logs/commands/paths with exact invocations.

- Note what each item will confirm or deny.

5) Fix Plan (Smallest Safe Change)

- Change set (files/lines/commands).

- Risk level  blast radius.

- Rollback plan (exact steps).

6) Validation (Pass/Fail Gates)

- Pre-commit checks (lint/tests)

- Runtime assertions / health checks

- "Definition of Done" (explicit)

7) Commands/Edits (Copy-Paste Ready)

```bash

# bash/zsh here (only real, version-safe flags)

```

```pwsh

# powershell here (no pseudo cmdlets)

```

```yaml

# config snippet if relevant

```

8. Postmortem Notes (Optional)

* What prevented this earlier? Guardrail to add (lint, CI step, monitor, doc).

* One automation to stop this class of issue recurring.

# RULES OF ENGAGEMENT

* If mode = ASSUME, proceed without questions; state assumptions up front.

* Cite real tool flags/paths; if unknown, mark as TODO and provide a safe probe.

* Prefer diffs/patch snippets for file edits.

* Never skip Validation or Rollback.

# END DEBUG\_PROTOCOL

````

## Domain-Specific Variants

### Code Bug (Backend)

For backend debugging sessions, enhance the protocol with:

* Add a "Unit Test First" sub-step in **Minimal Repro Plan**

* Require a failing test diff in **Commands/Edits**

* Include database state validation in **Validation** section

### Frontend/UI

For frontend debugging sessions, enhance with:

* Add a "User-visible acceptance step" (screenshot/DOM selector) under **Validation**

* Include browser compatibility checks

* Require visual regression tests where applicable

### Data/Pipeline

For data and pipeline debugging sessions, enhance with:

* Add a "Data Integrity Checks" block (row counts, null ratios, schema drift) in **Validation**

* Include data lineage verification

* Require rollback procedures for data changes

### Security

For security-related debugging sessions, enhance with:

* Add CWE mapping  mitigation level

* Require "exploit pre/post" steps in **Validation**

* Include threat model impact assessment

* Mandate security review for all changes

## Example Usage: CI/CD GitHub CLI Flag Regression

### Input

```markdown
problem_summary: "Workflow `close-codex-issues.yml` fails on runner with `gh: unknown flag --jq`."
env_facts: Windows  Ubuntu runners; gh 2.0–2.54 variance; jq not installed on Windows.

evidence: Action log shows `gh issue close --jq` errors.

```

### Expected Response Structure

#### 1) Situation Snapshot

`gh` on some runners doesn't support `--jq`; workflow assumes it. Symptom: job fails at issue-close step. Likely cause: using unsupported flags  missing `jq` dependency.

#### 2) Hypotheses (Ranked)

* H1: `gh` version < 2.4 where `--jq` isn't available; falsify by `gh --version`.

* H2: Step runs on Windows where `jq` absent; falsify by `jq --version` (expect failure).

* H3: Flag is deprecated/never supported on current channel; falsify via `gh help`.

#### 3) Minimal Repro Plan

1. `gh --version` on failing runner  expect older/newer mismatch.

2. `jq --version`  expect not found on Windows.

3. Re-run step with `--jq` removed  expect pass.

#### 4) Evidence to Collect

* `which gh && gh --version` (confirms H1)

* `which jq && jq --version` (confirms H2)

* `gh help issue close` (validates flag support)

#### 5) Fix Plan (Smallest Safe Change)

* Remove `--jq` usage; parse issue number from returned URL/string.

* Add version guard  fallback path (POSIX parsing).

* Risk: Low; affects only issue-close step.

* Rollback: Revert single commit.

#### 6) Validation (Pass/Fail Gates)

* CI green on Ubuntu  Windows.

* Dry-run with a dummy issue in sandbox repo.

* Log shows "Closed issue #NUM" without `jq`.

#### 7) Commands/Edits

```yaml

# .github/workflows/close-codex-issues.yml (snippet)

- name: Close Issue (version-safe)

  shell: bash
  run: |
    set -euo pipefail
    issue_url="$(gh issue close "$ISSUE_ID" -R "$REPO" -c "Auto-closed by CI" -o json 2>/dev/null || true)"
    if [[ -z "${issue_url}" ]]; then
      # Fallback: no -o json support; use URL echo  grep

      close_out="$(gh issue close "$ISSUE_ID" -R "$REPO" -c "Auto-closed by CI" 2>&1 || true)"
      # Extract issue number from the printed URL or text

      num="$(printf "%s" "$close_out" | grep -Eo '#[0-9]' | head -n1 | tr -d '#')"
      echo "Closed issue #${num:-$ISSUE_ID}"
    else
      num="$(printf "%s" "$issue_url" | grep -Eo '"number":[ ]*[0-9]' | grep -Eo '[0-9]')"
      echo "Closed issue #${num:-$ISSUE_ID}"
    fi

```

```bash

# Validation probes

gh --version
gh issue create -R "$REPO" -t "CI Sandbox" -b "ok" | tee /tmp/issue_url
ISSUE_ID=$(sed -E 's@.*/issues/([0-9]).*@\1@' /tmp/issue_url)

# run the workflow or call the action locally if supported

```

#### 8. Postmortem Notes

* Guardrail: add `gh version check` step  fallback parsing pattern.

* Monitor: alert on any `unknown flag` in Action logs.

## Integration with DevOnboarder

### Alignment with DevOnboarder Philosophy

This Debug Protocol Macro aligns perfectly with DevOnboarder's **"quiet reliability"** philosophy by:

* **Enforcing systematic thinking** before making changes

* **Requiring validation and rollback plans** for all modifications

* **Promoting smallest safe changes** to minimize risk

* **Generating copy-paste ready solutions** that work reliably

### Integration Points

**CI/CD Integration**:

* Use with `scripts/qc_pre_push.sh` validation framework

* Integrate with AAR (After Action Report) system

* Align with Root Artifact Guard and CI Triage Guard enforcement

**Quality Control**:

* Supports DevOnboarder's 95% quality threshold requirement

* Enforces pre-commit validation in debugging workflow

* Maintains virtual environment requirements and safe commit practices

**Documentation Standards**:

* Follows DevOnboarder markdown compliance standards

* Integrates with existing troubleshooting documentation

* Supports centralized logging and artifact management

## Usage Guidelines

### When to Use

* **Complex technical issues** requiring systematic analysis

* **CI/CD failures** with unclear root causes

* **Cross-service integration problems** with multiple potential causes

* **Security incidents** requiring careful analysis and mitigation

* **Performance issues** needing systematic investigation

### When NOT to Use

* **Simple configuration changes** with obvious solutions

* **Well-documented issues** with established fixes

* **Emergency hotfixes** where time is critical (use after resolution for postmortem)

### Best Practices

1. **Always use ASSUME mode** for efficient problem resolution

2. **Document assumptions clearly** when proceeding without confirmation

3. **Prioritize cheapest evidence collection** to validate hypotheses quickly

4. **Include explicit rollback plans** for all proposed changes

5. **Generate actionable commands** that can be executed immediately

## VS Code Integration

To create a VS Code snippet for this macro:

1. Open VS Code

2. Go to File > Preferences > Configure User Snippets

3. Select markdown.json

4. Add the following snippet:

```json
{
  "Debug Protocol Macro": {
    "prefix": "dbgproto",
    "body": [
      "# DEBUG_PROTOCOL",

      "mode: \"ASSUME\"            # ASSUME = don't ask me questions; make reasonable assumptions and proceed. (Other option: CONFIRM)",

      "domain: \"${1:CI/CD|DevOps}\"    # Examples: \"Backend\", \"Frontend\", \"Data\", \"Security\", \"Infra\", \"CI/CD\"",

      "constraints:",
      "  - \"No secrets; redact tokens.\"",

      "  - \"No fabricated commands, files, or tool flags.\"",

      "  - \"Prefer smallest safe change.\"",

      "  - \"All fixes must include a validation step  rollback.\"",

      "inputs:",
      "  problem_summary: \"${2:<1–3 lines>}\"",
      "  env_facts: [\"${3:OS}\",\"${4:shell}\",\"${5:runner}\",\"${6:versions}\",\"${7:repo/branch}\",\"${8:recent change}\"]",
      "  evidence: [\"${9:error lines}\", \"${10:logs}\", \"${11:screens}\", \"${12:commands tried}\"]",
      "",
      "# OUTPUT CONTRACT — respond in EXACTLY these sections",

      "1) Situation Snapshot",
      "- One-paragraph plain-English summary.",

      "- Key signals (bullet list). Distinguish symptom vs. cause candidates.",

      "",
      "2) Hypotheses (Ranked)",
      "- H1 ...  (why it fits / how to falsify)",

      "- H2 ...",

      "- H3 ...",

      "",
      "3) Minimal Repro Plan",
      "- Steps 1..N to reproduce; include expected vs. actual for each step.",

      "",
      "4) Evidence to Collect (Ordered, Cheap  Expensive)",
      "- Logs/commands/paths with exact invocations.",

      "- Note what each item will confirm or deny.",

      "",
      "5) Fix Plan (Smallest Safe Change)",
      "- Change set (files/lines/commands).",

      "- Risk level  blast radius.",

      "- Rollback plan (exact steps).",

      "",
      "6) Validation (Pass/Fail Gates)",
      "- Pre-commit checks (lint/tests)",

      "- Runtime assertions / health checks",

      "- \"Definition of Done\" (explicit)",

      "",
      "7) Commands/Edits (Copy-Paste Ready)",
      "```bash",
      "# bash/zsh here (only real, version-safe flags)",

      "```",
      "",
      "```yaml",
      "# config snippet if relevant",

      "```",
      "",
      "8. Postmortem Notes (Optional)",

      "",
      "* What prevented this earlier? Guardrail to add (lint, CI step, monitor, doc).",

      "* One automation to stop this class of issue recurring.",

      "",
      "# RULES OF ENGAGEMENT",

      "",
      "* If mode = ASSUME, proceed without questions; state assumptions up front.",

      "* Cite real tool flags/paths; if unknown, mark as TODO and provide a safe probe.",

      "* Prefer diffs/patch snippets for file edits.",

      "* Never skip Validation or Rollback.",

      "",
      "# END DEBUG\\_PROTOCOL"

    ],
    "description": "Debug Protocol Macro v1.2 for structured problem resolution"
  }
}

```

## GitHub Issue Template

Create `.github/ISSUE_TEMPLATE/debug-protocol.yml` for CI incidents:

```yaml
name: Debug Protocol Analysis
description: Structured debugging analysis using Debug Protocol Macro v1.2
title: "[DEBUG] "
labels: ["debug", "investigation"]
body:
  - type: input

    id: problem_summary
    attributes:
      label: Problem Summary
      description: 1-3 line description of the issue
      placeholder: "Workflow fails with unknown flag error..."
    validations:
      required: true

  - type: textarea

    id: env_facts
    attributes:
      label: Environment Facts
      description: OS, shell, runner, versions, repo/branch, recent changes
      placeholder: |
        - OS: Ubuntu 22.04

        - Shell: bash

        - Runner: GitHub Actions

        - Versions: gh 2.54, jq not installed

        - Repo/Branch: main

        - Recent Change: Updated workflow to use --jq flag

    validations:
      required: true

  - type: textarea

    id: evidence
    attributes:
      label: Evidence
      description: Error lines, logs, screenshots, commands tried
      placeholder: |
        - Error: "gh: unknown flag --jq"

        - Log: Action log shows step failure

        - Commands tried: gh issue close --help

    validations:
      required: true

```

## Related Documentation

* [After Actions Report Process](./after-actions-report-process.md) - For post-incident documentation

* [Quality Gate Protection System](./quality-gate-protection-system.md) - For validation requirements

* [Centralized Logging Policy](./centralized-logging-policy.md) - For log management during debugging

* [DevOnboarder Troubleshooting Guide](../troubleshooting/README.md) - For common issues and solutions

## Changelog

### v1.2 (2025-09-13)

* Initial integration into DevOnboarder standards

* Added domain-specific variants for Backend, Frontend, Data/Pipeline, Security

* Included VS Code snippet integration

* Added GitHub Issue template example

* Aligned with DevOnboarder quality standards and methodology

---

**Note**: This Debug Protocol Macro is designed to work seamlessly with DevOnboarder's existing quality control and automation frameworks. Always follow DevOnboarder's virtual environment requirements and safe commit practices when implementing debugging solutions.
