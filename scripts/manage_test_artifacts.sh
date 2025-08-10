#!/usr/bin/env bash
# Enhanced test artifact management for DevOnboarder with token governance
# Extends centralized logging system with token compliance validation

set -euo pipefail

# Ensure we're in DevOnboarder root (required pattern)
if [ ! -f ".github/workflows/ci.yml" ]; then
    echo "FAILED Please run this script from the DevOnboarder root directory"
    exit 1
fi

# Use existing centralized logging pattern (mandatory DevOnboarder requirement)
mkdir -p logs
LOG_FILE="logs/test_artifact_management_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}EMOJI DevOnboarder Enhanced Test Artifact Manager${NC}"
echo "=============================================="
echo "Integrating token governance with test artifact management"
echo ""

# Enhanced artifact structure within logs/ (extends existing system)
LOGS_DIR="logs"
TEMP_DIR="$LOGS_DIR/temp"
ARCHIVE_DIR="$LOGS_DIR/archive"
COVERAGE_DIR="$LOGS_DIR/coverage"
PYTEST_DIR="$LOGS_DIR/pytest"
TOKEN_AUDIT_DIR="$LOGS_DIR/token-audit"
CURRENT_SESSION="test_session_$(date +%Y%m%d_%H%M%S)"

# Function to validate token environment with governance integration
validate_token_environment() {
    echo -e "${BLUE}SYMBOL Validating Token Environment & Policy Compliance${NC}"

    # Create token audit directory
    mkdir -p "$TOKEN_AUDIT_DIR"

    # Check for token scope registry
    if [ ! -f ".codex/tokens/token_scope_map.yaml" ]; then
        echo "   WARNING  Token scope registry not found"
        echo "   Creating basic registry structure..."
        mkdir -p .codex/tokens
        echo "# Token scope registry - please configure" > .codex/tokens/token_scope_map.yaml
    else
        echo "   SUCCESS Token scope registry found"
    fi

    # Run token audit if available
    if [ -f "scripts/audit_token_usage.py" ]; then
        echo "   Running token compliance audit..."
        # Activate virtual environment for Python tools
        if [ -d ".venv" ]; then
            # shellcheck source=/dev/null
            source .venv/bin/activate
            python scripts/audit_token_usage.py \
                --project-root . \
                --json-output "$TOKEN_AUDIT_DIR/session-token-audit.json" 2>/dev/null || {
                echo "   WARNING  Token audit encountered issues - check logs"
            }
        else
            echo "   WARNING  Virtual environment not found - skipping Python token audit"
        fi
    fi

    # Check DevOnboarder token hierarchy compliance
    local github_token_status=""
    local token_compliance="compliant"

    if [ -n "${CI_ISSUE_AUTOMATION_TOKEN:-}" ]; then
        github_token_status="SUCCESS CI_ISSUE_AUTOMATION_TOKEN (primary - compliant)"
    elif [ -n "${DIAGNOSTICS_BOT_KEY:-}" ]; then
        github_token_status="SUCCESS DIAGNOSTICS_BOT_KEY (specialized - compliant)"
    elif [ -n "${CI_HEALTH_KEY:-}" ]; then
        github_token_status="SUCCESS CI_HEALTH_KEY (health monitoring - compliant)"
    elif [ -n "${GITHUB_TOKEN:-}" ]; then
        github_token_status="WARNING GITHUB_TOKEN (policy violation - readonly only)"
        token_compliance="violation"
    else
        github_token_status="FAILED No GitHub tokens configured"
        token_compliance="missing"
    fi

    echo "   GitHub Token Status: $github_token_status"

    # Check for specialized tokens for test artifact management
    local specialized_tokens=(
        "DIAGNOSTICS_BOT_KEY:Root Artifact Guard monitoring"
        "CI_HEALTH_KEY:CI pipeline health tracking"
        "AAR_BOT_TOKEN:Test result reporting"
        "CHECKLIST_BOT_TOKEN:PR validation"
    )

    for token_check in "${specialized_tokens[@]}"; do
        IFS=':' read -r token_name description <<< "$token_check"
        if [ -n "${!token_name:-}" ]; then
            echo "   SUCCESS $description configured ($token_name)"
        else
            echo "   WARNING  $description not configured ($token_name)"
        fi
    done

    # Create token environment summary
    cat > "$TOKEN_AUDIT_DIR/token-environment-summary.json" << EOF
{
  "session": "$CURRENT_SESSION",
  "timestamp": "$(date -Iseconds)",
  "token_compliance": "$token_compliance",
  "github_token_status": "$github_token_status",
  "registry_available": $([ -f ".codex/tokens/token_scope_map.yaml" ] && echo "true" || echo "false"),
  "virtual_env_available": $([ -d ".venv" ] && echo "true" || echo "false"),
  "audit_script_available": $([ -f "scripts/audit_token_usage.py" ] && echo "true" || echo "false")
}
EOF

    echo "   CHECKLIST Token environment summary: $TOKEN_AUDIT_DIR/token-environment-summary.json"

    # Overall compliance assessment
    case "$token_compliance" in
        "compliant")
            echo "   LOCKED Overall Token Compliance: SUCCESS COMPLIANT"
            ;;
        "violation")
            echo "   LOCKED Overall Token Compliance: WARNING  POLICY VIOLATIONS DETECTED"
            ;;
        "missing")
            echo "   LOCKED Overall Token Compliance: FAILED CRITICAL TOKENS MISSING"
            ;;
    esac
}

