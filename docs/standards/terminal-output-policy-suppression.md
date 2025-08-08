# Terminal Output Policy Suppression System

## Overview

The Terminal Output Policy Suppression System allows developers to mark reviewed code patterns as safe, preventing false positives while maintaining security vigilance for new violations.

## Suppression Comment Format

```bash
# terminal-output-policy: reviewed-safe - [reason]
```

### Example Usage

```yaml
# terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter
payload=$(python - <<'PY'
import json
print(json.dumps({"safe": "code"}))
PY
)
```

## When to Use Suppression

### ✅ **SAFE PATTERNS** (Appropriate for suppression)

1. **Python here-docs with quoted delimiters**:

   ```bash
   # terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter
   python - <<'PY'
   ```

2. **GitHub Actions multiline output**:

   ```bash
   # terminal-output-policy: reviewed-safe - GitHub Actions output syntax
   echo "files<<EOF" >> $GITHUB_OUTPUT
   ```

3. **Manually validated secure here-docs**:

   ```bash
   # terminal-output-policy: reviewed-safe - Static content, no variable expansion
   cat > config.txt <<'EOF'
   ```

### ❌ **DANGEROUS PATTERNS** (Never suppress)

1. **Unquoted here-docs with variables**:

   ```bash
   cat << EOF  # DANGEROUS - variables expand
   user = $USER
   EOF
   ```

2. **Here-docs to privileged locations**:

   ```bash
   sudo tee /etc/config << EOF  # DANGEROUS - privileged write
   ```

3. **Dynamic content from user input**:

   ```bash
   cat << EOF  # DANGEROUS - user input injection
   Hello $USER_INPUT
   EOF
   ```

## Review Process

### Manual Review Checklist

Before adding suppression comment, verify:

- [ ] **Quoted delimiter used**: `<<'EOF'` or `<<'PY'` prevents variable expansion
- [ ] **No user input**: No variables from external sources
- [ ] **No privileged operations**: Not writing to protected files
- [ ] **Static or controlled content**: Content is predictable and safe
- [ ] **Security impact assessed**: Understand what the code does

### Documentation Requirements

When suppressing, include:

1. **Clear reasoning**: Why this pattern is safe
2. **Review date**: When it was assessed (optional but recommended)
3. **Reviewer**: Who assessed it (for team tracking)

```bash
# terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter (reviewed 2025-08-08 by @platform-team)
```

## Validation Script Behavior

### Current Logic

The validation script (`scripts/validate_terminal_output_simple.sh`):

1. **Scans for here-doc patterns**: `cat.*<<`, `python.*<<`, `bash.*<<`
2. **Checks for suppression comment**: `terminal-output-policy: reviewed-safe`
3. **Skips flagged files**: No warnings for suppressed patterns
4. **Provides guidance**: Instructions for suppression when violations found

### Output Examples

**Without suppression**:

```text
⚠️  WARNING: Actual here-doc pattern found - verify safety (add '# terminal-output-policy: reviewed-safe' to suppress)
```

**With suppression**:

```text
✓ ENFORCEMENT SUCCESS: No critical terminal output violations found
```

## Integration Points

### Pre-commit Hooks

Terminal Output Policy enforcement runs in pre-commit hooks and respects suppression comments.

### CI/CD Pipeline

All GitHub Actions workflows validate terminal output policy with suppression support.

### Agent Guidelines

All DevOnboarder agents must:

1. **Respect existing suppressions**: Never remove suppression comments
2. **Add suppressions appropriately**: Only for manually reviewed safe patterns
3. **Document reasoning**: Include clear explanation for suppressions
4. **Follow review process**: Complete manual checklist before suppressing

## Examples in DevOnboarder

### Current Suppressions

1. **`.github/workflows/auto-fix.yml`**:
   - 2 Python here-docs for OpenAI API calls
   - Safe due to quoted delimiters and controlled content

2. **`.github/workflows/review-known-errors.yml`**:
   - 2 Python here-docs for data processing
   - Safe due to quoted delimiters and no external input

### Best Practices

```yaml
# ✅ GOOD - Clear suppression with reasoning
- name: Process data
  run: |
    # terminal-output-policy: reviewed-safe - Python here-doc with quoted delimiter for JSON processing
    result=$(python - <<'PY'
    import json
    print(json.dumps({"status": "processed"}))
    PY
    )

# ❌ BAD - No suppression comment for risky pattern
- name: Write config
  run: |
    cat > config.txt << EOF
    user = $USER
    EOF
```

## Security Considerations

### Defense in Depth

Suppression system provides:

1. **Manual review requirement**: Human assessment of safety
2. **Documentation trail**: Reasons preserved in code
3. **Selective bypassing**: Only specific patterns suppressed
4. **Ongoing vigilance**: New violations still caught

### Audit Trail

Suppression comments create permanent audit trail:

- **What**: Pattern that was suppressed
- **Why**: Reasoning for safety assessment
- **When**: Git history shows when added
- **Who**: Git author shows reviewer

## Related Documentation

- [Terminal Output Policy](terminal-output-policy.md)
- [DevOnboarder Security Standards](security-standards.md)
- [Pre-commit Hooks](../development/pre-commit-hooks.md)
- [Agent Development Guidelines](../agents/development-guidelines.md)

---

**Last Updated**: 2025-08-08
**Review Required**: When adding new suppression patterns
**Enforcement**: Pre-commit hooks, CI/CD pipelines, agent validation
