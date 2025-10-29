---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Common markdown linting issues and solutions for DevOnboarder files"

document_type: troubleshooting
merge_candidate: false
project: DevOnboarder
similarity_group: MARKDOWN_LINTING_TROUBLESHOOTING.md-docs
status: active
tags: 
title: "Markdown Linting Troubleshooting"

updated_at: 2025-10-27
visibility: internal
---

# Markdown Linting Troubleshooting Guide

**Date**: 2025-08-03
**Purpose**: Common markdown linting issues and their solutions in DevOnboarder

## Overview

This document provides solutions to recurring markdown linting issues in DevOnboarder. All markdown files are validated using markdownlint-cli2 with strict enforcement via pre-commit hooks and CI workflows.

## Configuration

DevOnboarder uses `.markdownlint.json` for configuration with strict enforcement of:

- **MD022**: Headings must be surrounded by blank lines

- **MD032**: Lists must be surrounded by blank lines

- **MD029**: Ordered list numbering consistency

- **MD031**: Fenced code blocks must be surrounded by blank lines

## Common Issues and Solutions

### 1. MD029 - Ordered List Prefix (RECURRING ISSUE)

**Problem**: When numbered lists are split by headings or other content, markdownlint expects numbering to restart at 1, not continue consecutively.

**Example of Violation**:

```markdown

1. First item

2. Second item

### Section Break

3. Third item ( Expected 1, got 3)

4. Fourth item ( Expected 2, got 4)

```

**Correct Solution**:

```markdown

1. First item

2. Second item

### Section Break

1. Third item (CORRECT: Restarted numbering)

2. Fourth item (CORRECT: Consecutive from restart)

```

**Why This Happens**: Markdownlint treats content between list items (like headings) as list breaks, requiring numbering to restart.

**Fix Command**:

```bash

# Check for MD029 violations

npx markdownlint *.md docs/*.md --config .markdownlint.json | grep "MD029"

# Manual fix required: Renumber all lists to start at 1 after breaks

```

### 2. MD022 - Headings Without Blank Lines

**Problem**: Headings must have blank lines both before and after.

**Example of Violation**:

```markdown
Some text

### Heading ( No blank line before)

More text ( No blank line after heading)

```

**Correct Solution**:

```markdown
Some text

### Heading

More text

```

### 3. MD032 - Lists Without Blank Lines

**Problem**: Lists must be surrounded by blank lines.

**Example of Violation**:

```markdown
Some text

- List item ( No blank line before list)

- Another item

More text ( No blank line after list)

```

**Correct Solution**:

```markdown
Some text

- List item

- Another item

More text

```

### 4. MD031 - Code Blocks Without Blank Lines

**Problem**: Fenced code blocks must be surrounded by blank lines.

**Example of Violation**:

```markdown
Some text

```bash ( No blank line before code block)
echo "hello"

```

More text ( No blank line after code block)

```text

**Correct Solution**:

```markdown
Some text

```bash
echo "hello"

```

More text

```text

## Validation Workflow

### Local Development

```bash

# Check all markdown files

npx markdownlint *.md docs/*.md --config .markdownlint.json

# Check specific file

npx markdownlint SPECIFIC_FILE.md --config .markdownlint.json

# Pre-commit hook automatically runs validation

git commit -m "Your commit message"

```

### CI Enforcement

- Pre-commit hooks block commits with violations

- GitHub Actions workflows validate on every PR

- Automated code review bot rejects PRs with violations

## Quick Fix Patterns

### For MD029 Issues

1. Identify all numbered lists in the document

2. Find any content breaks (headings, paragraphs, code blocks)

3. Restart numbering at 1 after each break

4. Maintain consecutive numbering within each section

### For Spacing Issues (MD022, MD032, MD031)

1. Add blank line before headings/lists/code blocks

2. Add blank line after headings/lists/code blocks

3. Ensure no trailing blank lines at end of file

## Prevention Strategies

### Writing Guidelines

- Always add blank lines around headings, lists, and code blocks

- Restart numbered lists at 1 after any content break

- Use markdownlint extension in VS Code for real-time feedback

- Run local validation before committing

### Template Structure

```markdown

# Main Heading

Introduction paragraph.

## Section Heading

Paragraph before list.

1. First numbered item

2. Second numbered item

### Subsection

1. Restart numbering after heading

2. Continue consecutively

Another paragraph.

- Unordered list item

- Another unordered item

```bash
echo "Code block with proper spacing"

```

Final paragraph.

```text

## Known Recurring Issues

### MD029 in Long Documents

- **Frequency**: High in README.md and documentation files

- **Root Cause**: Lists split by multiple headings and sections

- **Prevention**: Always restart numbering after headings

- **Detection**: Search for "MD029" in markdownlint output

### Mixed List Types

- **Issue**: Switching between numbered and bulleted lists

- **Solution**: Maintain consistent spacing around all list types

- **Validation**: Ensure blank lines before and after every list

## Troubleshooting Commands

```bash

# Full validation suite

bash scripts/run_tests.sh

# Markdown-only validation

npx markdownlint *.md docs/*.md --config .markdownlint.json

# Check specific violation type

npx markdownlint *.md docs/*.md --config .markdownlint.json | grep "MD029"

# Validate specific file

npx markdownlint FILENAME.md --config .markdownlint.json

```

## Integration with DevOnboarder Workflow

### Development Process

1. Write markdown content

2. Run local markdownlint validation

3. Fix any violations before committing

4. Pre-commit hooks provide final validation

5. CI workflows enforce compliance

### Quality Gates

- Pre-commit hooks block non-compliant commits

- GitHub Actions fail PRs with violations

- Code review bot provides automated feedback

- Documentation deployment requires clean validation

---

**Reference**: This guide addresses recurring issues documented in `ENFORCEMENT_DOCUMENTATION_AUDIT.md`

**Validation**: All solutions tested against DevOnboarder's markdownlint configuration
**Updates**: Maintain this guide as new patterns emerge
