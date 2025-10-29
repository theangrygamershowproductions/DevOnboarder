---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
updated_at: 2025-10-27
---

# DevOnboarder Policy Quick Access

## Quick Reference Script

We've created a comprehensive policy reference tool:

```bash

# Show all policies

./scripts/devonboarder_policy_check.sh

# Specific policy areas

./scripts/devonboarder_policy_check.sh terminal      # Terminal output rules

./scripts/devonboarder_policy_check.sh triage       # Issue management

./scripts/devonboarder_policy_check.sh priority     # Priority framework

./scripts/devonboarder_policy_check.sh escalation   # Emergency procedures

./scripts/devonboarder_policy_check.sh tokens       # Token Architecture

./scripts/devonboarder_policy_check.sh violations   # Check current violations

```

## CLI Shortcuts Integration

To add to your existing DevOnboarder CLI shortcuts (`~/.zshrc`):

```bash

# DevOnboarder Policy Functions

devonboarder-policy() {
    if [[ -f "./scripts/devonboarder_policy_check.sh" ]]; then
        ./scripts/devonboarder_policy_check.sh "$@"
    else
        echo "Policy script not found. Are you in DevOnboarder repository?"
    fi
}

# Quick policy checks

alias policy-terminal="devonboarder-policy terminal"
alias policy-check="devonboarder-policy violations"
alias policy-triage="devonboarder-policy triage"

```

## VS Code Task Integration

Add to `.vscode/tasks.json`:

```json
{
    "label": "DevOnboarder: Policy Check",
    "type": "shell",
    "command": "./scripts/devonboarder_policy_check.sh",
    "args": ["${input:policyType}"],
    "group": "test",
    "options": {
        "inputs": [
            {
                "id": "policyType",
                "description": "Policy type to check",
                "type": "pickString",
                "options": [
                    "all",
                    "terminal",
                    "triage",
                    "priority",
                    "escalation",
                    "tokens",
                    "violations"
                ]
            }
        ]
    }
}

```

## Agent Integration Pattern

For AI agents, use this detection pattern:

```bash

# Check if policy tool is available

if [[ -f "./scripts/devonboarder_policy_check.sh" ]]; then
    # Use comprehensive policy tool

    ./scripts/devonboarder_policy_check.sh terminal
else
    # Fallback to individual scripts

    ./scripts/validate_terminal_output.sh
fi

```

## Daily Usage Patterns

```bash

# Morning check routine

./scripts/devonboarder_policy_check.sh violations

# Before major work

./scripts/devonboarder_policy_check.sh priority

# When troubleshooting CI

./scripts/devonboarder_policy_check.sh escalation

# Before commits

./scripts/devonboarder_policy_check.sh terminal

```

## Documentation References

- **Full Implementation Guidelines**: `docs/troubleshooting/DOCUMENTATION_AS_INFRASTRUCTURE_IMPLEMENTATION_GUIDELINES.md`

- **Existing CLI Shortcuts**: `docs/cli-shortcuts.md`

- **Priority Framework**: `docs/PRIORITY_STACK_FRAMEWORK_UPDATE.md`

- **Issue Triage SOP**: `docs/ISSUE_DISCOVERY_TRIAGE_SOP.md`
