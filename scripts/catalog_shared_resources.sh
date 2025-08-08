#!/bin/bash
# shellcheck disable=SC2162,SC2002,SC2126,SC2012
# scripts/catalog_shared_resources.sh
# Catalogs shared infrastructure and configuration dependencies for strategic repository split

set -euo pipefail

LOG_FILE="logs/shared_resources_catalog_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Shared Resources Catalog"
echo "===================================="
echo "Cataloging shared infrastructure for strategic repository split assessment"
echo ""

# Database schema and migration dependencies
echo "=== Database Schema Dependencies ==="
echo "Analyzing database models, migrations, and shared schema elements..."

echo "Database Models:"
find src/ -name "models.py" -o -name "*model*.py" 2>/dev/null | head -10 | while read -r file; do
    echo "  - $file"
    grep -n "class.*:" "$file" 2>/dev/null | head -3 | sed 's/^/    /'
done

echo ""
echo "Migration Files:"
find . -name "*migration*" -o -name "*alembic*" 2>/dev/null | head -10

echo ""
echo "Database Configuration:"
grep -r "DATABASE_URL\|SQLALCHEMY_DATABASE_URI\|DB_" . 2>/dev/null | grep -v ".git" | head -5

echo ""

# Configuration file dependencies
echo "=== Shared Configuration Files ==="
echo "Analyzing configuration dependencies across services..."

echo "Environment Configuration:"
find . -name "*.env*" -o -name ".env*" 2>/dev/null | grep -v ".git" | head -10

echo ""
echo "YAML/JSON Configuration:"
find . -name "*.yml" -o -name "*.yaml" -o -name "*.json" 2>/dev/null | \
    grep -E "(config|env|settings)" | grep -v node_modules | head -10

echo ""
echo "Python Configuration Files:"
find . -name "config.py" -o -name "settings.py" -o -name "*config*.py" 2>/dev/null | \
    grep -v ".git" | head -10

echo ""

# Docker and containerization dependencies
echo "=== Docker and Container Dependencies ==="
echo "Analyzing container orchestration and shared infrastructure..."

echo "Docker Configuration Files:"
find . -name "Dockerfile*" -o -name "docker-compose*" 2>/dev/null | head -10

echo ""
echo "Docker services defined:"
if [ -f "docker-compose.ci.yaml" ]; then
    echo "CI Docker Compose Services:"
    grep -E "^\s+[a-zA-Z_-]+:" docker-compose.ci.yaml 2>/dev/null | sed 's/^/  /' | head -10
fi

if [ -f "docker-compose.tags.dev.yaml" ]; then
    echo "Development Docker Compose Services:"
    grep -E "^\s+[a-zA-Z_-]+:" docker-compose.tags.dev.yaml 2>/dev/null | sed 's/^/  /' | head -5
fi

echo ""

# CI/CD workflow dependencies
echo "=== CI/CD Infrastructure Dependencies ==="
echo "Analyzing GitHub Actions workflows and shared automation..."

workflow_count=$(ls .github/workflows/ 2>/dev/null | wc -l)
echo "Total workflows: $workflow_count"

echo ""
echo "Multi-service workflows:"
find .github/workflows/ -name "*.yml" -exec grep -l "frontend\|bot\|auth\|xp\|devonboarder" {} \; 2>/dev/null | \
    head -10 | while read workflow; do
    echo "  - $(basename "$workflow")"
    grep -E "(frontend|bot|auth|xp)" "$workflow" 2>/dev/null | head -2 | sed 's/^/    /'
done

echo ""
echo "Shared CI scripts:"
find scripts/ -name "*.sh" 2>/dev/null | grep -E "(test|build|deploy|ci)" | head -10

echo ""

# Package management and dependencies
echo "=== Package Management Dependencies ==="
echo "Analyzing shared dependencies and version management..."

echo "Python Dependencies:"
if [ -f "pyproject.toml" ]; then
    echo "  - pyproject.toml (main Python dependencies)"
    grep -E "^\[|name\s*=" pyproject.toml 2>/dev/null | head -5 | sed 's/^/    /'
fi

if [ -f "requirements-dev.txt" ]; then
    echo "  - requirements-dev.txt"
    head -5 requirements-dev.txt 2>/dev/null | sed 's/^/    /'
fi

echo ""
echo "Node.js Dependencies:"
find . -name "package.json" -not -path "./node_modules/*" 2>/dev/null | while read pkg; do
    echo "  - $pkg"
    grep -E '"name"|"version"' "$pkg" 2>/dev/null | head -2 | sed 's/^/    /'
