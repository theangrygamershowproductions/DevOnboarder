---
agent: doc_lint_enforcer
purpose: Enforce documentation quality standards with zero tolerance for shortcuts
trigger: on_pull_request, on_push_to_main, manual_validation
environment: CI, pre-commit
output: .codex/logs/doc_lint_enforcer.log
permissions:
    - repo:read
    - workflows:write
    - pull_requests:write
    - issues:write
codex-agent: true
name: "Documentation Lint Enforcer"
type: "monitoring"
description: "Enforces NO_SHORTCUTS_POLICY with blocking validation for markdown, vale, and documentation standards"
---

# Documentation Lint Enforcer Agent

## Mission Statement

**ZERO TOLERANCE** for documentation shortcuts. This agent enforces the [NO_SHORTCUTS_POLICY](../docs/policies/NO_SHORTCUTS_POLICY.md) with blocking validation that prevents tech debt accumulation.

## Enforcement Scope

### Critical Validations (BLOCKING)

- **Markdown Linting**: All `.md` files must pass `markdownlint-cli2`
- **Documentation Quality**: All docs must pass `vale` validation
- **Agent Schema**: All agent frontmatter must validate against JSON schema
- **Terminal Output Policy**: All shell scripts must comply with security patterns
- **Commit Message Format**: All commits must follow conventional format

### Quality Gates

```bash
# Primary validation command
npx markdownlint-cli2 "**/*.md" "!**/node_modules/**"

# Documentation quality enforcement
source .venv/bin/activate && python -m vale docs/

# Agent schema validation
python scripts/validate_agents.py

# Terminal output policy compliance
bash scripts/validate_terminal_output_simple.sh

# Commit message format validation
bash scripts/check_commit_messages.sh
```

## Failure Response Patterns

### Markdown Linting Failures

**Immediate Action**: Block PR with detailed error report

```yaml
# Example CI integration
- name: Documentation Lint Enforcer
  run: |
    echo "🔐 NO_SHORTCUTS_POLICY: Enforcing markdown standards"
    npx markdownlint-cli2 "**/*.md" "!**/node_modules/**" || {
      echo "❌ BLOCKED: Markdown linting failures detected"
      echo "📋 Fix with: npx markdownlint-cli2 --fix '**/*.md'"
      echo "📖 Reference: docs/policies/NO_SHORTCUTS_POLICY.md"
      exit 1
    }
```

### Vale Documentation Quality Failures

**Immediate Action**: Block PR with style guidance

```bash
# Vale enforcement pattern
if ! python -m vale docs/; then
    echo "❌ BLOCKED: Documentation quality standards not met"
    echo "📋 Vale configuration: .vale.ini"
    echo "📖 Writing guide: docs/writing-style-guide.md"
    exit 1
fi
```

### Agent Schema Violations

**Immediate Action**: Block PR with schema validation report

```bash
# Agent frontmatter validation
if ! python scripts/validate_agents.py; then
    echo "❌ BLOCKED: Agent frontmatter schema violations"
    echo "📋 Schema reference: schema/agent-schema.json"
    echo "📖 Agent guide: agents/guidelines/"
    exit 1
fi
```

## Auto-Fix Integration

### Safe Auto-Fixes (ALLOWED)

- Markdown formatting via `markdownlint-cli2 --fix`
- Trailing whitespace removal
- End-of-file normalization
- Python formatting via `black`

### Manual Review Required (BLOCKED AUTO-FIX)

- Content restructuring
- Security pattern violations
- Breaking schema changes
- Policy bypass attempts

## CI Integration Pattern

