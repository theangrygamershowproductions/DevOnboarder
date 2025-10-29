---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Comprehensive automation tools for maintaining code quality and fixing common issues automatically, including markdown formatter, shell script fixer, and comprehensive auto-fixer orchestration"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: documentation-documentation
status: active
tags: 
title: "DevOnboarder Auto-Fixer Tools"

updated_at: 2025-10-27
visibility: internal
---

# DevOnboarder Auto-Fixer Tools

Comprehensive automation tools for maintaining code quality and fixing common issues automatically.

## Overview

DevOnboarder includes several Python-based auto-fixer tools that integrate with the QC system to automatically resolve common formatting and compliance issues:

- **Markdown Auto-Formatter**: Fixes markdownlint violations

- **Shell Script Auto-Fixer**: Resolves shellcheck issues

- **Comprehensive Auto-Fixer**: Orchestrates all fixers together

## Tools

### 1. Markdown Auto-Formatter

**File**: `scripts/fix_markdown_formatting.py`

**Purpose**: Automatically fixes common markdownlint violations in markdown files.

**Features**:

- MD022: Ensures blank lines around headings

- MD032: Ensures blank lines around lists

- MD031: Ensures blank lines around fenced code blocks

- MD026: Removes trailing punctuation from headings

- MD009: Removes trailing spaces

- Processes single files, directories, or entire repository

- Creates backups before modification

- Centralized logging to `logs/markdown_formatter.log`

**Usage**:

```bash

# Fix specific files

python scripts/fix_markdown_formatting.py docs/README.md CHANGELOG.md

# Fix all markdown in a directory

python scripts/fix_markdown_formatting.py docs/

# Fix all markdown files in repository

python scripts/fix_markdown_formatting.py --all

# Dry run to see what would be changed

python scripts/fix_markdown_formatting.py --all --dry-run

# Don't create backup files

python scripts/fix_markdown_formatting.py docs/ --no-backup

```

### 2. Shell Script Auto-Fixer

**File**: `scripts/fix_shell_scripts.py`

**Purpose**: Automatically fixes common shellcheck violations in shell scripts.

**Features**:

- SC2086: Adds proper variable quoting

- SC2126: Replaces `grep | wc -l` with `grep -c`

- SC2129: Groups redirect operations for efficiency

- SC2034: Adds comments for potentially unused variables

- Processes shell scripts (.sh, .bash files)

- Creates backups before modification

- Centralized logging to `logs/shell_script_fixer.log`

**Usage**:

```bash

# Fix specific scripts

python scripts/fix_shell_scripts.py scripts/backup.sh scripts/deploy.sh

# Fix all scripts in a directory

python scripts/fix_shell_scripts.py scripts/

# Fix all shell scripts in repository

python scripts/fix_shell_scripts.py --all

# Dry run to see what would be changed

python scripts/fix_shell_scripts.py --all --dry-run

```

### 3. Comprehensive Auto-Fixer

**File**: `scripts/comprehensive_auto_fixer.py`

**Purpose**: Orchestrates all auto-fixers and integrates with DevOnboarder's QC system.

**Features**:

- Runs markdown formatter

- Runs shell script fixer

- Integrates with Python formatters (black, ruff)

- Runs pre-commit auto-fixes

- Comprehensive reporting

- Centralized logging to `logs/comprehensive_auto_fixer.log`

**Usage**:

```bash

# Fix all file types across entire repository

python scripts/comprehensive_auto_fixer.py --all

# Fix only markdown files

python scripts/comprehensive_auto_fixer.py --markdown docs/

# Fix only shell scripts

python scripts/comprehensive_auto_fixer.py --shell scripts/

# Run Python formatters only

python scripts/comprehensive_auto_fixer.py --python

# Run pre-commit fixes only

python scripts/comprehensive_auto_fixer.py --pre-commit

# Combine multiple fixers

python scripts/comprehensive_auto_fixer.py --markdown docs/ --shell scripts/ --python

# Dry run to see what would be changed

python scripts/comprehensive_auto_fixer.py --all --dry-run

```

