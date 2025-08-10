# AAR System Node.js Environment Setup

## Overview

The AAR (After Action Report) system requires Node.js 22 for proper operation. This directory contains the AAR system's package.json and associated Node.js dependencies.

## Important: Node.js Environment Requirements

**CRITICAL**: Always use Node.js version 22 before running any npm commands in this directory.

### Quick Setup

```bash
# Navigate to AAR directory
cd aar/

# Setup Node.js environment and run npm command
./setup-node-env.sh install

# Or setup environment manually
nvm use 22  # Uses .nvmrc file
npm install
```

### Environment Management

The AAR system includes automatic Node.js environment management:

- **`.nvmrc`**: Specifies Node.js version 22
- **`setup-node-env.sh`**: Automated environment setup script
- **Environment validation**: Ensures correct Node.js version before npm operations

### Usage Examples

```bash
# Install dependencies with environment check
./setup-node-env.sh install

# Run AAR tests with environment check
./setup-node-env.sh run aar:test

# Setup environment only (no npm command)
./setup-node-env.sh

# Manual approach (if you prefer)
nvm use 22
npm install
npm run aar:test
```

### Available Scripts

All AAR system scripts are available via npm:

```bash
npm run aar:render          # Render AAR from JSON to markdown
npm run aar:validate        # Validate AAR JSON files
npm run aar:test            # Test AAR validation
npm run aar:full-test       # Complete AAR system test
npm run aar:ui:install      # Install AAR UI dependencies
npm run aar:ui:dev          # Start AAR UI development server
npm run aar:ui:build        # Build AAR UI for production
```

### Security and Best Practices

- **Never run npm in repository root**: AAR dependencies belong in `aar/` directory
- **Always check Node.js version**: Use `node --version` to verify you're on v22.x
- **Use environment script**: `./setup-node-env.sh` prevents version mismatches
- **Respect .gitignore**: `aar/node_modules/` is automatically excluded from git

### Troubleshooting

**Problem**: "nvm: command not found"

**Solution**: Install nvm or source it manually:

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Or source existing nvm
source ~/.nvm/nvm.sh
```

**Problem**: Wrong Node.js version

**Solution**: Use the environment setup script:

```bash
./setup-node-env.sh
```

**Problem**: npm commands fail with module errors

**Solution**: Ensure you're in the aar/ directory with correct Node.js version:

```bash
cd aar/
nvm use 22
npm install
```

### Integration with DevOnboarder

The AAR system integrates with DevOnboarder's infrastructure:

- **Docker integration**: `npm run aar:stack:up` for containerized deployment
- **CI/CD compatibility**: Environment script works in automated pipelines
- **Root Artifact Guard**: Prevents accidental npm pollution in repository root
- **Quality gates**: All AAR operations respect DevOnboarder's 95% quality threshold

### Migration Notes

This directory was created to contain AAR system dependencies that were previously in the repository root. This change:

- **Prevents root pollution**: No more `./node_modules` in repository root
- **Improves organization**: AAR system self-contained in `aar/` directory
- **Enforces best practices**: Explicit Node.js version management
- **Maintains compatibility**: All existing AAR scripts continue to work
