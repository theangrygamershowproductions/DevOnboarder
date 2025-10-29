---
author: "DevOnboarder Team"
consolidation_priority: P3
content_uniqueness_score: 4
created_at: 2025-09-12
description: "Documentation description needed"

document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: CONFIGURATION_MANAGEMENT_POLICY.md-docs
status: active
tags: 
title: "Configuration Management Policy"

updated_at: 2025-10-27
visibility: internal
---

# Configuration Management Policy

## Overview

DevOnboarder maintains a strict distinction between **permanent project configuration** and **temporary backup configurations** to prevent accidental deletion of critical infrastructure files.

## Permanent Project Configuration Files

These files are **NEVER** cleaned up by automation scripts and are essential for project functionality:

### Primary Configuration Directory (`config/`)

| File | Purpose | Protected By |
|------|---------|--------------|
| `config/.coveragerc.xp` | XP service coverage isolation | `clean_pytest_artifacts.sh` exclusion |
| `config/.coveragerc.auth` | Auth service coverage configuration | `clean_pytest_artifacts.sh` exclusion |
| `config/.coveragerc.discord` | Discord integration coverage settings | `clean_pytest_artifacts.sh` exclusion |
| `config/devonboarder.config.yml` | Main application configuration | Git version control |
| `config/aar-config.json` | After Action Report system settings | Git version control |
| `config/env-sync-config.yaml` | Environment variable sync rules | Git version control |

### Project Structure Configuration

- `.github/workflows/*.yml` - CI/CD pipeline definitions

- `pyproject.toml` - Python project dependencies and tool settings

- `package.json` files - Node.js service configurations

- `docker-compose.*.yaml` - Container orchestration

- `.tool-versions` - Language version requirements

## Temporary/Backup Configuration Files

These files are **safe to clean up** and are generated during operations:

### Test & CI Artifacts

- `config_backups/` - Temporary directory created during testing

- `logs/*.config` - Configuration snapshots

- `test-results/config-*` - Test-generated copies

- `*.backup` files - Backup copies during updates

### Runtime Generated

- `.env.ci` - CI-specific environment (regenerated)

- Temporary coverage configs in pytest cache

- Any config files with timestamps

## Cleanup Script Protection

The `scripts/clean_pytest_artifacts.sh` script implements these protections:

```bash

# PROTECTS permanent configs in config/ directory

find . -name ".coverage*" -not -path "./config/*" -delete

# REMOVES temporary backup directory only

rm -rf config_backups/

```

## Critical Protection: Coverage Masking Solution

**NEVER remove `config/.coveragerc.*` files** - these are core infrastructure for the coverage masking solution that enables accurate per-service quality measurement.

## Validation Commands

```bash

# Check protected files exist

ls -la config/.coveragerc.*

# Test cleanup protection (dry run)

bash scripts/clean_pytest_artifacts.sh --dry-run

# Verify config directory integrity

ls -la config/

```

## Developer Guidelines

1. **Adding new permanent configs**: Place in `config/` directory and update this documentation

2. **Creating temporary configs**: Use timestamped names or place in `logs/` directory

3. **Testing config changes**: Use `config_backups/` for temporary copies

4. **Never bypass protections**: Don't modify cleanup script exclusions without review

## Emergency Recovery

If permanent configuration files are accidentally deleted:

```bash

# Restore from git

git checkout HEAD -- config/

# Regenerate coverage configs if needed

# (See docs/COVERAGE_MASKING_SOLUTION.md)

```

---

**Last Updated**: September 5, 2025

**Related Documentation**: `docs/COVERAGE_MASKING_SOLUTION.md`
