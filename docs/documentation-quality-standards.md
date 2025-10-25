---
similarity_group: documentation-quality-standards.md-docs
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Documentation Quality Standards

## Cross-Reference Validation Patterns

### Template-to-Documentation Links

**Pattern**: Templates should reference actual documentation files

```bash
# Validation check for template references
find templates/ -name "*.md" -exec grep -H '\[documentation links]' {} \; | while read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    link=$(echo "$line" | grep -o 'docs/[^)]*\.md')
    if [[ ! -f "$link" ]]; then
        echo " Broken template reference in $file  $link"
    fi
done
```

### Documentation Cross-References

**Pattern**: Documentation should maintain accurate internal links

```bash
# Enhanced link validation patterns
VALIDATION_PATTERNS=(
    'docs/[^)]*\.md'           # Documentation links
    'scripts/[^)]*\.sh'        # Script references
    'templates/[^)]*\.md'      # Template references
    'frameworks/[^)]*'         # Framework references
)
```

### Quality Gates Integration

**Pre-commit hooks enforce:**

1. **Link Existence**: All referenced files must exist
2. **Path Accuracy**: Relative paths resolved correctly
3. **Cross-Reference Integrity**: Bidirectional link validation
4. **Template Consistency**: Templates reference current documentation

### Standard Validation Commands

```bash
# Enhanced internal link validation with parallelization and metrics
scripts/validate_internal_links.sh  # Validates 513 files in ~60 seconds

# GitHub-style anchor generation (supports duplicate headings)
python3 scripts/anchors_github.py < file.md  # Returns JSON with anchors array

# Enhanced safe commit with validation hardening
scripts/safe_commit_enhanced.sh "message"  # Prevents silent staging drift

# Template-specific validation
scripts/validate_template_references.sh  # Template consistency validation

# Framework documentation validation
scripts/audit_frameworks.sh  # Framework documentation integrity
```

### Common Anti-Patterns

 **Hardcoded paths without validation**

```markdown
[Terminal Policy](TERMINAL_OUTPUT_VIOLATIONS.md)  # File doesn't exist
```

 **Validated references with automated checking**

```markdown
[Terminal Policy](TERMINAL_OUTPUT_VIOLATIONS.md)  # Validated via pre-commit
```

 **Outdated cross-references**

```markdown
[Documentation Framework](frameworks/README.md)  # Stale reference
```

 **Maintained cross-references**

```markdown
[Quality Framework](../frameworks/quality-assurance/README.md)  # Current and validated
```

### Automated Validation Workflow

1. **Pre-commit**: `validate_internal_links.sh` catches broken links with parallel processing
2. **CI Integration**: `docs-quality.yml` workflow validates on PR changes
3. **PR Welcome**: `pr-welcome.yml` workflow handles fork contributions securely
4. **Enhanced Commits**: `safe_commit_enhanced.sh` prevents staging drift
5. **Metrics Tracking**: JSON reports with real-time file counts and broken link statistics

---
**Enhanced**: October 2, 2025 (PR #1720)
**Integration**: Pre-commit hooks  CI workflows  enhanced safe commit wrapper
**Performance**: 513 markdown files validated in ~60 seconds with parallelization
**Coverage**: Internal links, fragments, GitHub-style anchors, duplicate headings
