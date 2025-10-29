---
consolidation_priority: P3
content_uniqueness_score: 4
merge_candidate: false
similarity_group: troubleshooting-troubleshooting
updated_at: 2025-10-27
---

# Documentation as Infrastructure (DaI) Implementation Guidelines

**CRITICAL**: These guidelines must be followed for any Documentation as Infrastructure implementation work in DevOnboarder.

## Implementation Requirements

### 1. Study Existing DevOnboarder Workflows

**Requirement**: Understand proper patterns before creating new workflows.

**Process**:

```bash

# Study existing workflow patterns

ls -la .github/workflows/

# Focus on these key patterns

# - ci.yml (comprehensive test pipeline)

# - auto-fix.yml (automated formatting)

# - potato-policy-focused.yml (security enforcement)

# - pr-automation.yml (PR automation framework)

```

**Key Patterns to Follow**:

- Consistent indentation (2 spaces for YAML)

- Proper job dependencies and conditionals

- Environment variable handling

- Error handling and logging

- Artifact management

### 2. Terminal Output Policy - ZERO TOLERANCE

**CRITICAL**: DevOnboarder has a ZERO TOLERANCE POLICY for terminal output violations.

**FORBIDDEN** (Will cause immediate terminal hanging):

```bash

# NEVER USE - These cause immediate terminal hanging

echo " Task completed"              # Emojis cause hanging

echo " Deployment successful"       # Unicode causes hanging

echo " Checklist: $(get_items)"    # Command substitution in echo

echo -e "Line1\nLine2\nLine3"        # Multi-line escape sequences

cat << 'EOF'                         # Here-doc patterns

Multi-line content
EOF
echo "Status: $STATUS_VAR"           # Variable expansion in echo

```

**REQUIRED** (Safe patterns only):

```bash

# ALWAYS USE - Plain ASCII text only

echo "Task completed successfully"
echo "Deployment finished"
echo "Processing file"
echo "Operation complete"

# For variables, use printf

printf "Status: %s\n" "$STATUS_VAR"
printf "Files processed: %d\n" "$FILE_COUNT"

# Store command output first, then echo

RESULT=$(command_here)
echo "Command completed"
printf "Result: %s\n" "$RESULT"

```

**Character Restrictions**:

-  **NO EMOJIS**: , , 🎯, , , , , , , etc.

-  **NO UNICODE**: Special symbols, arrows, bullets, etc.

-  **NO SPECIAL FORMATTING**: Colors, bold, underline, etc.

-  **ONLY ASCII**: Letters, numbers, basic punctuation (. , : ; - _ )

### 3. Token Architecture v2.1 Compliance

**Requirement**: Use existing Token Architecture v2.1 system systematically.

**Token Hierarchy**:

```bash

# Proper token hierarchy (CI_ISSUE_AUTOMATION_TOKEN  CI_BOT_TOKEN  GITHUB_TOKEN)

CI_ISSUE_AUTOMATION_TOKEN || CI_BOT_TOKEN || GITHUB_TOKEN

```

**Implementation Pattern**:

```yaml

# In GitHub Actions workflows

env:
  # Token Architecture v2.1 hierarchy

  GH_TOKEN: ${{ secrets.CI_ISSUE_AUTOMATION_TOKEN || secrets.CI_BOT_TOKEN || secrets.GITHUB_TOKEN }}

steps:

- name: Load DevOnboarder Token Architecture v2.1

  run: |
    # Load Token Architecture v2.1 system

    if [ -f "scripts/enhanced_token_loader.sh" ]; then
        source scripts/enhanced_token_loader.sh
        echo "Token Architecture v2.1 loaded successfully"
    else
        echo "Token Architecture v2.1 not found, using fallback"
    fi

```

**Required Scripts**:

- `scripts/enhanced_token_loader.sh` - Primary token loading system

- `scripts/load_token_environment.sh` - Legacy fallback loader

