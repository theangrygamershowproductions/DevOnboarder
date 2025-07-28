#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar

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
for md in $(git ls-files '*.md' | grep -v '^\.codex/agents/' | grep -v '^codex/agents/' | grep -v '^codex/tasks/' | grep -v '^agents/' | grep -v '^\.github/' | grep -v '^docs/' | grep -v '^infra/' | grep -v '^Codex_Contributor_Dashboard.md$' | grep -v '^codex.plan.md$'); do
  if [ "$(head -n1 "$md")" = "---" ]; then
    tmp=$(mktemp)
    frontmatter_file=$(mktemp)
    # Extract only the first YAML frontmatter block
    awk '/^---$/{if(NR==1){next} else {exit}} {print}' "$md" > "$frontmatter_file"
    python -c "
import sys, yaml, json
from datetime import date, datetime

class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (date, datetime)):
            return obj.isoformat()
        return super().default(obj)

try:
    with open('$frontmatter_file') as f:
        content = f.read().strip()
        if content:
            data = yaml.safe_load(content)
        else:
            data = {}
    json.dump(data, open('$tmp', 'w'), cls=DateTimeEncoder)
except Exception as e:
    print(f'Error parsing frontmatter in $md: {e}', file=sys.stderr)
    sys.exit(1)
"
    rm "$frontmatter_file"
    # Check if ajv is available locally, fallback to npx
    if [ -f "./node_modules/.bin/ajv" ]; then
        AJV_CMD="./node_modules/.bin/ajv"
    else
        AJV_CMD="npx -y ajv-cli"
    fi
    if ! $AJV_CMD validate -s schema/frontmatter.schema.json -d "$tmp" >/dev/null 2>&1; then
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

# Note: Tests are run via separate pre-commit pytest hook
echo "All checks passed!"
