# NPM Security Standards for DevOnboarder

## Overview

This document establishes mandatory security standards for npm dependency management to prevent Root Artifact Guard violations and maintain DevOnboarder's "quiet reliability" philosophy.

## Root Artifact Guard Compliance

DevOnboarder enforces strict artifact hygiene to prevent repository pollution. The Root Artifact Guard automatically blocks commits containing violations.

### Prohibited Actions

**NEVER run these commands from repository root:**

```bash
# FORBIDDEN - Creates root node_modules pollution
npm install
npm ci
npm audit fix
npm update
```

### Required Practices

**Service-Specific Dependency Management:**

```bash
# CORRECT - Frontend dependencies
npm audit fix --prefix frontend
npm ci --prefix frontend
npm install package-name --prefix frontend

# CORRECT - Bot dependencies
npm audit fix --prefix bot
npm ci --prefix bot
npm install package-name --prefix bot
```

**Documentation Tooling Approach:**

```bash
# CORRECT - Use npx for root tooling
npx markdownlint-cli2 docs/
npx ajv-cli validate schema.json
npx typedoc --version

# CORRECT - No permanent installation in root
```

## Security Vulnerability Response Process

### Step 1: Identify Vulnerability Scope

```bash
# Check which services have vulnerabilities
npm audit --prefix frontend
npm audit --prefix bot
npm audit  # Check root tooling (documentation only)
```

### Step 2: Apply Service-Specific Fixes

```bash
# Fix frontend vulnerabilities
cd frontend && npm audit fix

# Fix bot vulnerabilities
cd bot && npm audit fix

# For root tooling: use npx approach (no permanent fix needed)
```

### Step 3: Validate Clean State

```bash
# Verify no root pollution created
ls -la node_modules 2>/dev/null && echo "ERROR: Root pollution detected" || echo "Clean state confirmed"

# Run Root Artifact Guard validation
bash scripts/enforce_output_location.sh
```

## Documentation Tooling Dependencies

DevOnboarder maintains legitimate package.json and package-lock.json in root for documentation tooling. These files are tracked in git and should remain.

### Root Package Files (Legitimate)

- `package.json` - Documentation tooling configuration
- `package-lock.json` - Dependency lock for reproducible builds
- `package.json.unused` - Legacy configuration reference

### NPX Usage Pattern

```bash
# Standard DevOnboarder documentation commands
npx markdownlint-cli2 "docs/**/*.md"
npx ajv-cli validate schema/agent-schema.json
npx typedoc --tsconfig bot/tsconfig.json
```

## Emergency Response: Root Pollution Cleanup

If root node_modules pollution occurs:

```bash
# Step 1: Clean pollution immediately
rm -rf node_modules

# Step 2: Verify git status
git status  # Should show no unexpected changes

# Step 3: Run quality validation
bash scripts/enforce_output_location.sh

# Step 4: Continue with proper service-specific approach
npm audit fix --prefix frontend
npm audit fix --prefix bot
```

## Pre-Commit Validation

The Root Artifact Guard automatically blocks commits with violations:

```text
Root Artifact Guard......................................................Failed
- hook id: enforce-no-root-artifacts
- exit code: 1

VIOLATION: Unexpected node_modules in root
   ./node_modules → should be in bot/ or frontend/ only
```

## Training and Prevention

### Developer Onboarding Checklist

- [ ] Understand DevOnboarder service structure (bot/, frontend/, root tooling)
- [ ] Know proper npm command patterns (--prefix usage)
- [ ] Recognize Root Artifact Guard enforcement
- [ ] Practice security fix workflow on test vulnerabilities

### Common Mistakes to Avoid

1. **Running npm audit fix from root** - Creates 500+ package pollution
2. **Installing global dependencies** - Violates isolation principles
3. **Ignoring Root Artifact Guard warnings** - Bypasses critical safety checks
4. **Removing legitimate root package files** - Breaks documentation tooling

## Integration with DevOnboarder Standards

This policy integrates with:

- **Terminal Output Policy** - All commands use plain ASCII text only
- **Quality Control Framework** - 95% validation threshold includes security checks
- **Virtual Environment Policy** - Isolation principles apply to npm dependencies
- **Pre-commit Hook System** - Automatic enforcement via Root Artifact Guard

## Enforcement

- **Pre-commit hooks** - Automatic blocking of violations
- **CI validation** - Repository-wide compliance checking
- **Documentation** - This standard is discoverable and actionable
- **Process integration** - Part of security vulnerability response workflow

## References

- Root Artifact Guard: `scripts/enforce_output_location.sh`
- Security audit process: `scripts/security_audit.sh`
- DevOnboarder CI hygiene: `docs/ci/ci-status-current.md`
- Terminal Output Policy: `docs/TERMINAL_OUTPUT_VIOLATIONS.md`

---

**Last Updated**: September 11, 2025
**Status**: Active enforcement via Root Artifact Guard
**Scope**: All npm dependency management in DevOnboarder repository
