---
similarity_group: ci-debug-wrapper.md-docs
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# CI Debug Wrapper

A unified tool for debugging DevOnboarder CI failures. Simplifies downloading reports, logs, and artifacts from GitHub Actions.

## Quick Start

```bash
# Show current CI status
python scripts/ci_debug_wrapper.py status

# Analyze recent failures
python scripts/ci_debug_wrapper.py failures

# Generate comprehensive debug report for latest failed run
python scripts/ci_debug_wrapper.py report

# Download logs for specific run
python scripts/ci_debug_wrapper.py logs --run-id abc12345

# Download artifacts for specific run
python scripts/ci_debug_wrapper.py artifacts --run-id abc12345
```

## Commands

- `status` - Show recent workflow runs and their status
- `failures` - List recent failed runs with debug commands
- `report` - Generate detailed failure analysis and download logs/artifacts
- `logs` - Download job logs (use `--failed-only` for failed jobs only)
- `artifacts` - Download CI artifacts (coverage reports, test results, etc.)

## Requirements

- GitHub CLI (`gh`) installed and authenticated
- Python 3.8 with standard library
- DevOnboarder repository context

## Output

Reports and downloads are saved to `ci_debug_output/` directory:

- `ci_debug_report_*.md` - Comprehensive failure analysis
- `artifacts_*/` - Downloaded CI artifacts
- `*_logs.txt` - Job logs for debugging

## Examples

```bash
# Debug the latest CI failure
python scripts/ci_debug_wrapper.py report

# Get logs for a specific failed run
python scripts/ci_debug_wrapper.py logs --run-id d3602500 --failed-only

# Download coverage and test artifacts
python scripts/ci_debug_wrapper.py artifacts --run-id d3602500</content>
<parameter name="filePath">/home/potato/DevOnboarder/docs/ci-debug-wrapper.md
