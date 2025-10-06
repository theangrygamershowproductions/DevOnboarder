---
title: External Toolkit Integration (Public-Safe Patterns)
description: How agents detect optional enhanced capabilities without exposing proprietary tool names or secrets.
author: TAGS DevSecOps
created_at: 2025-10-06
updated_at: 2025-10-06
project: DevOnboarder
related_components: [agents, ci, security, vscode, mcp]
document_type: guide
status: active
visibility: public
canonical_url: https://github.com/theangrygamershowproductions/DevOnboarder/blob/main/docs/agents/external-toolkit-integration.md
codex_scope: tags/devonboarder
codex_role: devsecops
codex_type: policy
codex_runtime: ci+local
tags: [security, detection, agents, mcp]
---

# DevOnboarder External Toolkit Integration Guide

## 🔒 Security Principle

**NEVER expose proprietary toolkit information in public repository**. Agents should detect and use external tools when available without revealing competitive advantages in version control.

## 🎯 Agent Context Loading Strategy

### Environment-Based Detection

Agents should check for external toolkit availability through environment detection:

```bash
# Agent toolkit detection pattern
# Use an environment variable or generic path to avoid exposing proprietary toolkit names
TOOLKIT_PATH="${TOOLKIT_PATH:-$HOME/.external-toolkit}"
if [ -d "$TOOLKIT_PATH" ]; then
    # Enhanced environment detected
    # Use enhanced capabilities without exposing details
    TOOLKIT_AVAILABLE=true
    ENHANCED_MODE=true
else
    # Standard open-source environment
    TOOLKIT_AVAILABLE=false
    ENHANCED_MODE=false
fi
```

### Secure Context Loading

```bash
# Safe toolkit reference pattern
if [ "$TOOLKIT_AVAILABLE" = "true" ]; then
    # Load enhanced capabilities from private toolkit
    source "$HOME/devonboarder-toolkit/core/shell-aliases.sh" 2>/dev/null || true
    # Enable premium features if authorized
    [ -f "$HOME/devonboarder-toolkit/premium/premium-cli.sh" ] && \
        export PREMIUM_FEATURES=true
fi
```

## 🤖 Agent Guidelines

### For AI Agents Working on DevOnboarder

1. **Environment Detection**: Always check for external toolkit availability
2. **Graceful Degradation**: Function fully without external tools
3. **No Exposure**: Never mention specific toolkit capabilities in public repo
4. **Security Boundaries**: Maintain clear separation between public/private features

### Context Loading Commands

```bash
# Check for enhanced toolkit capabilities
if command -v dt-external-pr >/dev/null 2>&1; then
    # Enhanced template system available
    USE_ENHANCED_TEMPLATES=true
fi

# Notion integration detection
if [ -f "$HOME/devonboarder-toolkit/core/notion-integration/README.md" ]; then
    # TAGS-only Notion integration available
    NOTION_INTEGRATION_AVAILABLE=true
fi
```

## 🎛️ Agent Configuration Patterns

### Dynamic Feature Detection

```python
# Python agent pattern for toolkit detection
import os
from pathlib import Path

def detect_toolkit_capabilities():
    """Detect available external toolkit features without exposure."""
    capabilities = {
        'enhanced_templates': False,
        'notion_integration': False,
        'premium_features': False
    }

    toolkit_path = Path.home() / "devonboarder-toolkit"
    if toolkit_path.exists():
        # TAGS environment detected - enable enhanced features
        capabilities['enhanced_templates'] = True

        notion_path = toolkit_path / "core" / "notion-integration"
        if notion_path.exists():
            capabilities['notion_integration'] = True

        premium_path = toolkit_path / "premium"
        if premium_path.exists():
            capabilities['premium_features'] = True

    return capabilities
```

### Conditional Agent Behavior

```bash
# Agent workflow adaptation
case "$ENHANCED_MODE" in
    "true")
        # TAGS internal environment - use advanced features
        echo "Enhanced DevOnboarder capabilities detected"
        # Use advanced automation without exposing specifics
        ;;
    "false")
        # Standard environment - use open-source features only
        echo "Using standard DevOnboarder capabilities"
        ;;
esac
```

## 📋 Implementation Checklist

### For Existing Agents

- [ ] Add environment detection logic
- [ ] Implement graceful degradation
- [ ] Remove any hardcoded external references
- [ ] Test both enhanced and standard modes

### For New Agents

- [ ] Include toolkit detection from start
- [ ] Design for dual-mode operation
- [ ] Maintain security boundaries
- [ ] Document internal vs external capabilities

## 🔍 Security Validation

### What Agents Should NEVER Do

- ❌ Reference specific toolkit file paths in public repo
- ❌ Expose premium feature details in commits
- ❌ Hardcode external tool dependencies
- ❌ Leak competitive advantage information

### What Agents Should Do

- ✅ Detect toolkit availability dynamically
- ✅ Degrade gracefully when tools unavailable
- ✅ Maintain functionality in both modes
- ✅ Use environment-based feature flags

## 🎯 Example Implementation

### Secure Template System Integration

```bash
# Secure external template integration
generate_external_pr_response() {
    local contributor="$1"
    local feature="$2"

    if [ "$TOOLKIT_AVAILABLE" = "true" ] && command -v dt-external-pr >/dev/null 2>&1; then
        # Use enhanced template system (TAGS internal)
        dt-external-pr | sed "s/{CONTRIBUTOR_USERNAME}/$contributor/g" | \
                         sed "s/{FEATURE_DESCRIPTION}/$feature/g"
    else
        # Use standard response (open source)
        cat << EOF
Thanks for your contribution to DevOnboarder, @$contributor!

Your $feature implementation looks interesting. We'll review it according to our security guidelines for external contributors.

Please ensure all tests pass and follow our contribution guidelines.
EOF
    fi
}
```

This approach ensures agents can leverage enhanced capabilities when available while maintaining complete security separation and open-source functionality.

---

**Security Reminder**: This guide itself should remain in the public repository as it demonstrates secure integration patterns without exposing proprietary toolkit details.
