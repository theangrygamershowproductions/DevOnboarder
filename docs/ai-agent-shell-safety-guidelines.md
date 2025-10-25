---
similarity_group: ai-agent-shell-safety-guidelines.md-docs

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# AI Agent Shell Safety Guidelines - Post-Incident Enhancement

##  Overview

Enhanced guidelines created in response to Shell Interpretation Incident (September 19, 2025) to prevent terminal command safety violations.

## 🚨 Critical Shell Safety Rules

### Rule 1: NEVER Use Complex Content in Inline Commands

```bash

#  DANGEROUS - Will cause shell interpretation errors

gh pr create --body "Content with *wildcards* and `special chars`"

gh issue create --body "Multi-line content with $variables"
echo "Text with emojis  and *patterns*"

```

```bash

#  SAFE - Use file-based approaches

gh pr create --body-file template.md
gh issue create --body-file issue_body.md
printf "Text: %s\n" "$variable"

```

### Rule 2: Mandatory DevOnboarder Tool Usage

**ALWAYS prefer DevOnboarder's safe automation scripts:**

```bash

#  SAFE - DevOnboarder tools with built-in safety

./scripts/create_pr.sh --template chore --title "Safe title"
./scripts/safe_commit.sh "Simple commit message"
./scripts/automate_pr_process.sh 1234 analyze

```

### Rule 3: Shell Metacharacter Validation

**Before executing ANY shell command, validate for:**

- `*` (asterisk) - glob patterns

- `[` `]` (brackets) - character classes

- `$` (dollar) - variable expansion

- `` ` `` (backtick) - command substitution

- `|` (pipe) - command chaining

- `>` `<` (redirection) - file operations

##  Pre-Command Checklist

Before executing any shell command, verify:

- [ ] No emojis or Unicode characters in terminal output

- [ ] No glob patterns (`*`, `?`, `[...]`) in command arguments

- [ ] No unquoted variables with special characters

- [ ] No multi-line content in shell variables

- [ ] No command substitution in echo statements

- [ ] Use `--body-file` instead of `--body` for GitHub CLI

- [ ] DevOnboarder safe tools used when available

##  Safe Patterns Library

### GitHub CLI Operations

```bash

# Creating PRs

echo "PR content here" > temp_pr_body.md
gh pr create --title "Simple title" --body-file temp_pr_body.md
rm temp_pr_body.md

# Creating Issues

cat > temp_issue.md << 'EOF'
Issue content without shell interpretation
EOF
gh issue create --title "Issue title" --body-file temp_issue.md
rm temp_issue.md

```

### Terminal Output

```bash

# Safe echo patterns

echo "Simple ASCII text only"
echo "Status: completed"
echo "Files processed: 5"

# Safe variable output

printf "Result: %s\n" "$variable"
printf "Status: %s\n" "$status"

```

### File Operations

```bash

# Safe file creation

cat > filename.md << 'EOF'
Content here without variable expansion
EOF

# Safe content with variables

cat > filename.md << EOF
Content with variables: $var
EOF

```

##  Pattern Recognition Training

### Anti-Patterns to Detect

1. **Complex GitHub CLI Commands**

   - `gh pr create --body "..."` with special characters

   - Multi-line content in command arguments

   - Unescaped quotes in command text

2. **Unsafe Echo Statements**

   - Emojis in echo commands (causes terminal hanging)

   - Variable expansion in echo (`echo "$var"`)

   - Command substitution in echo (`echo "$(cmd)"`)

3. **Shell Variable Issues**

   - Unquoted variables with metacharacters

   - Complex content in shell variables

   - Variable expansion in unsafe contexts

### Recovery Patterns

When shell interpretation errors occur:

1. **Identify the problematic command**

2. **Create temporary file for complex content**

3. **Use DevOnboarder's safe alternatives**

4. **Document the incident for pattern recognition**

## 📚 DevOnboarder Safe Tools Reference

### PR Management

- `scripts/create_pr.sh` - Safe PR creation with templates

- `scripts/automate_pr_process.sh` - Automated PR workflows

- `scripts/create_fix_pr.sh` - Quick fix PR creation

### Commit Operations

- `scripts/safe_commit.sh` - Safe commit with validation

- `scripts/git_safety_wrapper.sh` - Git operation wrapper

### Validation Tools

- `scripts/validate_shell_safety.sh` - Shell command safety validator ( Tested & Operational)

- `scripts/qc_pre_push.sh` - Comprehensive quality validation

## 🎯 Incident Prevention Strategy

### Pre-Execution Validation

Before any shell command:

1. **Run command through mental safety checklist**

2. **Check for DevOnboarder tool alternatives**

3. **Validate content for shell metacharacters**

4. **Use file-based approach for complex content**

### Post-Incident Learning

When shell errors occur:

1. **Document the specific error pattern**

2. **Add pattern to validation scripts**

3. **Update AI agent training data**

4. **Enhance prevention guidelines**

##  Success Metrics

Track prevention effectiveness:

- Zero shell interpretation incidents

- 100% usage of safe DevOnboarder tools

- No terminal hanging from emoji/Unicode output

- All complex content via file-based methods

---

**Created**: September 19, 2025

**Incident Reference**: shell-interpretation-incident-20250919.md
**Status**: Active Guidelines
**Review Date**: Quarterly

*These guidelines ensure AI agents follow DevOnboarder's "quiet reliability" philosophy while preventing terminal command safety violations.*
