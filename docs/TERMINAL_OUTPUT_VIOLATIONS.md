---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Zero tolerance policy for terminal output violations and enforcement guidelines
document_type: reference
merge_candidate: false
project: DevOnboarder
similarity_group: TERMINAL_OUTPUT_VIOLATIONS.md-docs
status: active
tags:

- reference

- policy

- terminal-output

- enforcement

title: Terminal Output Violations Reference
updated_at: '2025-09-12'
visibility: internal
---

# Terminal Output Policy Violations and Enforcement

## CRITICAL: Zero Tolerance Policy

DevOnboarder enforces **ZERO TOLERANCE** for terminal output violations that cause immediate system hanging. This document provides enforcement guidelines and approved patterns.

## Immediate Hanging Triggers

### FORBIDDEN (Causes Terminal Hanging)

```bash

#  FORBIDDEN - Emojis cause immediate hanging

echo " Task completed"
echo " Processing"
echo " Results ready"

#  FORBIDDEN - Command substitution in echo

echo "Files found: $(find . -name '*.py' | wc -l)"
echo "Size: $(du -h file.txt)"

#  FORBIDDEN - Multi-line echo variables

COMMENT="Line 1
Line 2
Line 3"
echo "$COMMENT"

#  FORBIDDEN - Variable expansion in echo

echo "Processing $FILE_NAME"
echo "Status: $BUILD_STATUS"

#  FORBIDDEN - Escape sequences

echo -e "Line1\nLine2\nLine3"
echo "Tab\there"

```

### APPROVED (Safe for DevOnboarder)

```bash

#  APPROVED - Individual echo with plain ASCII

echo "Task completed successfully"
echo "Processing file"
echo "Results ready for review"

#  APPROVED - File-based output for complex content

cat > output.txt << 'EOF'
Line 1
Line 2
Line 3
EOF

#  APPROVED - Separate commands

echo "Files found:"
find . -name '*.py' | wc -l
echo "Processing complete"

#  APPROVED - Plain text only

echo "Operation finished"
echo "Check logs for details"
echo "Next step: review results"

```

## Centralized Color Utilities

DevOnboarder provides standardized color functions to replace raw ANSI escape sequences:

### Usage Pattern

```bash
# Source the centralized utilities
source scripts/color_utils.sh

# Use semantic color functions
red "Error message"           # For errors and failures
green "Success message"       # For success and completion
yellow "Warning message"      # For warnings and cautions
blue "Info message"           # For general information
cyan "Debug message"          # For debug output (if DEBUG=1)
purple "Special message"      # For special cases
bold "Section header"         # For emphasis and headers

# High-level semantic functions
error "Something went wrong"      # Formatted with  prefix
success "Operation completed"     # Formatted with  prefix
warn "Potential issue detected"   # Formatted with  prefix
info "Processing step 1"          # Formatted with  prefix
section "Main Configuration"      # Formatted section header
```

### Migration from Raw ANSI

```bash
#  FORBIDDEN - Raw ANSI variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${RED}Error occurred${NC}"

#  APPROVED - Centralized color functions
source scripts/color_utils.sh
error "Error occurred"
```

### Benefits

- **Consistency**: Standardized colors across all scripts
- **Maintenance**: Single point of control for color definitions
- **Compliance**: Built-in terminal output policy adherence
- **Semantics**: Clear meaning through function names

## Enforcement Mechanisms

### 1. Pre-commit Validation

```bash

# Automatically runs before every commit

bash scripts/validate_terminal_output.sh

```

### 2. CI Pipeline Enforcement

All workflows include validation step that blocks deployment on violations.

### 3. Automated Code Review

Bot automatically rejects PRs containing forbidden patterns.

## Violation Consequences

### First Violation

- **Immediate**: Commit blocked

- **Required**: Fix all violations

- **Process**: Re-read this documentation

### Second Violation

- **Immediate**: All workflow changes require human review

- **Required**: Acknowledge understanding of policy

- **Process**: Mandatory re-training on safe patterns

### Third Violation

- **Immediate**: Restricted from workflow modifications

- **Required**: Project lead approval for any changes

- **Process**: Comprehensive review of all previous work

## Safe Migration Patterns

### Converting Emojis

```bash

# Before: echo " Success"

# After:  echo "Success"

# Before: echo " Building"

# After:  echo "Building application"

# Before: echo " Warning"

# After:  echo "Warning: Check configuration"

```

### Converting Command Substitution

```bash

# Before: echo "Found $(ls | wc -l) files"

# After

echo "Counting files..."
ls | wc -l
echo "Count complete"

```

### Converting Multi-line Variables

```bash

# Before

MESSAGE="Line 1
Line 2
Line 3"
echo "$MESSAGE"

# After

cat > message.txt << 'EOF'
Line 1
Line 2
Line 3
EOF

```

## GitHub Actions Specific

### Safe Comment Patterns

```yaml

#  APPROVED

- name: Comment on PR

  run: |
    cat > comment.md << 'EOF'
    **Status Update**

    Build completed successfully.

    Check artifacts for results.
    EOF
    gh pr comment $PR_NUMBER --body-file comment.md

#  FORBIDDEN

- name: Comment on PR

  run: |
    gh pr comment $PR_NUMBER --body " Build complete! Found $(ls | wc -l) files"

```

### Safe Summary Patterns

```yaml

#  APPROVED

- name: Create summary

  run: |
    echo "Build Summary" >> $GITHUB_STEP_SUMMARY
    echo "Status: Complete" >> $GITHUB_STEP_SUMMARY
    echo "Next: Review artifacts" >> $GITHUB_STEP_SUMMARY

#  FORBIDDEN

- name: Create summary

  run: |
    echo " Build Summary: $(date)" >> $GITHUB_STEP_SUMMARY
    echo " Files: $(find . -name '*.py' | wc -l)" >> $GITHUB_STEP_SUMMARY

```

## Emergency Recovery

If terminal hanging occurs:

1. **Immediate**: Kill hanging process with CtrlC

2. **Identify**: Check recent changes for forbidden patterns

3. **Fix**: Replace with approved patterns from this document

4. **Validate**: Run `bash scripts/validate_terminal_output.sh`

5. **Test**: Verify no hanging in clean environment

## Policy Acknowledgment Required

Before any workflow modifications, acknowledge:

> "I understand DevOnboarder has ZERO TOLERANCE for emojis, command substitution,
> and multi-line variables in terminal output. These cause immediate hanging.
> I will use ONLY individual echo commands with plain ASCII text."

## Training Validation

Test your understanding:

```bash

# Which is safe?

# A: echo " Done"

# B: echo "Done"

# Answer: B

# Which is safe?

# A: echo "Files: $(ls | wc -l)"

# B: echo "Counting files" && ls | wc -l

# Answer: B

# Which is safe?

# A: echo "$MULTI_LINE_VAR"

# B: cat > file.txt << 'EOF' && cat file.txt

# Answer: B

```

All workflow modifications must pass these basic safety checks.

## Escalation Process

Persistent violations escalate through:

1. **Technical**: Automated blocking and validation

2. **Process**: Human review requirements

3. **Governance**: Project lead intervention

4. **Final**: Workflow modification restrictions

**Remember**: This policy exists because violations cause real, immediate system failures in the DevOnboarder environment. It is not negotiable.
