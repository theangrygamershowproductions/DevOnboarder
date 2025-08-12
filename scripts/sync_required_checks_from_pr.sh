#!/usr/bin/env bash
set -euo pipefail

# Sync required status checks from a known-good green PR
# Usage: ./scripts/sync_required_checks_from_pr.sh <green-pr-number>

if [ $# -lt 1 ]; then
    echo "Usage: $0 <green-pr-number>"
    echo ""
    echo "Syncs required status checks from a known-good green PR to protection.json"
    echo "and creates a pull request with the updated configuration."
    echo ""
    echo "Example: $0 1123"
    exit 2
fi

PR="$1"
OWNER=${OWNER:-theangrygamershowproductions}
REPO=${REPO:-DevOnboarder}

echo "Syncing required checks from PR #$PR..."

# Fetch live check names from the PR head commit
echo "Fetching check runs from PR #$PR..."
SHA=$(gh pr view "$PR" --json headRefOid -q .headRefOid)

if [ -z "$SHA" ]; then
    echo "Error: Could not get SHA for PR #$PR"
    exit 1
fi

echo "Found commit SHA: $SHA"

# Get live check names using GitHub API and Python processing
echo "Extracting check run names..."
CHECK_RUNS_JSON=$(gh api -H "Accept: application/vnd.github+json" \
    "repos/$OWNER/$REPO/commits/$SHA/check-runs")

mapfile -t LIVE < <(
    python3 <<PY
import json, sys

try:
    data = json.loads("""$CHECK_RUNS_JSON""")
    check_runs = data.get("check_runs", [])

    # Extract and sort unique check names
    names = sorted(set(
        run.get("name", "").strip()
        for run in check_runs
        if run.get("name", "").strip()
    ))

    for name in names:
        print(name)

except json.JSONDecodeError as e:
    print(f"Error parsing JSON: {e}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error processing check runs: {e}", file=sys.stderr)
    sys.exit(1)
PY
)

if [ ${#LIVE[@]} -eq 0 ]; then
    echo "Error: No check runs found for PR #$PR commit $SHA"
    exit 1
fi

echo "Found ${#LIVE[@]} check runs:"
printf '  - %s\n' "${LIVE[@]}"

# Update protection.json in-place (preserves other keys)
echo "Updating protection.json..."
tmp=$(mktemp)

python3 - <<PY > "$tmp"
import json
import sys

# Read existing protection.json
try:
    with open("protection.json", "r") as f:
        config = json.load(f)
except FileNotFoundError:
    print("Error: protection.json not found", file=sys.stderr)
    sys.exit(1)
except json.JSONDecodeError as e:
    print(f"Error parsing protection.json: {e}", file=sys.stderr)
    sys.exit(1)

# Update required status checks while preserving other settings
config.setdefault("required_status_checks", {})
config["required_status_checks"]["strict"] = True
config["required_status_checks"]["contexts"] = [
$(printf '    "%s",\n' "${LIVE[@]}" | sed '$ s/,$//')
]

# Output updated configuration
json.dump(config, sys.stdout, indent=2, sort_keys=False)
print()  # Add final newline
PY

# Validate JSON and update file
if command -v jq >/dev/null 2>&1; then
    if jq . "$tmp" >/dev/null 2>&1; then
        jq . "$tmp" > protection.json
        echo "SUCCESS protection.json updated with valid JSON"
    else
        echo "Error: Generated invalid JSON"
        cat "$tmp"
        exit 1
    fi
else
    mv "$tmp" protection.json
    echo "SUCCESS protection.json updated (jq not available for validation)"
fi

rm -f "$tmp" 2>/dev/null || true

# Create branch and commit changes
branch="chore/sync-required-checks-from-pr-$PR"
echo "Creating branch: $branch"

if git rev-parse --verify "$branch" >/dev/null 2>&1; then
    git checkout "$branch"
    echo "Switched to existing branch: $branch"
else
    git checkout -b "$branch"
    echo "Created new branch: $branch"
fi

# Stage and commit changes
git add protection.json

if git diff --staged --quiet; then
    echo "No changes to commit - protection.json already up to date"
    exit 0
fi

git commit -m "CHORE(ci): sync required checks from PR #$PR (drift auto-fix)

Synced required status checks from known-good PR #$PR:
$(printf '- %s\n' "${LIVE[@]}")

This ensures branch protection remains effective with current check names."

echo "Pushing branch to origin..."
git push -u origin "$branch"

echo "Creating pull request..."
gh pr create \
    --title "CONFIG Sync required checks from PR #$PR" \
    --body "## Auto-sync Required Status Checks

**Source PR**: #$PR (commit $SHA)
**Purpose**: Keep branch protection effective with current check names

### Changes
- Updated \`protection.json\` with ${#LIVE[@]} check names from green PR
- Maintains strict status check enforcement
- Preserves all other protection settings

### Check Names Synced
$(
for check in "${LIVE[@]}"; do
    printf '- **%s**\n' "$check"
done
)

This PR was generated automatically by the drift auto-fix system.

**Review**: Verify check names match expectations, then merge to apply protection.
**Testing**: Run \`./scripts/verify-branch-protection.sh\` after merge to confirm sync." \
    --label "automation,ci-governance,drift-fix,auto-generated"

echo ""
echo "SUCCESS Self-healing sync complete!"
echo "SYMBOL PR created: review and merge to apply updated protection"
echo "SEARCH Verify with: ./scripts/verify-branch-protection.sh (after merge)"
