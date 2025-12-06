# Priority Matrix GPG Signing Status

**Status**: ADVISORY (non-blocking)  
**Created**: 2025-12-04  
**Context**: PR #1901 (SHA pinning migration)  
**Tracked in**: Issue #1904

## Problem Statement

The Priority Matrix Auto-Synthesis workflow is configured to GPG-sign commits using a dedicated bot identity (`PMBOT_GPG_KEY_ID: 9BA7DCDBF5D4DEDD`), but the automation is failing with:

> "Automated GPG signing failed and no fallback commit was detected."

## Root Cause Analysis

### What's Confirmed

1. **Secrets exist but may be invalid**:
   - `PMBOT_GPG_PRIVATE` - exists (created 2025-09-23), base64-encoded GPG private key
   - `PMBOT_GPG_KEY_ID` - exists as variable: `9BA7DCDBF5D4DEDD`
   - `PMBOT_NAME` - exists: "Priority Matrix Bot"
   - `PMBOT_EMAIL` - exists: `priority-matrix@theangrygamershow.com`

2. **Workflow expects**:

   ```bash
   printf '%s\n' "$PMBOT_GPG_PRIVATE" | base64 -d | gpg --batch --import --quiet
   ```

   - Secret should be base64-encoded armored GPG key
   - Import runs with `--quiet` (errors suppressed in logs)
   - If import fails, `git commit -S` will fail with "no secret key"

3. **Current behavior**:
   - Workflow runs but GPG signing fails
   - Bot posts "Manual Action Required" comment
   - No actual blocker to PR merge (advisory only)

### What's Unknown (Investigation Needed)

- **Is the GPG key valid?**
    - Key may be expired (1-year validity common)
    - Key may be corrupted in secret storage
    - Base64 encoding may be incorrect
  
- **Does the key match the key ID?**
    - `PMBOT_GPG_KEY_ID` may not correspond to the key in `PMBOT_GPG_PRIVATE`
    - Key rotation may have happened without updating secrets

## Current Impact: MINIMAL

**Branch Protection Status**: Priority Matrix is **NOT a required check** for main branch.

This means:

- ❌ Workflow failures do **NOT** block PR merges
- ⚠️ Bot comment is a **nag**, not a gate
- ✅ PRs can merge without Priority Matrix synthesis
- 📋 Manual synthesis remains an option when needed

**Verified via**:

```bash
gh api repos/theangrygamershowproductions/DevOnboarder/branches/main/protection \
  --jq '.required_status_checks.contexts[]' | grep -i priority
# Returns: (empty - not in required checks)
```

## Tactical Decision (v3 Scope)

### Option Chosen: **Maintain Advisory Status**

**Rationale**:

1. Priority Matrix is **already non-blocking** - no new risk introduced
2. GPG key troubleshooting is **out of scope** for SHA pinning migration (PR #1901)
3. Manual fallback exists and is documented in workflow comments
4. No user complaints about Priority Matrix being stale
5. Structural fix (BWS/MCP integration) is a v4 infrastructure project

**Policy for v3**:

- Accept Priority Matrix workflow failures as **expected** until GPG key issue resolved
- Use manual synthesis when Priority Matrix updates are actually needed:

  ```bash
  source .venv/bin/activate
  python scripts/synthesize_priority_matrix.py
  git add docs/ agents/ .codex/agents/ *.md
  git commit -S -m "FEAT(docs): manual Priority Matrix field synthesis"
  git push
  ```

- Do **NOT** attempt to "fix" the GPG key during v3 feature freeze
- Document this status for future work

### Options Rejected

**Option 1: Use personal GPG key temporarily**

- ❌ Adds technical debt (key swap later)
- ❌ Blurs bot vs human attribution
- ❌ Out of scope for SHA pinning work

**Option 2: Fix GPG key in GitHub Secrets**

- ❌ Requires key rotation/regeneration
- ❌ Investigation time unknown (key may be expired, corrupted, or mismatched)
- ❌ Not blocking any v3 work

## Structural Solution (v4 Scope)

### Target Architecture: BWS + MCP Auth Stack

**Design Goal**: GPG key lives in Bitwarden, GitHub Actions fetches via MCP, no raw secrets in GitHub.

#### Phase 1: Key Provisioning (BWS)

1. **Verify or regenerate PM Bot GPG key**:

   ```bash
   # Check current key expiry
   gpg --list-keys 9BA7DCDBF5D4DEDD
   
   # If expired or invalid, generate new key
   gpg --quick-generate-key "TAGS Priority Matrix Bot <priority-matrix@theangrygamershow.com>" rsa4096 sign 1y
   
   # Export armored key
   gpg --export-secret-keys --armor <NEW_KEY_ID> > pmbot.gpg
   ```

2. **Store in Bitwarden Secrets Manager**:
   - Item name: `TAGS_PMBOT_GPG`
   - Fields:
     - `armored_key` - contents of `pmbot.gpg` (NOT base64, just armored)
     - `key_id` - GPG key ID/fingerprint
     - `key_expiry` - expiration date for monitoring
   - Project: `cicd-automation` (existing)

#### Phase 2: MCP Bridge Implementation

1. **Expose via BWS MCP Server**:
   - Tool: `get_pmbot_gpg_key()`
   - Auth: Requires `cicd-automation` project access
   - Returns: `{ armored_key, key_id }` only to trusted CI contexts
   - Implementation in `ecosystem/tags-mcp-servers/servers/bitwarden_server/`

2. **Update workflow to use MCP**:

   ```yaml
   - name: Fetch PM Bot GPG key from BWS MCP
     env:
       BWS_MCP_TOKEN: ${{ secrets.BWS_MCP_TOKEN }}
     run: |
       # Call MCP to get ephemeral key
       pmbot_key=$(mcp-cli get-pmbot-gpg-key --auth "$BWS_MCP_TOKEN")
       echo "$pmbot_key" | jq -r '.armored_key' | gpg --batch --import
       
       # Configure git
       key_id=$(echo "$pmbot_key" | jq -r '.key_id')
       git config --global user.signingkey "$key_id"
   ```

3. **Replace GitHub Secrets with MCP token**:
   - Remove: `PMBOT_GPG_PRIVATE` (raw key)
   - Keep: `PMBOT_GPG_KEY_ID`, `PMBOT_NAME`, `PMBOT_EMAIL` (metadata)
   - Add: `BWS_MCP_TOKEN` (MCP auth token, short-lived or rotatable)

#### Phase 3: Enforcement Update

1. **Add MCP contract flag**:

   ```yaml
   env:
     PMBOT_MCP_ENABLED: ${{ vars.PMBOT_MCP_ENABLED || 'false' }}
   ```

2. **Update failure handling**:
   - If `PMBOT_MCP_ENABLED=true` and signing fails → **hard block** (MCP should work)
   - If `PMBOT_MCP_ENABLED=false` and signing fails → **advisory** (legacy mode)

3. **Flip to required after MCP bridge validated**:
   - Once BWS MCP integration tested and stable
   - Update branch protection to include Priority Matrix as required check
   - Set `PMBOT_MCP_ENABLED=true` to enforce MCP contract

## Dependencies

### For Manual Synthesis (Available Now)

- Python virtual environment (`.venv`)
- Personal GPG key configured for signing
- Ability to push to branch

### For Structural Fix (v4)

- `ecosystem/tags-mcp-servers/` BWS MCP server
- MCP CLI tool for GitHub Actions
- Key rotation procedure documented
- BWS project permissions configured
- Testing infrastructure for MCP auth flow

## Testing Checklist (When Fixing)

### Immediate (Manual Synthesis)

- [ ] Activate venv: `source .venv/bin/activate`
- [ ] Run synthesis: `python scripts/synthesize_priority_matrix.py`
- [ ] Verify changes: `git status` shows updated docs
- [ ] Manual commit: `git commit -S -m "FEAT(docs): manual Priority Matrix field synthesis"`
- [ ] Push: `git push`

### Structural (MCP Integration)

- [ ] GPG key stored in BWS with correct metadata
- [ ] BWS MCP server exposes `get_pmbot_gpg_key()` tool
- [ ] GitHub Actions can authenticate to MCP
- [ ] Test workflow can import key and sign commits
- [ ] Key rotation procedure tested (generate new, update BWS, no GitHub changes needed)
- [ ] Branch protection updated to require Priority Matrix check
- [ ] Failure handling switches from advisory to blocking

## Decision Log

| Date       | Decision                                      | Rationale                                |
|------------|-----------------------------------------------|------------------------------------------|
| 2025-12-04 | Maintain advisory status through v3           | Out of scope for SHA pinning migration   |
| 2025-12-04 | Document BWS/MCP structural solution          | Correct long-term architecture           |
| 2025-12-04 | Do NOT attempt GPG key fix during v3 freeze   | Feature freeze discipline                |
| TBD        | Implement BWS MCP integration                 | v4 infrastructure project                |
| TBD        | Rotate GPG key and test MCP flow              | Validation before enforcement            |
| TBD        | Enable Priority Matrix as required check      | After MCP bridge stable                  |

## References

- **Current Workflow**: `.github/workflows/priority-matrix-synthesis.yml`
- **MCP Architecture**: `ecosystem/tags-mcp-servers/MCP_INTEGRATION_FRAMEWORK.md`
- **BWS Integration**: `ecosystem/tags-mcp-servers/servers/bitwarden_server/`
- **Feature Freeze Policy**: `TAGS_V3_FEATURE_FREEZE_2025-11-28.md`
- **Related Issue**: (none yet - will create in v4)

## Next Steps

### For PR #1901 (v3)

- ✅ Accept Priority Matrix advisory failures (current state)
- ✅ Document this decision (this file)
- ✅ Continue with SHA pinning merge gate focus
- ⏭️ Merge PR #1901 without touching Priority Matrix

### For v4 (Infrastructure Phase)

1. Create issue: "INFRA: Migrate Priority Matrix GPG signing to BWS MCP"
2. Verify/rotate PM Bot GPG key
3. Store key in BWS (`TAGS_PMBOT_GPG`)
4. Implement MCP bridge tool (`get_pmbot_gpg_key`)
5. Update workflow to use MCP instead of GitHub Secrets
6. Test key rotation procedure
7. Enable as required check in branch protection
8. Document key maintenance procedures

---

**Status Summary**: Priority Matrix GPG signing is **broken but non-blocking**. Maintaining advisory status through v3 feature freeze per scope discipline. Structural fix via BWS/MCP integration is documented for v4 infrastructure work.
