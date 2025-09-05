# Phase 3: Developer Scripts Implementation Plan

## 🎯 **Phase 3 Scope: Developer Utility & Validation Scripts**

### **Priority 1: Development Setup & Environment Scripts** 🛠️

1. **`scripts/dev_setup.sh`** - Development environment initialization
2. **`scripts/setup_automation.sh`** - Automation framework setup
3. **`scripts/setup_tunnel.sh`** - Tunnel configuration setup
4. **`scripts/setup_discord_env.sh`** - Discord environment configuration
5. **`scripts/setup_vscode_integration.sh`** - VS Code development integration

### **Priority 2: Testing & Validation Scripts** 🧪

1. **`scripts/run_tests.sh`** - Comprehensive test execution
2. **`scripts/run_tests_with_logging.sh`** - Enhanced test execution with logging
3. **`scripts/validate_token_architecture.sh`** - Token architecture validation
4. **`scripts/validate_ci_locally.sh`** - Local CI validation
5. **`scripts/validate_pr_checklist.sh`** - PR checklist validation

### **Priority 3: Quality Assurance & Validation Scripts** 📋

1. **`scripts/validate_agents.sh`** - Agent configuration validation
2. **`scripts/validate-bot-permissions.sh`** - Bot permissions validation
3. **`scripts/validate_quality_gates.sh`** - Quality gates validation
4. **`scripts/validate_tunnel_setup.sh`** - Tunnel setup validation
5. **`scripts/quick_validate.sh`** - Quick validation suite

## 🔧 **Token Requirements by Script Category**

### **Development Setup Scripts**

- **Discord Setup**: `DISCORD_BOT_TOKEN`, `DISCORD_CLIENT_SECRET` (Runtime tokens in `.env`)
- **Automation Setup**: May use `gh` CLI for repository setup
- **Tunnel Setup**: `CF_DNS_API_TOKEN`, `TUNNEL_TOKEN` (Runtime tokens in `.env`)

### **Testing & Validation Scripts**

- **Test Runners**: Usually no tokens required, but may need environment setup
- **Token Validation**: Requires access to both `.tokens` and `.env` files for validation
- **CI Validation**: `AAR_TOKEN` for GitHub API access (CI/CD token in `.tokens`)

### **Quality Assurance Scripts**

- **Agent Validation**: No tokens required, file-based validation
- **Bot Permissions**: May use `gh` CLI for permission checks
- **Quality Gates**: Typically no tokens, but may access GitHub API for status

## 🚀 **Implementation Strategy**

### **Pattern: Smart Token Detection**

Phase 3 scripts will use enhanced detection to determine if tokens are needed:

```bash

# Load tokens using Token Architecture v2.1 with developer guidance

if [ -f "scripts/enhanced_token_loader.sh" ]; then
    # shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
    source scripts/enhanced_token_loader.sh
elif [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback for development

if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

# Optional token requirements - only validate if needed by script logic

if command -v require_tokens >/dev/null 2>&1 && [ "${REQUIRES_TOKENS:-}" = "true" ]; then
    if ! require_tokens "$@"; then
        echo "❌ Cannot proceed without required tokens for this operation"
        exit 1
    fi
fi
```

### **Enhanced Features for Developer Scripts**

1. ✅ **Conditional Token Loading** - Only load tokens when actually needed
2. ✅ **Developer-Friendly Errors** - Clear guidance for setup issues
3. ✅ **Environment Detection** - Automatic development vs CI detection
4. ✅ **Validation Reporting** - Comprehensive validation output
5. ✅ **Self-Contained Execution** - No external dependencies required

## 📋 **Implementation Approach**

### **Batch 1: Setup Scripts** (Scripts 1-5)

Focus on development environment initialization scripts that may need tokens for external service setup.

### **Batch 2: Testing Scripts** (Scripts 6-10)

Enhance test runners and validation scripts, with special attention to token architecture validation.

### **Batch 3: Quality Assurance** (Scripts 11-15)

Complete validation and quality assurance scripts with comprehensive reporting.

## 🎯 **Success Metrics for Phase 3**

- ✅ **15 developer scripts enhanced** with smart token loading
- ✅ **Conditional token requirements** - Only load when needed
- ✅ **Developer experience optimized** - Clear setup guidance
- ✅ **CI/CD compatibility maintained** - Works in all environments
- ✅ **Zero breaking changes** - Existing workflows preserved
- ✅ **Comprehensive validation** - Token architecture compliance verified

## 🔄 **Phase 3 vs Previous Phases**

**Phase 1 (Critical)**: 5 scripts - Always need tokens, mission-critical operations
**Phase 2 (Automation)**: 7 scripts - CI/CD automation, always need API access
**Phase 3 (Developer)**: 15 scripts - Variable token needs, developer-focused tools

**Key Difference**: Phase 3 scripts have **conditional token requirements** - they only load tokens when the specific operation requires them, making them more efficient for development workflows.

## 🚀 **Ready to Implement Batch 1: Setup Scripts**

Starting with development environment setup scripts that establish the foundation for local development! 🛠️
