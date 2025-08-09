---
title: "ci_triage_guard"
description: "Blocks generation when infra/CI failures are detected."
author: "TAGS Engineering"
version: "1.0.0"
created_at: "2025-08-09"
updated_at: "2025-08-09"
tags: ["guard", "ci"]
project: "DevOnboarder"
document_type: "agent"
status: "prod"
visibility: "internal"
codex_scope: "tags"
codex_role: "guard"
codex_type: "system-agent"
codex_runtime: "ci"
---

# CI Triage Guard Agent

## Purpose

Critical safety agent that blocks code generation when infrastructure or CI failures are detected. Prevents automated changes during system instability.

## Triggers

### Infrastructure Failures

- **Build System**: Node.js, Python, or system dependency failures
- **Database**: Connection issues, migration failures, schema problems
- **Network**: Service connectivity, DNS resolution, timeout issues
- **Storage**: Disk space, file system, artifact upload problems

### CI Pipeline Failures

- **Test Failures**: Flaky tests, timeout issues, environment problems
- **Coverage Drops**: Significant coverage regression indicating test issues
- **Linting Failures**: Code quality tools reporting system-level problems
- **Security Scans**: Vulnerability detection or scanning tool failures

### Known Failure Patterns

- **Dependency Issues**: Package installation, lock file corruption
- **Configuration Problems**: Environment variables, service configuration
- **Resource Exhaustion**: Memory, CPU, or concurrent job limits
- **External Dependencies**: Third-party service outages

## Actions

### Immediate Response

1. **Halt Codegen**: Immediately stop all code generation agents
2. **Notify Teams**: Alert relevant teams about the infrastructure issue
3. **Log Analysis**: Capture relevant logs for debugging
4. **Status Communication**: Update status channels with current situation

### Investigation

1. **Pattern Recognition**: Identify if this is a known issue pattern
2. **Root Cause Analysis**: Gather data for debugging
3. **Impact Assessment**: Determine scope and severity
4. **Escalation**: Route to appropriate teams based on issue type

### Recovery

1. **Monitor Status**: Watch for issue resolution
2. **Validation**: Ensure systems are stable before re-enabling agents
3. **Resume Operations**: Gradually re-enable automated agents
4. **Post-Incident**: Generate after-action reports

## Configuration

### Detection Rules

```yaml
failure_patterns:
  infrastructure:
    - "npm install failed"
    - "pip install failed"
    - "database connection refused"
    - "timeout waiting for condition"

  flaky_tests:
    - "jest did not exit one second after"
    - "test timeout"
    - "connection refused in test"

  resource_issues:
    - "out of memory"
    - "disk space"
    - "too many open files"
```

### Escalation Matrix

| Issue Type | Primary Team | Secondary | Escalation Time |
|------------|-------------|-----------|-----------------|
| Infrastructure | DevOps | Engineering | 15 minutes |
| Database | Engineering | DevOps | 10 minutes |
| Security | Security | Engineering | 5 minutes |
| External Services | Engineering | DevOps | 30 minutes |

## Safety Features

- **Fail-Safe Design**: Defaults to blocking when in doubt
- **Manual Override**: Authorized personnel can override blocks
- **Audit Trail**: All blocking decisions are logged
- **Escalation**: Automatic escalation for critical issues
