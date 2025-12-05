#!/usr/bin/env bash
# Merge Gate Report - Single source of truth for PR merge readiness
# 
# Usage: ./scripts/merge_gate_report.sh <pr-number>
#
# Returns exit code 0 if PR is merge-ready, non-zero otherwise
#
# Documented Exception Support:
#   If docs/SONAR_SCOPE_DECISION_PR<pr-number>.md exists, SonarCloud failures
#   for pre-existing hotspots NOT modified by the PR are treated as WARNINGS
#   instead of BLOCKERS. New hotspots still block.
#
# Systemic Failure Tracking SOP:
#   Any documented exception MUST have a "Tracked in: #<issue>" reference.
#   Exceptions without tracking issues are treated as BLOCKERS.

set -euo pipefail

PR_NUMBER="${1:?Usage: $0 <pr-number>}"
REPO_OWNER="theangrygamershowproductions"
REPO_NAME="DevOnboarder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Enforce Systemic Failure Tracking SOP
# Any documented exception MUST have a tracking issue reference
EXCEPTION_DOCS=$(find "$REPO_ROOT/docs" -type f \( -name "*STATUS*.md" -o -name "*DECISION*.md" \) 2>/dev/null || true)
MISSING_ISSUE_REFS=()

for doc in $EXCEPTION_DOCS; do
    # Check if doc declares a documented exception
    if grep -qi "documented exception" "$doc" 2>/dev/null; then
        # Verify it has a tracking issue reference (flexible pattern)
        # Accepts: "Tracked in: #123", "**Tracked in**: Issue #123", etc.
        if ! grep -qiE "\*?\*?Tracked in\*?\*?:.*#[0-9]+" "$doc" 2>/dev/null; then
            MISSING_ISSUE_REFS+=("$(basename "$doc")")
        fi
    fi
done

if [ ${#MISSING_ISSUE_REFS[@]} -gt 0 ]; then
    echo "❌ MERGE GATE BLOCKED: Documented exceptions without tracking issues"
    echo ""
    echo "The following documents declare exceptions but lack 'Tracked in: #<issue>' references:"
    for doc in "${MISSING_ISSUE_REFS[@]}"; do
        echo "  - $doc"
    done
    echo ""
    echo "SOP Requirement: Any documented exception MUST have a GitHub issue for tracking."
    echo "Fix: Add 'Tracked in: #<issue>' near the top of each document."
    echo "Helper: ./scripts/open_system_issue.sh <doc_path> <issue_title>"
    echo ""
    exit 1
fi

# Canonical truth: branch protection defines what is actually required.
# Only these 2 checks are enforced by GitHub branch protection on main.
REQUIRED_CHECKS=(
    "QC Gate (Required - Basic Sanity)"
    "Validate Actions Policy Compliance"
)

# Advisory checks: reported, but DO NOT block merges because
# they are NOT in branch protection (yet).
ADVISORY_CHECKS=(
    "Enforce Terminal Output Policy"     # Strongly recommended, but not branch-protected
    "validate-yaml"                      # Nice-to-have quality check
    "markdownlint / lint"                # Nice-to-have quality check
    # SonarCloud intentionally omitted:
    # no workflow exists today; implement in v4+ before re-adding.
)

echo "═══════════════════════════════════════════════════════════════"
echo "PR #${PR_NUMBER} – Merge Gate Report"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Fetch PR data
PR_DATA=$(gh pr view "$PR_NUMBER" --json statusCheckRollup,reviewDecision,mergeable,mergeStateStatus)

# Parse review state
REVIEW_DECISION=$(echo "$PR_DATA" | jq -r '.reviewDecision')
MERGEABLE=$(echo "$PR_DATA" | jq -r '.mergeable')
MERGE_STATE=$(echo "$PR_DATA" | jq -r '.mergeStateStatus')

# Get unresolved conversation count
UNRESOLVED_THREADS=$(gh api graphql -f query="
query(\$owner:String!, \$name:String!, \$number:Int!) {
  repository(owner:\$owner, name:\$name) {
    pullRequest(number:\$number) {
      reviewThreads(first:100) {
        nodes {
          isResolved
          isOutdated
          comments(first:1) {
            nodes {
              author { login }
            }
          }
        }
      }
    }
  }
}" -F owner="$REPO_OWNER" -F name="$REPO_NAME" -F number="$PR_NUMBER" | \
  jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false and .isOutdated == false)] | length')

# Check required status checks
echo "Required Status Checks (branch-protected):"
echo "───────────────────────────────────────────"
REQUIRED_FAILED=()
for check_name in "${REQUIRED_CHECKS[@]}"; do
    CONCLUSION=$(echo "$PR_DATA" | jq -r --arg name "$check_name" \
        '.statusCheckRollup[] | select(.name == $name) | .conclusion // "MISSING"')
    
    if [ "$CONCLUSION" = "SUCCESS" ]; then
        echo "  ✅ $check_name"
    else
        echo "  ❌ $check_name ($CONCLUSION)"
        REQUIRED_FAILED+=("$check_name")
    fi
done
echo ""

# Check advisory checks
echo "Advisory Checks (not blocking, but strongly recommended):"
echo "──────────────────────────────────────────────────────────"
ADVISORY_FAILED=()
for check_name in "${ADVISORY_CHECKS[@]}"; do
    CONCLUSION=$(echo "$PR_DATA" | jq -r --arg name "$check_name" \
        '.statusCheckRollup[] | select(.name | contains($name)) | .conclusion // "MISSING"' | head -1)
    
    if [ "$CONCLUSION" = "SUCCESS" ]; then
        echo "  ✅ $check_name"
    elif [ "$CONCLUSION" = "MISSING" ]; then
        echo "  ℹ️  $check_name (not run)"
    else
        echo "  ⚠️  $check_name ($CONCLUSION)"
        ADVISORY_FAILED+=("$check_name")
    fi
done
echo ""

# Check review state
echo "Review State:"
echo "─────────────"
case "$REVIEW_DECISION" in
    "APPROVED")
        echo "  ✅ Review decision: APPROVED"
        REVIEW_BLOCKED=false
        ;;
    "REVIEW_REQUIRED")
        echo "  ❌ Review decision: REVIEW_REQUIRED (need 1 approving review)"
        REVIEW_BLOCKED=true
        ;;
    "CHANGES_REQUESTED")
        echo "  ❌ Review decision: CHANGES_REQUESTED"
        REVIEW_BLOCKED=true
        ;;
    *)
        echo "  ⚠️  Review decision: $REVIEW_DECISION"
        REVIEW_BLOCKED=true
        ;;
