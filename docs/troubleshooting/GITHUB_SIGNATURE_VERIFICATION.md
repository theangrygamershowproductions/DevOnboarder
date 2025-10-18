---
similarity_group: troubleshooting-troubleshooting

content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---

# GitHub Signature Verification Troubleshooting

## Overview

This guide addresses the common issue where Git shows "Can't check signature: No public key" for GitHub merge commits, even though the commits are properly signed.

## Problem Description

### Symptoms

```bash
$ git log --show-signature
commit 9a16f185... (origin/main, origin/HEAD, main)
gpg: Signature made [date]
gpg:                using RSA key B5690EEEBB952194
gpg: Can't check signature: No public key
Merge: ...

```

### Root Cause

- GitHub automatically signs merge commits with their web-flow GPG key

- Your local GPG keyring doesn't have GitHub's public keys imported

- The commits **are properly signed** - you just can't verify them locally

## Quick Fix

### Immediate Solution

```bash

# Import GitHub's web-flow signing key

gpg --keyserver keys.openpgp.org --recv-keys B5690EEEBB952194

```

### Comprehensive Solution

Use our automated script to import all GitHub signing keys:

```bash

# Run the GitHub GPG key setup script

bash scripts/setup_github_gpg_keys.sh

```

## Verification

After importing the keys, verify the fix:

```bash

# Check that the key is now available

gpg --list-keys B5690EEEBB952194

# Verify a specific commit signature

git show --show-signature <commit-hash>

# Should now show

# gpg: Good signature from "GitHub <noreply@github.com>"

```

## Prevention

### For New Developers

Add to your development setup:

```bash

# As part of initial environment setup

bash scripts/setup_github_gpg_keys.sh

```

### For Team Onboarding

Include in your `.zshrc` or development documentation:

```bash

# Optional: Add to shell startup

if ! gpg --list-keys B5690EEEBB952194 >/dev/null 2>&1; then
    echo "Setting up GitHub GPG keys..."
    bash scripts/setup_github_gpg_keys.sh
fi

```

## Advanced Troubleshooting

### Check What Keys Are Missing

```bash

# Show signature details for recent commits

git log --show-signature --oneline -5

# Look for "Can't check signature: No public key" messages

# Note the key IDs that are missing

```

### Manual Key Import

If the automated script fails:

```bash

# Try different keyservers

gpg --keyserver keyserver.ubuntu.com --recv-keys B5690EEEBB952194
gpg --keyserver pgp.mit.edu --recv-keys B5690EEEBB952194

# Or download directly from GitHub

curl -s https://github.com/web-flow.gpg | gpg --import

```

### Trust Level Warnings

You may still see warnings like:

```text
gpg:  This key is not certified with a trusted signature!

```

This is normal - it means the key is imported but not in your "web of trust." For verification purposes, this is sufficient.

## Understanding GitHub Signing

### When GitHub Signs Commits

- Web interface merges (Merge pull request button)

- Squash and merge operations

- Rebase and merge operations

- Some automated operations

### GitHub's Signing Keys

| Key ID | Purpose | Description |
|--------|---------|-------------|
| B5690EEEBB952194 | Web-flow | Primary merge commit signing |
| 4AEE18F83AFDEB23 | GitHub | General GitHub operations |
| 23AEE39F96BA1C7A | GitHub | Additional signing key |

## Integration with DevOnboarder

### Setup Scripts

The GPG key import is integrated into:

- `scripts/setup_github_gpg_keys.sh` - Standalone setup

- `scripts/setup-env.sh` - May include GPG setup

- Development onboarding documentation

### CI/CD Considerations

For CI environments that need signature verification:

```yaml

# In GitHub Actions

- name: Setup GitHub GPG keys

  run: bash scripts/setup_github_gpg_keys.sh

```

## Common Questions

### Q: Are the commits actually signed

**A:** Yes! The "Can't check signature" message means the signature exists but you don't have the public key to verify it.

### Q: Is this a security issue

**A:** No, this is just a verification limitation. The commits are properly signed by GitHub.

### Q: Why doesn't Git import these keys automatically

**A:** Git doesn't automatically import keys for security reasons. You must explicitly import keys you trust.

### Q: Should I trust GitHub's keys

**A:** For verifying GitHub's own merge commits, yes. These keys are publicly documented and widely used.

## See Also

- [GitHub GPG Signature Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification)

- [DevOnboarder GPG Setup Script](../../scripts/setup_github_gpg_keys.sh)

- [Git Signature Verification Documentation](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)

---

**Last Updated**: 2025-01-27

**Related Issues**: Signature verification, GPG key management, GitHub merge commits
**Solution Status**:  Resolved with automated script