# Function to create structured temp area within logs/ with token awareness
init_enhanced_structure() {
    echo -e "${BLUE}SYMBOL Initializing enhanced log structure with token governance...${NC}"

    mkdir -p "$TEMP_DIR"
    mkdir -p "$ARCHIVE_DIR"
    mkdir -p "$COVERAGE_DIR"
    mkdir -p "$PYTEST_DIR"
    mkdir -p "$TOKEN_AUDIT_DIR"

    # Create .gitignore for temp and archive dirs if needed
    for dir in "$TEMP_DIR" "$ARCHIVE_DIR" "$TOKEN_AUDIT_DIR"; do
        if [ ! -f "$dir/.gitignore" ]; then
            cat > "$dir/.gitignore" << 'EOF'
# Temporary artifacts - exclude from git
*
!.gitignore
EOF
        fi
    done

    # Validate token environment during initialization
    validate_token_environment

    echo "SUCCESS Enhanced structure ready in $LOGS_DIR with token governance"
}

# Function to setup test session with token validation
setup_test_session() {
    echo -e "${BLUE}SYMBOL Setting up test session with token governance: $CURRENT_SESSION${NC}"

    init_enhanced_structure

    # Create session-specific directories
    local session_dir="$TEMP_DIR/$CURRENT_SESSION"
    mkdir -p "$session_dir/pytest"
    mkdir -p "$session_dir/coverage"
    mkdir -p "$session_dir/logs"
    mkdir -p "$session_dir/artifacts"
    mkdir -p "$session_dir/token-audit"

    # Export environment variables for test tools (DevOnboarder virtual env pattern)
    export PYTEST_CACHE_DIR="$session_dir/pytest/.pytest_cache"
    export COVERAGE_FILE="$session_dir/coverage/.coverage"
    export COVERAGE_DATA_FILE="$session_dir/coverage/.coverage"
    export NODE_ENV="test"
    export CI="true"

    echo "SUCCESS Test session ready: $session_dir"
    echo "   Pytest cache: $PYTEST_CACHE_DIR"
    echo "   Coverage data: $COVERAGE_FILE"
    echo "   Session logs: $session_dir/logs/"
    echo "   Token audit: $session_dir/token-audit/"

    # Create comprehensive session info with token governance
    cat > "$session_dir/session_info.json" << EOF
{
  "session_id": "$CURRENT_SESSION",
  "start_time": "$(date -Iseconds)",
  "log_file": "$LOG_FILE",
  "python_version": "$(python --version 2>&1 || echo 'Not available')",
  "node_version": "$(node --version 2>/dev/null || echo 'Not available')",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'Not available')",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'Not available')",
  "token_governance": {
    "policy": "No Default Token Policy v1.0",
    "registry_file": ".codex/tokens/token_scope_map.yaml",
    "audit_enabled": $([ -f "scripts/audit_token_usage.py" ] && echo "true" || echo "false"),
    "virtual_env": "$([ -d ".venv" ] && echo "active" || echo "missing")"
  }
}
EOF

    # Copy current token audit results to session
    if [ -f "$TOKEN_AUDIT_DIR/session-token-audit.json" ]; then
        cp "$TOKEN_AUDIT_DIR/session-token-audit.json" "$session_dir/token-audit/"
    fi

    if [ -f "$TOKEN_AUDIT_DIR/token-environment-summary.json" ]; then
        cp "$TOKEN_AUDIT_DIR/token-environment-summary.json" "$session_dir/token-audit/"
    fi

    # Store session dir for cleanup
    echo "$session_dir" > "$TEMP_DIR/.current_session"

    # Create cleanup trap
    trap 'cleanup_test_session_with_tokens '"$session_dir" EXIT
}

