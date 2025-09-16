---
author: DevOnboarder Team
codex-agent:
  name: Agent.OnboardingAgent
  output: Onboarding guidance
  role: Guides new contributors through the onboarding checklist
  scope: docs/ONBOARDING.md
  triggers: Contributor requests or scheduled reminders
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
title: Onboarding Agent
updated_at: '2025-09-12'
visibility: internal
---

# Onboarding Agent

**Status:** Planned.

**Purpose:** Helps new contributors complete project onboarding steps.

**Inputs:** Developer questions or periodic automation.

**Outputs:** Reminders and onboarding checklist progress updates.

**Environment:** None defined yet.

**Workflow:** Responds to requests and reviews onboarding tasks, notifying via workflow when actions are required.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