esac

if [ "$UNRESOLVED_THREADS" -eq 0 ]; then
    echo "  ✅ Unresolved conversations: 0"
else
    echo "  ❌ Unresolved conversations: $UNRESOLVED_THREADS (all must be resolved)"
fi
echo ""

# Final verdict
echo "═══════════════════════════════════════════════════════════════"
echo "VERDICT:"
echo "═══════════════════════════════════════════════════════════════"

BLOCKERS=()

if [ "${#REQUIRED_FAILED[@]}" -gt 0 ]; then
    BLOCKERS+=("Required checks failing: ${REQUIRED_FAILED[*]}")
fi

if [ "$REVIEW_BLOCKED" = true ]; then
    BLOCKERS+=("Review required or changes requested")
fi

if [ "$UNRESOLVED_THREADS" -gt 0 ]; then
    BLOCKERS+=("$UNRESOLVED_THREADS unresolved conversations")
fi

if [ "${#BLOCKERS[@]}" -eq 0 ]; then
    echo "✅ MERGE READY"
    echo ""
    echo "All branch-protected checks passed, review approved, no unresolved conversations."
    
    if [ "${#ADVISORY_FAILED[@]}" -gt 0 ]; then
        echo ""
        echo "Advisory warnings (not blocking, but should investigate):"
        for warning in "${ADVISORY_FAILED[@]}"; do
            echo "  - $warning"
        done
    fi
    
    exit 0
else
    echo "🔒 BLOCKED"
    echo ""
    echo "Blockers:"
    for blocker in "${BLOCKERS[@]}"; do
        echo "  - $blocker"
    done
    
    if [ "${#ADVISORY_FAILED[@]}" -gt 0 ]; then
        echo ""
        echo "Advisory warnings (not blocking v3, but should address):"
        for warning in "${ADVISORY_FAILED[@]}"; do
            echo "  - $warning"
        done
    fi
    
    exit 1
fi
