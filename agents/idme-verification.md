---
title: "ID.me Verification Agent"

description: "Agent for verifying users through ID.me OAuth integration during onboarding process"

document_type: agent
tags: "["agent", "idme", "verification", "oauth", "onboarding"]"
project: core-agents
author: "DevOnboarder Team"
created_at: 2025-09-12
updated_at: 2025-10-27
status: active
visibility: internal
codex-agent: 
name: Agent.IdmeVerification
output: "Verification confirmation"
role: "Verifies users through ID.me"
scope: "user onboarding"
triggers: "ID.me OAuth token submission"
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: documentation-documentation
---

# ID.me Verification Agent

**Status:** Planned.

**Purpose:** Handles user verification via ID.me.

**Inputs:** OAuth tokens and user account identifiers.

**Outputs:** Confirmation of verification status and assigned roles.

**Environment:** No variables specified yet; will depend on ID.me application credentials.
