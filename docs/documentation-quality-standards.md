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
find templates/ -name "*.md" -exec grep -H '\[.*\](docs/.*\.md)' {} \; | while read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    link=$(echo "$line" | grep -o 'docs/[^)]*\.md')
    if [[ ! -f "$link" ]]; then
        echo "ERROR: Broken template reference in $file -> $link"
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
# Full documentation quality check
scripts/validate_internal_links.sh

# Template-specific validation
scripts/validate_template_references.sh  # New script for template validation

# Framework documentation validation
scripts/audit_frameworks.sh  # Existing script enhanced with link checking
```

### Common Anti-Patterns

❌ **Hardcoded paths without validation**

```markdown
[Terminal Policy](docs/TERMINAL_OUTPUT_POLICY.md)  # File doesn't exist
```

✅ **Validated references with automated checking**

```markdown
[Terminal Policy](docs/TERMINAL_OUTPUT_VIOLATIONS.md)  # Validated via pre-commit
```

❌ **Outdated cross-references**

```markdown
[Old Framework](frameworks/deprecated-framework/README.md)  # Stale reference
```

✅ **Maintained cross-references**

```markdown
[Quality Framework](frameworks/quality-assurance/README.md)  # Current and validated
```

### Automated Validation Workflow

1. **Pre-commit**: `validate_internal_links.sh` catches broken links before commit
2. **Documentation quality**: `check_docs.sh` validates prose and structure
3. **Framework audit**: `audit_frameworks.sh` checks framework documentation integrity
4. **Template validation**: New template-specific checks for consistency

---
**Implemented**: October 2, 2025
**Integration**: Pre-commit hooks + quality assurance framework
**Coverage**: Templates, documentation, framework references, cross-links
