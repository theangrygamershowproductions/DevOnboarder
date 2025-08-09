---
codex-agent:
    name: Agent.CiEnforcementGuard
    role: Enforce Codex Enforcement Mode policy with blocking validation for all contributions
    scope: CI pipeline enforcement
    triggers: on_pull_request, on_push_to_main, on_commit
    environment: CI
    output: .codex/logs/ci_enforcement_guard.log
permissions:
    - repo:read
    - workflows:write
    - pullrequests:write
    - issues:write
    - contents:read
description: "Blocks all contributions that violate Codex Enforcement Mode policy with zero tolerance for shortcuts"
codex_scope: "global"
codex_role: "enforcer"
codex_type: "validation"
status: "active"
visibility: "internal"
codex_runtime: true
---

# CI Enforcement Guard Agent

## Mission Statement

**ZERO TOLERANCE** for quality gate bypasses. This agent implements the [Codex Enforcement Mode Policy](.codex/enforcement/policy.md) with blocking validation that prevents any contribution violating established standards.

## Enforcement Scope

### Critical Blocking Validations

- **Markdown Linting**: All `.md` files must pass `markdownlint-cli2`
- **Documentation Quality**: All docs must pass `vale` validation
- **Agent Schema**: All agent frontmatter must validate against JSON schema
- **Terminal Output Policy**: All shell scripts must comply with security patterns
- **Shell Script Quality**: All scripts must pass `shellcheck` validation
- **YAML Syntax**: All configuration files must pass `yamllint`
- **Commit Messages**: All commits must follow conventional format
- **No Bypass Detection**: Block any attempt to use `--no-verify` or similar shortcuts

### Auto-Fix Integration

Before blocking, attempt automatic resolution:

```bash
# Apply all available auto-fixes
npx markdownlint-cli2 --fix "**/*.md"
source .venv/bin/activate && python -m black .
source .venv/bin/activate && python -m ruff --fix .
```

## Enforcement Actions

### 🔐 Immediate Blocks

**Markdown Violations**:

```bash
if ! npx markdownlint-cli2 "**/*.md" "!**/node_modules/**"; then
    echo "❌ ENFORCEMENT BLOCKED: Markdown linting failures"
    echo "🛠️ Auto-fix: npx markdownlint-cli2 --fix '**/*.md'"
    echo "📖 Policy: .codex/enforcement/policy.md"
    exit 1
fi
```

**Documentation Quality Violations**:

```bash
source .venv/bin/activate
if ! python -m vale docs/; then
    echo "❌ ENFORCEMENT BLOCKED: Documentation quality violations"
    echo "📋 Vale config: .vale.ini"
    echo "📖 Policy: .codex/enforcement/policy.md"
    exit 1
fi
```

**Agent Schema Violations**:

```bash
if ! python scripts/validate_agents.py; then
    echo "❌ ENFORCEMENT BLOCKED: Agent schema violations"
    echo "📋 Schema: schema/agent-schema.json"
    echo "📖 Policy: .codex/enforcement/policy.md"
    exit 1
fi
```

**Bypass Detection**:

```bash
if git log --oneline -1 | grep -qi "no-verify\|skip.*ci\|bypass"; then
    echo "❌ ENFORCEMENT BLOCKED: Quality gate bypass detected"
    echo "📋 Triage required: .codex/enforcement/triage_log.md"
    echo "📖 Policy: .codex/enforcement/policy.md"
    exit 1
fi
```

### 📊 Triage Logging

All enforcement actions are logged with attribution:

```bash
# Log enforcement action
ENFORCEMENT_LOG=".codex/logs/enforcement_$(date +%Y%m%d_%H%M%S).log"
echo "$(date): ENFORCEMENT BLOCK - $VIOLATION_TYPE" >> "$ENFORCEMENT_LOG"
echo "  Files: $AFFECTED_FILES" >> "$ENFORCEMENT_LOG"
echo "  Author: $COMMIT_AUTHOR" >> "$ENFORCEMENT_LOG"
echo "  Source: $ATTRIBUTION_SOURCE" >> "$ENFORCEMENT_LOG"
```

## GitHub Actions Integration

