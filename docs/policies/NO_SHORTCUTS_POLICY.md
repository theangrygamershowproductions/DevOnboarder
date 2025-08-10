# NO SHORTCUTS POLICY

**Effective Date**: August 8, 2025
**Status**: ENFORCED
**Scope**: All contributors, agents, and automated tools

## Policy Statement

DevOnboarder has reached **production-grade maturity**. We no longer accept shortcuts, workarounds, or "just ship it" mentality that accumulates tech debt and creates validation noise.

**Zero tolerance for:**

- Bypassing quality gates with `--no-verify`
- Manual fixes to avoid proper tooling
- Inconsistent formatting to "just get it working"
- Documentation that fails linting
- Scripts that violate security patterns

## Enforcement Mechanisms

### 1. CI Gates are BLOCKING

All quality checks now **fail fast and block**:

- ❌ Markdown linting failures block PR merge
- ❌ Vale documentation quality failures block PR merge
- ❌ Terminal output policy violations block PR merge
- ❌ Commit message format violations block PR merge
- ❌ Coverage below 95% blocks PR merge

### 2. Pre-Commit Hooks are MANDATORY

Local validation **prevents** issues from reaching CI:

- All markdown must pass `markdownlint-cli2`
- All documentation must pass `vale`
- All shell scripts must pass `shellcheck`
- All agent frontmatter must validate against schema

### 3. Agent Compliance is REQUIRED

All AI agents (Claude, GitHub Copilot, etc.) must:

- Follow established patterns exactly
- Never suggest bypassing quality gates
- Always use proper tooling syntax
- Respect security boundaries and suppression systems

## Quality Standards Reference

### ✅ Correct Patterns

| Category | ✅ Correct | ❌ Lazy Shortcut |
|----------|-----------|------------------|
| **Markdown Headers** | `### Heading` | `**Heading**` |
| **Links** | `[Text](https://url)` | `https://url` |
| **Shell Variables** | `printf "%s\n" "$VAR"` | `echo $VAR` |
| **Here-docs** | `<<'EOF'` (quoted) | `<<EOF` (unquoted) |
| **Terminal Output** | `echo "Task completed"` | `echo "✅ Task completed"` |
| **Code Blocks** | \`\`\`bash | \`\`\` (no language) |
| **File Paths** | Virtual environment context | System installation |
| **Commit Messages** | `FEAT(scope): description` | `update` / `fix` |

### 🛡️ Security Boundaries

| Pattern | ✅ Safe | ❌ Dangerous |
|---------|---------|-------------|
| **Environment Variables** | `.env` → sync script | Manual multi-file edits |
| **Secrets** | GitHub Actions secrets | Committed credentials |
| **Suppression Comments** | `# terminal-output-policy: reviewed-safe` | Removal to avoid errors |
| **Here-docs with Variables** | `<<'EOF'` (quoted delimiter) | `<<EOF` (expansion risk) |

## Violation Response

### First Violation

- **Immediate**: PR/commit blocked
- **Action**: Fix using proper tooling
- **Documentation**: Reference this policy

### Repeat Violations

- **Pattern Recognition**: Agent education required
- **Systematic Issues**: Tool/process improvement needed
- **Persistent Shortcuts**: Escalation to project leads

### Emergency Bypasses

**Potato Approval Required**: Only project leads can approve bypassing quality gates with documented justification and remediation plan.

## Implementation Tools

### Pre-Commit Configuration

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.8.1
    hooks:
      - id: markdownlint-cli2
        args: ["--config", ".markdownlint-cli2.jsonc"]

  - repo: local
    hooks:
      - id: vale
        name: Vale Documentation Quality
        entry: python -m vale
        language: system
        files: \.md$

      - id: terminal-output-policy
        name: Terminal Output Policy Validation
        entry: bash scripts/validate_terminal_output_simple.sh
        language: system
        files: \.sh$
```

### CI Enforcement

```yaml
# GitHub Actions - BLOCKING mode
- name: Markdown Lint
  run: npx markdownlint-cli2 "**/*.md" "!**/node_modules/**"
  continue-on-error: false  # 🔐 BLOCKS PR

- name: Documentation Quality
  run: |
    source .venv/bin/activate
    python -m vale docs/
  continue-on-error: false  # 🔐 BLOCKS PR

- name: Terminal Output Policy
  run: bash scripts/validate_terminal_output_simple.sh
  continue-on-error: false  # 🔐 BLOCKS PR
```

## Agent Requirements

### For AI Assistants

1. **NEVER suggest bypassing quality gates**
2. **ALWAYS use established patterns from this document**
3. **RESPECT suppression systems** - add suppressions for genuinely safe patterns only
4. **FOLLOW virtual environment requirements** - no system installations
5. **VALIDATE before suggesting** - assume quality gates are intentional

### For Human Contributors

1. **Run pre-commit hooks locally** before pushing
2. **Use project tooling** instead of manual fixes
3. **Follow documentation standards** established in this policy
4. **Request policy updates** through proper channels if patterns are genuinely problematic

## Success Metrics

- **Zero CI failures** due to avoidable quality gate violations
- **Consistent formatting** across all documentation and scripts
- **Security compliance** with no suppression system bypasses
- **Agent compliance** with no shortcut suggestions
- **Platform reliability** through disciplined development practices

## Policy Updates

This policy can only be updated through:

1. **Issue creation** with detailed justification
2. **Team review** and consensus
3. **Documentation update** with migration plan
4. **Tool configuration alignment** with new standards

**Remember**: This platform serves real users. Shortcuts create cascading failures. Quality gates exist for critical reasons.

---

**Enforcement**: This policy is automatically validated by CI and pre-commit hooks. Violations block all contributions until resolved using proper tooling.
