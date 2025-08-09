# Orchestrator Hub-and-Spoke Implementation Guide

## Overview

The DevOnboarder Orchestrator System is a comprehensive hub-and-spoke architecture that provides intelligent routing, automated triage, and coordinated agent execution across the development workflow.

## System Architecture

### Hub-and-Spoke Model

```text
                    ┌─────────────────┐
                    │   Orchestrator  │
                    │      Hub        │
                    └─────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────┐    ┌──────────▼──────┐    ┌─────────▼─────┐
│   Codex    │    │    Coverage     │    │   CI Triage   │
│   Router   │    │  Orchestrator   │    │    Guard      │
└────────────┘    └─────────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  PR Routing │    │  Test Coverage  │    │  CI Monitoring  │
│   & Triage  │    │   Management    │    │  & Resolution   │
└─────────────┘    └─────────────────┘    └─────────────────┘
```

## Implementation Status

### ✅ Phase 1: Orchestrator Infrastructure

**Created Files:**

- `.codex/orchestrator/config.yml` - Central routing configuration
- `.github/workflows/orchestrator.yml` - GitHub Actions workflow
- `scripts/enhanced_env_sync.sh` - Environment allowlist integration

**Key Features:**

- YAML-based configuration management
- Agent permission validation
- Environment-specific routing
- Security boundary enforcement

### ✅ Phase 2: Agent Scaffolds

**Created Files:**

- `.codex/agents/tags/codex_router/agent_tags_codex_router.md`
- `.codex/agents/tags/codex_triage/agent_tags_codex_triage.md`
- `.codex/agents/tags/coverage_orchestrator/agent_tags_coverage_orchestrator.md`
- `.codex/agents/tags/ci_triage_guard/agent_tags_ci_triage_guard.md`

**Agent Capabilities:**

1. **Codex Router**: Intelligent PR routing and label management
2. **Codex Triage**: Automated issue prioritization and assignment
3. **Coverage Orchestrator**: Test coverage management and enforcement
4. **CI Triage Guard**: CI failure detection and resolution

### ✅ Phase 3: PR Routing Toggle System

**Created Files:**

- `src/routes/orchestrator/pr-routing.ts` - Backend API service
- `frontend/src/components/orchestrator/PRRoutingToggle.tsx` - React component
- `frontend/src/components/orchestrator/OrchestratorStatus.tsx` - Status display

**Features:**

- Real-time PR routing enable/disable
- GitHub API integration for label management
- Status monitoring and error handling
- TypeScript type safety throughout

### ✅ Phase 4: Public Documentation Strategy

**Created Files:**

- `public_docs/orchestration_model.md` - Public framework documentation
- `public_docs/agent_integration.md` - Integration guide
- `public_docs/configuration_examples.md` - Configuration examples

**Documentation Strategy:**

- **Public Layer**: Framework concepts and integration patterns
- **Internal Layer**: Specific routing rules and agent configurations
- **Security Separation**: No sensitive configuration in public docs

### ✅ Phase 5: Environment Allowlist System

**Created Files:**

- `envmaps/frontend.allowlist` - Frontend-safe environment variables
- `envmaps/bot.allowlist` - Discord bot configuration variables
- `envmaps/auth.allowlist` - Authentication service variables
- `envmaps/integration.allowlist` - Discord integration variables
- `envmaps/backend.allowlist` - Backend service variables
- `envmaps/orchestrator.allowlist` - Orchestrator system variables

**Security Features:**

- Service-specific variable allowlists
- Automatic security boundary enforcement
- Integration with existing environment sync system
- Validation and audit capabilities

## Configuration Reference

### Orchestrator Config (`.codex/orchestrator/config.yml`)

```yaml
agents:
  codex_router:
    type: "router"
    permissions: ["repo:read", "issues:write", "pulls:write"]
    trigger_conditions:
      - "label_added:codex:route"
      - "label_added:needs-triage"

  coverage_orchestrator:
    type: "orchestrator"
    permissions: ["repo:read", "workflows:read", "checks:read"]
    trigger_conditions:
      - "workflow_run:completed"
      - "check_run:completed"

routing_rules:
  - name: "codex_routing"
    condition: "has_label:codex:route"
    agent: "codex_router"
    priority: "high"

  - name: "coverage_check"
    condition: "workflow_run:completed AND check_name:coverage"
    agent: "coverage_orchestrator"
    priority: "medium"
```

### Environment Allowlists

Each service has its own allowlist file in `envmaps/`:

```bash
# Frontend allowlist example (envmaps/frontend.allowlist)
VITE_AUTH_URL
VITE_API_URL
VITE_FEEDBACK_URL
VITE_DISCORD_INTEGRATION_URL
VITE_DASHBOARD_URL

# Auth service allowlist (envmaps/auth.allowlist)
API_BASE_URL
AUTH_URL
FRONTEND_URL
DISCORD_CLIENT_ID
JWT_ALGORITHM
```

