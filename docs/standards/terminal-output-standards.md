# DevOnboarder Terminal Output Standards

## Overview

DevOnboarder enforces strict terminal output standards to maintain "quiet reliability" and prevent terminal hanging issues. This document outlines the mandatory standards for all scripts and workflows.

## Core Principles

1. **Quiet Reliability**: Clean, consolidated output that doesn't spam the terminal
2. **ASCII Only**: No emojis, Unicode symbols, or special characters that cause hanging
3. **Consistent Formatting**: Standardized color and messaging patterns
4. **User Experience**: Consider both CI and interactive terminal usage

## Terminal Output Policy

### ✅ CORRECT Patterns

```bash
# Single consolidated echo/printf for blocks
echo "Multi-line content here:
- Item 1
- Item 2
- Item 3"

# Individual echo commands for separate messages
echo "Task completed successfully"
echo "Next step: Review changes"

# Color functions for consistent formatting
source scripts/color_utils.sh
green "Success message"
red "Error occurred"
```

### ❌ FORBIDDEN Patterns

```bash
# Multiple sequential printf causing terminal spam
printf "Line 1\n"
printf "Line 2\n"
printf "Line 3\n"

# Raw ANSI escape sequences (inconsistent across scripts)
RED='\033[0;31m'
echo -e "${RED}Error message${NC}"

# Emojis and Unicode (causes terminal hanging)
echo "✅ Task completed"
echo "🚀 Deployment successful"

# Variable expansion in echo (can cause hanging)
echo "Status: $STATUS_VAR"
echo "Result: $(command_output)"
```

## Color Standards

### Centralized Color Functions

All scripts MUST use the centralized color utilities:

```bash
# Source the utility functions
source scripts/color_utils.sh

# Use standardized color functions
red "Error message"           # Errors and failures
green "Success message"       # Success and completion
yellow "Warning message"      # Warnings and cautions
blue "Info message"           # General information
cyan "Debug message"          # Debug output (if DEBUG=1)
purple "Special message"      # Special cases
bold "Section header"         # Emphasis and headers

# High-level semantic functions
error "Something went wrong"      # Formatted error with ERROR: prefix
success "Operation completed"     # Formatted success with SUCCESS: prefix
warn "Potential issue detected"   # Formatted warning with WARNING: prefix
info "Processing step 1"          # Formatted info with INFO: prefix
section "Main Configuration"      # Formatted section header
```

### Migration from Raw ANSI

**Before (WRONG)**:

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${RED}Error occurred${NC}"
```

**After (CORRECT)**:

```bash
source scripts/color_utils.sh
error "Error occurred"
```

## Variable Handling

### Safe Variable Output

```bash
# ✅ CORRECT - Use printf for variables
printf "Status: %s\n" "$STATUS_VAR"
printf "Files processed: %d\n" "$FILE_COUNT"

# ✅ CORRECT - Store command output first

RESULT=$(command_here)
printf "Result: %s\n" "$RESULT"

# ❌ WRONG - Variable expansion in echo
echo "Status: $STATUS_VAR"
echo "Result: $(command_output)"
```

## Script Implementation Standards

### Required Script Header

```bash
#!/bin/bash
# Script name and purpose
# DevOnboarder terminal output compliant

# Source color utilities
source "$(dirname "$0")/color_utils.sh"

# Script implementation follows...
```

### Error Handling Pattern

```bash
# Standard error handling with color functions
if ! command_that_might_fail; then
    error "Command failed with specific details"
    exit 1
fi

success "Command completed successfully"
```

### Section Organization

```bash
# Use section headers for organization
section "Environment Setup"
info "Configuring development environment"

section "Dependency Installation"
info "Installing required packages"

section "Validation"
success "All components configured correctly"
```

## Enforcement

### Pre-commit Validation

The terminal output policy is enforced by:

- `scripts/validate_terminal_output.sh` - Detects violations
- `scripts/validation_summary.sh` - Reports compliance status
- Pre-commit hooks block commits with violations

### CI Integration

All workflows must follow terminal output standards:

- Use color functions instead of raw ANSI
- Apply single consolidated output patterns
- Follow variable handling guidelines

### Script Audit Commands

```bash
# Check for terminal output violations
bash scripts/validate_terminal_output.sh

# Generate compliance summary
bash scripts/validation_summary.sh

# Validate specific script
shellcheck scripts/your_script.sh
```

## Migration Guide

### Step 1: Source Color Utilities

Add to the top of your script:

```bash
source "$(dirname "$0")/color_utils.sh"
```

### Step 2: Replace Raw ANSI

Find and replace patterns:

- `RED='\033[0;31m'` → Remove and use `red()` function
- `echo -e "${RED}message${NC}"` → `red "message"`
- `printf "\033[32m%s\033[0m\n"` → `green "message"`

### Step 3: Consolidate Output

- Multiple `printf` commands → Single `echo` with multi-line content
- Variable expansion in echo → `printf` with format strings
- Command substitution in echo → Store result first, then output

### Step 4: Test Compliance

```bash
# Validate the script follows standards
bash scripts/validate_terminal_output.sh scripts/your_script.sh

# Test in both CI and interactive environments
bash scripts/your_script.sh
```

## Examples

### Complete Example Script

```bash
#!/bin/bash
# Example DevOnboarder compliant script

source "$(dirname "$0")/color_utils.sh"

section "Script Initialization"
info "Starting example process"

# Safe variable handling
FILE_COUNT=5
printf "Processing %d files\n" "$FILE_COUNT"

# Command execution with error handling
if ! some_command; then
    error "Command failed - check permissions"
    exit 1
fi

success "Example script completed successfully"
```

## Troubleshooting

### Common Issues

1. **Terminal Hanging**: Remove all emojis and Unicode characters
2. **Inconsistent Colors**: Use centralized color functions
3. **Command Spam**: Consolidate multiple printf into single echo
4. **Variable Issues**: Use printf format strings for variables

### Quick Fixes

```bash
# Fix raw ANSI usage
source scripts/color_utils.sh
# Replace all echo -e "${COLOR}..." with color functions

# Fix multiple printf spam
# Replace series of printf with single echo block

# Fix emoji usage
# Remove all ✅ ❌ 🚀 etc. and use plain text
```

## Related Documentation

- `docs/TERMINAL_OUTPUT_VIOLATIONS.md` - Comprehensive violation guide
- `scripts/validate_terminal_output.sh` - Validation script
- `scripts/color_utils.sh` - Centralized color functions
- DevOnboarder Copilot Instructions - Terminal output policy details

---

**Remember**: Terminal output standards are enforced with ZERO TOLERANCE to maintain DevOnboarder's "quiet reliability" philosophy.
