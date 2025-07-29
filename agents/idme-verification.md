---
codex-agent:
    name: Agent.IdmeVerification
    role: Verifies users through ID.me
    scope: user onboarding
    triggers: ID.me OAuth token submission
    output: Verification confirmation
---

# ID.me Verification Agent

**Status:** Planned.

**Purpose:** Handles user verification via ID.me.

**Inputs:** OAuth tokens and user account identifiers.

**Outputs:** Confirmation of verification status and assigned roles.

**Environment:** No variables specified yet; will depend on ID.me application credentials.
