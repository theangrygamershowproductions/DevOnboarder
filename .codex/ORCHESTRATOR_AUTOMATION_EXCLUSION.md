# Orchestrator Automation Exclusion Notice

## ⚠️ CRITICAL: Orchestrator Folder Protection

**ATTENTION ALL AUTOMATED SYSTEMS AND AGENTS:**

The `.codex/orchestrator/` directory and its contents are **STRICTLY OFF-LIMITS** to automated modifications.

### 🚫 PROHIBITED ACTIONS

- **NO automated file modifications** in `.codex/orchestrator/`
- **NO automated configuration changes** to `config.yml`
- **NO automated secret management** in orchestrator directory
- **NO external agent access** to orchestrator configurations
- **NO bulk operations** affecting orchestrator files

### ✅ REQUIRED PROCEDURES

1. **Human Oversight Required**: All changes must be reviewed by TAGS Engineering
2. **Manual Approval Process**: No automated merges for orchestrator changes
3. **Security Review**: All modifications require security assessment
4. **Documentation Updates**: Changes must be documented in After-Action Reports

### 🔒 SECURITY RATIONALE

The orchestrator configuration contains:

- Private routing rules and agent configurations
- Security-sensitive permission matrices
- Internal organizational policies
- Strategic automation decisions

### 📋 ENFORCEMENT MECHANISMS

- **Git Protection**: Listed in `.gitignore` for privacy
- **Bot Permissions**: Protected paths in `.codex/bot-permissions.yaml`
- **Internal Marker**: `.internal` file marking private status
- **Access Control**: TAGS Engineering Team access only

### 🎯 COMPLIANCE REQUIREMENT

**All agents, bots, and automated systems MUST respect these restrictions.**

Violation of orchestrator folder protection constitutes a security policy breach requiring immediate escalation to project maintainers.

---

**Established**: August 9, 2025
**Authority**: TAGS Engineering Team
**Status**: ACTIVE ENFORCEMENT
