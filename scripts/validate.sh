#!/usr/bin/env bash
set -euo pipefail

# Aggregate validation checks documented in AGENTS.md and docs.

# Verify required ignore entries exist
bash "$(dirname "$0")/check_potato_ignore.sh"

# Confirm required external domains are reachable
bash "$(dirname "$0")/check_network_access.sh"

# Lint documentation with markdownlint and Vale
bash "$(dirname "$0")/check_docs.sh"

# Ensure environment variable docs match .env examples
python "$(dirname "$0")/check_env_docs.py"

# Ensure API endpoints include docstrings
python "$(dirname "$0")/check_docstrings.py" src/devonboarder

# Confirm optional tools like Jest, Vitest and Vale are installed
bash "$(dirname "$0")/check_dependencies.sh"

# Run linters and test suites with coverage
bash "$(dirname "$0")/run_tests.sh"
