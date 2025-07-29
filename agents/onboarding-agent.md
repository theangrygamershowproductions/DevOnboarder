---
codex-agent:
    name: Agent.OnboardingAgent
    role: Guides new contributors through the onboarding checklist
    scope: docs/ONBOARDING.md
    triggers: Contributor requests or scheduled reminders
    output: Onboarding guidance
---

# Onboarding Agent

**Status:** Planned.

**Purpose:** Helps new contributors complete project onboarding steps.

**Inputs:** Developer questions or periodic automation.

**Outputs:** Reminders and onboarding checklist progress updates.

**Environment:** None defined yet.

**Workflow:** Responds to requests and reviews onboarding tasks, notifying via workflow when actions are required.

**Notification:** Route alerts through `.github/workflows/notify.yml`.
