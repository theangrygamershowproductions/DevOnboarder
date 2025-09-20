---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: scripts-scripts
status: active
tags:

- documentation

title: Git Utilities
updated_at: '2025-09-12'
visibility: internal
---

# Git Utilities Documentation

## Overview

DevOnboarder includes several git utility scripts to streamline common git operations, handle sync conflicts, and manage repository state safely.

## Available Git Utilities

### 1. `scripts/commit_changes.sh`

**Purpose**: Interactive commit utility for handling staged and unstaged changes with intelligent commit message suggestions.

**Features**:

- Checks git repository status

- Shows staged and unstaged changes

- Prompts to stage unstaged changes

- Analyzes changed files and generates multiple smart commit message suggestions

- Interactive selection from suggested messages or custom input

- Provides commit confirmation and status display

**Usage**:

```bash

# Run interactively

./scripts/commit_changes.sh

# The script will

# 1. Show you what files are staged/unstaged

# 2. Analyze file types and content

# 3. Generate 3-5 intelligent commit message suggestions

# 4. Let you select from suggestions or enter custom message

# 5. Commit changes and show final status

```

**Smart Message Generation Examples**:

- Git utilities: `"FEAT(scripts): add git workflow utilities for safer sync operations"`

- Documentation: `"DOCS: add comprehensive git utilities documentation"`

- Branch cleanup: `"FEAT(scripts): add comprehensive branch cleanup utilities"`

- Config changes: `"CONFIG: update configuration files"`

### 2. `scripts/commit_message_guide.sh`

**Purpose**: Educational tool to learn and practice DevOnboarder commit message conventions.

**Features**:

- Comprehensive examples for all commit types (FEAT, FIX, DOCS, CHORE, etc.)

- Interactive commit message builder with step-by-step guidance

- Current changes analysis with type suggestions

- Scope guidelines and usage examples

- Format validation and best practices

**Usage**:

```bash

# Learn commit message patterns

./scripts/commit_message_guide.sh

# Features include

# 1. View examples for each commit type

# 2. Learn scope guidelines (auth, bot, scripts, etc.)

# 3. Interactive message builder

# 4. Analyze your current staged changes

# 5. Get specific suggestions for your files

```

### 3. `scripts/sync_with_remote.sh`

**Purpose**: Comprehensive git synchronization utility to handle pull/push conflicts safely with detailed status checking.

**Features**:

- Fetches latest remote changes

- Detects if local branch is behind/ahead of remote

- Handles uncommitted changes validation

- Automatic pull with conflict detection

- Safe push with error handling

- Colorized output for clear status indication

**Usage**:

```bash

# Run full sync check and resolution

./scripts/sync_with_remote.sh

# The script automatically

# 1. Fetches from origin

# 2. Checks if behind remote (pulls if needed)

# 3. Checks if ahead of remote (pushes if needed)

# 4. Reports final sync status

```

**Safety Features**:

- ✅ Validates git repository

- ✅ Checks for uncommitted changes before pulling

- ✅ Handles merge conflicts gracefully

- ✅ Provides clear error messages and recovery instructions

### 3. `scripts/simple_sync.sh`

**Purpose**: Minimal git sync script for quick pull and push operations.

**Features**:

- Simple pull from `origin main`

- Status check after pull

- Push to `origin main`

- Basic operation logging

**Usage**:

```bash

# Quick sync with main branch

./scripts/simple_sync.sh

# Equivalent to

# git pull origin main

# git push origin main

```

**When to Use**: Fast sync when you're confident there are no conflicts and just need a quick update/push cycle.

### 4. `scripts/quick_branch_cleanup.sh`

**Purpose**: Safe cleanup of obviously stale local and remote branches with automated commit handling.

**Features**:

- Switches to main branch safely

- Fetches latest changes and prunes deleted remote branches

- Identifies and removes merged local branches interactively

- Cleans up known stale remote branches (Codex/automated branches)

- Commits cleanup changes with proper pre-commit hook handling

- Comprehensive log review prompts for hook failures

**Usage**:

```bash

# Run comprehensive branch cleanup

./scripts/quick_branch_cleanup.sh

# The script will

# 1. Switch to main branch if not already there

# 2. Fetch and prune remote tracking branches

# 3. Show current branch status

# 4. Interactively delete merged local branches

# 5. Clean up stale remote branches

# 6. Commit any changes from cleanup

# 7. Handle pre-commit hook failures with log review

```

**Safety Features**:

- ✅ Validates repository and branch state

- ✅ Interactive confirmation for all deletions

- ✅ Protects important branches (main, active features)

- ✅ Handles pre-commit hook failures gracefully

- ✅ Provides recovery instructions for commit issues

### 5. `scripts/git_commit_utils.sh`

**Purpose**: Reusable utility functions for robust git commit handling across all DevOnboarder scripts.

**Functions**:

- `commit_with_log_review()`: Enhanced commit with comprehensive pre-commit failure handling

