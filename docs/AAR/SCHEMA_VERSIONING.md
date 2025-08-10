# AAR Schema Versioning System

## Overview

DevOnboarder AAR schemas follow semantic versioning with backward compatibility guarantees and automated migration support.

## Schema Versions

- **v1.0.0** (Current): Initial schema with comprehensive validation
- **v1.1.0** (Planned): Enhanced auto-linking and metadata support
- **v2.0.0** (Future): Breaking changes with migration support

## Version Management

### Current Schema Location

- **Active Schema**: `docs/AAR/schema/aar.schema.json` (always latest version)
- **Version Archive**: `docs/AAR/schemas/aar.v{VERSION}.json` (historical versions)

### Schema Structure Requirements

All schemas must include:

```json
{
  "$id": "https://devonboarder.io/schemas/aar/{VERSION}",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "version": "{VERSION}",
  "properties": {
    "schema_version": {
      "type": "string",
      "const": "{VERSION}",
      "description": "AAR schema version for validation and migration"
    }
  },
  "required": ["schema_version", ...]
}
```

## Migration Framework

### Migration Scripts

Use `scripts/migrate_aar.js` for version upgrades:

```bash
# Migrate single file
node scripts/migrate_aar.js docs/AAR/data/old.aar.json --to 1.1.0

# Migrate all AAR data files
node scripts/migrate_aar.js docs/AAR/data/*.aar.json --to 1.1.0

# Dry run migration (preview changes)
node scripts/migrate_aar.js docs/AAR/data/*.aar.json --to 1.1.0 --dry-run
```

### Migration Rules

- **Patch versions (1.0.0 → 1.0.1)**: Bug fixes, no data changes
- **Minor versions (1.0.0 → 1.1.0)**: New optional fields, backward compatible
- **Major versions (1.0.0 → 2.0.0)**: Breaking changes, migration required

### Backward Compatibility

- **Renderer**: Supports schemas within same major version
- **Validation**: Always uses latest schema for new AARs
- **Legacy Data**: Automatically migrated during CI validation

## Version Control Integration

### Pre-commit Hooks

Schema changes trigger automatic validation:

```bash
# Validate schema evolution
npm run aar:validate-schema-evolution

# Update version archive
npm run aar:archive-schema
```

### CI Pipeline

GitHub Actions automatically:

1. Validates schema changes for breaking changes
2. Updates version archive
3. Migrates existing AAR data if needed
4. Runs regression tests with new schema

## Development Workflow

### Adding New Fields (Minor Version)

1. Update `docs/AAR/schema/aar.schema.json`
2. Increment minor version in schema
3. Add migration logic in `scripts/migrate_aar.js`
4. Update templates and documentation
5. Run `npm run aar:test` to validate

### Breaking Changes (Major Version)

1. Create new schema file: `docs/AAR/schemas/aar.v2.0.0.json`
2. Implement migration script
3. Update renderer to support both versions
4. Deprecation notice for old version
5. Migration timeline communication

## Error Handling

### Schema Validation Failures

The system provides human-readable error messages:

```javascript
// Example error output
{
  "valid": false,
  "errors": [
    {
      "field": "executive_summary.problem",
      "rule": "minLength",
      "message": "Problem description must be at least 10 characters",
      "suggestion": "Provide a detailed problem statement"
    }
  ]
}
```

### Migration Failures

Migration scripts include rollback mechanisms:

```bash
# Rollback migration if issues occur
node scripts/migrate_aar.js docs/AAR/data/*.aar.json --rollback
```

## Security Considerations

### URL Validation

All URLs in AAR data are validated and sanitized:

```javascript
// URL validation pattern
const urlPattern = /^https:\/\/(github\.com|docs\.google\.com|[a-z0-9-]+\.devonboarder\.io)/;
```

### HTML Sanitization

Free-text fields are sanitized before rendering:

```javascript
// DOMPurify configuration for AAR content
const sanitizeConfig = {
  ALLOWED_TAGS: ['p', 'strong', 'em', 'ul', 'ol', 'li', 'code'],
  ALLOWED_ATTR: []
};
```

## Future Enhancements

### Planned Features

- **v1.1.0**: Auto-linking to GitHub PRs/issues
- **v1.2.0**: Rich media support (images, diagrams)
- **v2.0.0**: Multi-format native support (PDF metadata)

### Extension Points

- **Custom validators**: Plugin system for organization-specific rules
- **Custom renderers**: Support for additional output formats
- **Integration hooks**: Webhook support for external systems
