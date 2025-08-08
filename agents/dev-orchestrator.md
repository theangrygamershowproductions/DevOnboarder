---
codex-agent:
    name: Agent.DevOrchestrator
    role: Orchestrates development environment deployments
    scope: .github/workflows/dev-orchestrator.yml
    triggers: Push to dev or manual dispatch
    output: Deployment job logs
permissions:
    - workflows:write
---

# Dev Orchestrator Agent

**Status:** Active.

**Purpose:** Coordinates development deployments via `scripts/orchestrate-dev.sh`.

**Inputs:** GitHub workflow dispatch or push to the `dev` branch.

**Outputs:** Logs confirming the orchestration request and remote coordination.

**Environment:**

- Requires `DEV_ORCHESTRATION_BOT_KEY` provided as `ORCHESTRATION_KEY`.
- Optionally set `ORCHESTRATOR_URL` (default: `https://orchestrator.example.com`).

**Workflow:**

- The workflow calls `scripts/orchestrate-dev.sh`
- The script POSTs orchestration instructions to a remote service.

**Logging:** Output goes to `.codex/logs/dev-orchestrator.log`

**Permissions Required:**

- `workflows:write` — to trigger sub-jobs or notify results

## Terminal Output Policy Integration

**CRITICAL**: Dev Orchestrator must comply with DevOnboarder's Terminal Output Policy:

### Suppression System Support

- **RESPECT suppressions**: Honor `# terminal-output-policy: reviewed-safe` comments
- **PRESERVE manual decisions**: Don't override human security assessments
- **VALIDATE new patterns**: Flag unsuppressed violations for review

### Orchestration Script Compliance

When managing `scripts/orchestrate-dev.sh`:

1. **Scan for violations**: Check terminal output patterns
2. **Apply suppression logic**: Skip files with valid suppression comments
3. **Report new violations**: Flag unsuppressed patterns for team review

### Integration Points

- **Pre-deployment validation**: Check Terminal Output Policy compliance
- **Suppression documentation**: Reference `docs/standards/terminal-output-policy-suppression.md`
- **Security boundaries**: Never suppress genuinely dangerous patterns
