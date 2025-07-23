#!/usr/bin/env bash
# filepath: scripts/scan_project_errors.sh
# Comprehensive scan for additional errors in the DevOnboarder project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔍 DevOnboarder Project Error Scanner"
echo "====================================="

# Track errors found
error_count=0
warning_count=0

log_error() {
    echo -e "   ${RED}❌ $1${NC}"
    ((error_count++))
}

log_warning() {
    echo -e "   ${YELLOW}⚠️  $1${NC}"
    ((warning_count++))
}

log_success() {
    echo -e "   ${GREEN}✅ $1${NC}"
}

# 1. Check Python Environment and Dependencies
check_python_environment() {
    echo -e "\n${BLUE}🐍 Python Environment Check${NC}"
    
    # Check Python version
    if command -v python >/dev/null 2>&1; then
        python_version=$(python --version 2>&1 | cut -d' ' -f2)
        if [[ "$python_version" == 3.12* ]]; then
            log_success "Python version: $python_version"
        else
            log_warning "Python version: $python_version (expected 3.12.x)"
        fi
    else
        log_error "Python not found in PATH"
    fi
    
    # Check if package is installable
    if python -c "import devonboarder" 2>/dev/null; then
        log_success "devonboarder package imports successfully"
    else
        log_error "devonboarder package import failed"
    fi
    
    # Check essential Python tools
    for tool in black ruff mypy pytest; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_success "$tool is available"
        else
            log_warning "$tool not found in PATH"
        fi
    done
    
    # Check requirements files
    if [ -f "requirements-dev.txt" ]; then
        log_success "requirements-dev.txt exists"
    else
        log_warning "requirements-dev.txt missing"
    fi
    
    if [ -f "pyproject.toml" ]; then
        log_success "pyproject.toml exists"
    else
        log_error "pyproject.toml missing (required for Python projects)"
    fi
}

# 2. Check Node.js Environment
check_nodejs_environment() {
    echo -e "\n${BLUE}📦 Node.js Environment Check${NC}"
    
    # Check Node.js version
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version | sed 's/v//')
        if [[ "$node_version" == 20* ]]; then
            log_success "Node.js version: $node_version"
        else
            log_warning "Node.js version: $node_version (expected 20.x)"
        fi
    else
        log_error "Node.js not found in PATH"
    fi
    
    # Check npm
    if command -v npm >/dev/null 2>&1; then
        log_success "npm is available"
    else
        log_error "npm not found"
    fi
    
    # Check bot directory
    if [ -d "bot" ]; then
        log_success "bot directory exists"
        if [ -f "bot/package.json" ]; then
            log_success "bot/package.json exists"
            if [ -f "bot/package-lock.json" ]; then
                log_success "bot/package-lock.json exists"
            else
                log_warning "bot/package-lock.json missing (run npm install)"
            fi
        else
            log_error "bot/package.json missing"
        fi
    else
        log_error "bot directory missing"
    fi
    
    # Check frontend directory
    if [ -d "frontend" ]; then
        log_success "frontend directory exists"
        if [ -f "frontend/package.json" ]; then
            log_success "frontend/package.json exists"
            if [ -f "frontend/package-lock.json" ]; then
                log_success "frontend/package-lock.json exists"
            else
                log_warning "frontend/package-lock.json missing (run npm install)"
            fi
        else
            log_error "frontend/package.json missing"
        fi
    else
        log_error "frontend directory missing"
    fi
}

# 3. Check Environment Configuration
check_environment_config() {
    echo -e "\n${BLUE}🔧 Environment Configuration Check${NC}"
    
    # Check .env files
    if [ -f ".env.example" ]; then
        log_success ".env.example exists"
    else
        log_error ".env.example missing"
    fi
    
    if [ -f ".env.dev" ]; then
        log_success ".env.dev exists"
    else
        log_error ".env.dev missing (run bash scripts/bootstrap.sh)"
    fi
    
    # Check service-specific env files
    for service in auth bot frontend; do
        if [ -d "$service" ]; then
            if [ -f "$service/.env.example" ]; then
                log_success "$service/.env.example exists"
            else
                log_warning "$service/.env.example missing"
            fi
            
            if [ -f "$service/.env" ]; then
                log_success "$service/.env exists"
            else
                log_warning "$service/.env missing (copy from .env.example)"
            fi
        fi
    done
}

