---
author: TAGS Engineering
codex_role: Engineering
codex_runtime: false
codex_scope: TAGS
codex_type: STANDARDS
consolidation_priority: P3
content_uniqueness_score: 5
created_at: '2025-09-11'
description: Comprehensive troubleshooting guide with common issues, debugging patterns,
  and resolution tools
document_type: standards
merge_candidate: false
project: core-instructions
related_modules:
- virtual-environment-policy.md
- terminal-output-policy.md
- ci-cd-automation.md
similarity_group: troubleshooting-debug
source: .github/copilot-instructions.md
status: active
tags:
- devonboarder
- troubleshooting
- debugging
- issues
- resolution
title: DevOnboarder Common Issues Resolution
updated_at: '2025-09-11'
visibility: internal
---

# DevOnboarder Troubleshooting Guide

## Common Issues

### 1. ModuleNotFoundError

- ✅ **Solution**: `source .venv/bin/activate && pip install -e .[test]`

- ❌ **NOT**: Install to system Python

### 2. Command not found (black, pytest, etc.)

- ✅ **Solution**: Use `python -m command` syntax in virtual environment

- ❌ **NOT**: Install globally with `pip install --user`

### 3. MyPy passes locally but fails in CI

- ✅ **Symptom**: "Library stubs not installed for 'requests' [import-untyped]"

- ✅ **Solution**: Add missing `types-*` packages to `pyproject.toml` test dependencies

- 📚 **Documentation**: `docs/troubleshooting/CI_MYPY_TYPE_STUBS.md`

- ❌ **NOT**: Install type stubs only locally

### 4. Automerge hangs indefinitely (CRITICAL INFRASTRUCTURE ISSUE)

- ✅ **Symptom**: All checks pass, automerge enabled, but PR shows "BLOCKED" indefinitely

- ✅ **Root Cause**: Repository default branch mismatch OR status check name misalignment

- ✅ **Quick Check**: `gh api repos/OWNER/REPO --jq '.default_branch'` (should be "main")

- ✅ **Solution**: Fix default branch + align status check names with actual check runs

- 📚 **Documentation**: `docs/troubleshooting/AUTOMERGE_HANGING_INDEFINITELY.md`

- 🛠️ **Health Check**: `bash scripts/check_automerge_health.sh`

- ❌ **NOT**: Assume it's a temporary GitHub issue - this requires configuration fixes

### 5. Coverage failures

Check test quality, not just quantity

### 6. Discord connection issues

Verify token and guild permissions

### 7. CI failures

Check GitHub CLI availability and error handling

### 8. Cache pollution in repository root

- ✅ **Detection**: Run `bash scripts/validate_cache_centralization.sh`

- ✅ **Solution**: Run `bash scripts/manage_logs.sh cache clean`

- ❌ **NOT**: Manually delete cache directories (bypasses DevOnboarder automation)

### 9. Jest Test Timeouts in CI

- ✅ **Symptom**: Tests hang indefinitely in CI causing workflow failures

- ✅ **Quick Fix**: Ensure Jest configuration includes `testTimeout: 30000`

- ✅ **Location**: `bot/package.json` Jest configuration block

- ✅ **Validation**: Run `bash scripts/check_jest_config.sh`

### 10. Dependency Update Failures

- ✅ **Pattern**: "Tests hang in CI but pass locally" → Missing Jest timeout configuration

- ✅ **Pattern**: "TypeScript compilation errors after upgrade" → Breaking changes in major versions

- ✅ **Pattern**: "Dependabot PR fails immediately" → Lock file conflicts or incompatible versions

- ✅ **Emergency Rollback**: `git revert <commit-hash> && git push origin main`

## Dependency Crisis Management

### When All Dependency PRs Fail

1. **Immediate Assessment**:

   ```bash
   # Check current CI status

   gh pr list --state=open --label=dependencies

   # Identify common failure patterns

   gh pr checks <pr-number> --watch
   ```

2. **Test Timeout Quick Fix**:

   ```bash
   # Emergency Jest timeout fix

   cd bot
   npm test -- --testTimeout=30000

   ```

3. **Incremental Recovery**:

   - Merge patch updates first (1.2.3 → 1.2.4)

   - Then minor updates (1.2.x → 1.3.0)

   - Major updates last with manual testing

### Dependabot PR Quick Assessment

**Before Merging Any Dependency PR**:

1. **Check CI Status**: All checks must be green

2. **Test Timeout Check**: Verify Jest testTimeout is configured

3. **Major Version Upgrades**: Review breaking changes documentation

4. **TypeScript Upgrades**: Run local type checking before merge

**Fast Track Criteria (Safe to Auto-Merge)**:

- ✅ Patch version updates (1.2.3 → 1.2.4)

- ✅ Minor version updates with green CI

