---
similarity_group: workflows-workflows

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# Issue Closure Template System Documentation

## Overview

DevOnboarder's Issue Closure Template System provides a robust solution for creating detailed issue closure comments while maintaining strict compliance with the project's terminal output policy.

## Problem Solved

The terminal output policy prevents:

- Multi-line comments in `gh issue close -c`

- Command substitution like `$(date -Iseconds)`

- Complex markdown formatting in terminal commands

- Here-doc syntax for structured content

## Solution: Two-Step Process

### Step 1: Detailed Comment

```bash
gh issue comment <number> --body-file <template-file>

```

### Step 2: Simple Closure

```bash
gh issue close <number> --reason completed

```

This approach completely eliminates complex content from terminal commands.

## Template System Components

### 1. Template Directory Structure

```text
templates/issue-closure/
├── pr-completion.md        # For PR-resolved issues

├── bug-fix.md             # For bug resolutions

├── ci-failure-fix.md      # For CI/build failures

└── feature-completion.md  # For feature implementations

```

### 2. Template Generator Script

**Location**: `scripts/generate_issue_closure_comment.sh`

**Usage**:

```bash
./scripts/generate_issue_closure_comment.sh <template-type> <issue-number> [options]

```

**Example**:

```bash
./scripts/generate_issue_closure_comment.sh pr-completion 1437 \
  --pr-number 1449 \
  --pr-title "Framework governance" \
  --resolver "Sprint 1 Team" \
  --impact "Enables robust issue closure" \
  --next-steps "Deploy to other scripts"

```

### 3. Enhanced CI Issue Wrapper

**Location**: `scripts/ci_gh_issue_wrapper.sh`

**Enhanced `handle_issue_close` Function**: Now supports three modes:

- Template file mode (recommended)

- Simple comment mode (legacy)

- No comment mode

**Usage**:

```bash

# Using template file (recommended)

handle_issue_close 1437 "" "logs/issue-closure-comments/issue-1437-pr-completion-comment.md"

# Legacy simple comment

handle_issue_close 1437 "Simple closure comment"

# No comment

handle_issue_close 1437

```

## Template Types and Use Cases

### PR Completion Template

**Use When**: Issue resolved by merging a pull request

**Key Fields**:

- PR number, title, branch name

- Implementation details

- Verification checklist

- Impact description

- Next steps

### Bug Fix Template

**Use When**: Bug has been identified and resolved

**Key Fields**:

- Root cause analysis

- Fix description

- Testing verification

- Prevention measures

### CI Failure Fix Template

**Use When**: CI/build failure has been diagnosed and resolved

**Key Fields**:

- Failure analysis

- Error details

- Resolution steps

- Prevention measures

### Feature Completion Template

**Use When**: New feature has been implemented

**Key Fields**:

- Feature description

- Implementation approach

- Acceptance criteria status

- Documentation updates

## Workflow Integration

### For Manual Issue Closure

1. **Generate Template**:

   ```bash
   ./scripts/generate_issue_closure_comment.sh pr-completion 1234 \
     --pr-number 5678 --pr-title "Fix authentication" \
     --resolver "Development Team"
   ```

2. **Review Generated Comment**:

   ```bash
   cat logs/issue-closure-comments/issue-1234-pr-completion-comment.md
   ```

3. **Apply and Close**:

   ```bash
   gh issue comment 1234 --body-file logs/issue-closure-comments/issue-1234-pr-completion-comment.md
   gh issue close 1234 --reason completed
   ```

### For Automated Scripts

Use the enhanced `ci_gh_issue_wrapper.sh`:

```bash

# Generate template first

./scripts/generate_issue_closure_comment.sh pr-completion "$ISSUE_NUMBER" \
  --pr-number "$PR_NUMBER" --pr-title "$PR_TITLE"

# Use wrapper with template file

source scripts/ci_gh_issue_wrapper.sh
handle_issue_close "$ISSUE_NUMBER" "" "logs/issue-closure-comments/issue-${ISSUE_NUMBER}-pr-completion-comment.md"

```

## Template Customization

### Adding New Template Types

1. **Create Template File**:

   ```bash
   cp templates/issue-closure/pr-completion.md templates/issue-closure/new-type.md
   ```

2. **Customize Placeholders**: Use `{PLACEHOLDER_NAME}` format

3. **Update Generator Script**: Add new placeholders to the Python replacement logic

4. **Test Template**:

   ```bash
   ./scripts/generate_issue_closure_comment.sh new-type 9999 --placeholder-value "test"
   ```

### Available Placeholders

- `{PR_NUMBER}`, `{PR_TITLE}`, `{BRANCH_NAME}`

- `{MERGE_DATE}`, `{COMMIT_COUNT}`

- `{CLOSURE_DATE}`, `{RESOLVER}`

- `{IMPACT_DESCRIPTION}`, `{NEXT_STEPS}`

- `{ROOT_CAUSE}`, `{FIX_DESCRIPTION}`

- `{FEATURE_NAME}`, `{IMPLEMENTATION_APPROACH}`

- And many more (see script for full list)

## Success Metrics

- **Zero terminal hanging**: No terminal output policy violations

- **Standardized documentation**: Consistent closure comment format

- **Improved workflow**: Cleaner separation of documentation and action

- **Team efficiency**: Reduced manual effort in issue management

## Migration from Legacy System

### Before (Problematic)

```bash

# This causes terminal hanging with complex content

gh issue close 1234 --comment "$(cat complex_comment.md)"

```

### After (Compliant)

```bash

# Two-step process - no terminal hanging

gh issue comment 1234 --body-file complex_comment.md
gh issue close 1234 --reason completed

```

---

**Implementation Date**: September 17, 2025

**Sprint**: Sprint 1 - Foundation Fixes

**Status**: ✅ Complete
**Next Steps**: Deploy to all automation scripts, train team on workflow
