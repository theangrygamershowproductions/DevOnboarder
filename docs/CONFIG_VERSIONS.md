# Configuration File Versions

# <!--

File: CONFIG_VERSIONS.md
Version: 1.0.0
Author: DevOnboarder Project
Created: 2025-07-25
Updated: 2025-07-25
Purpose: Track versioning metadata for configuration files
Dependencies: None
DevOnboarder Project Standards: Compliant with copilot-instructions.md
=============================================================================
-->

## Overview

This document tracks versioning and metadata for configuration files across the DevOnboarder project that don't support comment headers (like JSON files) or need centralized documentation.

## Configuration File Registry

### Root Configuration Files

#### package.json (Root)

-   **File Path**: `/package.json`
-   **Version**: 1.0.0
-   **Purpose**: Root project documentation scripts and tools
-   **Key Dependencies**: typedoc, markdownlint-cli2
-   **Node Engine**: >=20
-   **Standards**: DevOnboarder Project Standards compliant
-   **Last Modified**: 2025-07-25
-   **Notes**: Controls documentation generation for bot and frontend APIs

#### pyproject.toml

-   **File Path**: `/pyproject.toml`
-   **Version**: 1.0.0
-   **Purpose**: Python project configuration with DevOnboarder standards
-   **Python Version**: >=3.12
-   **Key Dependencies**: fastapi, SQLAlchemy, pytest, ruff
-   **Coverage Requirement**: 96%+
-   **Linting**: ruff with line-length=88, target-version="py312"
-   **Last Modified**: 2025-07-25
-   **Notes**: Includes development, testing, and production dependencies

### Service-Specific Configuration Files

#### bot/package.json

-   **File Path**: `/bot/package.json`
-   **Version**: 1.0.0
-   **Purpose**: Discord bot dependencies and scripts
-   **Key Dependencies**: discord.js, typescript, jest
-   **Coverage Requirement**: 100%
-   **Standards**: DevOnboarder bot service standards
-   **Last Modified**: 2025-07-25
-   **Notes**: Multi-guild support (dev/prod environments)

#### frontend/package.json

-   **File Path**: `/frontend/package.json`
-   **Version**: 0.1.0
-   **Purpose**: React frontend dependencies and build tools
-   **Key Dependencies**: react, vite, typescript, vitest
-   **Coverage Requirement**: 100% statements, 98.43%+ branches
-   **Standards**: DevOnboarder frontend service standards
-   **Last Modified**: 2025-07-25
-   **Notes**: Vite-based build system with comprehensive testing

### Environment Configuration

#### .env.dev

-   **File Path**: `/.env.dev`
-   **Version**: 1.0.0
-   **Purpose**: Static development environment variables for CI/CD
-   **Security Model**: Non-sensitive static values only, secrets via GitHub Actions
-   **Environment**: Development (Guild ID: 1386935663139749998)
-   **Standards**: DevOnboarder security and CI standards compliant
-   **Last Modified**: 2025-07-25
-   **Notes**: Supports docker-compose CI pipeline, separates static from secret values

#### docker-compose.ci.yaml

-   **File Path**: `/docker-compose.ci.yaml`
-   **Version**: 1.0.0
-   **Purpose**: CI/CD pipeline container orchestration
-   **Services**: backend, bot, frontend, postgres
-   **Standards**: DevOnboarder CI/CD standards
-   **Last Modified**: 2025-07-25
-   **Notes**: Supports comprehensive test suite execution with .env.dev integration

#### docker-compose.tags.dev.yaml

-   **File Path**: `/docker-compose.tags.dev.yaml`
-   **Version**: 1.0.0
-   **Purpose**: TAGS development environment container orchestration
-   **Environment**: Development (Guild ID: 1386935663139749998)
-   **Standards**: DevOnboarder environment standards
-   **Last Modified**: 2025-07-25
-   **Notes**: Multi-service development deployment

#### docker-compose.tags.prod.yaml

-   **File Path**: `/docker-compose.tags.prod.yaml`
-   **Version**: 1.0.0
-   **Purpose**: TAGS production environment container orchestration
-   **Environment**: Production (Guild ID: 1065367728992571444)
-   **Standards**: DevOnboarder environment standards
-   **Last Modified**: 2025-07-25
-   **Notes**: Multi-service production deployment

#### config/devonboarder.config.yml

-   **File Path**: `/config/devonboarder.config.yml`
-   **Version**: 1.0.0
-   **Purpose**: Application configuration settings
-   **Environment Support**: development, production
-   **Standards**: DevOnboarder configuration standards
-   **Last Modified**: 2025-07-25
-   **Notes**: Multi-environment settings and feature flags

## Versioning Standards

### For JSON Files

-   Use standard `package.json` fields: `name`, `version`, `description`, `author`
-   Document metadata in this file instead of inline comments
-   Maintain semantic versioning (MAJOR.MINOR.PATCH)

### For TOML Files

-   Support comment headers for metadata
-   Include DevOnboarder project standards header
-   Track dependencies and tool configurations

### For YAML Files

-   Support comment headers for metadata
-   Include service-specific configuration details
-   Maintain environment-specific settings

## Maintenance Guidelines

### Update Process

1. When modifying any configuration file, update this document
2. Increment version numbers following semantic versioning
3. Document breaking changes and migration notes
4. Ensure compliance with DevOnboarder SOP standards

### Review Requirements

-   All configuration changes require PR review
-   Coverage requirements must be maintained
-   CI/CD pipelines must pass validation
-   Documentation must be updated simultaneously

## Related Documentation

-   [DevOnboarder Project Standards](../.github/copilot-instructions.md)
-   [CI/CD Workflow Documentation](../docs/ci-workflow.md)
-   [Service Architecture Overview](../docs/architecture.svg)

---

**Last Updated**: 2025-07-25
**Maintained By**: DevOnboarder Project Team
**Review Cycle**: Updated with each configuration change