- `scripts/validate_token_architecture.sh` - Validation system

### 4. Incremental Testing Approach

**Requirement**: Test each component individually before integration.

**Testing Process**:

1. **Create one workflow at a time**

2. **Validate YAML syntax immediately**: `yamllint .github/workflows/new-workflow.yml`

3. **Test token loading**: Verify scripts load correctly

4. **Validate environment variables**: Check all required vars exist

5. **Test workflow execution**: Run in isolation before integration

**Validation Commands**:

```bash

# YAML validation (required before commit)

source .venv/bin/activate
yamllint .github/workflows/your-workflow.yml

# Token validation

bash scripts/validate_token_architecture.sh

# Pre-push quality check (95% threshold)

./scripts/qc_pre_push.sh

```

### 5. Charter Compliance Without Policy Violations

**Requirement**: Implement charter requirements while respecting core DevOnboarder policies.

**Charter Requirements**:

- 100% PR documentation compliance enforcement

- Documentation drift detection within 24 hours

- 98% setup guide success rate tracking

- 90% issue solutions documented within 48 hours

- Cross-version compatibility validation

- Outsider validation program

- Waiver protocol with 72-hour approval

**Policy Boundaries**:

- Terminal output policy (no emojis/Unicode)

- Token Architecture v2.1 compliance

- YAML quality standards

- Virtual environment requirements

- Centralized logging policy

- Root artifact guard enforcement

**Implementation Strategy**:

```bash

# Phase approach - implement incrementally

# Phase 1: Foundation (policies  token architecture)

# Phase 2: Core enforcement (PR compliance  drift detection)

# Phase 3: Metrics and validation (success rates  solutions)

# Phase 4: Governance (waiver protocol  reporting)

```

## Implementation Checklist

Before creating any DaI workflows:

- [ ] **Study existing workflows** for proper patterns

- [ ] **Review terminal output policy** - no emojis/Unicode allowed

- [ ] **Understand Token Architecture v2.1** - use existing scripts

- [ ] **Plan incremental approach** - test each piece separately

- [ ] **Map charter requirements** to DevOnboarder policies

- [ ] **Validate YAML syntax** before proceeding

- [ ] **Test token loading** in isolation

- [ ] **Run quality checks** before committing

## Emergency Procedures

### If Terminal Output Violations Detected

```bash

# Immediate action - remove all emojis/Unicode

grep -r "[🔑🚨🎯🏆🔴🎉]" .github/workflows/

# Replace ALL matches with plain ASCII text

```

### If YAML Syntax Errors

```bash

# Stop immediately and fix

yamllint .github/workflows/problematic-file.yml

# Fix all errors before proceeding

```

### If Token Architecture Violations

```bash

# Validate current implementation

bash scripts/validate_token_architecture.sh

# Fix hierarchy issues using existing patterns

```

## Key Success Factors

1. **Policy First**: DevOnboarder policies are non-negotiable

2. **ASCII Only**: Terminal output must be plain ASCII text

3. **Use Existing Systems**: Leverage Token Architecture v2.1

4. **Test Incrementally**: Validate each component separately

5. **Quality Gates**: Use existing validation systems

6. **Charter Alignment**: Meet requirements without policy violations

## Common Failures to Avoid

 **Manual workflow creation without studying existing patterns**
 **Using emojis or Unicode in terminal output (causes hanging)**

 **Bypassing Token Architecture v2.1 system**

 **Creating all workflows at once without testing**

 **Ignoring YAML quality standards**

 **Missing virtual environment requirements**

## Documentation Standards

When documenting DaI implementation:

- Use clear, step-by-step instructions

- Include validation commands

- Provide working examples

- Test all code snippets

- Follow markdown linting standards

- Include troubleshooting sections

---

**Remember**: DevOnboarder's "quiet reliability" philosophy requires following established patterns and policies. Quality gates exist for critical reasons and cannot be bypassed.
