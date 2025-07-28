# 95% Quality Control Rule for DevOnboarder

## Overview

All code changes MUST achieve a minimum 95% quality score before pushing to any branch. This ensures "quiet reliability" and maintains our high standards.

## Quality Control Checklist

### Mandatory Checks (Must Pass)

1. **✅ YAML Linting** - All YAML files pass yamllint
2. **✅ Python Linting** - Code passes `python -m ruff check .`
3. **✅ Python Formatting** - Code passes `python -m black --check .`
4. **✅ Type Checking** - Code passes `python -m mypy src/devonboarder`
5. **✅ Test Coverage** - Minimum 95% coverage: `python -m pytest --cov=src --cov-fail-under=95`
6. **✅ Documentation** - Passes Vale documentation checks
7. **✅ Commit Messages** - Follow conventional commit format
8. **✅ Security Scan** - No high-severity issues: `python -m bandit -r src -ll`

### Virtual Environment Requirements

- **ALWAYS** run QC in virtual environment: `source .venv/bin/activate`
- **NEVER** install packages to system Python
- **VERIFY** environment before any validation: `which python` should show `.venv`

## Usage

### Before Every Push

```bash
# Activate virtual environment
source .venv/bin/activate

# Run automated QC check
./scripts/qc_pre_push.sh

# Only push if 95% threshold is met
git push
```

### Manual QC Process

```bash
# 1. Virtual environment activation
source .venv/bin/activate
pip install -e .[test]

# 2. Code quality
python -m ruff check . && python -m ruff check . --fix
python -m black .
python -m mypy src/devonboarder

# 3. YAML validation
yamllint .github/workflows/

# 4. Test coverage
python -m pytest --cov=src --cov-fail-under=95

# 5. Documentation
./scripts/check_docs.sh

# 6. Security
python -m bandit -r src -ll

# 7. Commit message validation
bash scripts/check_commit_messages.sh
```

## Quality Score Calculation

- **Total Checks**: 8 mandatory checks
- **Success Threshold**: ≥95% (8/8 or 7/8 checks passing)
- **Failure Action**: Block push, provide specific fix guidance

## CI Integration

The QC process is enforced in CI but should be run locally first:

```yaml
- name: Quality Control Gate
  run: ./scripts/qc_pre_push.sh
```

## Agent Guidelines

### For GitHub Copilot

1. **ALWAYS** run QC before suggesting commits
2. **VERIFY** virtual environment context in all examples
3. **CHECK** that code changes don't reduce quality score
4. **PROVIDE** specific fix commands when QC fails
5. **ENSURE** all file modifications follow project standards

### QC Rule Enforcement

- **No exceptions** to 95% threshold
- **Fix issues immediately** rather than bypassing
- **Update QC script** if new quality requirements emerge
- **Document deviations** in PR summaries if temporary workarounds needed

## Common Issues & Fixes

### Trailing Spaces (YAML)

```bash
# Find and fix trailing spaces
sed -i 's/[[:space:]]*$//' .github/workflows/*.yml
```

### Python Formatting

```bash
python -m black .
python -m ruff check . --fix
```

### Coverage Below 95%

```bash
# Run with detailed coverage report
python -m pytest --cov=src --cov-report=html
# Check htmlcov/index.html for uncovered lines
```

### Type Errors

```bash
# Fix type hints
python -m mypy src/devonboarder --show-error-codes
```

## Benefits

- **Consistent Quality**: All changes meet same high standards
- **Early Detection**: Catch issues before CI/review
- **Team Efficiency**: Reduces review cycles
- **Reliability**: Maintains project's "quiet reliability" philosophy
- **Automation**: Reduces manual oversight burden

## Monitoring

- QC score tracked in CI artifacts
- Failed QC attempts logged for process improvement
- Regular review of QC effectiveness and thresholds

---

**Remember**: Quality is not negotiable. The 95% threshold ensures DevOnboarder maintains its reputation for reliability and excellence.