- `stage_changes_with_confirmation()`: Interactive staging with file preview

- `check_for_changes()`: Smart detection of staged/unstaged changes

- `show_commit_preparation()`: Summary of files and changes before commit

**Usage**:

```bash

# Source in other scripts

source scripts/git_commit_utils.sh

# Use enhanced commit function

commit_with_log_review "FEAT(scripts): add new automation utility"

# Stage changes interactively

stage_changes_with_confirmation "automation script updates"

```

## Comparison Matrix

| Feature | commit_changes.sh | commit_message_guide.sh | sync_with_remote.sh | simple_sync.sh | quick_branch_cleanup.sh |
|---------|-------------------|-------------------------|---------------------|----------------|-------------------------|
| **Interactive** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes |

| **Educational** | ❌ No | ✅ Yes | ❌ No | ❌ No | ❌ No |

| **Message Suggestions** | ✅ Multiple smart options | ✅ Examples + builder | ❌ No | ❌ No | ✅ Automated for cleanup |

| **File Analysis** | ✅ Yes | ✅ Yes | ❌ No | ❌ No | ✅ Branch analysis |

| **Conflict Handling** | ❌ No | ❌ No | ✅ Yes | ❌ No | ✅ Branch conflicts |

| **Safety Checks** | ✅ Moderate | ❌ No | ✅ Comprehensive | ❌ Minimal | ✅ Comprehensive |

| **Branch Awareness** | ✅ Current branch | ❌ No | ✅ Current branch | ❌ main only | ✅ All branches |

| **Pre-commit Log Review** | ✅ Yes | ❌ No | ❌ No | ❌ No | ✅ Yes |

| **Use Case** | Committing changes | Learning conventions | Sync conflicts | Quick sync | Branch maintenance |

## Common Workflows

### Daily Development Workflow

```bash

# 1. Commit your work with enhanced error handling

./scripts/commit_changes.sh

# 2. Sync with remote safely

./scripts/sync_with_remote.sh

```

### Branch Maintenance Workflow

```bash

# Comprehensive branch cleanup with commit handling

./scripts/quick_branch_cleanup.sh

# This handles

# - Removing merged local branches

# - Cleaning stale remote branches

# - Committing cleanup changes

# - Pre-commit hook failure recovery

```

### Pre-commit Hook Failure Workflow

```bash

# When any commit fails due to pre-commit hooks

# 1. Read the detailed error output provided by enhanced utilities

# 2. Fix the specific violations (markdown, shellcheck, formatting)

# 3. Stage fixes: git add .

# 4. Retry: git commit -m "original message"

# 5. Or use enhanced tools for guidance

```

### Quick Update Workflow

```bash

# For simple, conflict-free updates

./scripts/simple_sync.sh

```

### Conflict Resolution Workflow

```bash

# When you encounter push conflicts

./scripts/sync_with_remote.sh

# If conflicts occur, the script will guide you to

# 1. Resolve conflicts manually

# 2. Stage resolved files: git add <file>

# 3. Complete merge: git commit

# 4. Re-run sync script

```

## Pre-commit Hook Integration and Log Review

**CRITICAL**: All DevOnboarder git utilities now include comprehensive pre-commit hook failure handling and log review prompts. This is essential because pre-commit hooks often flag markdown, bash script, or code formatting violations that must be fixed before commits can succeed.

### Enhanced Commit Process

Every commit operation in DevOnboarder utilities now follows this pattern:

1. **Attempt Commit**: Try the initial commit with git hooks

2. **Hook Failure Detection**: Detect if pre-commit hooks failed

3. **Comprehensive Log Review**: Provide detailed guidance on fixing issues

4. **Recovery Options**: Offer multiple paths to resolve and retry

### Common Pre-commit Issues

**Markdown Violations** (most common):

- `MD022`: Headings must have blank lines before and after

- `MD032`: Lists must have blank lines before and after

- `MD031`: Fenced code blocks need blank lines around them

- `MD007`: Proper list indentation (4 spaces for nested items)

- `MD009`: No trailing spaces (except 2 for line breaks)

**Bash Script Issues**:

- Shellcheck warnings (quoting, variable usage, etc.)

- Script formatting and best practices violations

- Missing executable permissions

**Code Formatting**:

- Python: black formatting, ruff linting violations

- TypeScript/JavaScript: ESLint rule violations

- File formatting (trailing spaces, line endings)

### Recovery Workflow

When a commit fails due to pre-commit hooks:

1. **Read the error output carefully** - it shows exactly what to fix

2. **Fix all reported violations** in the affected files

3. **Stage fixes**: `git add .`

4. **Retry commit**: `git commit -m "original message"`

5. **Or amend**: `git commit --amend --no-edit`

### Alternative Recovery Options

- **Reset commit attempt**: `git reset --soft HEAD~1`

- **Check status**: `git status`

