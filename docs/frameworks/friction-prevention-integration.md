---
similarity_group: frameworks-frameworks
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Framework Phase 2 Integration Guide

## Overview

This guide provides comprehensive information for integrating Framework Phase 2 (Friction Prevention Framework) into your DevOnboarder development workflow. It covers migration from legacy scripts, integration patterns, and best practices.

## Migration from Legacy Scripts

### Script Location Mapping

The following table shows the migration path from legacy script locations to Framework Phase 2 structure:

| Legacy Location | Framework Phase 2 Location | Category | Notes |
|---|---|---|---|
| `scripts/automate_pr_process.sh` | `frameworks/friction_prevention/automation/automate_pr_process.sh` | Automation | Complete PR workflow |
| `scripts/smart_env_sync.sh` | `frameworks/friction_prevention/workflow/smart_env_sync.sh` | Workflow | Environment sync |
| `scripts/qc_pre_push.sh` | `frameworks/friction_prevention/workflow/qc_pre_push.sh` | Workflow | Quality control |
| `scripts/safe_commit.sh` | `frameworks/friction_prevention/developer_experience/safe_commit.sh` | Dev Experience | Safe commits |
| `scripts/monitor_ci_health.sh` | `frameworks/friction_prevention/workflow/monitor_ci_health.sh` | Workflow | CI monitoring |
| `scripts/analyze_logs.sh` | `frameworks/friction_prevention/productivity/analyze_logs.sh` | Productivity | Log analysis |
| `scripts/generate_aar.py` | `frameworks/friction_prevention/productivity/generate_aar.py` | Productivity | AAR generation |

### Migration Checklist

**Phase 1: Preparation**

- [ ] Activate virtual environment: `source .venv/bin/activate`
- [ ] Create feature branch: `git checkout -b feat/framework-migration-yourname`
- [ ] Run QC validation: `./frameworks/friction_prevention/workflow/qc_pre_push.sh`
- [ ] Backup current workflow configurations

**Phase 2: Update References**

- [ ] Update `.github/workflows/` references to framework paths
- [ ] Update `Makefile` targets to use framework scripts
- [ ] Update documentation references in `docs/`
- [ ] Update any custom scripts that call legacy script locations

**Phase 3: Validation**

- [ ] Test framework script execution
- [ ] Validate CI/CD pipeline functionality
- [ ] Run comprehensive quality gates
- [ ] Verify all integrations work correctly

**Phase 4: Cleanup**

- [ ] Remove legacy script references (but keep files during transition)
- [ ] Update team documentation
- [ ] Communicate changes to team members
- [ ] Monitor for any missed references

## Integration Patterns

### CI/CD Pipeline Integration

#### GitHub Actions Integration

```yaml
# .github/workflows/framework-integration.yml
name: Framework Phase 2 Integration

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  quality-gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python Environment
        run: |
          python -m venv .venv
          source .venv/bin/activate
          pip install -e .[test]

      - name: Run Framework QC Validation
        run: |
          source .venv/bin/activate
          ./frameworks/friction_prevention/workflow/qc_pre_push.sh

      - name: PR Health Assessment
        if: github.event_name == 'pull_request'
        run: |
          source .venv/bin/activate
          ./frameworks/friction_prevention/automation/assess_pr_health.sh ${{ github.event.number }}

      - name: Monitor CI Health
        run: |
          source .venv/bin/activate
          ./frameworks/friction_prevention/workflow/monitor_ci_health.sh
```

#### Pre-commit Hook Integration

```bash
# .git/hooks/pre-commit
#!/bin/bash

set -e

# Ensure virtual environment is activated
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "Error: Virtual environment not activated"
    echo "Run: source .venv/bin/activate"
    exit 1
fi

# Run Framework Phase 2 validations
echo "Running Framework Phase 2 validations..."

# Quality control validation
./frameworks/friction_prevention/workflow/qc_pre_push.sh

# Internal link validation for documentation changes
if git diff --cached --name-only | grep -q '\.md$'; then
    ./frameworks/friction_prevention/workflow/validate_internal_links.sh
fi

echo "Framework validations passed "
```

### Developer Workflow Integration

#### Enhanced Safe Commit Process

```bash
# Enhanced developer workflow using Framework Phase 2
function dev_workflow() {
    # 1. Ensure proper environment
    source .venv/bin/activate

    # 2. Run pre-development checks
    ./frameworks/friction_prevention/workflow/smart_env_sync.sh --validate-only

    # 3. Development work happens here...

    # 4. Pre-commit validation
    ./frameworks/friction_prevention/workflow/qc_pre_push.sh

    # 5. Safe commit with comprehensive validation
    ./frameworks/friction_prevention/developer_experience/safe_commit.sh "$1"

    # 6. Optional: Branch cleanup if feature complete
    if [[ "$2" == "--cleanup" ]]; then
        ./frameworks/friction_prevention/automation/auto_branch_manager.sh --auto
    fi
}

# Usage examples:
# dev_workflow "FEAT(auth): add JWT validation endpoint"
# dev_workflow "FIX(ci): resolve timeout issues" --cleanup
```

