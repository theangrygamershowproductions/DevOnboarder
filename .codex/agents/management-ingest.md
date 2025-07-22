# Management Ingest Agent

## Agent Configuration

```yaml
codex_runtime: false         # Ensures Codex doesn't execute runtime code
codex_dry_run: true          # Custom signal for simulated output logging
discord_role_required: "CTO"
authentication_required: true
environment: dev
integration_log: "https://codex.theangrygamershow.com/docs/devonboarder/ci-integration-hold"
```

> ⚠️ **This agent is currently in dry-run mode.** All outputs are logged, but no live actions are executed.

## Overview

Processes executive commands and routes them to appropriate Discord servers based on environment in dry-run mode for safe integration testing.

## Dry-Run Behavior

**Input Processing**: Validates command structure and role permissions
**Authorization Check**: Verifies Discord role mapping without live API calls
**Output Simulation**: Logs intended actions without execution
**Integration Testing**: Validates service communication patterns

## Prerequisites

```bash
# Setup environment for dry-run testing
bash scripts/setup_discord_env.sh dev
export DISCORD_BOT_READY=false
export LIVE_TRIGGERS_ENABLED=false

# Verify dry-run configuration
python -m diagnostics --check-codex --dry-run
```

## Dry-Run Logic

**Command Flow**:
1. Parse executive command (CEO, CTO, COO directives)
2. Validate role permissions via DevOnboarder auth service (simulated)
3. Log intended Discord routing without actual webhook calls
4. Output structured response for CI validation

**Safety Guards**:
- All Discord API calls simulated
- No actual webhook notifications sent
- Role validation logged but not enforced
- All outputs captured in `.codex/state/management-log.json`

## Usage Examples

```bash
# Development dry-run testing
./scripts/trigger_codex_agent_dryrun.sh management-ingest dev

# CI integration testing
DEPLOY_ENV=dev CODEX_DRY_RUN=true python -m codex.agents.management_ingest
```

## Expected Dry-Run Output

```json
{
  "agent": "management-ingest",
  "mode": "dry-run",
  "input_command": "CTO security audit",
  "role_validation": "simulated_success",
  "intended_action": "route_to_discord_dev_server",
  "discord_server": "1386935663139749998",
  "webhook_target": "simulated",
  "timestamp": "2025-07-21T10:00:00Z",
  "status": "dry_run_complete"
}
```

## Integration Status

- [CI Integration Status](https://codex.theangrygamershow.com/docs/devonboarder/ci-integration-hold)
- [Discord Bot Integration Guide](https://codex.theangrygamershow.com/docs/devonboarder/discord-integration)
- [Codex Dry-Run Strategy](https://codex.theangrygamershow.com/docs/devonboarder/codex-ci-dryrun-strategy)

**Current Status**: 🧪 Dry-run mode active for safe CI integration testing