done

echo ""
echo "Version Management:"
if [ -f ".tool-versions" ]; then
    echo "  - .tool-versions (language version requirements)"
    cat .tool-versions 2>/dev/null | sed 's/^/    /'
fi

echo ""

# Security and secrets management
echo "=== Security and Secrets Management ==="
echo "Analyzing shared security configurations and secret dependencies..."

echo "Environment Variables:"
grep -r "os.environ\|getenv\|ENV\[" src/ 2>/dev/null | cut -d: -f1 | sort | uniq | head -10 | \
    while read file; do
        echo "  - $file"
    done

echo ""
echo "Secrets and Tokens:"
find . -name "*.py" -exec grep -l "TOKEN\|SECRET\|KEY\|PASSWORD" {} \; 2>/dev/null | \
    grep -v ".git" | head -5 | while read file; do
    echo "  - $file"
    grep -n "TOKEN\|SECRET\|KEY\|PASSWORD" "$file" 2>/dev/null | head -2 | sed 's/^/    /'
done

echo ""

# Shared utilities and libraries
echo "=== Shared Utilities and Libraries ==="
echo "Analyzing shared code dependencies..."

echo "Shared Utility Modules:"
find src/utils/ -name "*.py" 2>/dev/null | head -10 | while read util; do
    echo "  - $util"
done

echo ""
echo "Cross-service imports:"
find src/ -name "*.py" -exec grep -l "from src\." {} \; 2>/dev/null | head -10 | while read file; do
    echo "  - $file"
    grep "from src\." "$file" 2>/dev/null | head -2 | sed 's/^/    /'
done

echo ""

# Documentation and assets
echo "=== Documentation and Shared Assets ==="
echo "Analyzing documentation and asset dependencies..."

echo "Documentation Structure:"
find docs/ -type f 2>/dev/null | head -10 | while read doc; do
    echo "  - $doc"
done

echo ""
echo "Static Assets:"
find . -name "static" -o -name "assets" -o -name "public" 2>/dev/null | \
    grep -v node_modules | head -5

echo ""

# Generate split complexity assessment
echo "=== Split Complexity Assessment ==="
echo "Generating shared resource impact analysis..."

# Count shared resources
db_models=$(find src/ -name "*model*.py" 2>/dev/null | wc -l)
config_files=$(find . -name "*.yml" -o -name "*.yaml" -o -name "*.json" 2>/dev/null | grep -E "(config|env)" | wc -l)
docker_files=$(find . -name "Dockerfile*" -o -name "docker-compose*" 2>/dev/null | wc -l)
ci_workflows=$(ls .github/workflows/ 2>/dev/null | wc -l)
shared_utils=$(find src/utils/ -name "*.py" 2>/dev/null | wc -l)

echo "Shared Resource Summary:"
echo "  Database models: $db_models files"
echo "  Configuration files: $config_files files"
echo "  Docker configurations: $docker_files files"
echo "  CI/CD workflows: $ci_workflows workflows"
echo "  Shared utilities: $shared_utils modules"

echo ""
echo "Split Complexity Factors:"
if [ "$db_models" -gt 5 ]; then
    echo "  - HIGH: Database model coupling ($db_models models)"
else
    echo "  - MEDIUM: Database model coupling ($db_models models)"
fi

if [ "$ci_workflows" -gt 15 ]; then
    echo "  - HIGH: CI/CD workflow complexity ($ci_workflows workflows)"
else
    echo "  - MEDIUM: CI/CD workflow complexity ($ci_workflows workflows)"
fi

if [ "$shared_utils" -gt 10 ]; then
    echo "  - HIGH: Shared utility dependencies ($shared_utils utilities)"
else
    echo "  - LOW: Shared utility dependencies ($shared_utils utilities)"
fi

echo ""
echo "Recommended Split Preparation:"
echo "1. Database: Plan shared schema extraction or service-specific databases"
echo "2. Configuration: Prepare service-specific environment management"
echo "3. CI/CD: Template multi-repo workflow patterns from current unified system"
echo "4. Utilities: Identify utilities to duplicate vs. extract to shared library"
echo "5. Documentation: Plan service-specific documentation structure"

echo ""
echo "Shared resources catalog complete"
echo "Results saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Review shared resource dependencies and coupling"
echo "2. Run service dependency analysis: bash scripts/analyze_service_dependencies.sh"
echo "3. Extract service interfaces: python scripts/extract_service_interfaces.py"
echo "4. Generate split readiness assessment: bash scripts/validate_split_readiness.sh"
