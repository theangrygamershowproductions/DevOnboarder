---
codex-agent: documentation-quality
role: Ensures markdown documentation meets formatting standards
triggers: 
  - Pull request creation/update
  - Documentation file changes
  - Manual quality checks
outputs:
  - Linting reports
  - Auto-fixed markdown files
  - Quality gate status
dependencies:
  - Vale CLI
  - markdownlint
  - scripts/check_docs.sh
---

# Documentation Quality Agent

## Purpose

The Documentation Quality Agent automatically validates and fixes markdown formatting issues to maintain consistent documentation standards across the DevOnboarder project.

## Responsibilities

### 1. **Automated Linting**
- Runs Vale and markdownlint on all markdown files
- Validates formatting compliance (MD022, MD032, MD007, etc.)
- Generates detailed linting reports

### 2. **Auto-Correction**
- Fixes common markdown formatting issues automatically
- Adds missing blank lines around headings and lists
- Corrects list indentation and spacing
- Ensures proper code block formatting

### 3. **Quality Gates**
- Blocks PRs with documentation quality issues
- Provides clear feedback on formatting problems
- Suggests specific fixes for each violation

### 4. **Report Generation**
- Creates standardized documentation quality reports
- Tracks formatting compliance metrics
- Generates summary reports for project health

## Triggers

### Automatic Triggers
- **Pull Request Events**: Validates documentation changes
- **Push to Main**: Ensures main branch documentation quality
- **File Changes**: Triggered by modifications to `.md` files

### Manual Triggers
```bash
# Run documentation quality check
./scripts/check_docs.sh

# Auto-fix markdown formatting issues
./scripts/fix_markdown_formatting.sh

# Generate quality report
./scripts/generate_doc_quality_report.sh
```

## Configuration

### Vale Configuration
- Uses `.vale.ini` for style rules
- Follows Microsoft Writing Style Guide
- Custom rules for DevOnboarder terminology

### Markdownlint Rules
- Enforces MD022 (blank lines around headings)
- Enforces MD032 (blank lines around lists)
- Enforces MD007 (proper list indentation)
- Enforces MD026 (no trailing punctuation in headings)

### Integration Points

#### CI/CD Pipeline
```yaml
# .github/workflows/ci.yml
- name: Documentation Quality Check
  run: |
    ./scripts/check_docs.sh
    ./scripts/validate_markdown_formatting.sh
```

#### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: markdown-lint
      name: Markdown formatting check
      entry: ./scripts/check_docs.sh
      language: script
```

## Scripts and Tools

### Primary Scripts
- `scripts/check_docs.sh` - Main documentation linting
- `scripts/fix_markdown_formatting.sh` - Auto-fixes formatting
- `scripts/validate_markdown_formatting.sh` - Validation only
- `scripts/generate_doc_quality_report.sh` - Quality reporting

### Dependencies
- Vale CLI (3.12.0+) for prose linting
- markdownlint for structural validation
- Python for custom formatting fixes

## Quality Standards

### Required Formatting
1. **Headings**: Surrounded by blank lines (MD022)
2. **Lists**: Surrounded by blank lines (MD032)
3. **Indentation**: 4-space for nested lists (MD007)
4. **Code Blocks**: Surrounded by blank lines (MD031)
5. **Punctuation**: No trailing punctuation in headings (MD026)

### Automated Fixes
- Adds missing blank lines automatically
- Corrects list indentation
- Fixes trailing whitespace
- Ensures consistent spacing

### Quality Metrics
- Documentation compliance percentage
- Number of formatting violations
- Auto-fix success rate
- Manual intervention requirements

## Integration with Codex

### Notification Integration
Sends quality reports through centralized notification system:

```bash
gh workflow run notify.yml -f data='{
  "type": "documentation-quality-report",
  "title": "Documentation Quality Report",
  "summary": "Generated quality metrics and compliance status",
  "details": "Full linting results and recommendations"
}'
```

### Agent Coordination
- Triggers after CI completion
- Coordinates with other quality agents
- Provides input to PR merge decisions

## Error Handling

### Common Issues
1. **Vale not found**: Downloads Vale automatically
2. **Formatting violations**: Provides specific fix suggestions
3. **Large file processing**: Handles timeout and memory limits
4. **Network issues**: Graceful degradation when tools unavailable

### Fallback Modes
- Basic linting when advanced tools unavailable
- Manual override for urgent documentation updates
- Batch processing for large documentation updates

## Monitoring and Metrics

### Tracked Metrics
- Documentation quality score (0-100)
- Violation counts by type
- Auto-fix success rate
- Processing time per file

### Reporting
- Weekly quality summary reports
- PR-specific linting feedback
- Trend analysis for documentation health

This agent ensures that all documentation maintains high quality standards and consistent formatting, preventing the accumulation of formatting debt and improving overall project documentation quality.
