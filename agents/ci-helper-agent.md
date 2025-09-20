---
author: DevOnboarder Team

codex-agent:
  name: Agent.CIHelperAgent
  output: Diagnostic notes
  role: Assists with CI troubleshooting and guidance
  scope: CI workflows
  triggers: Failed jobs or developer requests
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: core-agents
similarity_group: documentation-documentation
status: active
tags:

- documentation

title: Ci Helper Agent
updated_at: '2025-09-12'
visibility: internal
---

# CI Helper Agent

**Status:** Active with PR-CI Integration.

**Purpose:** Provides comprehensive CI troubleshooting with integrated PR comment analysis, pointing maintainers to logs, common resolutions, and relevant reviewer feedback.

**Inputs:**

- CI failure events or manual invocation

- PR numbers for integrated comment-CI analysis

- Workflow run IDs for detailed failure analysis

**Outputs:**

- Summarized diagnostics and next steps

- PR comment correlation analysis

- Integrated recommendations combining CI logs and review feedback

- Priority-scored action items

**Environment:**

- DevOnboarder CI Health Dashboard integration

- GitHub CLI with proper authentication

- Token Architecture v2.1 support

**Workflow:**

1. Monitors workflow results and surfaces troubleshooting information

2. Extracts PR comments and correlates with CI failures

3. Provides integrated analysis via `--diagnose-pr` command

4. Generates priority-based recommendations

**Key Commands:**

```bash

# Full CI health analysis

devonboarder-ci-health

# Integrated PR + CI analysis

devonboarder-ci-health --diagnose-pr PR_NUMBER

# Live monitoring mode

devonboarder-ci-health --live

```

**Integration Features:**

- **Comment-CI Correlation**: Links Copilot suggestions to specific CI failures

- **Priority Scoring**: Ranks recommendations by impact and confidence

- **Pattern Recognition**: Learns from historical comment-CI relationships

- **Automated Insights**: Identifies high-confidence fixes from review feedback

**Notification:** Route alerts through `.github/workflows/notify.yml` with enhanced PR context.
