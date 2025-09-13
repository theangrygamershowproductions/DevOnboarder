---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: MyPy type checking failures in CI environments and solutions for type stub dependencies
document_type: troubleshooting
merge_candidate: false
project: DevOnboarder
similarity_group: troubleshooting-troubleshooting
status: active
tags:
- troubleshooting
- ci
- mypy
- type-checking
title: CI MyPy Type Checking Failures
updated_at: '2025-09-12'
visibility: internal
---

# CI MyPy Type Checking Failures

## Problem: MyPy Passes Locally But Fails in CI

### Symptoms

- ✅ **Local Development**: `python -m mypy src/` passes without errors

- ❌ **CI Environment**: MyPy fails with "Library stubs not installed" errors:

```text
src/devonboarder/diagnostics.py:11: error: Library stubs not installed for "requests" [import-untyped]
    import requests
    ^
src/devonboarder/diagnostics.py:11: note: Hint: "python3 -m pip install types-requests"

```

- 🤔 **Confusion**: Developers have type stubs installed locally but CI doesn't

### Root Cause

#### Dependency Mismatch Between Local and CI Environments

1. **Local Environment**: Type stubs like `types-requests` may have been installed manually during development

2. **CI Environment**: Only installs dependencies explicitly listed in `pyproject.toml`

3. **Installation Gap**: `pip install -e .[test]` in CI doesn't include manually installed packages

### Quick Fix

Add missing type stubs to `pyproject.toml` test dependencies:

```toml
[project.optional-dependencies]
test = [
    "pytest",
    "pytest-cov",
    # ... other dependencies

    "mypy",
    "types-requests",  # <- Add missing type stub

    # ... remaining dependencies

]

```

### Step-by-Step Resolution

#### 1. Identify Missing Type Stubs

Check what's installed locally but not in `pyproject.toml`:

```bash

# List installed type stubs

source .venv/bin/activate
pip list | grep -i types

# Common missing stubs

# - types-requests

# - types-PyYAML

# - types-setuptools

# - types-psutil

```

#### 2. Update Dependencies

Add missing type stubs to your `pyproject.toml`:

```toml
[project.optional-dependencies]
test = [
    # Existing dependencies...

    "mypy",
    "types-requests",     # For requests library

    "types-PyYAML",       # For yaml library

    "types-setuptools",   # For setuptools

    # Add other types-* packages as needed

]

```

#### 3. Test Locally

Verify the fix works by recreating CI conditions:

```bash

# Create fresh environment

python -m venv test-env
source test-env/bin/activate

# Install only declared dependencies

pip install -e .[test]

# Test MyPy

python -m mypy src/

```

#### 4. Commit and Test in CI

```bash
git add pyproject.toml
./scripts/safe_commit.sh "FIX(ci): add missing types-* dependencies for MyPy compatibility"

git push

```

### Prevention Strategies

#### 1. Dependency Audit Process

Regularly check for undeclared dependencies:

```bash

# Create clean environment and test

python -m venv audit-env
source audit-env/bin/activate
pip install -e .[test]
./scripts/qc_pre_push.sh

```

#### 2. Documentation Updates

When adding new libraries, document both runtime and type dependencies:

```python

# When adding this import

import requests

# Remember to add both

# 1. Runtime dependency (if not already present)

# 2. Type stub dependency in test section

```

#### 3. Pre-commit Hook Enhancement

Consider adding a check for common missing type stubs:

```bash

# Check for imports without corresponding type stubs

grep -r "import requests" src/ && grep -q "types-requests" pyproject.toml

```

### Common Type Stub Dependencies

| Library | Type Stub Package | Usage |
|---------|------------------|-------|
| `requests` | `types-requests` | HTTP client |
| `PyYAML` | `types-PyYAML` | YAML parsing |
| `setuptools` | `types-setuptools` | Package setup |
| `psutil` | `types-psutil` | System utilities |
| `redis` | `types-redis` | Redis client |
| `flask` | `types-flask` | Flask framework |

### Related Issues

- **Environment Parity**: Ensuring local and CI environments match exactly

- **Dependency Management**: Keeping runtime and development dependencies in sync

- **Type Safety**: Maintaining MyPy compliance across environments

### DevOnboarder Integration

This issue integrates with DevOnboarder's automated diagnostic system:

- **Automated Detection**: The misalignment detection system identifies MyPy failures

- **GitHub Issue Creation**: Failures automatically create tracking issues

- **Comprehensive Logging**: Full diagnostic reports available in CI artifacts

- **Quality Gates**: 95% QC threshold prevents pushes until resolved

### See Also

- [Quality Control Documentation](../standards/quality-control.md)

- [Environment Setup Guide](../SETUP.md)

- [MyPy Configuration](../../pyproject.toml)

- [CI Troubleshooting Scripts](../../scripts/ci_troubleshoot.sh)

---

**Created**: September 2, 2025

**Last Updated**: September 2, 2025
**Applies To**: DevOnboarder v0.1.0+
**Issue Type**: CI Environment Mismatch
