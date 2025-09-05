# DevOnboarder ShellCheck Best Practices

This document outlines the recommended approach for handling external dependencies in DevOnboarder scripts to balance safety and maintainability.

## Hybrid Approach Overview

### Global Configuration (.shellcheckrc)

- Handles common, well-known external dependencies
- Reduces boilerplate across 60+ Token Architecture scripts
- Covers: .venv/bin/activate, standard project loaders

### Explicit Per-Script Comments

- Used for unusual or script-specific external dependencies
- Provides clear documentation of what external files are being sourced
- Example: `# shellcheck source=external-config.sh disable=SC1091`

## Recommended Pattern for New DevOnboarder Scripts

```bash
# Standard DevOnboarder virtual environment (covered by .shellcheckrc)
source .venv/bin/activate

# Standard project loaders (covered by .shellcheckrc)
source scripts/load_token_environment.sh

# Unusual external dependency (use explicit comment)
# shellcheck source=custom-external.sh disable=SC1091
# source custom-external.sh
```

## Benefits of Hybrid Approach

- Reduces 60+ repetitive comments for standard patterns
- Preserves explicit documentation for unusual dependencies
- Maintains shellcheck safety for legitimate external dependency issues
- Clear project standards for contributors
