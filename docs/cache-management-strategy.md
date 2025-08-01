# Centralized Cache Management Strategy

## Overview

DevOnboarder implements a centralized cache management strategy to maintain repository hygiene and ensure compliance with the Enhanced Root Artifact Guard. All cache directories are consolidated in the `logs/` directory to support unified troubleshooting and prevent repository pollution.

## Cache Directory Structure

```text
logs/
├── .pytest_cache/          # Pytest execution cache
├── .mypy_cache/            # MyPy type checking cache
├── coverage_html/          # Coverage HTML reports
├── test_run_*.log          # Test execution logs
└── coverage_*.log          # Coverage data logs
```

## Configuration

### pyproject.toml

The centralized cache configuration is defined in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
cache_dir = "logs/.pytest_cache"
addopts = [
    "--cov=src",
    "--cov-report=html:logs/coverage_html",
    "--cov-report=term",
    "--cov-fail-under=95",
    "--cache-dir=logs/.pytest_cache"
]

[tool.mypy]
cache_dir = "logs/.mypy_cache"
show_error_codes = true
warn_unused_ignores = true

[tool.coverage.html]
directory = "logs/coverage_html"

[tool.coverage.xml]
output = "logs/coverage.xml"
```

### Environment Variables

The enhanced test runner sets environment variables to enforce cache locations:

```bash
export PYTEST_CACHE_DIR="logs/.pytest_cache"
export MYPY_CACHE_DIR="logs/.mypy_cache"
```

## Cache Management Commands

### List Cache Directories

```bash
bash scripts/manage_logs.sh cache list
```

Shows all cache directories with their sizes.

### Clean Old Cache Directories

```bash
bash scripts/manage_logs.sh cache clean
```

Removes cache directories older than 7 days (default).

### Cache Size Analysis

```bash
bash scripts/manage_logs.sh cache size
```

Displays size analysis of individual cache directories.

### Purge All Caches

```bash
bash scripts/manage_logs.sh cache purge
```

Removes all cache directories (use with caution).

## Benefits

### 1. Unified Troubleshooting

All diagnostic information is centralized in the `logs/` directory:

- Test execution logs
- Cache state and performance data
- Coverage reports and data
- CI diagnostic information

### 2. Repository Hygiene

- Eliminates cache pollution in repository root
- Maintains Enhanced Root Artifact Guard compliance
- Prevents CI pipeline instability

### 3. Enhanced Diagnostics

- Cache state preserved with test logs
- Performance analysis capabilities
- Historical cache effectiveness tracking

### 4. DevOnboarder Philosophy Alignment

- Supports "quiet reliability" through consistent structure
- Maintains centralized logging policy compliance
- Enables systematic troubleshooting procedures

## Root Artifact Guard Integration

The Enhanced Root Artifact Guard automatically detects and prevents cache pollution:

```bash
# Check for violations
bash scripts/enhanced_root_artifact_guard.sh --check

# Auto-clean any violations
bash scripts/enhanced_root_artifact_guard.sh --auto-clean
```

Cache directories in the repository root are considered violations and will be automatically cleaned.

## CI/CD Integration

The centralized cache strategy ensures CI stability:

1. **Consistent Environment**: Same cache locations across all environments
2. **Pollution Prevention**: Automatic cleanup of root-level cache artifacts
3. **Performance Optimization**: Cache reuse improves build times
4. **Diagnostic Capability**: Cache state available for troubleshooting

## Best Practices

### Development Workflow

1. Use the enhanced test runner: `bash scripts/run_tests_with_logging.sh`
2. Check cache status regularly: `bash scripts/manage_logs.sh cache size`
3. Clean old caches periodically: `bash scripts/manage_logs.sh cache clean`

### CI/CD Workflow

1. Pre-run cleanup for fresh diagnosis: `bash scripts/manage_logs.sh pre-run`
2. Run tests with centralized configuration
3. Validate Enhanced Root Artifact Guard compliance

### Troubleshooting

1. Check cache directory sizes if performance degrades
2. Use cache purge for complete reset if needed
3. Review test logs alongside cache state for comprehensive diagnosis

## Migration Notes

This strategy replaces the previous approach where cache directories were created in the repository root. The migration includes:

1. Configuration updates in `pyproject.toml`
2. Enhanced test runner with cache management
3. Extended log management system
4. Enhanced Root Artifact Guard compliance

All existing workflows continue to function while benefiting from improved repository hygiene and troubleshooting capabilities.