# 4. Check Docker Configuration
check_docker_config() {
    echo -e "\n${BLUE}🐳 Docker Configuration Check${NC}"
    
    # Check Docker availability
    if command -v docker >/dev/null 2>&1; then
        log_success "Docker is available"
        if docker info >/dev/null 2>&1; then
            log_success "Docker daemon is running"
        else
            log_warning "Docker daemon not running"
        fi
    else
        log_error "Docker not found"
    fi
    
    if command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1; then
        log_success "Docker Compose is available"
    else
        log_error "Docker Compose not found"
    fi
    
    # Check compose files
    if [ -f "docker-compose.ci.yaml" ]; then
        log_success "docker-compose.ci.yaml exists"
    else
        log_error "docker-compose.ci.yaml missing"
    fi
    
    # Check archived compose files
    archived_files=("archive/docker-compose.dev.yaml" "archive/docker-compose.prod.yaml")
    for file in "${archived_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "$file exists"
        else
            log_warning "$file missing"
        fi
    done
}

# 5. Check Documentation and Scripts
check_documentation() {
    echo -e "\n${BLUE}📚 Documentation and Scripts Check${NC}"
    
    # Check essential documentation
    essential_docs=("README.md" "CONTRIBUTING.md" "CODE_OF_CONDUCT.md" "LICENSE.md")
    for doc in "${essential_docs[@]}"; do
        if [ -f "$doc" ]; then
            log_success "$doc exists"
        else
            log_error "$doc missing"
        fi
    done
    
    # Check docs directory
    if [ -d "docs" ]; then
        log_success "docs directory exists"
        if [ -f "docs/README.md" ]; then
            log_success "docs/README.md exists"
        else
            log_warning "docs/README.md missing"
        fi
    else
        log_error "docs directory missing"
    fi
    
    # Check scripts directory
    if [ -d "scripts" ]; then
        log_success "scripts directory exists"
        
        essential_scripts=("bootstrap.sh" "setup-env.sh" "run_tests.sh" "check_docs.sh")
        for script in "${essential_scripts[@]}"; do
            if [ -f "scripts/$script" ]; then
                log_success "scripts/$script exists"
                if [ -x "scripts/$script" ]; then
                    log_success "scripts/$script is executable"
                else
                    log_warning "scripts/$script not executable"
                fi
            else
                log_error "scripts/$script missing"
            fi
        done
    else
        log_error "scripts directory missing"
    fi
}

# 6. Check Git Configuration
check_git_config() {
    echo -e "\n${BLUE}📋 Git Configuration Check${NC}"
    
    # Check if we're in a git repository
    if git rev-parse --git-dir >/dev/null 2>&1; then
        log_success "Git repository detected"
        
        # Check branch
        current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        log_success "Current branch: $current_branch"
        
        # Check remote
        if git remote -v >/dev/null 2>&1; then
            log_success "Git remote configured"
        else
            log_warning "No git remote configured"
        fi
    else
        log_error "Not in a git repository"
    fi
    
    # Check git files
    if [ -f ".gitignore" ]; then
        log_success ".gitignore exists"
        # Check for Potato entry
        if grep -q "Potato.md" .gitignore 2>/dev/null; then
            log_success "Potato.md found in .gitignore"
        else
            log_error "Potato.md missing from .gitignore (required by policy)"
        fi
    else
        log_error ".gitignore missing"
    fi
    
    if [ -f ".pre-commit-config.yaml" ]; then
        log_success ".pre-commit-config.yaml exists"
    else
        log_warning ".pre-commit-config.yaml missing"
    fi
}

# 7. Check CI/CD Configuration
check_cicd_config() {
    echo -e "\n${BLUE}🚀 CI/CD Configuration Check${NC}"
    
    # Check GitHub workflows
    if [ -d ".github/workflows" ]; then
        log_success ".github/workflows directory exists"
        
        if [ -f ".github/workflows/ci.yml" ]; then
            log_success "ci.yml workflow exists"
        else
            log_error "ci.yml workflow missing"
        fi
        
        if [ -f ".github/workflows/auto-fix.yml" ]; then
            log_success "auto-fix.yml workflow exists"
        else
            log_warning "auto-fix.yml workflow missing"
        fi
    else
        log_error ".github/workflows directory missing"
    fi
    
    # Check GitHub templates
    if [ -f ".github/pull_request_template.md" ]; then
        log_success "Pull request template exists"
    else
        log_warning "Pull request template missing"
    fi
    
    # Check issue templates
    if [ -d ".github/ISSUE_TEMPLATE" ]; then
        log_success "Issue templates directory exists"
    else
        log_warning "Issue templates directory missing"
    fi
}

