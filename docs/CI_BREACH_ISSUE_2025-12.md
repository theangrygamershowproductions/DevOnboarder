# CI Breach — Main Merge with Failing Checks (2025-12-20)

This issue documents a governance breach: a merge to `main` with failing checks and insufficient branch protection enforcement.

## Summary
- Multiple failing workflow runs observed on `main` at 2025-12-20T09:07:34Z:
  - CI Monitor — failure (YAML lint)
  - Env Doc Alignment — failure
  - Secrets Alignment — failure
  - Auto Fix — failure
  - Cleanup CI Failure — failure
  - CI Failure Analyzer — failure
- Head SHA for runs: `3c0c30c4f50f54edac2dff5d4b1f44ccbf0302ee`
- Commit: `3c0c30c4` — "CI(workflows): SHA pin migration for v3 freeze compliance (issue #294) (#1901)"
- Author: Mr. Potato <reesey275@theangrygamershow.com>

## Impact Surface
- Changed files primarily in `.github/workflows` (49 files) plus `AGENTS.md`, `docs/`, and `scripts/`
- Workflow updates include action pinning, policy enforcement, YAML lint config changes, and merge gate scripts

## Branch Protection (current)
- Required status checks (strict=true):
  - QC Gate (Required - Basic Sanity)
  - Validate Actions Policy Compliance
- Required PR reviews: 1 (code owners not required; last-push approval disabled)
- Enforce admins: enabled
- Conversation resolution requirement: (not printed; verify)

Observation: Only two checks are enforced as required; other critical workflows (YAML lint, secrets/env alignment, CI monitor) are advisory and can fail post-merge.

## Root Cause Hypothesis
- Merge gate allowed PR to merge because required contexts were green while advisory checks failed.
- Post-merge `workflow_run` triggers surfaced failures on `main`:
  - YAML lint failure in CI Monitor (validate-yaml job)
- Policy coverage gap: not all critical checks are in required contexts for `main`.

## Remediation Plan
1. Branch protection tightening:
   - Add required status checks:
     - CI Monitor (validate-yaml)
     - Env Doc Alignment
     - Secrets Alignment
     - Enforce Terminal Output Policy (if not already in required)
   - Enable `required_conversation_resolution`
   - Consider `require_code_owner_reviews=true` and `require_last_push_approval=true` for high-risk repos
2. Merge gate enforcement:
   - Treat Merge Gate verdict as a single required status check (aggregates QC + Actions Policy + Terminal Policy + YAML lint + alignment checks)
   - Ensure agents use `merge_gate_report.sh` and respect verdict; prohibit bypass
3. Temporary safeguard:
   - Lock direct pushes to `main` (require PR) until protection updates are verified
4. Post-incident follow-up:
   - Audit last 10 merges and runs for similar gaps
   - Document SOP in AGENTS.md (already present) and circulate a training note

## Evidence
- Workflow run (CI Monitor): https://github.com/theangrygamershowproductions/DevOnboarder/actions/runs/20392201562
- Head SHA: `3c0c30c4f50f54edac2dff5d4b1f44ccbf0302ee`
- Latest merges and commits referenced via internal audit

## Acceptance Criteria
- Branch protection updated with expanded required checks on `main`
- Merge Gate status added as a required check (or equivalent single gate)
- Direct pushes to `main` disabled; PR gating verified
- Incident recorded with SOP reinforcement; training note shared

---

Owner: @reesey275  
Labels: governance, ci, security, documentation
