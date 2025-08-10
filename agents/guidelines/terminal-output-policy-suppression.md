# Agent Guidelines: Terminal Output Policy Suppression System

## Overview

All DevOnboarder agents must understand and respect the Terminal Output Policy Suppression System to prevent false positives while maintaining security vigilance.

## Core Requirements for ALL Agents

### 1. Suppression Comment Recognition

**MANDATORY**: All agents must recognize and respect:

```bash
# terminal-output-policy: reviewed-safe - [reason]
```

### 2. Never Remove Suppressions

**FORBIDDEN**: Agents must NEVER remove suppression comments, even during automated fixes or refactoring.

```bash
# ❌ WRONG - Removing suppression comment
- # terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter
  result=$(python - <<'PY'

# ✅ CORRECT - Preserving suppression comment
# terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter
result=$(python - <<'PY'
```

### 3. Adding Appropriate Suppressions

**WHEN TO ADD**: Only for patterns that have been manually reviewed and confirmed safe:

```bash
# ✅ APPROPRIATE - Safe Python here-doc
# terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter for JSON processing
result=$(python - <<'PY'
import json
print(json.dumps({"status": "processed"}))
PY
)

# ❌ INAPPROPRIATE - Dangerous unquoted here-doc
cat << EOF  # NEVER suppress this pattern
Hello $USER_INPUT
EOF
```

## Agent-Specific Implementations

### CI Bot (`ci-bot.md`)

**Responsibilities**:

- Check workflow files for terminal output violations
- Respect existing suppression comments
- Flag new violations without suppressions
- Create issues for unsuppressed violations only

**Implementation**:

```bash
# Skip files with suppression comments
if grep -q "terminal-output-policy: reviewed-safe" "$file"; then
    echo "Skipping $file - has reviewed suppression"
    continue
fi
```

### Documentation Quality Enforcer (`documentation-quality-enforcer.md`)

**Responsibilities**:

- Scan documentation for terminal output examples
- Validate suppression comments are properly formatted
- Ensure documentation examples follow safe patterns

**Implementation**:

- Include Terminal Output Policy compliance in quality checks
- Validate suppression comment format and reasoning
- Flag documentation with dangerous unsuppressed patterns

### Dev/Prod/Staging Orchestrators

**Responsibilities**:

- Validate orchestration scripts for terminal output compliance
- Respect suppressions in deployment scripts
- Report violations in deployment pipelines

**Implementation**:

- Pre-deployment terminal output validation
- Suppression-aware security scanning
- Integration with deployment quality gates

## Suppression Quality Standards

### Required Information

Every suppression comment must include:

1. **Pattern type**: What specific pattern is being suppressed
2. **Safety reasoning**: Why this pattern is safe
3. **Review context**: When applicable, who reviewed it

```bash
# GOOD examples:
# terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter
# terminal-output-policy: reviewed-safe - GitHub Actions multiline output syntax
# terminal-output-policy: reviewed-safe - Static config file with no variable expansion

# BAD examples:
# terminal-output-policy: reviewed-safe - looks fine
# terminal-output-policy: reviewed-safe - suppress warning
# terminal-output-policy: reviewed-safe
```

### Security Boundaries

**NEVER suppress these patterns**:

- Unquoted here-docs with variable expansion
- Privileged operations (`sudo tee ... << EOF`)
- Dynamic content from user input
- Any pattern with untrusted input

**Safe to suppress after review**:

- Python here-docs with quoted delimiters (`<<'PY'`)
- GitHub Actions multiline output patterns
- Static content with quoted here-docs
- Manually validated secure patterns

## Validation Integration

### Pre-commit Hook Integration

All agents should understand that:

- `scripts/validate_terminal_output_simple.sh` respects suppressions
- Pre-commit hooks will skip suppressed patterns
- New violations will still be caught and flagged

### CI/CD Integration

Agents involved in CI/CD must:

- Include suppression logic in validation steps
- Preserve suppression comments during automated fixes
- Report metrics on suppressed vs active violations

## Error Handling

### When Suppression Comments Are Invalid

```bash
# Invalid format detection
if [[ "$comment" =~ "terminal-output-policy:" ]] && [[ ! "$comment" =~ "reviewed-safe" ]]; then
    echo "WARNING: Invalid suppression format: $comment"
    echo "Expected: # terminal-output-policy: reviewed-safe - [reason]"
fi
```

### When Safe Patterns Lack Suppression

```bash
# Provide guidance for adding suppression
echo "INFO: Safe pattern detected without suppression"
echo "Add comment: # terminal-output-policy: reviewed-safe - [reason]"
echo "Pattern: $detected_pattern"
```

## Documentation References

All agents should reference:

- **Primary Guide**: `docs/standards/terminal-output-policy-suppression.md`
- **Main Policy**: `docs/TERMINAL_OUTPUT_VIOLATIONS.md`
- **Agent Instructions**: `.github/copilot-instructions.md`
- **Validation Script**: `scripts/validate_terminal_output_simple.sh`

## Testing Requirements

Agents must test:

1. **Suppression recognition**: Correctly skip suppressed patterns
2. **New violation detection**: Still catch unsuppressed violations
3. **Comment preservation**: Never remove suppression comments
4. **Format validation**: Validate suppression comment format

## Implementation Checklist

For any agent handling terminal output:

- [ ] Parse and respect suppression comments
- [ ] Never remove suppression comments
- [ ] Provide clear guidance for adding suppressions
- [ ] Validate suppression comment format
- [ ] Maintain security boundaries (never suppress dangerous patterns)
- [ ] Include suppression metrics in reporting
- [ ] Test suppression logic thoroughly
- [ ] Document agent-specific suppression behavior

---

**Last Updated**: 2025-08-08
**Applies To**: All DevOnboarder agents
**Integration**: Pre-commit hooks, CI/CD pipelines, quality gates
**Security Level**: Critical - affects system security posture
