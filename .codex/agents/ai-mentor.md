---
agent: ai-mentor
consolidation_priority: P3
content_uniqueness_score: 4
description: Provides automated mentorship and resource guidance to new contributors based on their questions or interactions in onboarding workflows
document_type: specification
environment: any
merge_candidate: false
output: .codex/logs/ai-mentor.log
permissions:
- repo:read
purpose: Provides automated mentorship and resource guidance to new contributors
similarity_group: agents-agents
tags:
- ai
- mentorship
- guidance
- onboarding
title: AI Mentor Agent
trigger: on_question_received
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
