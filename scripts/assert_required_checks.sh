#!/usr/bin/env bash
# Assert Required Checks - Compares live PR check run names to required checks in protection.json
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: $0 <pr-number>"
    exit 2
fi
PR="$1"

# Check for jq availability
have_jq=0
command -v jq >/dev/null 2>&1 && have_jq=1

echo "===== Assert Required Checks Against Live PR ====="
echo "PR Number: $PR"
echo "jq available: $have_jq"

# Read required contexts from protection.json
echo "Reading required contexts from protection.json..."
if [ $have_jq -eq 1 ]; then
    mapfile -t required < <(jq -r '.required_status_checks.contexts[]' protection.json | sort -u)
else
    # Python fallback - no external dependencies
    mapfile -t required < <(python - <<'PY'
import json
try:
    with open("protection.json") as f:
        d = json.load(f)
    contexts = d.get("required_status_checks", {}).get("contexts", [])
    for c in sorted(set(contexts)):
        print(c)
except Exception as e:
    print(f"Error reading protection.json: {e}", file=sys.stderr)
    exit(1)
PY
)
fi

if [ ${#required[@]} -eq 0 ]; then
    echo "::error::No required contexts found in protection.json"
    exit 1
fi

# Fetch live check names for the PR HEAD
OWNER=${OWNER:-theangrygamershowproductions}
REPO=${REPO:-DevOnboarder}

echo "Fetching PR HEAD SHA for PR #$PR..."
SHA=$(gh pr view "$PR" --json headRefOid -q .headRefOid)
echo "PR HEAD SHA: $SHA"

echo "Fetching check runs for commit $SHA..."
raw=$(gh api -H "Accept: application/vnd.github+json" "repos/$OWNER/$REPO/commits/$SHA/check-runs")

if [ $have_jq -eq 1 ]; then
    mapfile -t live < <(jq -r '.check_runs[].name' <<<"$raw" | sort -u)
else
    # Python fallback JSON parse
    mapfile -t live < <(python -c "
import json
data = json.loads('''$raw''')
names = sorted(set(r.get('name', '') for r in data.get('check_runs', [])))
for name in names:
    if name:
        print(name)
")
fi

echo ""
echo "Required contexts (${#required[@]} total):"
printf '  - %s\n' "${required[@]}"

echo ""
echo "Live check runs on PR #$PR (${#live[@]} total):"
printf '  - %s\n' "${live[@]}"

# Diff: each required must be present in live
echo ""
echo "Checking for missing required checks..."
missing=()
for ctx in "${required[@]}"; do
    if ! printf '%s\n' "${live[@]}" | grep -Fxq "$ctx"; then
        missing+=("$ctx")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "::error::Missing check runs on PR #$PR (${#missing[@]} missing):"
    printf '  - %s\n' "${missing[@]}"
    echo ""
    echo "This indicates either:"
    echo "1. Check names in protection.json don't match actual workflow names"
    echo "2. Some workflows haven't triggered yet for this PR"
    echo "3. Workflows are conditionally skipped for this PR"
    echo ""
    echo "To fix:"
    echo "- Update protection.json with exact check names from live runs"
    echo "- Ensure all required workflows trigger for PR changes"
    echo "- Remove conditional checks from required list"
    exit 1
fi

echo "SUCCESS Required checks match live PR check names."
echo "All ${#required[@]} required checks are present in PR #$PR"
