---
agent: ai-mentor
purpose: Provides automated mentorship and resource guidance to new contributors
trigger: on_question_received
environment: any
output: .codex/logs/ai-mentor.log
permissions:
  - repo:read
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