```yaml
name: Documentation Lint Enforcer
on:
  pull_request:
    paths: ['**/*.md', 'agents/**', 'docs/**']
  push:
    branches: [main]

jobs:
  enforce_no_shortcuts:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Environment
        run: |
          python -m venv .venv
          source .venv/bin/activate
          pip install -e .[test]

      - name: Markdown Lint Enforcement
        run: npx markdownlint-cli2 "**/*.md" "!**/node_modules/**"
        continue-on-error: false  # 🔐 BLOCKING

      - name: Documentation Quality Enforcement
        run: |
          source .venv/bin/activate
          python -m vale docs/
        continue-on-error: false  # 🔐 BLOCKING

      - name: Agent Schema Enforcement
        run: python scripts/validate_agents.py
        continue-on-error: false  # 🔐 BLOCKING

      - name: Terminal Output Policy Enforcement
        run: bash scripts/validate_terminal_output_simple.sh
        continue-on-error: false  # 🔐 BLOCKING

      - name: Generate Enforcement Report
        if: failure()
        run: |
          echo "🚨 NO_SHORTCUTS_POLICY VIOLATION DETECTED"
          echo "📋 All quality gates must pass before merge"
          echo "📖 Policy reference: docs/policies/NO_SHORTCUTS_POLICY.md"
          echo "🛠️ Auto-fix available for most issues"
```

## Agent Behavior Requirements

### For AI Assistants (Claude, Copilot, etc.)

1. **NEVER suggest bypassing quality gates** with `--no-verify` or similar
2. **ALWAYS use auto-fix tools** before manual corrections
3. **RESPECT established patterns** from NO_SHORTCUTS_POLICY.md
4. **VALIDATE before creating** - assume all linting rules are intentional
5. **FOLLOW virtual environment requirements** - no system installations

### For Human Contributors

1. **Run pre-commit hooks locally** before pushing
2. **Use project auto-fix tools** instead of manual formatting
3. **Reference NO_SHORTCUTS_POLICY.md** for quality standards
4. **Request policy updates** through proper channels if genuinely problematic

## Escalation Patterns

### First Violation

- Block PR with detailed fix instructions
- Reference auto-fix commands
- Link to quality standards documentation

### Repeat Violations

- Pattern recognition analysis
- Agent/contributor education required
- Tool/process improvement investigation

### Systematic Issues

- Policy review and potential updates
- Tooling enhancement consideration
- Training documentation updates

## Success Metrics

- **Zero avoidable CI failures** due to documentation quality issues
- **Consistent formatting** across all documentation
- **Agent compliance** with established standards
- **Reduced validation noise** during legitimate development work

## Integration Points

### Pre-Commit Hook Integration

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.18.1
    hooks:
      - id: markdownlint-cli2
        args: ["--config", ".markdownlint-cli2.jsonc"]

  - repo: local
    hooks:
      - id: doc-lint-enforcer
        name: Documentation Lint Enforcer
        entry: bash scripts/doc_lint_enforcer.sh
        language: system
        files: \.(md|yml|yaml)$
```

### GitHub Actions Integration

- **Required status check** for all PRs
- **Branch protection rules** enforcement
- **Auto-comment** with fix instructions on failures
- **Success badges** for compliant repositories

## Monitoring and Alerting

### Quality Trend Analysis

- Track enforcement success rates
- Identify recurring violation patterns
- Monitor auto-fix effectiveness
- Generate compliance reports

### Alert Conditions

- **Critical**: Multiple enforcement failures in single PR
- **Warning**: Repeat violations from same contributor/agent
- **Info**: Successful auto-fix applications

## Emergency Procedures

### Potato Approval Override

**Only for critical production issues**:

1. Document justification in emergency issue
2. Create remediation plan with timeline
3. Apply minimal bypass with tracking
4. Schedule immediate fix in next sprint

**Never acceptable**:

- Convenience bypasses
- "Just this once" exceptions
- Avoiding legitimate quality work
- Shortcut accumulation

---

**Enforcement Philosophy**: This agent exists to **prevent** the frustration of accumulated shortcuts. Every bypass creates future validation noise. Quality gates exist for platform reliability and should be respected, not circumvented.