# 8. Check Test Configuration
check_test_config() {
    echo -e "\n${BLUE}🧪 Test Configuration Check${NC}"
    
    # Check test directories
    if [ -d "tests" ]; then
        log_success "tests directory exists"
        
        if [ -f "tests/__init__.py" ]; then
            log_success "tests/__init__.py exists"
        else
            log_warning "tests/__init__.py missing"
        fi
    else
        log_error "tests directory missing"
    fi
    
    # Check test configuration files
    if [ -f "pytest.ini" ]; then
        log_success "pytest.ini exists"
    else
        log_error "pytest.ini missing"
    fi
    
    if [ -f ".coveragerc" ] || grep -q "cov" pytest.ini 2>/dev/null; then
        log_success "Coverage configuration found"
    else
        log_warning "Coverage configuration missing"
    fi
    
    # Check if tests can run
    if [ -d "tests" ] && command -v pytest >/dev/null 2>&1; then
        echo -n "   Testing pytest execution: "
        if pytest --collect-only >/dev/null 2>&1; then
            log_success "pytest can collect tests"
        else
            log_error "pytest collection failed"
        fi
    fi
}

# 9. Run quick syntax checks
check_syntax() {
    echo -e "\n${BLUE}🔍 Syntax Check${NC}"
    
    # Check Python syntax
    if command -v python >/dev/null 2>&1; then
        echo -n "   Python syntax check: "
        python_files=$(find . -name "*.py" -not -path "./venv/*" -not -path "./.venv/*" -not -path "./env/*" 2>/dev/null | head -10)
        
        if [ -n "$python_files" ]; then
            syntax_errors=0
            while IFS= read -r file; do
                if ! python -m py_compile "$file" 2>/dev/null; then
                    ((syntax_errors++))
                fi
            done <<< "$python_files"
            
            if [ $syntax_errors -eq 0 ]; then
                log_success "No Python syntax errors found"
            else
                log_error "$syntax_errors Python syntax errors found"
            fi
        else
            log_warning "No Python files found to check"
        fi
    fi
    
    # Check shell script syntax
    if command -v shellcheck >/dev/null 2>&1; then
        echo -n "   Shell script check: "
        shell_files=$(find scripts -name "*.sh" 2>/dev/null | head -5)
        
        if [ -n "$shell_files" ]; then
            shellcheck_errors=0
            while IFS= read -r file; do
                if ! shellcheck "$file" >/dev/null 2>&1; then
                    ((shellcheck_errors++))
                fi
            done <<< "$shell_files"
            
            if [ $shellcheck_errors -eq 0 ]; then
                log_success "No shellcheck errors found"
            else
                log_warning "$shellcheck_errors shellcheck issues found"
            fi
        else
            log_warning "No shell scripts found to check"
        fi
    else
        log_warning "shellcheck not available for shell script validation"
    fi
}

# Main execution
main() {
    check_python_environment
    check_nodejs_environment
    check_environment_config
    check_docker_config
    check_documentation
    check_git_config
    check_cicd_config
    check_test_config
    check_syntax
    
    # Summary
    echo ""
    echo -e "${BLUE}📊 Error Scan Summary${NC}"
    echo "==============================="
    echo -e "   ${RED}Errors: $error_count${NC}"
    echo -e "   ${YELLOW}Warnings: $warning_count${NC}"
    
    if [ $error_count -eq 0 ]; then
        echo -e "\n${GREEN}🎉 No critical errors found! Project appears healthy.${NC}"
        if [ $warning_count -gt 0 ]; then
            echo -e "${YELLOW}📋 Address the $warning_count warnings when possible.${NC}"
        fi
        return 0
    else
        echo -e "\n${RED}❌ Found $error_count critical errors that need attention.${NC}"
        echo -e "${YELLOW}💡 Run the specific error resolution scripts to address these issues.${NC}"
        return 1
    fi
}

# Run the scan
if main "$@"; then
    exit 0
else
    exit 1
fi
