# GH_TOKEN Authentication Quick Reference

## 🚨 AUTHENTICATION CONFLICT ISSUE

`GH_TOKEN` breaks interactive GitHub CLI usage due to limited permissions.

## ❌ PROBLEM SYMPTOMS

```bash
# These commands fail with "Bad credentials"
gh pr checks 1184
gh issue list
gh auth status

# Error: HTTP 401: Bad credentials
```

## 🔍 ROOT CAUSE

- `GH_TOKEN` = CI automation token (limited permissions)
- `GITHUB_TOKEN` = Personal access token (full permissions)
- Conflict when `GH_TOKEN` overrides personal authentication

## ✅ QUICK FIXES

### Option 1: Clear GH_TOKEN (Recommended)

```bash
unset GH_TOKEN
gh auth login
```

### Option 2: Override with personal token

```bash
export GITHUB_TOKEN='your_personal_token'
gh pr checks 1184
```

### Option 3: Web interface fallback

```bash
# Visit directly in browser
open https://github.com/theangrygamershowproductions/DevOnboarder/pull/1184
```

## 📋 PREVENTION

- **Never use `GH_TOKEN` for development**
- **Use personal tokens for interactive work**
- **Keep `GH_TOKEN` only for CI environments**
- **Document token usage clearly**

## 🔗 RELATED DOCS

- [Full troubleshooting guide](troubleshooting.md#github-cli-authentication-issues)
- [CI environment variables](ci-env-vars.md)
- [No default token policy](docs/policies/no-default-token-policy.md)
