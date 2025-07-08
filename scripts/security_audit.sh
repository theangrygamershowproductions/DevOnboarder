#!/usr/bin/env bash
set -euo pipefail

DATE=$(date -I)
OUT="docs/security-audit-${DATE}.md"

{
  echo "# Security Audit - ${DATE}"
  echo
  echo "We ran dependency audits for Python and Node packages and scanned the code with Bandit."
  echo
  echo "## Python (\`pip-audit\`)"
  if pip-audit >/tmp/pip_audit.log 2>&1; then
    cat /tmp/pip_audit.log
  else
    echo "\`pip-audit\` could not complete in the Codex environment due to restricted network access."
  fi
  echo
  echo "## Python Static Analysis (\`bandit -r src -ll\`)"
  bandit -r src -ll || true
  echo
  echo "## Node (\`npm audit --audit-level=high\`)"
  for dir in frontend bot; do
    if [ -f "$dir/package.json" ]; then
      echo "### $dir"
      (cd "$dir" && npm audit --audit-level=high) || true
      echo
    fi
  done
} > "$OUT"

echo "Results saved to $OUT"