#### Automation Integration

```bash
# Automated PR workflow using Framework Phase 2
function automated_pr_workflow() {
    local pr_number="$1"

    # Activate environment
    source .venv/bin/activate

    # Health assessment
    ./frameworks/friction_prevention/automation/assess_pr_health.sh "$pr_number"

    # Automated processing
    ./frameworks/friction_prevention/automation/automate_pr_process.sh

    # Post-merge cleanup (if applicable)
    if [[ "$2" == "--post-merge" ]]; then
        ./frameworks/friction_prevention/automation/automate_post_merge_cleanup.sh
    fi
}
```

## Makefile Integration

### Updated Makefile Targets

```makefile
# Framework Phase 2 Integration in Makefile

# Quality gates using framework scripts
.PHONY: framework-qc
framework-qc:
    @echo "Running Framework Phase 2 Quality Control..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/workflow/qc_pre_push.sh

# Safe commit helper
.PHONY: framework-commit
framework-commit:
    @echo "Framework Safe Commit..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/developer_experience/safe_commit.sh "$(MSG)"

# Environment validation
.PHONY: framework-env-check
framework-env-check:
    @echo "Framework Environment Validation..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/workflow/smart_env_sync.sh --validate-only

# CI health monitoring
.PHONY: framework-ci-health
framework-ci-health:
    @echo "Framework CI Health Check..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/workflow/monitor_ci_health.sh

# Branch management
.PHONY: framework-branch-cleanup
framework-branch-cleanup:
    @echo "Framework Branch Cleanup..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/automation/comprehensive_branch_cleanup.sh

# Log analysis
.PHONY: framework-analyze-logs
framework-analyze-logs:
    @echo "Framework Log Analysis..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/productivity/analyze_logs.sh

# AAR generation
.PHONY: framework-generate-aar
framework-generate-aar:
    @echo "Framework AAR Generation..."
    @source .venv/bin/activate && ./frameworks/friction_prevention/productivity/generate_aar.py $(WORKFLOW_ID)

# Complete framework workflow
.PHONY: framework-full-workflow
framework-full-workflow: framework-env-check framework-qc framework-ci-health
    @echo "Complete Framework Phase 2 workflow executed "

# Usage examples:
# make framework-qc
# make framework-commit MSG="FEAT(feature): description"
# make framework-env-check
# make framework-full-workflow
```

## VS Code Integration

### VS Code Tasks Configuration

```json
// .vscode/tasks.json - Framework Phase 2 Integration
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Framework: Quality Control",
            "type": "shell",
            "command": "./frameworks/friction_prevention/workflow/qc_pre_push.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Framework: Safe Commit",
            "type": "shell",
            "command": "./frameworks/friction_prevention/developer_experience/safe_commit.sh",
            "args": ["${input:commitMessage}"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Framework: Environment Check",
            "type": "shell",
            "command": "./frameworks/friction_prevention/workflow/smart_env_sync.sh",
            "args": ["--validate-only"],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Framework: PR Health Check",
            "type": "shell",
            "command": "./frameworks/friction_prevention/automation/assess_pr_health.sh",
            "args": ["${input:prNumber}"],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ],
    "inputs": [
        {
            "id": "commitMessage",
            "description": "Commit message (TYPE(scope): description)",
            "default": "FEAT(feature): description",
            "type": "promptString"
        },
        {
            "id": "prNumber",
            "description": "Pull Request Number",
            "default": "",
            "type": "promptString"
        }
    ]
}
```

### VS Code Settings

```json
// .vscode/settings.json - Framework Integration
{
    "terminal.integrated.env.linux": {
        "FRAMEWORK_PHASE": "2",
        "FRAMEWORK_NAME": "friction_prevention"
    },
    "files.associations": {
        "frameworks/friction_prevention/**/*.sh": "shellscript",
        "frameworks/friction_prevention/**/*.py": "python"
    },
    "shellcheck.customArgs": [
        "-x",
        "--source-path=frameworks/friction_prevention/config"
    ]
}
```

## Team Collaboration Guidelines

### Onboarding New Team Members

**Framework Phase 2 Onboarding Checklist:**

1. **Environment Setup**
   - [ ] Clone DevOnboarder repository
   - [ ] Setup virtual environment: `python -m venv .venv && source .venv/bin/activate`
   - [ ] Install dependencies: `pip install -e .[test]`
   - [ ] Validate setup: `./frameworks/friction_prevention/workflow/qc_pre_push.sh`

2. **Framework Orientation**
   - [ ] Review `docs/frameworks/friction-prevention.md`
   - [ ] Understand script categories and purposes
   - [ ] Practice safe commit workflow
   - [ ] Complete sample framework operations

3. **Integration Setup**
   - [ ] Configure VS Code tasks and settings
   - [ ] Setup pre-commit hooks
   - [ ] Update personal development scripts
   - [ ] Test all framework integration points

### Team Communication Protocols

**Framework Usage Communication:**