## Integration with QC System

### Pre-Commit Integration

Add to your pre-commit workflow:

```bash

# Run auto-fixes before pre-commit validation

python scripts/comprehensive_auto_fixer.py --all

# Run standard pre-commit checks

./scripts/qc_pre_push.sh

```

### CI Integration

Add to GitHub Actions workflows:

```yaml

- name: Run Auto-Fixers

  run: |
    source .venv/bin/activate
    python scripts/comprehensive_auto_fixer.py --all

- name: Commit Auto-Fixes

  run: |
    git add .
    git diff --staged --quiet || git commit -m "AUTO: Apply code quality fixes"

```

### Make Target Integration

Add to `Makefile`:

```makefile
autofix:
    @echo "Running DevOnboarder auto-fixers..."
    source .venv/bin/activate && python scripts/comprehensive_auto_fixer.py --all

autofix-markdown:
    @echo "Fixing markdown files..."
    source .venv/bin/activate && python scripts/fix_markdown_formatting.py --all

autofix-shell:
    @echo "Fixing shell scripts..."
    source .venv/bin/activate && python scripts/fix_shell_scripts.py --all

```

## Configuration

### Centralized Logging

All auto-fixer tools log to the centralized `logs/` directory:

- `logs/markdown_formatter.log`

- `logs/shell_script_fixer.log`

- `logs/comprehensive_auto_fixer.log`

### Backup Management

By default, tools create `.bak` backup files before making changes. Use `--no-backup` to disable.

### Excluded Directories

Auto-fixers skip these directories by default:

- `node_modules/`

- `.venv/`, `venv/`

- `.git/`

- `logs/`

- `archive/`

## Error Handling

### Graceful Degradation

Tools continue processing other files even if individual files fail.

### Timeout Protection

Subprocess operations have 5-minute timeouts to prevent hanging.

### Safe Modifications

- Original content is preserved via backups

- Changes are only made if content actually differs

- Comprehensive logging tracks all modifications

## Best Practices

### Development Workflow

1. **Before committing**:

   ```bash
   python scripts/comprehensive_auto_fixer.py --all
   ./scripts/qc_pre_push.sh
   ```

2. **For specific file types**:

   ```bash
   # After editing markdown files

   python scripts/fix_markdown_formatting.py docs/

   # After editing shell scripts

   python scripts/fix_shell_scripts.py scripts/
   ```

3. **Integration with safe_commit.sh**:

   ```bash
   # Auto-fix then commit safely

   python scripts/comprehensive_auto_fixer.py --all
   ./scripts/safe_commit.sh "FEAT(docs): update documentation"
   ```

### Quality Assurance

- Always run `--dry-run` first on important files

- Review logs in `logs/` directory for detailed change reports

- Keep backups enabled for critical modifications

- Use comprehensive auto-fixer for complete coverage

## Maintenance

### Adding New Fixers

1. Create new Python script in `scripts/`

2. Follow existing pattern with:

   - Centralized logging

   - Backup creation

   - Command-line argument parsing

   - Error handling

3. Integrate with `comprehensive_auto_fixer.py`

### Updating Fix Rules

Modify the content-fixing functions in individual scripts:

- `fix_markdown_content()` in `fix_markdown_formatting.py`

- `fix_shell_script_content()` in `fix_shell_scripts.py`

## DevOnboarder Integration

These tools are part of DevOnboarder's "quiet reliability" philosophy:

- **Automated**: Reduce manual formatting work

- **Consistent**: Apply uniform standards across repository

- **Integrated**: Work seamlessly with existing QC system

- **Logged**: Comprehensive audit trail of all changes

- **Safe**: Backup and validation built-in

The auto-fixer tools complement DevOnboarder's existing quality control infrastructure while reducing the manual burden of maintaining code quality standards.
