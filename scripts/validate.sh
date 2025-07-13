#!/usr/bin/env bash
set -euo pipefail

# Aggregate validation checks documented in AGENTS.md and docs.

# Verify required ignore entries exist
bash "$(dirname "$0")/check_potato_ignore.sh"

# Confirm required external domains are reachable
bash "$(dirname "$0")/check_network_access.sh"

# Verify .tool-versions usage
if [ ! -f .tool-versions ]; then
  echo ".tool-versions file is required" >&2
  exit 1
fi
if [ -f .python-version ] || [ -f .nvmrc ]; then
  echo "Remove .python-version and .nvmrc; use .tool-versions" >&2
  exit 1
fi

# Lint documentation with markdownlint and Vale
bash "$(dirname "$0")/check_docs.sh"

# Lint GitHub Actions workflows
if command -v yamllint >/dev/null 2>&1; then
  yamllint -c .github/.yamllint-config .github/workflows/**/*.yml
else
  echo "::warning::yamllint not installed; skipping workflow lint"
fi

# Lint Markdown files
if command -v markdownlint >/dev/null 2>&1; then
  markdownlint 'docs/**/*.md' '*.md'
else
  echo "::warning::markdownlint not installed; skipping Markdown lint"
fi

# Validate frontmatter schema
for md in $(git ls-files 'docs/**/*.md' '*.md'); do
  if [ "$(head -n1 "$md")" = "---" ]; then
    tmp=$(mktemp)
    sed -n '/^---$/,/^---$/p' "$md" | sed '1d;$d' |
      python - <<'EOF' "$tmp"
import sys, yaml, json
data = yaml.safe_load(sys.stdin.read() or "{}")
json.dump(data, open(sys.argv[1], 'w'))
EOF
    if ! npx -y ajv-cli validate -s schema/frontmatter.schema.json -d "$tmp" >/dev/null; then
      echo "Frontmatter validation failed for $md" >&2
      rm "$tmp"
      exit 1
    fi
    rm "$tmp"
  fi
done

# Ensure environment variable docs match .env examples
python "$(dirname "$0")/check_env_docs.py"

# Ensure API endpoints include docstrings
python "$(dirname "$0")/check_docstrings.py" src/devonboarder

# Confirm optional tools like Jest, Vitest and Vale are installed
bash "$(dirname "$0")/check_dependencies.sh"

# Print unreferenced Docker artifacts
unused=$(git ls-files | grep -E 'Dockerfile|docker-compose\.' | grep -v '^docker-compose.ci.yaml$' || true)
if [ -n "$unused" ]; then
  echo "Unreferenced Docker files:" && echo "$unused"
fi

# Run linters and test suites with coverage
bash "$(dirname "$0")/run_tests.sh"