- **Daily Standups**: Report framework script usage and any issues
- **PR Reviews**: Mention framework validations in PR descriptions
- **Issue Reporting**: Use framework health metrics for issue triage
- **Knowledge Sharing**: Share framework optimization tips and patterns

**Example PR Description Template:**

```markdown
## Framework Phase 2 Validation 

- [ ] QC Validation: `./frameworks/friction_prevention/workflow/qc_pre_push.sh` 
- [ ] Safe Commit: Used framework safe commit wrapper 
- [ ] Environment Check: Validated with `smart_env_sync.sh --validate-only` 
- [ ] PR Health: Assessed with `assess_pr_health.sh` 

## Changes Summary
[Your change description here]

## Framework Script Usage
- Used `automate_pr_process.sh` for workflow automation
- Applied `comprehensive_branch_cleanup.sh` for cleanup
```

## Performance Monitoring

### Framework Metrics Collection

```bash
# Framework performance monitoring script
function framework_metrics() {
    local start_time=$(date %s)
    local script_name="$1"
    local log_file="logs/framework_metrics_$(date %Y%m%d).log"

    # Execute framework script with timing
    echo "$(date '%Y-%m-%d %H:%M:%S UTC') - Starting $script_name" >> "$log_file"

    if "$script_name" "${@:2}"; then
        local end_time=$(date %s)
        local duration=$((end_time - start_time))
        echo "$(date '%Y-%m-%d %H:%M:%S UTC') - Completed $script_name (${duration}s) " >> "$log_file"
        return 0
    else
        local end_time=$(date %s)
        local duration=$((end_time - start_time))
        echo "$(date '%Y-%m-%d %H:%M:%S UTC') - Failed $script_name (${duration}s) " >> "$log_file"
        return 1
    fi
}

# Usage:
# framework_metrics "./frameworks/friction_prevention/workflow/qc_pre_push.sh"
# framework_metrics "./frameworks/friction_prevention/automation/assess_pr_health.sh" "1740"
```

### Health Dashboard Integration

Framework Phase 2 scripts can be integrated with monitoring dashboards:

```bash
# Framework health report generation
./frameworks/friction_prevention/productivity/analyze_logs.sh --framework-health > framework_health_report.json

# CI health integration
./frameworks/friction_prevention/workflow/monitor_ci_health.sh --json-output > ci_health_metrics.json

# Combined health metrics
{
    "framework_phase": 2,
    "timestamp": "$(date -u %Y-%m-%dT%H:%M:%SZ)",
    "framework_health": $(cat framework_health_report.json),
    "ci_health": $(cat ci_health_metrics.json)
} > combined_health_metrics.json
```

## Troubleshooting Integration Issues

### Common Integration Problems

1. **Virtual Environment Issues**

   ```bash
   # Problem: Scripts fail due to missing virtual environment
   # Solution: Always activate before framework script execution
   source .venv/bin/activate
   ./frameworks/friction_prevention/workflow/qc_pre_push.sh
   ```

2. **Path Resolution Issues**

   ```bash
   # Problem: Scripts not found or wrong script executed
   # Solution: Use absolute paths from project root
   ./frameworks/friction_prevention/automation/script_name.sh
   # NOT: cd frameworks/friction_prevention/automation && ./script_name.sh
   ```

3. **Permission Issues**

   ```bash
   # Problem: Permission denied on script execution
   # Solution: Ensure execute permissions on framework scripts
   chmod x frameworks/friction_prevention/**/*.sh
   ```

4. **Quality Gate Failures**

   ```bash
   # Problem: QC validation fails
   # Solution: Run individual validations to identify specific issues
   ./frameworks/friction_prevention/workflow/qc_pre_push.sh --verbose
   ```

### Debugging Framework Issues

```bash
# Debug framework script execution
FRAMEWORK_DEBUG=1 ./frameworks/friction_prevention/workflow/script_name.sh

# Analyze framework logs
./frameworks/friction_prevention/productivity/analyze_logs.sh --framework-focus

# Generate AAR for framework issues
./frameworks/friction_prevention/productivity/generate_aar.py --framework-analysis
```

## Next Steps

### Post-Integration Tasks

1. **Monitor Framework Performance**
   - Track script execution times
   - Monitor error rates and patterns
   - Analyze framework adoption metrics

2. **Optimize Framework Usage**
   - Identify frequently used script combinations
   - Create custom workflow compositions
   - Develop team-specific automation patterns

3. **Prepare for Phase 3**
   - Review Security Validation Framework requirements
   - Plan Phase 3 integration timeline
   - Document lessons learned from Phase 2

### Continuous Improvement

- **Weekly Framework Reviews**: Assess framework effectiveness and identify improvements
- **Monthly Metrics Analysis**: Review framework performance and adoption metrics
- **Quarterly Framework Evolution**: Plan framework enhancements and Phase 3 preparation

---

**Integration Guide Version**: 1.0.0
**Last Updated**: October 4, 2025
**Framework Phase**: 2 (Friction Prevention)
**Status**: Ready for Team Adoption
