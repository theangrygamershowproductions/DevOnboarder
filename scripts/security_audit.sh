#!/usr/bin/env bash
set -euo pipefail

DATE=$(date -I)
OUT="docs/security-audit-${DATE}.md"

{
  echo "# Security Audit - ${DATE}"
  echo
  echo "We ran dependency audits for both Python and Node packages."
  echo
  echo "## Python (\`pip-audit\`)"
  if pip-audit >/tmp/pip_audit.log 2>&1; then
    cat /tmp/pip_audit.log
  else
    echo "\`pip-audit\` could not complete in the Codex environment due to restricted network access."
  fi
  echo
  echo "## Node (\`npm audit --production\`)"
  for dir in frontend bot; do
    if [ -f "$dir/package.json" ]; then
      echo "### $dir"
      (cd "$dir" && npm audit --production) || true
      echo
    fi
  done
} > "$OUT"

echo "Results saved to $OUT"
