# Potato Orchestration Framework

## Overview

The **Potato Orchestration Framework** provides a generic hub-and-spoke model for CI/CD agent orchestration with configurable routing, intelligent guardrails, and comprehensive audit capabilities.

## Architecture

### Hub-and-Spoke Model

```text
                    ┌─────────────────┐
                    │   Orchestrator  │
                    │      Hub        │
                    └─────────┬───────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
         ┌────▼───┐       ┌───▼───┐      ┌───▼────┐
         │ Router │       │Triage │      │ Guard  │
         │ Agent  │       │ Agent │      │ Agent  │
         └────┬───┘       └───┬───┘      └───┬────┘
              │               │              │
    ┌─────────▼──────┐        │    ┌─────────▼──────┐
    │ Coverage       │        │    │ Security       │
    │ Orchestrator   │        │    │ Scanner        │
    └────────────────┘        │    └────────────────┘
                              │
                    ┌─────────▼──────┐
                    │ Documentation  │
                    │ Generator      │
                    └────────────────┘
```

### Core Components

#### 1. Orchestrator Hub

- **Central coordination**: Routes requests to specialized agents
- **Policy enforcement**: Applies organizational rules and guardrails
- **State management**: Tracks agent availability and workloads
- **Audit logging**: Records all routing decisions and agent actions

#### 2. Agent Types

##### Router Agents

- Analyze incoming requests (PRs, issues, CI events)
- Apply routing rules based on context (labels, paths, CI status)
- Direct traffic to appropriate specialized agents

##### Triage Agents

- Safe default handlers for unlabeled requests
- Organize and prepare work for human review
- No code modification capabilities

##### Guard Agents

- Safety mechanisms that prevent unsafe operations
- Block automation during infrastructure failures
- Enforce security and quality policies

##### Orchestrator Agents

- Specialized agents for specific domains (coverage, docs, security)
- Coordinate complex multi-step workflows
- Generate targeted improvements and fixes

## Configuration

### Routing Rules

Routing behavior is controlled through declarative YAML configuration:

```yaml
routing:
  - if: event == "pull_request" && label ~ "codex:route"
    run: [codex_router]
  - if: event == "pull_request" && !(label ~ "codex:route")
    run: [codex_triage]
  - if: event == "workflow_run" && job == "tests" && status == "failure"
    run: [ci_triage_guard, coverage_orchestrator]
```

### Agent Definitions

Agents are defined with clear boundaries and capabilities:

```yaml
agents:
  codex_router:
    ref: ./agents/router.md
    secrets: [CODEX_API_KEY]
    permissions: [route_agents, create_issue, apply_labels]

  coverage_orchestrator:
    ref: ./agents/coverage.md
    secrets: [CODEX_API_KEY]
    permissions: [read_ci_logs, open_pr]
```

### Policy Framework

Organizational policies are enforced consistently:

```yaml
policies:
  node_version: "20.x"
  python_version: "3.11"
  forbid: [curl_pipe_sh, remote_code_exec]
  require: [lockfile_integrity, gh_version>=2.0.0]
```

## Integration Examples

### GitHub Actions Integration

```yaml
name: Orchestrator
on:
  pull_request: { types: [labeled, opened, synchronize] }
  schedule: [{ cron: '0 */6 * * *' }]

jobs:
  orchestrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Orchestrator
        env:
          CODEX_API_KEY: ${{ secrets.CODEX_API_KEY }}
        run: |
          python orchestrator.py --config .codex/orchestrator/config.yml
```

### Dashboard Integration

```typescript
// React component for PR routing control
import { PRRoutingToggle } from './components/PRRoutingToggle';

function PRDashboard({ pr }) {
  return (
    <PRRoutingToggle
      owner={pr.owner}
      repo={pr.repo}
      prNumber={pr.number}
      onToggle={(enabled) => console.log('Routing:', enabled)}
    />
  );
}
```

### API Integration

```typescript
// REST API for programmatic control
const routingService = new PRRoutingService(githubToken);

// Enable routing for a PR
await routingService.updatePRRouting({
  owner: 'myorg',
  repo: 'myrepo',
  number: 123,
  enabled: true
});

// Check routing status
const status = await routingService.getPRRoutingStatus('myorg', 'myrepo', 123);
```

## Features

### Intelligent Routing

- **Context-aware**: Routes based on file paths, labels, CI status
- **Load balancing**: Distributes work across available agents
- **Priority handling**: Critical issues get immediate attention

### Safety Guardrails

- **Fail-safe design**: Blocks automation during infrastructure issues
- **Human oversight**: All critical decisions require approval
- **Audit trails**: Complete logging of all agent actions

### Extensibility

- **Plugin architecture**: Easy to add new agent types
- **Custom routing**: Configurable rules for any workflow
- **API integration**: REST APIs for external system integration

## Getting Started

### Basic Setup

1. **Install the framework**:

   ```bash
   npm install @potato/orchestrator
   ```

2. **Create configuration**:

   ```yaml
   # orchestrator.yml
   version: 1
   agents:
     basic_triage:
       ref: ./agents/triage.md
       permissions: [create_issue, apply_labels]
   ```

3. **Deploy to CI**:

   ```yaml
   # .github/workflows/orchestrator.yml
   - name: Run Orchestrator
     run: potato-orchestrator --config orchestrator.yml
   ```

### Advanced Configuration

See `integration_examples.md` for platform-specific implementations and advanced routing strategies.

## License

The Potato Orchestration Framework is open source under the MIT License. Commercial orchestrator implementations (PotatoOS) available under separate licensing.

## Support

- **Documentation**: `docs/`
- **Examples**: `examples/`
- **Community**: GitHub Discussions
- **Enterprise**: Contact sales for PotatoOS
