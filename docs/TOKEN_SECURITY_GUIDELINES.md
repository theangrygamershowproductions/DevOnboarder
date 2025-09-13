---
author: DevOnboarder Team
consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Documentation description needed
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: TOKEN_SECURITY_GUIDELINES.md-docs
status: active
tags:
- documentation
title: Token Security Guidelines
updated_at: '2025-09-12'
visibility: internal
---

# DevOnboarder Token Security Guidelines

## ⚠️ CRITICAL: Token Output Security

## NEVER output full token values to console, logs, or any visible medium

## Security Vulnerabilities

### ❌ **Dangerous Practices**

```bash

# NEVER DO THIS - Security violation

echo "TOKEN=$MY_SECRET_TOKEN"
log "Found token: $FULL_TOKEN_VALUE"
printf "Token: %s\n" "$DISCORD_BOT_TOKEN"

```bash

## ✅ **Secure Practices**

```bash

# Always mask token values

token_name="DISCORD_BOT_TOKEN"
token_value="$DISCORD_BOT_TOKEN"
masked_value="${token_value:0:8}***MASKED***"
echo "$token_name=$masked_value"

```bash

## Token Masking Implementation

### Shell Script Pattern

```bash

# Extract token name and mask the value for security

token_name=$(echo "$token_line" | cut -d'=' -f1)
token_value=$(echo "$token_line" | cut -d'=' -f2-)
masked_value="${token_value:0:8}***MASKED***"
log "  ${token_name}=${masked_value}"

```bash

## Python Pattern

```python
def mask_token(token_value: str) -> str:
    """Mask token value for safe console output."""
    if not token_value:
        return "EMPTY"
    if len(token_value) < 8:
        return "***MASKED***"
    return f"{token_value[:8]}***MASKED***"

# Usage

print(f"Token: {mask_token(os.getenv('SECRET_TOKEN'))}")

```bash

## Exposure Risks

### 🚨 **High Risk Environments**

- **CI/CD Logs**: Stored permanently, accessible to team

- **Terminal History**: May persist in `.zsh_history`, `.bash_history`

- **Log Files**: Written to disk, potentially backed up

- **Screen Sharing**: Visible to meeting participants

- **Screenshots**: Accidental inclusion in documentation

- **Debug Sessions**: IDE console output, debugging tools

### 🔒 **Mitigation Strategies**

1. **Always mask** token values in any output

2. **Use environment variables** instead of hardcoded values

3. **Implement token validation** without exposing values

4. **Clear terminal history** after sensitive operations

5. **Review logs** before sharing or committing

## DevOnboarder Implementation Status

### ✅ **Secured Components**

- `scripts/migrate_cicd_tokens.sh` - Masks token values in dry-run output

- `scripts/migrate_tokens_from_env.sh` - Masks token values in dry-run output

- `scripts/token_loader.py` - Only outputs token names and file paths

### 🔍 **Security Validation**

```bash

# Test security compliance

bash scripts/migrate_cicd_tokens.sh --dry-run | grep -E "github_pat|MTM5|CHANGE_ME"

# Should only show masked values: github_p***MASKED***

# Validate token loader security

python3 scripts/token_loader.py info

# Should never output actual token values

```bash

## Emergency Response

### 🚨 **If Tokens Are Exposed**

1. **Immediately rotate** all exposed tokens

2. **Review access logs** for unauthorized usage

3. **Update systems** with new token values

4. **Audit codebase** for additional exposure points

5. **Document incident** and improve security practices

### 📝 **Prevention Checklist**

- [ ] All scripts mask token values in output

- [ ] CI/CD workflows use secure token handling

- [ ] Documentation examples use placeholder values

- [ ] Team training on token security best practices

- [ ] Regular security audits of token handling code

## Best Practices Summary

### 🎯 **Golden Rules**

1. **NEVER** output full token values anywhere

2. **ALWAYS** mask sensitive data in console output

3. **VALIDATE** tokens without exposing them

4. **USE** environment variables for token storage

5. **AUDIT** regularly for token exposure risks

### 🛡️ **DevOnboarder Standards**

- Token masking pattern: `${token:0:8}***MASKED***`

- Security-first development approach

- Regular security audits of token handling

- Clear separation between CI/CD and runtime tokens

- Enhanced Potato Policy protection for all token files

---

**Last Updated**: September 4, 2025

**Security Level**: CRITICAL
**Compliance**: DevOnboarder Zero Tolerance Security Policy
**Review Required**: Any changes to token handling must include security review