# Function to activate virtual environment with validation (DevOnboarder requirement)
activate_virtual_env() {
    if [ ! -d ".venv" ]; then
        echo -e "${RED}FAILED Virtual environment not found${NC}"
        echo "DevOnboarder requires virtual environment setup:"
        echo "  python -m venv .venv"
        echo "  source .venv/bin/activate"
        echo "  pip install -e .[test]"
        return 1
    fi

    # shellcheck source=/dev/null
    source .venv/bin/activate

    # Validate environment (DevOnboarder pattern)
    echo -e "${BLUE}SYMBOL Virtual environment activated${NC}"
    echo "   Python: $(which python)"
    echo "   Pip: $(which pip)"
    echo "   Python version: $(python --version)"

    # Check for required packages (DevOnboarder dependencies)
    local missing_packages=()
    python -c "import pytest" 2>/dev/null || missing_packages+=("pytest")
    python -c "import coverage" 2>/dev/null || missing_packages+=("coverage")
    python -c "import yaml" 2>/dev/null || missing_packages+=("pyyaml")

    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "${YELLOW}WARNING  Missing packages: ${missing_packages[*]}${NC}"
        echo "Installing missing packages..."
        pip install -e '.[test]'
    fi
}

# Enhanced cleanup function with token audit preservation
cleanup_test_session_with_tokens() {
    local session_dir="$1"
    echo -e "${YELLOW}CLEANUP Cleaning up test session with token governance...${NC}"

    if [ -d "$session_dir" ]; then
        # Update session info with end time and token compliance
        if [ -f "$session_dir/session_info.json" ]; then
            local temp_file
            temp_file=$(mktemp)

            # Use jq if available, otherwise create basic end record
            if command -v jq >/dev/null 2>&1; then
                local start_time_seconds
                start_time_seconds=$(date -d "$(jq -r '.start_time' "$session_dir/session_info.json")" +%s 2>/dev/null || echo "0")
                local duration_seconds=$(($(date +%s) - start_time_seconds))
                jq '. + {"end_time": "'"$(date -Iseconds)"'", "duration_seconds": '"$duration_seconds"'}' \
                    "$session_dir/session_info.json" > "$temp_file"
            else
                echo '{"cleanup_time": "'"$(date -Iseconds)"'", "note": "jq not available for duration calculation"}' > "$temp_file"
            fi

            mv "$temp_file" "$session_dir/session_info.json"
        fi

        # Archive token audit data to persistent location
        if [ -d "$session_dir/token-audit" ]; then
            cp -r "$session_dir/token-audit"/* "$TOKEN_AUDIT_DIR/" 2>/dev/null || true
            echo "SUCCESS Token audit data preserved in $TOKEN_AUDIT_DIR/"
        fi

        # Preserve coverage data (DevOnboarder pattern)
        if [ -f "$session_dir/coverage/.coverage" ]; then
            cp "$session_dir/coverage/.coverage" "$COVERAGE_DIR/.coverage.$(date +%Y%m%d_%H%M%S)"
            echo "SUCCESS Coverage data archived to $COVERAGE_DIR/"
        fi

        # Copy HTML coverage reports if they exist
        if [ -d "$session_dir/coverage/htmlcov" ]; then
            cp -r "$session_dir/coverage/htmlcov" "$COVERAGE_DIR/htmlcov_$(date +%Y%m%d_%H%M%S)"
            echo "SUCCESS HTML coverage report archived"
        fi

        # Archive test logs to main logs directory (centralized logging requirement)
        find "$session_dir/logs" -name "*.log" -exec cp {} "$LOGS_DIR/" \; 2>/dev/null || true

        # Archive pytest artifacts
        if [ -d "$session_dir/pytest" ]; then
            cp -r "$session_dir/pytest" "$PYTEST_DIR/pytest_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        fi

        # Create comprehensive session archive
        local archive_name
        archive_name="test_artifacts_$(date +%Y%m%d_%H%M%S).tar.gz"
        echo "Creating session archive with token governance data..."
        tar -czf "$ARCHIVE_DIR/$archive_name" -C "$TEMP_DIR" "$(basename "$session_dir")" 2>/dev/null || {
            echo "WARNING  Archive creation failed, but continuing cleanup"
        }

        # Remove temporary session directory
        rm -rf "$session_dir"
        rm -f "$TEMP_DIR/.current_session"

        echo "SUCCESS Test session cleaned up with token governance preserved"
        echo "   Archive: $ARCHIVE_DIR/$archive_name"
        echo "   Coverage: $COVERAGE_DIR/"
        echo "   Token audit: $TOKEN_AUDIT_DIR/"
        echo "   Logs: $LOGS_DIR/"
    fi
}

# Enhanced test execution with token governance integration
run_tests_with_artifacts() {
    echo -e "${BLUE}EMOJI Running tests with enhanced artifact management & token governance${NC}"

    setup_test_session
    local session_dir="$TEMP_DIR/$CURRENT_SESSION"

    # Activate virtual environment (DevOnboarder requirement)
    activate_virtual_env || return 1

    local start_time
    start_time=$(date +%s)

    # Initialize result tracking
    local pytest_exit_code=0
    local bot_exit_code=0
    local frontend_exit_code=0
    local token_audit_exit_code=0

    # Run token compliance audit first
    echo -e "${BLUE}SYMBOL Running token compliance audit...${NC}"
    if [ -f "scripts/audit_token_usage.py" ]; then
        python scripts/audit_token_usage.py \
            --project-root . \
            --json-output "$session_dir/token-audit/comprehensive-audit.json" 2>&1 | \
            tee "$session_dir/logs/token-audit.log"
        token_audit_exit_code=${PIPESTATUS[0]}
        echo "Token audit completed with exit code: $token_audit_exit_code"
    else
        echo "WARNING  Token audit script not available"
    fi

    # Run Python tests with session-specific paths (DevOnboarder pattern)
    echo -e "${BLUE}STATS Running Python tests...${NC}"
    python -m pytest \
        --cache-dir="$session_dir/pytest/.pytest_cache" \
        --cov=src \
        --cov-report=html:"$session_dir/coverage/htmlcov" \
        --cov-report=xml:"$session_dir/coverage/coverage.xml" \
        --cov-report=term \
        --junitxml="$session_dir/artifacts/pytest-results.xml" \
        --tb=short \
        tests/ 2>&1 | tee "$session_dir/logs/pytest.log"

    pytest_exit_code=${PIPESTATUS[0]}
    echo "Python tests completed with exit code: $pytest_exit_code"

    # Run bot tests if bot directory exists (Node.js hygiene)
    if [ -d "bot" ]; then
        echo -e "${BLUE}Bot Running bot tests...${NC}"
        (
            cd bot
            # Ensure bot dependencies are installed (DevOnboarder pattern)
            if [ ! -d "node_modules" ]; then
                echo "Installing bot dependencies..."
                npm ci
            fi

            # Create coverage directory for bot
            mkdir -p "../$session_dir/coverage/bot"

            # Run tests with coverage
            npm test -- --coverage --coverageDirectory="../$session_dir/coverage/bot" --passWithNoTests
        ) 2>&1 | tee "$session_dir/logs/bot-tests.log"
        bot_exit_code=${PIPESTATUS[0]}
        echo "Bot tests completed with exit code: $bot_exit_code"
    else
        echo "WARNING  Bot directory not found, skipping bot tests"
    fi

    # Run frontend tests if frontend directory exists (Node.js hygiene)
    if [ -d "frontend" ]; then
        echo -e "${BLUE}SYMBOL  Running frontend tests...${NC}"
        (
            cd frontend
            # Ensure frontend dependencies are installed (DevOnboarder pattern)
            if [ ! -d "node_modules" ]; then
                echo "Installing frontend dependencies..."
                npm ci
            fi

            # Create coverage directory for frontend
            mkdir -p "../$session_dir/coverage/frontend"

            # Run tests with coverage
            npm test -- --coverage --coverageDirectory="../$session_dir/coverage/frontend" --passWithNoTests --watchAll=false
        ) 2>&1 | tee "$session_dir/logs/frontend-tests.log"
        frontend_exit_code=${PIPESTATUS[0]}
        echo "Frontend tests completed with exit code: $frontend_exit_code"
    else
        echo "WARNING  Frontend directory not found, skipping frontend tests"
    fi

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Generate comprehensive test report with token governance
    cat > "$session_dir/artifacts/test-summary.md" << EOF
# DevOnboarder Test Execution Summary with Token Governance

**Session**: $CURRENT_SESSION
**Date**: $(date)
**Duration**: ${duration}s ($(date -d@$duration -u +%H:%M:%S))
**Policy**: No Default Token Policy v1.0

## Token Governance Results

- **Token Audit**: $([ "$token_audit_exit_code" -eq 0 ] && echo "SUCCESS COMPLIANT" || echo "WARNING  ISSUES DETECTED (exit code: $token_audit_exit_code)")
- **Registry Available**: $([ -f ".codex/tokens/token_scope_map.yaml" ] && echo "SUCCESS YES" || echo "FAILED NO")
- **Virtual Environment**: $([ -d ".venv" ] && echo "SUCCESS ACTIVE" || echo "FAILED MISSING")

## Test Results

- **Python Tests**: $([ "$pytest_exit_code" -eq 0 ] && echo "SUCCESS PASSED" || echo "FAILED FAILED (exit code: $pytest_exit_code)")
- **Bot Tests**: $([ "$bot_exit_code" -eq 0 ] && echo "SUCCESS PASSED" || echo "FAILED FAILED (exit code: $bot_exit_code)")
- **Frontend Tests**: $([ "$frontend_exit_code" -eq 0 ] && echo "SUCCESS PASSED" || echo "FAILED FAILED (exit code: $frontend_exit_code)")

## Coverage Reports

- **Python HTML**: $session_dir/coverage/htmlcov/index.html
- **Python XML**: $session_dir/coverage/coverage.xml
- **Bot Coverage**: $session_dir/coverage/bot/
- **Frontend Coverage**: $session_dir/coverage/frontend/

## Token Governance Artifacts

- **Token Audit Results**: $session_dir/token-audit/comprehensive-audit.json
- **Environment Summary**: $session_dir/token-audit/token-environment-summary.json
- **Audit Log**: $session_dir/logs/token-audit.log

## Test Artifacts

- **Pytest Results**: $session_dir/artifacts/pytest-results.xml
- **Test Logs**: $session_dir/logs/
- **Session Info**: $session_dir/session_info.json

## Archive Information

After cleanup, artifacts will be available at:
- **Coverage Data**: $COVERAGE_DIR/
- **Token Audit Data**: $TOKEN_AUDIT_DIR/
- **Session Archive**: $ARCHIVE_DIR/test_artifacts_*.tar.gz
- **Centralized Logs**: $LOGS_DIR/
EOF

    # Create JSON summary for CI integration with token governance
    cat > "$session_dir/artifacts/test-results.json" << EOF
{
  "session": "$CURRENT_SESSION",
  "timestamp": "$(date -Iseconds)",
  "duration_seconds": $duration,
  "token_governance": {
    "policy": "No Default Token Policy v1.0",
    "audit_exit_code": $token_audit_exit_code,
    "registry_available": $([ -f ".codex/tokens/token_scope_map.yaml" ] && echo "true" || echo "false"),
    "virtual_env_active": $([ -d ".venv" ] && echo "true" || echo "false")
  },
  "results": {
    "python": {
      "exit_code": $pytest_exit_code,
      "status": "$([ "$pytest_exit_code" -eq 0 ] && echo "passed" || echo "failed")"
    },
    "bot": {
      "exit_code": $bot_exit_code,
      "status": "$([ "$bot_exit_code" -eq 0 ] && echo "passed" || echo "failed")"
    },
    "frontend": {
      "exit_code": $frontend_exit_code,
      "status": "$([ "$frontend_exit_code" -eq 0 ] && echo "passed" || echo "failed")"
    }
  },
  "artifacts": {
    "coverage_html": "$session_dir/coverage/htmlcov/",
    "coverage_xml": "$session_dir/coverage/coverage.xml",
    "junit_xml": "$session_dir/artifacts/pytest-results.xml",
    "test_logs": "$session_dir/logs/",
    "token_audit": "$session_dir/token-audit/"
  }
}
EOF

    echo ""
    echo -e "${GREEN}SUCCESS Test execution complete with token governance${NC}"
    echo "STATS Results summary: $session_dir/artifacts/test-summary.md"
    echo "CHECKLIST JSON results: $session_dir/artifacts/test-results.json"
    echo "SYMBOL Token audit: $session_dir/token-audit/"
    echo "SYMBOL Session directory: $session_dir"
    echo ""

    # Display overall result including token compliance
    local overall_success=true

    if [ "$pytest_exit_code" -ne 0 ] || [ "$bot_exit_code" -ne 0 ] || [ "$frontend_exit_code" -ne 0 ]; then
        overall_success=false
    fi

    if [ "$token_audit_exit_code" -ne 0 ]; then
        echo -e "${YELLOW}WARNING  Token governance issues detected${NC}"
        echo "Review token audit results in: $session_dir/token-audit/"
    fi

    if $overall_success; then
        echo -e "${GREEN}COMPLETE All tests passed with token governance compliance!${NC}"
        return 0
    else
        echo -e "${RED}FAILED Some tests failed${NC}"
        echo "Check logs in: $session_dir/logs/"
        return 1
    fi
}

# Enhanced artifact listing with token governance information
list_artifacts() {
    echo -e "${BLUE}STATS Current Test Artifacts with Token Governance${NC}"
    echo ""

    init_enhanced_structure

    echo "Token Governance Status:"
    echo "  Registry: $([ -f ".codex/tokens/token_scope_map.yaml" ] && echo "SUCCESS Available" || echo "FAILED Missing")"
    echo "  Audit Script: $([ -f "scripts/audit_token_usage.py" ] && echo "SUCCESS Available" || echo "FAILED Missing")"
    echo "  Virtual Env: $([ -d ".venv" ] && echo "SUCCESS Active" || echo "FAILED Missing")"
    echo ""

    echo "Active Sessions:"
    if [ -d "$TEMP_DIR" ]; then
        find "$TEMP_DIR" -maxdepth 1 -type d -name "test_session_*" 2>/dev/null | while read -r session; do
            if [ -d "$session" ]; then
                local size
                size=$(du -sh "$session" 2>/dev/null | cut -f1)
                local created
                created=$(stat -c %y "$session" 2>/dev/null | cut -d' ' -f1)
                echo "  - $(basename "$session") ($size, created: $created)"

                # Show session details if available
                if [ -f "$session/session_info.json" ]; then
                    local start_time duration token_policy
                    start_time=$(jq -r '.start_time // "unknown"' "$session/session_info.json" 2>/dev/null || echo "unknown")
                    duration=$(jq -r '.duration_seconds // "unknown"' "$session/session_info.json" 2>/dev/null || echo "unknown")
                    token_policy=$(jq -r '.token_governance.policy // "unknown"' "$session/session_info.json" 2>/dev/null || echo "unknown")
                    echo "    Start: $start_time, Duration: ${duration}s"
                    echo "    Token Policy: $token_policy"
                fi
            fi
        done
    else
        echo "  No active sessions"
    fi

    echo ""
    echo "Token Audit Data:"
    if [ -d "$TOKEN_AUDIT_DIR" ]; then
        find "$TOKEN_AUDIT_DIR" -name "*.json" 2>/dev/null | head -5 | while read -r audit_file; do
            if [ -f "$audit_file" ]; then
                local size
                size=$(du -sh "$audit_file" 2>/dev/null | cut -f1)
                echo "  - $(basename "$audit_file") ($size)"
            fi
        done
    else
        echo "  No token audit data"
    fi

    echo ""
    echo "Archived Sessions:"
    if [ -d "$ARCHIVE_DIR" ]; then
        find "$ARCHIVE_DIR" -name "test_artifacts_*.tar.gz" 2>/dev/null | head -5 | while read -r archive; do
            if [ -f "$archive" ]; then
                local size
                size=$(du -sh "$archive" 2>/dev/null | cut -f1)
                local created
                created=$(stat -c %y "$archive" 2>/dev/null | cut -d' ' -f1)
                echo "  - $(basename "$archive") ($size, created: $created)"
            fi
        done
    else
        echo "  No archived sessions"
    fi

    echo ""
    echo "Coverage Data:"
    if [ -d "$COVERAGE_DIR" ]; then
        find "$COVERAGE_DIR" -name ".coverage.*" 2>/dev/null | head -5 | while read -r coverage; do
            if [ -f "$coverage" ]; then
                local size
                size=$(du -sh "$coverage" 2>/dev/null | cut -f1)
                echo "  - $(basename "$coverage") ($size)"
            fi
        done

        # Show HTML coverage directories
        find "$COVERAGE_DIR" -type d -name "htmlcov_*" 2>/dev/null | head -3 | while read -r htmlcov; do
            if [ -d "$htmlcov" ]; then
                local size
                size=$(du -sh "$htmlcov" 2>/dev/null | cut -f1)
                echo "  - $(basename "$htmlcov") ($size)"
            fi
        done
    else
        echo "  No coverage data"
    fi

    echo ""
    if [ -d "$LOGS_DIR" ]; then
        local total_size
        total_size=$(du -sh "$LOGS_DIR" 2>/dev/null | cut -f1)
        echo "Total Size: $total_size"
    fi

    echo ""
    echo -e "${GREEN}Enhanced Structure with Token Governance:${NC}"
    echo "  logs/                    # Main centralized location"
    echo "    |-- temp/              # Session-based temporary artifacts"
    echo "    |-- archive/           # Compressed session archives"
    echo "    |-- coverage/          # Persistent coverage data"
    echo "    |-- pytest/           # Pytest artifacts"
    echo "    |-- token-audit/       # Token governance audit data"
    echo "    \`-- *.log              # Regular DevOnboarder logs"
}

# Enhanced cleanup with token audit preservation
clean_old_artifacts() {
    local days="${1:-7}"
    echo -e "${YELLOW}CLEANUP Cleaning test artifacts older than $days days (preserving token audit data)${NC}"

    init_enhanced_structure

    local cleaned_count=0

    # Clean temp sessions older than specified days
    if [ -d "$TEMP_DIR" ]; then
        find "$TEMP_DIR" -type d -name "test_session_*" -mtime +"$days" -print0 | while IFS= read -r -d '' session; do
            echo "Removing old session: $(basename "$session")"
            rm -rf "$session"
            ((cleaned_count++))
        done
    fi

    # Clean archived artifacts older than specified days
    if [ -d "$ARCHIVE_DIR" ]; then
        find "$ARCHIVE_DIR" -name "test_artifacts_*.tar.gz" -mtime +"$days" -print0 | while IFS= read -r -d '' archive; do
            echo "Removing old archive: $(basename "$archive")"
            rm -f "$archive"
            ((cleaned_count++))
        done
    fi

    # Clean old coverage data (keep recent ones)
    if [ -d "$COVERAGE_DIR" ]; then
        find "$COVERAGE_DIR" -name ".coverage.*" -mtime +"$days" -delete 2>/dev/null || true
        find "$COVERAGE_DIR" -type d -name "htmlcov_*" -mtime +"$days" -exec rm -rf {} + 2>/dev/null || true
    fi

    # Clean old pytest artifacts
    if [ -d "$PYTEST_DIR" ]; then
        find "$PYTEST_DIR" -type d -name "pytest_*" -mtime +"$days" -exec rm -rf {} + 2>/dev/null || true
    fi

    # Clean old token audit data (but keep more recent than other artifacts)
    local token_audit_retention=$((days * 2))  # Keep token audit data twice as long
    if [ -d "$TOKEN_AUDIT_DIR" ]; then
        find "$TOKEN_AUDIT_DIR" -name "*.json" -mtime +"$token_audit_retention" -delete 2>/dev/null || true
        find "$TOKEN_AUDIT_DIR" -name "*.log" -mtime +"$token_audit_retention" -delete 2>/dev/null || true
    fi

    echo "SUCCESS Cleanup complete (token audit data retained for ${token_audit_retention} days)"
}

# Main command handling with token governance
case "${1:-help}" in
    "setup")
        setup_test_session
        session_dir="$TEMP_DIR/$CURRENT_SESSION"
        echo ""
        echo -e "${GREEN}Session ready for manual testing with token governance:${NC}"
        echo "  Session directory: $session_dir"
        echo "  Activate environment: source .venv/bin/activate"
        echo "  PYTEST_CACHE_DIR: $PYTEST_CACHE_DIR"
        echo "  COVERAGE_FILE: $COVERAGE_FILE"
        echo "  Token audit: $session_dir/token-audit/"
        ;;
    "run")
        run_tests_with_artifacts
        ;;
    "clean")
        clean_old_artifacts "${2:-7}"
        ;;
    "list")
        list_artifacts
        ;;
    "validate-tokens")
        init_enhanced_structure
        validate_token_environment
        echo ""
        echo -e "${GREEN}Token validation complete${NC}"
        echo "Results available in: $TOKEN_AUDIT_DIR/"
        ;;
    "help"|*)
        echo "DevOnboarder Enhanced Test Artifact Manager with Token Governance"
        echo "Extends centralized logging with structured session management and token compliance"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  setup                 - Create new test session for manual testing"
        echo "  run                   - Run all tests with full artifact management & token governance"
        echo "  clean [days]          - Clean artifacts older than N days (default: 7)"
        echo "  list                  - List current artifacts and sizes with token governance status"
        echo "  validate-tokens       - Run standalone token governance validation"
        echo ""
        echo "Token Governance Features:"
        echo "  • No Default Token Policy enforcement"
        echo "  • Token scope registry validation"
        echo "  • Virtual environment compliance checking"
        echo "  • Centralized token audit logging"
        echo ""
        echo "Examples:"
        echo "  $0 run                    # Run tests with full token governance"
        echo "  $0 validate-tokens        # Check token compliance only"
        echo "  $0 setup                  # Setup session for manual testing"
        echo "  $0 clean 3               # Clean artifacts older than 3 days"
        echo ""
        echo "Directory Structure (extends logs/ with token governance):"
        echo "  logs/temp/               - Session-based temporary artifacts"
        echo "  logs/archive/            - Compressed session archives"
        echo "  logs/coverage/           - Persistent coverage data"
        echo "  logs/pytest/             - Pytest artifacts"
        echo "  logs/token-audit/        - Token governance audit data"
        echo "  logs/*.log               - Regular DevOnboarder logs"
        ;;
esac