- **Use enhanced tools**: `./scripts/commit_changes.sh`

- **Learn patterns**: `./scripts/commit_message_guide.sh`

These utilities integrate with the DevOnboarder development workflow:

### Pre-commit Integration

```bash

# Use commit_changes.sh before pre-commit hooks

./scripts/commit_changes.sh

# Pre-commit hooks run automatically on commit

```

### CI/CD Integration

```bash

# In CI workflows, sync utilities help with

# - Branch synchronization

# - Automated commits of generated files

# - Conflict resolution in automation

```

### Branch Cleanup Integration

```bash

# Works with existing branch cleanup utilities

./scripts/cleanup_branches.sh      # Clean stale branches

./scripts/sync_with_remote.sh      # Sync main branch

```

## Error Handling

All scripts include comprehensive error handling:

### Common Error Scenarios

1. **Not in git repository**:

   ```text
   ❌ Not in a git repository
   ```

1. **Uncommitted changes during sync**:

   ```text
   ❌ You have uncommitted changes. Please commit or stash them first.
   ```

1. **Merge conflicts**:

   ```text
   ❌ Pull failed - there may be conflicts

   Please resolve conflicts manually and try again.
   ```

1. **Push failures**:

   ```text
   ❌ Push failed
   ```

### Recovery Actions

- **Uncommitted changes**: Run `commit_changes.sh` first

- **Merge conflicts**: Edit conflicted files, then `git add <file>` and `git commit`

- **Push failures**: Check network, permissions, or run `sync_with_remote.sh`

## Best Practices

### When to Use Each Script

1. **`commit_changes.sh`**:

- You have unstaged changes to commit

- You want intelligent commit message generation

- You need interactive confirmation

1. **`sync_with_remote.sh`**:

- You encountered push rejections

- You need comprehensive conflict handling

- You want detailed sync status information

1. **`simple_sync.sh`**:

- Quick updates with no expected conflicts

- Automated scripts that need basic sync

- When speed is more important than safety checks

### Development Workflow Best Practices

```bash

# ✅ RECOMMENDED: Comprehensive workflow

./scripts/commit_changes.sh       # Commit your changes

./scripts/sync_with_remote.sh     # Safe sync with conflict handling

# ✅ ACCEPTABLE: Quick workflow (low-risk scenarios)

./scripts/simple_sync.sh          # Quick sync when confident

# ❌ AVOID: Manual commands without safety checks

git pull origin main && git push origin main

```

## Troubleshooting

### Script Won't Execute

```bash

# Make sure scripts are executable

chmod +x scripts/*.sh

```

### Pre-commit Hook Failures

**Most Common Issue**: This is the primary reason commits fail in DevOnboarder.

```bash

# When you see pre-commit hook failures

# 1. READ the error output carefully - it tells you exactly what to fix

# 2. Common fixes

# Markdown issues (most frequent)

markdownlint-cli2 --fix "**/*.md"  # Auto-fix some markdown issues

# Bash script issues

shellcheck scripts/*.sh            # Check all scripts

shellcheck -f diff scripts/file.sh  # Show specific fixes needed

# Python formatting

source .venv/bin/activate
python -m black .                  # Auto-format Python files

python -m ruff check --fix .       # Fix ruff linting issues

# After fixing

git add .
git commit -m "original message"   # Retry with same message

```

### Markdown Formatting Quick Fixes

```bash

### Markdown Formatting Quick Fixes

**Common markdown violations and how to fix them:**

**MD022 - Add blank lines around headings:**

```text

Before:

## Section Title

Content here.

## Next Section

After:

## Section Title

Content here.

## Next Section

```

**MD032 - Add blank lines around lists:**

```text

Before:
Paragraph text.

- List item 1

- List item 2

Next paragraph.

After:
Paragraph text.

- List item 1

- List item 2

Next paragraph.

```

**MD031 - Add blank lines around code blocks:**

```text

Before:
Some text.

```

```bash
code here

```

```text
More text.

After:
Some text.

```

```bash
code here

```

```text
More text.

```

### Terminal Output Issues

```bash

# If terminal commands don't show output, scripts include logging

# Check recent commits for execution confirmation

git log --oneline -3

```

### Permission Issues

```bash

# Ensure git credentials are configured

git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

```

## Contributing

When modifying these git utilities:

1. **Maintain safety checks**: Never remove validation logic

2. **Preserve error handling**: Ensure graceful failure modes

3. **Update documentation**: Keep this guide current

4. **Test thoroughly**: Verify in multiple git states

5. **Follow DevOnboarder standards**: Use consistent formatting and logging

## Related Documentation

- [Branch Cleanup Documentation](../BRANCH_CLEANUP_ANALYSIS.md)

- [DevOnboarder Workflow Guide](../../CONTRIBUTING.md)

- [CI/CD Integration](../../.github/workflows/)

- [Pre-commit Hooks](../../.pre-commit-config.yaml)