## API Integration

### PR Routing API

```typescript
// Backend service (src/routes/orchestrator/pr-routing.ts)
export class PRRoutingService {
  async updatePRRouting(prNumber: number, enabled: boolean): Promise<void>
  async getPRRoutingStatus(prNumber: number): Promise<RoutingStatus>
}

// Frontend component (frontend/src/components/orchestrator/PRRoutingToggle.tsx)
export const PRRoutingToggle: React.FC<PRRoutingToggleProps> = ({ prNumber })
```

### Environment Sync Integration

```bash
# Enhanced sync with allowlists
bash scripts/enhanced_env_sync.sh

# Validate allowlist configurations
bash scripts/enhanced_env_sync.sh --validate-allowlists

# Service-specific synchronization
bash scripts/enhanced_env_sync.sh --service frontend
```

## Workflow Integration

### GitHub Actions Workflow

The orchestrator integrates with GitHub Actions via `.github/workflows/orchestrator.yml`:

```yaml
name: Orchestrator System
on:
  pull_request:
    types: [opened, labeled, synchronize]
  workflow_run:
    workflows: ["CI"]
    types: [completed]

jobs:
  orchestrator:
    runs-on: ubuntu-latest
    steps:
      - name: Setup Orchestrator
        run: |
          npm install handlebars ajv ajv-formats
          python -m pip install pyyaml

      - name: Execute Orchestrator
        run: |
          python scripts/orchestrator_runner.py \
            --config .codex/orchestrator/config.yml \
            --event ${{ github.event_name }} \
            --dry-run
```

## Security Model

### Permission System

Each agent operates with minimal required permissions:

- **Read Permissions**: Repository content, workflow status
- **Write Permissions**: Issues, labels, PR metadata only
- **Restricted**: No code modification, deployment, or sensitive data access

### Environment Security

- **Allowlist-Based**: Only approved variables sync between environments
- **Service Isolation**: Each service has specific variable allowlist
- **CI Protection**: Sensitive variables excluded from CI environments
- **Audit Trail**: All environment changes logged and tracked

## Monitoring and Observability

### Agent Execution Logs

```bash
# View orchestrator logs
tail -f .codex/logs/orchestrator.log

# Agent-specific logs
tail -f .codex/logs/codex_router.log
tail -f .codex/logs/coverage_orchestrator.log
```

### Status Monitoring

- **Dashboard Integration**: Real-time orchestrator status
- **PR Routing Status**: Per-PR routing enable/disable state
- **Agent Health**: Individual agent execution status
- **Error Reporting**: Comprehensive error logging and alerts

## Development Guidelines

### Adding New Agents

1. **Create Agent Scaffold**: Add new agent definition in `.codex/agents/tags/`
2. **Update Configuration**: Add agent to `.codex/orchestrator/config.yml`
3. **Define Permissions**: Specify minimal required permissions
4. **Add Routing Rules**: Define trigger conditions and priorities
5. **Environment Variables**: Add to appropriate allowlist if needed

### Testing Orchestrator Changes

```bash
# Validate configuration
python scripts/validate_orchestrator_config.py .codex/orchestrator/config.yml

# Test environment sync
bash scripts/enhanced_env_sync.sh --dry-run

# Test PR routing
curl -X POST http://localhost:8001/api/orchestrator/pr-routing \
  -H "Content-Type: application/json" \
  -d '{"prNumber": 123, "enabled": true}'
```

### Troubleshooting

**Common Issues:**

1. **Agent Not Triggering**: Check routing rules and trigger conditions
2. **Permission Denied**: Verify agent permissions in configuration
3. **Environment Sync Failing**: Check allowlist files for typos
4. **API Errors**: Verify GitHub token permissions and API endpoints

**Debugging Commands:**

```bash
# Check orchestrator status
bash scripts/check_orchestrator_health.sh

# Validate agent permissions
bash scripts/validate-bot-permissions.sh

# Test environment allowlists
bash scripts/enhanced_env_sync.sh --validate-allowlists
```

## Future Enhancements

### Planned Features

- **Machine Learning Integration**: Intelligent routing based on historical data
- **Multi-Repository Support**: Cross-repository orchestration
- **Advanced Metrics**: Performance and effectiveness analytics
- **Custom Agent Framework**: Plugin system for custom agents

### Extension Points

- **Custom Routing Logic**: Add new routing conditions and priorities
- **External Integrations**: Slack, Teams, external CI systems
- **Advanced Workflows**: Multi-step orchestration patterns
- **Performance Optimization**: Caching and parallel execution

## Conclusion

The DevOnboarder Orchestrator System provides a robust, secure, and extensible foundation for automated development workflow management. The hub-and-spoke architecture ensures scalability while maintaining security boundaries and operational clarity.

For support and contributions, see the main DevOnboarder documentation and contribution guidelines.
