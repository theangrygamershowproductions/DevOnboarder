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

set -euo pipefail

PR_NUMBER="${1:?Usage: $0 <pr-number>}"
REPO_OWNER="theangrygamershowproductions"
REPO_NAME="DevOnboarder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check for documented Sonar exception
SONAR_EXCEPTION_DOC="$REPO_ROOT/docs/SONAR_SCOPE_DECISION_PR${PR_NUMBER}.md"
HAS_SONAR_EXCEPTION=false
if [ -f "$SONAR_EXCEPTION_DOC" ]; then
    HAS_SONAR_EXCEPTION=true
fi

# Define v3-required checks (source of truth)
# These MUST be green for merge - no exceptions unless documented
REQUIRED_CHECKS=(
    "QC Gate (Required - Basic Sanity)"
    "Validate Actions Policy Compliance"
    "Terminal Output Policy Enforcement"  # ZERO TOLERANCE - must be green
    "SonarCloud Code Analysis"            # Security hotspots must be addressed (or documented exception)
)

# Define v3-advisory checks (not blocking, but should be tracked)
ADVISORY_CHECKS=(
    "validate-yaml"
    "markdownlint / lint"
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
echo "Required Status Checks (v3-blocking):"
echo "──────────────────────────────────────"
REQUIRED_FAILED=()
DOCUMENTED_EXCEPTIONS=()
for check_name in "${REQUIRED_CHECKS[@]}"; do
    CONCLUSION=$(echo "$PR_DATA" | jq -r --arg name "$check_name" \
        '.statusCheckRollup[] | select(.name == $name) | .conclusion // "MISSING"')
    
    if [ "$CONCLUSION" = "SUCCESS" ]; then
        echo "  ✅ $check_name"
    elif [ "$check_name" = "SonarCloud Code Analysis" ] && [ "$HAS_SONAR_EXCEPTION" = true ]; then
        echo "  ⚠️  $check_name ($CONCLUSION - documented exception)"
        DOCUMENTED_EXCEPTIONS+=("$check_name")
    else
        echo "  ❌ $check_name ($CONCLUSION)"
        REQUIRED_FAILED+=("$check_name")
    fi
done
echo ""

# Check advisory checks
echo "Advisory Checks (not blocking, but tracked):"
echo "─────────────────────────────────────────────"
ADVISORY_FAILED=()
for check_name in "${ADVISORY_CHECKS[@]}"; do
    CONCLUSION=$(echo "$PR_DATA" | jq -r --arg name "$check_name" \
        '.statusCheckRollup[] | select(.name | contains($name)) | .conclusion // "MISSING"' | head -1)
    
    if [ "$CONCLUSION" = "SUCCESS" ] || [ "$CONCLUSION" = "MISSING" ]; then
        echo "  ℹ️  $check_name ($CONCLUSION)"
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
    echo "All required checks passed, review approved, no unresolved conversations."
    
    if [ "${#DOCUMENTED_EXCEPTIONS[@]}" -gt 0 ]; then
        echo ""
        echo "Note: The following checks have documented exceptions:"
        for exception in "${DOCUMENTED_EXCEPTIONS[@]}"; do
            echo "  - $exception (see $SONAR_EXCEPTION_DOC)"
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
    
    if [ "${#DOCUMENTED_EXCEPTIONS[@]}" -gt 0 ]; then
        echo ""
        echo "Documented exceptions (not blocking):"
        for exception in "${DOCUMENTED_EXCEPTIONS[@]}"; do
            echo "  - $exception (see $SONAR_EXCEPTION_DOC)"
        done
    fi
    
    if [ "${#ADVISORY_FAILED[@]}" -gt 0 ]; then
        echo ""
        echo "Advisory warnings (not blocking v3, but should address):"
        for warning in "${ADVISORY_FAILED[@]}"; do
            echo "  - $warning"
        done
    fi
    
    exit 1
fi
