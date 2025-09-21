---
author: DevOnboarder Team

codex-agent:
  name: Agent.AiMentor
  output: .codex/logs/ai-mentor.log
  role: Provides automated mentorship and resource guidance to new contributors
  scope: onboarding assistance
  triggers: on_question_received
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
permissions:

- repo:read

project: core-agents
similarity_group: documentation-documentation
status: active
tags:

- documentation

title: Ai Mentor
updated_at: '2025-09-12'
visibility: internal
---

# AI Mentor Agent

**Status:** Planned.

**Purpose:** Provides automated mentorship and guidance to new contributors based on their questions or interactions in onboarding workflows.

**Inputs:** Contributor-submitted questions, project metadata (e.g. docs, directory layout, team roles).

**Outputs:** Curated resources, recommended next steps, and embedded guidance links.

**Environment:** No specific environment variables defined yet; designed to be platform-agnostic.

**Workflow:**

- Monitors contributor prompts (once integrated)

- Suggests responses based on documentation, team contacts, and project workflow

**Logging:** Output goes to `.codex/logs/ai-mentor.log`

**Permissions Required:**

- `repo:read` – to read project context and docs for recommendations