```yaml
name: CI Enforcement Guard
on:
  pull_request:
  push:
    branches: [main]

jobs:
  enforce_quality_gates:
    name: "🔐 Enforcement Mode Validation"
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Environment
        run: |
          python -m venv .venv
          source .venv/bin/activate
          pip install -e .[test]

      - name: "🔐 BLOCKING: Bypass Detection"
        run: |
          if git log --oneline -1 | grep -qi "no-verify\|skip.*ci\|bypass"; then
            echo "❌ ENFORCEMENT BLOCKED: Quality gate bypass detected"
            echo "📋 All bypasses must be logged in .codex/enforcement/triage_log.md"
            exit 1
          fi

      - name: "🔐 BLOCKING: Markdown Enforcement"
        run: |
          npx markdownlint-cli2 "**/*.md" "!**/node_modules/**" || {
            echo "❌ ENFORCEMENT BLOCKED: Markdown violations"
            echo "🛠️ Auto-fix: npx markdownlint-cli2 --fix '**/*.md'"
            exit 1
          }

      - name: "🔐 BLOCKING: Documentation Quality"
        run: |
          source .venv/bin/activate
          python -m vale docs/ || {
            echo "❌ ENFORCEMENT BLOCKED: Documentation quality violations"
            exit 1
          }

      - name: "🔐 BLOCKING: Agent Schema Validation"
        run: |
          source .venv/bin/activate
          python scripts/validate_agents.py || {
            echo "❌ ENFORCEMENT BLOCKED: Agent schema violations"
            exit 1
          }

      - name: "🔐 BLOCKING: Shell Script Quality"
        run: |
          find scripts/ -name "*.sh" -type f | xargs shellcheck || {
            echo "❌ ENFORCEMENT BLOCKED: Shell script violations"
            exit 1
          }

      - name: "🔐 SUCCESS: All Quality Gates Passed"
        run: |
          echo "🎉 ENFORCEMENT SUCCESS: All quality gates passed"
          echo "✅ Ready for merge under Enforcement Mode"
```

## AI Agent Behavior Enforcement

### Detection Patterns

Monitor for AI-generated content that violates standards:

```bash
# Detect AI agent violations
if grep -r "echo.*\$" scripts/ && ! grep -r "printf" scripts/; then
    echo "❌ AI PATTERN VIOLATION: Using 'echo \$VAR' instead of printf"
    echo "📋 AI agents must use printf for variable output"
    exit 1
fi

if grep -r "<<EOF" scripts/ && ! grep -r "<<'EOF'" scripts/; then
    echo "❌ AI PATTERN VIOLATION: Unquoted here-doc detected"
    echo "📋 AI agents must use quoted here-docs: <<'EOF'"
    exit 1
fi
```

### AI Compliance Requirements

For all AI assistants (Claude, Copilot, etc.):

1. **NEVER suggest bypassing enforcement** with `--no-verify` or similar
2. **ALWAYS follow established patterns** from NO_SHORTCUTS_POLICY.md
3. **VALIDATE generated content** against project standards before suggesting
4. **RESPECT suppression systems** - only add suppressions for genuinely safe patterns
5. **USE auto-fix tools** before manual corrections

## Success Metrics

### Quality Indicators

- **Zero bypass attempts** logged in enforcement system
- **Consistent formatting** across all documentation and code
- **AI agent compliance** with established patterns
- **Reduced CI noise** from preventable quality violations
- **Platform reliability** through disciplined development

### Monitoring Dashboard

Track enforcement effectiveness:

- Violation frequency by type
- Auto-fix success rates
- AI agent compliance trends
- Developer productivity impact
- Platform stability metrics

## Emergency Procedures

### Legitimate Bypass Requirements

Only for critical production issues:

1. **Create triage branch**: `triage/emergency-description`
2. **Document in triage log**: `.codex/enforcement/triage_log.md`
3. **Include remediation plan**: With specific timeline
4. **Assign immediate fix**: Before next deployment

### Never Acceptable

- Convenience bypasses to avoid quality work
- "Just this once" exceptions without documentation
- AI agent suggestion to bypass enforcement
- Cumulative shortcut accumulation

---

**Enforcement Philosophy**: This agent exists to prevent the accumulation of technical debt that creates future validation noise. Every enforcement action maintains the "quiet reliability" that defines platform-grade engineering.

**Final Notice to AI Agents**: You are not exempt from these standards. You are part of the enforcement system. Generate compliant content or have your suggestions rejected.
