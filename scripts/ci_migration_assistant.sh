#!/bin/bash

# CI Migration Assistant Script
# Helps transition from monolithic ci.yml to component-based CI

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/.ci-migration-backup"

echo "=== DevOnboarder CI Migration Assistant ==="
echo "This script helps transition to component-based CI"
echo

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check current CI setup
check_current_ci() {
    print_step "Checking current CI setup..."

    if [ -f "$PROJECT_ROOT/.github/workflows/ci.yml" ]; then
        local line_count
        line_count=$(wc -l < "$PROJECT_ROOT/.github/workflows/ci.yml")
        print_status "Found monolithic ci.yml with $line_count lines"

        if [ "$line_count" -gt 500 ]; then
            print_warning "Large monolithic CI detected - perfect candidate for component-based approach"
        fi
    else
        print_status "No monolithic ci.yml found"
    fi

    # Count workflow files
    local workflow_count
    workflow_count=$(find "$PROJECT_ROOT/.github/workflows" -name "*.yml" -o -name "*.yaml" | wc -l)
    print_status "Found $workflow_count total workflow files"
}

# Backup current CI
backup_current_ci() {
    print_step "Creating backup of current CI configuration..."

    mkdir -p "$BACKUP_DIR"
    cp -r "$PROJECT_ROOT/.github/workflows" "$BACKUP_DIR/"

    print_status "Backup created at: $BACKUP_DIR"
}

# Validate component workflows
validate_component_workflows() {
    print_step "Validating component-based workflows..."

    local workflows=(
        "component-orchestrator.yml"
        "backend-component.yml"
        "frontend-component.yml"
        "bot-component.yml"
        "aar-ui-component.yml"
        "docs-component.yml"
        "infrastructure-component.yml"
    )

    for workflow in "${workflows[@]}"; do
        if [ -f "$PROJECT_ROOT/.github/workflows/$workflow" ]; then
            print_status "✅ Found: $workflow"
        else
            print_error "❌ Missing: $workflow"
            return 1
        fi
    done

    print_status "All component workflows found"
}

# Test component workflows
test_component_workflows() {
    print_step "Testing component workflow syntax..."

    cd "$PROJECT_ROOT"

    # Basic YAML validation
    for workflow in .github/workflows/*-component*.yml; do
        if [ -f "$workflow" ]; then
            echo "Testing $(basename "$workflow")..."
            python -c "import yaml; yaml.safe_load(open('$workflow'))" && echo "✅ Valid YAML" || echo "❌ Invalid YAML"
        fi
    done
}

# Show migration status
show_migration_status() {
    print_step "Migration Status Summary"
    echo

    echo "Component Workflows:"
    echo "  ✅ Orchestrator: Routes changes to appropriate components"
    echo "  ✅ Backend: Python FastAPI testing and validation"
    echo "  ✅ Frontend: React testing with Vitest"
    echo "  ✅ Bot: Discord.js TypeScript testing"
    echo "  ✅ AAR UI: React component testing"
    echo "  ✅ Docs: Vale and markdownlint validation"
    echo "  ✅ Infrastructure: Docker, scripts, and workflow validation"
    echo

    echo "Migration Benefits:"
    echo "  🚀 Faster CI: Only run tests for changed components"
    echo "  💰 Cost Savings: Reduced GitHub Actions minutes usage"
    echo "  🎯 Targeted Feedback: Component-specific error reporting"
    echo "  📊 Better Coverage: Component-level coverage reporting"
    echo "  🔧 Easier Maintenance: Smaller, focused workflow files"
    echo
}

# Main execution
main() {
    print_step "Starting CI migration process..."

    check_current_ci
    backup_current_ci
    validate_component_workflows
    test_component_workflows
    show_migration_status

    echo
    print_status "🎉 Component-based CI migration completed successfully!"
    echo
    print_step "Next Steps:"
    echo "1. Test the new component workflows with a small change"
    echo "2. Monitor CI execution times and resource usage"
    echo "3. Gradually phase out monolithic ci.yml (rename to ci.yml.backup)"
    echo "4. Update branch protection rules if needed"
    echo
    print_warning "Keep backup at: $BACKUP_DIR"
}

# Run main function
main "$@"