- ✅ Test framework maintenance updates (@types/*, ts-jest)

**Requires Investigation**:

- ⚠️ Major version jumps (5.8.x → 5.9.x)

- ⚠️ Framework core updates (TypeScript, Jest major versions)

- ⚠️ Any PR with failing CI checks

## Environment Variable Management Issues

### Critical Issues Requiring Immediate Action

- **Environment File Inconsistencies**:

    - ✅ **Detection**: Run `bash scripts/smart_env_sync.sh --validate-only` to detect mismatches

    - ✅ **Solution**: Run `bash scripts/smart_env_sync.sh --sync-all` to synchronize

    - ❌ **NOT**: Manually edit individual environment files

- **Security Audit Failures**:

    - ✅ **Detection**: Run `bash scripts/env_security_audit.sh`

    - ✅ **Pattern**: Production secrets in CI files (CRITICAL violation)

    - ✅ **Solution**: Move production secrets to gitignored files only

    - ⚠️ **Emergency**: Never commit production secrets to CI environment

- **Tunnel Hostname Validation Failures**:

    - ✅ **Pattern**: "ERROR: uses old multi-subdomain format"

    - ✅ **Solution**: Use single domain format (auth.theangrygamershow.com)

    - ❌ **NOT**: Disable validation to avoid errors

- **Discord Bot Authentication Failures in Docker**:

    - ✅ **Pattern**: Bot shows "0 env vars loaded" or "DISCORD_GUILD_ID not configured"

    - ✅ **Root Cause**: Environment file mismatch between docker-compose.yaml and container mount

    - ✅ **Solution**: Ensure compose file env_file matches volume mount (.env.dev → /app/.env:ro)

    - ✅ **Verification**: Check container logs with `docker compose logs bot`

- **Missing Bot Environment Variables**:

    - ✅ **Pattern**: Bot starts but missing DISCORD_GUILD_ID, ENVIRONMENT, DISCORD_BOT_READY

    - ✅ **Solution**: Add variables to main .env file and run `bash scripts/smart_env_sync.sh --sync-all`

    - ❌ **NOT**: Manually edit .env.dev or docker-specific files directly

- **Multi-Service Container Failures**:

    - ✅ **Diagnostic Pattern**: Check `docker compose ps` → logs → environment sync → security audit

    - ✅ **Service Order**: Database fails → Auth fails → Backend fails → Bot fails

    - ✅ **Environment Consistency**: All services should reference same environment file in compose

## Validation-Driven Resolution Pattern

DevOnboarder follows a **validation-first troubleshooting approach** where scripts provide actionable guidance:

```bash

# Step 1: Run validation to identify issues

bash scripts/validate_cache_centralization.sh

# Output: "Solution: Run cache cleanup with: bash scripts/manage_logs.sh cache clean"

# Step 2: Follow the provided solution exactly

bash scripts/manage_logs.sh cache clean

# Step 3: Re-validate to confirm resolution

bash scripts/validate_cache_centralization.sh

# Output: "SUCCESS: No cache pollution found in repository root"

```

**Key Principle**: When validation scripts suggest specific commands, use those commands rather than manual fixes. This ensures compliance with DevOnboarder's automated quality gates.

## Debugging Tools (Virtual Environment Context)

- `python -m diagnostics`: Verify packages and environment

- `npm run status --prefix bot`: Check bot connectivity

- `python -m vale docs/`: Validate documentation

- Coverage reports: Generated by test commands

**Dependency-Specific Diagnostics**:

- `bash scripts/check_jest_config.sh`: Verify Jest timeout configuration

- `npm run test --prefix bot`: Test bot directly for dependency issues

- `python -m pytest tests/`: Test backend directly for module errors

- `gh pr list --state=open --label=dependencies`: Check pending dependency PRs

## Enhanced Logging and CI Troubleshooting

### Test Execution with Persistent Logs

```bash

# Enhanced test runner with comprehensive logging

bash scripts/run_tests_with_logging.sh

# Standard test runner (CI compatible)

bash scripts/run_tests.sh

```

### Log Management

```bash

# List all log files and sizes

bash scripts/manage_logs.sh list

# Clean logs older than 7 days

bash scripts/manage_logs.sh clean

# Remove all logs (with confirmation)

bash scripts/manage_logs.sh purge

# Archive current logs

bash scripts/manage_logs.sh archive

# Custom retention (3 days) with dry-run

bash scripts/manage_logs.sh --days 3 --dry-run clean

```

**Log Locations**:

- Test logs: `logs/test_run_TIMESTAMP.log`

- Coverage data: `logs/coverage_data_TIMESTAMP`

- CI diagnostics: `logs/ci_diagnostic_TIMESTAMP.log`

- All logs excluded from git via `.gitignore`

**When Terminal Output Fails**:

- Check `logs/test_run_*.log` for complete test output

- Use `bash scripts/run_tests_with_logging.sh` for persistent logging

- Review CI failure patterns in diagnostic logs

- Use Root Artifact Guard to identify pollution sources

## Enhanced CI Troubleshooting Framework

### CI Triage Guard System

Automated detection and resolution of CI patterns:

```bash

# Check CI health status

bash scripts/monitor_ci_health.sh

# Analyze recurring failure patterns

bash scripts/analyze_ci_patterns.sh

# Generate comprehensive CI diagnostic report

bash scripts/ci_failure_diagnoser.py

```

### Root Artifact Guard Usage

```bash

# Check for repository pollution

bash scripts/enforce_output_location.sh

# Clean all artifacts comprehensively

bash scripts/final_cleanup.sh

# Verify clean state before commits

git status --short  # Should show only intended changes

```

### Automated Issue Management

- CI failures automatically create issues via `codex.ci.yml`

- Pattern recognition prevents duplicate issue creation

- Successful runs automatically close resolved issues

- Comprehensive logging preserves diagnostic information
