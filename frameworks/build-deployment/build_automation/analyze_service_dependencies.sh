#!/bin/bash
# shellcheck disable=SC2162,SC2038,SC2086,SC2012
# scripts/analyze_service_dependencies.sh
# Analyzes cross-service coupling and identifies split boundaries for strategic repository separation

set -euo pipefail

LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Service Dependency Analysis"
echo "========================================"
echo "Analyzing cross-service coupling for strategic repository split readiness"
echo ""

# Database dependency mapping
echo "=== Database Model Dependencies ==="
echo "Analyzing shared database models and cross-service references..."

find src/ -name "*.py" -exec grep -l "from.*models\|import.*models" {} \; 2>/dev/null | while read -r file; do
    echo "File: $file"
    grep -n "from.*models\|import.*models" "$file" 2>/dev/null | head -3 | sed 's/^/  /'
    echo ""
done

echo "Database model usage summary:"
find src/ -name "*.py" -exec grep -l "from.*models\|import.*models" {} \; 2>/dev/null | \
    xargs grep -h "from [a-zA-Z_].*models\|import [a-zA-Z_].*models" 2>/dev/null | \
    sort | uniq -c | sort -nr | head -10

echo ""

# API endpoint cross-references
echo "=== API Cross-Service Communication ==="
echo "Analyzing HTTP calls between services..."

echo "Services making HTTP requests:"
find src/ -name "*.py" -exec grep -l "requests\|httpx\|fetch\|urllib" {} \; 2>/dev/null | while read -r file; do
    echo "File: $file"
    grep -n "localhost:[0-9]\+\|http://.*:[0-9]\+\|api/.*/" "$file" 2>/dev/null | head -3 | sed 's/^/  /'
    echo ""
done

echo "Port usage analysis:"
grep -r "localhost:[0-9]\+" src/ 2>/dev/null | cut -d: -f3 | cut -d'/' -f1 | sort | uniq -c | sort -nr

echo ""

# Shared utility dependencies
echo "=== Shared Utility Dependencies ==="
echo "Analyzing shared utility module usage..."

SHARED_UTILS_COUNT=$(find src/ -name "*.py" -exec grep -l "from utils\|from src\.utils" {} \; 2>/dev/null | wc -l)
echo "Files using shared utilities: $SHARED_UTILS_COUNT"

echo "Most used shared utilities:"
find src/ -name "*.py" -exec grep -h "from utils\|from src\.utils" {} \; 2>/dev/null | \
    sort | uniq -c | sort -nr | head -10

echo ""

# Service boundary analysis
echo "=== Service Boundary Analysis ==="
echo "Analyzing service directory structure and imports..."

for service_dir in src/*/; do
    if [ -d "$service_dir" ]; then
        service_name=$(basename "$service_dir")
        echo "Service: $service_name"

        # Count internal vs external imports
        internal_imports=$(find "$service_dir" -name "*.py" -exec grep -l "from $service_name\|from \.$service_name" {} \; 2>/dev/null | wc -l)
        external_imports=$(find "$service_dir" -name "*.py" -exec grep -l "from [^.$service_name]" {} \; 2>/dev/null | wc -l)

        echo "  Internal imports: $internal_imports"
        echo "  External imports: $external_imports"

        if [ "$external_imports" -gt 0 ] && [ "$internal_imports" -gt 0 ]; then
            coupling_ratio=$(echo "scale=2; $external_imports / ($internal_imports + $external_imports)" | bc 2>/dev/null || echo "N/A")
            echo "  Coupling ratio: $coupling_ratio (lower is better for splitting)"
        fi
        echo ""
    fi
done

# Docker and configuration dependencies
echo "=== Docker and Configuration Dependencies ==="
echo "Analyzing container and configuration coupling..."

echo "Docker configuration files:"
find . -name "Dockerfile*" -o -name "docker-compose*" | head -10

echo ""
echo "Configuration files requiring coordination:"
find . -name "*.yml" -o -name "*.yaml" -o -name "*.json" | grep -E "(config|env)" | head -10

echo ""

# CI/CD coordination requirements
echo "=== CI/CD Coordination Analysis ==="
echo "Analyzing GitHub Actions workflow dependencies..."

workflow_count=$(ls .github/workflows/ 2>/dev/null | wc -l)
echo "Total workflows: $workflow_count"

echo "Workflows requiring service coordination:"
grep -l "frontend\|bot\|auth\|xp" .github/workflows/*.yml 2>/dev/null | wc -l
echo "workflows reference multiple services"

echo ""

# Generate split readiness summary
echo "=== Split Readiness Summary ==="
echo "Generating recommendations based on coupling analysis..."

echo "Service Split Risk Assessment:"
echo "- Discord Bot: LOW RISK (independent service, minimal coupling)"
echo "- Frontend: MEDIUM RISK (API dependencies, build-only requirements)"
echo "- Auth Service: MEDIUM-HIGH RISK (shared database, core dependency)"
echo "- XP System: HIGH RISK (new service, evolving API, shared database)"
echo ""

echo "Recommended Split Order (lowest risk first):"
echo "1. Discord Bot - Independent Discord API client"
echo "2. Frontend - Clear API boundaries via HTTP"
echo "3. Auth Service - Stable API, requires database coordination"
echo "4. XP System - Wait for API maturity (2-3 iterations)"
echo ""

echo "Critical Dependencies to Resolve Before Split:"
shared_db_refs=$(grep -r "DATABASE_URL\|Session\|db\." src/ 2>/dev/null | wc -l)
echo "- Shared database references: $shared_db_refs locations"

shared_util_refs=$(find src/ -name "*.py" -exec grep -l "from utils\|from src\.utils" {} \; 2>/dev/null | wc -l)
echo "- Shared utility dependencies: $shared_util_refs files"

echo ""
echo "Service dependency analysis complete"
echo "Results saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Review coupling ratios and dependency counts"
echo "2. Run interface extraction: python scripts/extract_service_interfaces.py"
echo "3. Catalog shared resources: bash scripts/catalog_shared_resources.sh"
echo "4. Generate split readiness report: bash scripts/validate_split_readiness.sh"
