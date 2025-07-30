#!/usr/bin/env bash
# Enhanced test artifact management for DevOnboarder
# Extends the existing centralized logging system with structured temporary session management

set -euo pipefail

# Ensure we're in DevOnboarder root (required pattern)
if [ ! -f ".github/workflows/ci.yml" ]; then
    echo "❌ Please run this script from the DevOnboarder root directory"
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

echo -e "${GREEN}🧪 DevOnboarder Enhanced Test Artifact Manager${NC}"
echo "=============================================="
echo "Extending centralized logging with structured session management"
echo ""

# Enhanced artifact structure within logs/ (extends existing system)
LOGS_DIR="logs"
TEMP_DIR="$LOGS_DIR/temp"
ARCHIVE_DIR="$LOGS_DIR/archive"
COVERAGE_DIR="$LOGS_DIR/coverage"
PYTEST_DIR="$LOGS_DIR/pytest"
CURRENT_SESSION="test_session_$(date +%Y%m%d_%H%M%S)"

# Function to create structured temp area within logs/
init_enhanced_structure() {
    echo -e "${BLUE}📁 Initializing enhanced log structure...${NC}"

    mkdir -p "$TEMP_DIR"
    mkdir -p "$ARCHIVE_DIR"
    mkdir -p "$COVERAGE_DIR"
    mkdir -p "$PYTEST_DIR"

    # Create .gitignore for temp and archive dirs if needed
    if [ ! -f "$TEMP_DIR/.gitignore" ]; then
        echo "*" > "$TEMP_DIR/.gitignore"
        echo "!.gitignore" >> "$TEMP_DIR/.gitignore"
    fi

    if [ ! -f "$ARCHIVE_DIR/.gitignore" ]; then
        echo "*" > "$ARCHIVE_DIR/.gitignore"
        echo "!.gitignore" >> "$ARCHIVE_DIR/.gitignore"
    fi

    echo "✅ Enhanced structure ready in $LOGS_DIR"
}

# Function to setup test session
setup_test_session() {
    echo -e "${BLUE}📁 Setting up test session: $CURRENT_SESSION${NC}"

    init_enhanced_structure

    # Create session-specific directories
    local session_dir="$TEMP_DIR/$CURRENT_SESSION"
    mkdir -p "$session_dir/pytest"
    mkdir -p "$session_dir/coverage"
    mkdir -p "$session_dir/logs"
    mkdir -p "$session_dir/artifacts"
    mkdir -p "$session_dir/node_modules_cache"

    # Export environment variables for test tools
    export PYTEST_CACHE_DIR="$session_dir/pytest/.pytest_cache"
    export COVERAGE_FILE="$session_dir/coverage/.coverage"
    export COVERAGE_DATA_FILE="$session_dir/coverage/.coverage"
    export NODE_ENV="test"
    export CI="true"  # Ensure tools use CI-appropriate settings

    echo "✅ Test session ready: $session_dir"
    echo "   Pytest cache: $PYTEST_CACHE_DIR"
    echo "   Coverage data: $COVERAGE_FILE"
    echo "   Session logs: $session_dir/logs/"

    # Create session info file
    cat > "$session_dir/session_info.json" << EOF
{
  "session_id": "$CURRENT_SESSION",
  "start_time": "$(date -Iseconds)",
  "log_file": "$LOG_FILE",
  "python_version": "$(python --version 2>&1 || echo 'Not available')",
  "node_version": "$(node --version 2>/dev/null || echo 'Not available')",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'Not available')",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'Not available')"
}
EOF

    # Store session dir for cleanup
    echo "$session_dir" > "$TEMP_DIR/.current_session"

    # Create cleanup trap
    trap 'cleanup_test_session '"$session_dir" EXIT
}

# Function to cleanup test session
cleanup_test_session() {
    local session_dir="$1"
    echo -e "${YELLOW}🧹 Cleaning up test session...${NC}"

    if [ -d "$session_dir" ]; then
        # Update session info with end time
        if [ -f "$session_dir/session_info.json" ]; then
            local temp_file
            temp_file=$(mktemp)
            jq '. + {"end_time": "'"$(date -Iseconds)"'", "duration_seconds": '$(( $(date +%s) - $(date -d "$(jq -r '.start_time' "$session_dir/session_info.json")" +%s) ))'}' "$session_dir/session_info.json" > "$temp_file" 2>/dev/null || echo '{"cleanup_time": "'"$(date -Iseconds)"'"}' > "$temp_file"
            mv "$temp_file" "$session_dir/session_info.json"
        fi

        # Archive important artifacts before cleanup
        local archive_name
        archive_name="test_artifacts_$(date +%Y%m%d_%H%M%S).tar.gz"

        # Copy coverage data to persistent location
        if [ -f "$session_dir/coverage/.coverage" ]; then
            cp "$session_dir/coverage/.coverage" "$COVERAGE_DIR/.coverage.$(date +%Y%m%d_%H%M%S)"
            echo "✅ Coverage data archived to $COVERAGE_DIR/"
        fi

        # Copy HTML coverage reports if they exist
        if [ -d "$session_dir/coverage/htmlcov" ]; then
            cp -r "$session_dir/coverage/htmlcov" "$COVERAGE_DIR/htmlcov_$(date +%Y%m%d_%H%M%S)"
            echo "✅ HTML coverage report archived"
        fi

        # Archive test logs to main logs directory
        find "$session_dir/logs" -name "*.log" -exec cp {} "$LOGS_DIR/" \; 2>/dev/null || true

        # Archive pytest artifacts
        if [ -d "$session_dir/pytest" ]; then
            cp -r "$session_dir/pytest" "$PYTEST_DIR/pytest_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        fi

        # Create compressed archive of full session for historical reference
        echo "Creating session archive..."
        tar -czf "$ARCHIVE_DIR/$archive_name" -C "$TEMP_DIR" "$(basename "$session_dir")" 2>/dev/null || {
            echo "⚠️  Archive creation failed, but continuing cleanup"
        }

        # Remove temporary session directory
        rm -rf "$session_dir"
        rm -f "$TEMP_DIR/.current_session"

        echo "✅ Test session cleaned up"
        echo "   Archive: $ARCHIVE_DIR/$archive_name"
        echo "   Coverage: $COVERAGE_DIR/"
        echo "   Logs: $LOGS_DIR/"
    fi
}

# Function to activate virtual environment with validation
activate_virtual_env() {
    if [ ! -d ".venv" ]; then
        echo -e "${RED}❌ Virtual environment not found${NC}"
        echo "Setup required:"
        echo "  python -m venv .venv"
        echo "  source .venv/bin/activate"
        echo "  pip install -e .[test]"
        return 1
    fi

    # shellcheck source=/dev/null
    source .venv/bin/activate

    # Validate environment
    echo -e "${BLUE}🐍 Virtual environment activated${NC}"
    echo "   Python: $(which python)"
    echo "   Pip: $(which pip)"
    echo "   Python version: $(python --version)"

    # Check for required packages
    local missing_packages=()
    python -c "import pytest" 2>/dev/null || missing_packages+=("pytest")
    python -c "import coverage" 2>/dev/null || missing_packages+=("coverage")

    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Missing packages: ${missing_packages[*]}${NC}"
        echo "Installing missing packages..."
        pip install -e '.[test]'
    fi
}

# Function to run tests with enhanced artifact management
run_tests_with_artifacts() {
    echo -e "${BLUE}🧪 Running tests with enhanced artifact management${NC}"

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

    # Run Python tests with session-specific paths
    echo -e "${BLUE}📊 Running Python tests...${NC}"
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

    # Run bot tests if bot directory exists
    if [ -d "bot" ]; then
        echo -e "${BLUE}🤖 Running bot tests...${NC}"
        (
            cd bot
            # Ensure bot dependencies are installed
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
        echo "⚠️  Bot directory not found, skipping bot tests"
    fi

    # Run frontend tests if frontend directory exists
    if [ -d "frontend" ]; then
        echo -e "${BLUE}⚛️  Running frontend tests...${NC}"
        (
            cd frontend
            # Ensure frontend dependencies are installed
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
        echo "⚠️  Frontend directory not found, skipping frontend tests"
    fi

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Generate comprehensive test report
    cat > "$session_dir/artifacts/test-summary.md" << EOF
# Test Execution Summary

**Session**: $CURRENT_SESSION
**Date**: $(date)
**Duration**: ${duration}s ($(date -d@$duration -u +%H:%M:%S))

## Results

- **Python Tests**: $([ "$pytest_exit_code" -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED (exit code: $pytest_exit_code)")
- **Bot Tests**: $([ "$bot_exit_code" -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED (exit code: $bot_exit_code)")
- **Frontend Tests**: $([ "$frontend_exit_code" -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED (exit code: $frontend_exit_code)")

## Coverage Reports

- **Python HTML**: $session_dir/coverage/htmlcov/index.html
- **Python XML**: $session_dir/coverage/coverage.xml
- **Bot Coverage**: $session_dir/coverage/bot/
- **Frontend Coverage**: $session_dir/coverage/frontend/

## Test Artifacts

- **Pytest Results**: $session_dir/artifacts/pytest-results.xml
- **Test Logs**: $session_dir/logs/
- **Session Info**: $session_dir/session_info.json

## Archive Information

After cleanup, artifacts will be available at:
- **Coverage Data**: $COVERAGE_DIR/
- **Session Archive**: $ARCHIVE_DIR/test_artifacts_*.tar.gz
- **Logs**: $LOGS_DIR/
EOF

    # Create JSON summary for CI integration
    cat > "$session_dir/artifacts/test-results.json" << EOF
{
  "session": "$CURRENT_SESSION",
  "timestamp": "$(date -Iseconds)",
  "duration_seconds": $duration,
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
    "test_logs": "$session_dir/logs/"
  }
}
EOF

    echo ""
    echo -e "${GREEN}✅ Test execution complete${NC}"
    echo "📊 Results summary: $session_dir/artifacts/test-summary.md"
    echo "📋 JSON results: $session_dir/artifacts/test-results.json"
    echo "📁 Session directory: $session_dir"
    echo ""

    # Display overall result
    if [ "$pytest_exit_code" -eq 0 ] && [ "$bot_exit_code" -eq 0 ] && [ "$frontend_exit_code" -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        echo "Check logs in: $session_dir/logs/"
        return 1
    fi
}

# Function to clean old test artifacts
clean_old_artifacts() {
    local days="${1:-7}"
    echo -e "${YELLOW}🧹 Cleaning test artifacts older than $days days${NC}"

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

    echo "✅ Cleanup complete"
}

# Function to list current artifacts with sizes
list_artifacts() {
    echo -e "${BLUE}📊 Current Test Artifacts${NC}"
    echo ""

    init_enhanced_structure

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
                    local start_time duration
                    start_time=$(jq -r '.start_time // "unknown"' "$session/session_info.json" 2>/dev/null)
                    duration=$(jq -r '.duration_seconds // "unknown"' "$session/session_info.json" 2>/dev/null)
                    echo "    Start: $start_time, Duration: ${duration}s"
                fi
            fi
        done
    else
        echo "  No active sessions"
    fi

    echo ""
    echo "Archived Sessions:"
    if [ -d "$ARCHIVE_DIR" ]; then
        find "$ARCHIVE_DIR" -name "test_artifacts_*.tar.gz" 2>/dev/null | while read -r archive; do
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
    echo "Pytest Artifacts:"
    if [ -d "$PYTEST_DIR" ]; then
        find "$PYTEST_DIR" -type d -name "pytest_*" 2>/dev/null | head -3 | while read -r pytest_dir; do
            if [ -d "$pytest_dir" ]; then
                local size
                size=$(du -sh "$pytest_dir" 2>/dev/null | cut -f1)
                echo "  - $(basename "$pytest_dir") ($size)"
            fi
        done
    else
        echo "  No pytest artifacts"
    fi

    echo ""
    if [ -d "$LOGS_DIR" ]; then
        local total_size
        total_size=$(du -sh "$LOGS_DIR" 2>/dev/null | cut -f1)
        echo "Total Size: $total_size"
    fi

    echo ""
    echo -e "${GREEN}Enhanced Structure:${NC}"
    echo "  logs/                    # Main centralized location"
    echo "    |-- temp/              # Session-based temporary artifacts"
    echo "    |-- archive/           # Compressed session archives"
    echo "    |-- coverage/          # Persistent coverage data"
    echo "    |-- pytest/           # Pytest artifacts"
    echo "    \`-- *.log              # Regular DevOnboarder logs"
}

# Function to extract and analyze archived session
analyze_archive() {
    local archive_name="$1"
    local archive_path="$ARCHIVE_DIR/$archive_name"

    if [ ! -f "$archive_path" ]; then
        echo -e "${RED}❌ Archive not found: $archive_name${NC}"
        echo "Available archives:"
        find "$ARCHIVE_DIR" -name "*.tar.gz" -exec basename {} \; 2>/dev/null | head -5
        return 1
    fi

    echo -e "${BLUE}📋 Analyzing archive: $archive_name${NC}"

    # Extract to temporary location for analysis
    local temp_extract="/tmp/devonboarder_archive_analysis_$$"
    mkdir -p "$temp_extract"

    tar -xzf "$archive_path" -C "$temp_extract" 2>/dev/null || {
        echo -e "${RED}❌ Failed to extract archive${NC}"
        rm -rf "$temp_extract"
        return 1
    }

    # Find the extracted session directory
    local session_dir
    session_dir=$(find "$temp_extract" -maxdepth 1 -type d -name "test_session_*" | head -1)

    if [ -z "$session_dir" ]; then
        echo -e "${RED}❌ No session directory found in archive${NC}"
        rm -rf "$temp_extract"
        return 1
    fi

    echo "Session Directory: $(basename "$session_dir")"

    # Show session info if available
    if [ -f "$session_dir/session_info.json" ]; then
        echo ""
        echo -e "${GREEN}Session Information:${NC}"
        jq . "$session_dir/session_info.json" 2>/dev/null || cat "$session_dir/session_info.json"
    fi

    # Show test results if available
    if [ -f "$session_dir/artifacts/test-results.json" ]; then
        echo ""
        echo -e "${GREEN}Test Results:${NC}"
        jq . "$session_dir/artifacts/test-results.json" 2>/dev/null || cat "$session_dir/artifacts/test-results.json"
    fi

    # Show summary if available
    if [ -f "$session_dir/artifacts/test-summary.md" ]; then
        echo ""
        echo -e "${GREEN}Test Summary:${NC}"
        cat "$session_dir/artifacts/test-summary.md"
    fi

    # Show available logs
    if [ -d "$session_dir/logs" ]; then
        echo ""
        echo -e "${GREEN}Available Logs:${NC}"
        find "$session_dir/logs" -name "*.log" -exec basename {} \; | while read -r log; do
            echo "  - $log"
        done
    fi

    # Cleanup temporary extraction
    rm -rf "$temp_extract"

    echo ""
    echo "To extract full archive for detailed analysis:"
    echo "  tar -xzf '$archive_path' -C /tmp/"
}

# Main command handling
case "${1:-help}" in
    "setup")
        setup_test_session
        session_dir="$TEMP_DIR/$CURRENT_SESSION"
        echo ""
        echo -e "${GREEN}Session ready for manual testing:${NC}"
        echo "  Session directory: $session_dir"
        echo "  Activate environment: source .venv/bin/activate"
        echo "  PYTEST_CACHE_DIR: $PYTEST_CACHE_DIR"
        echo "  COVERAGE_FILE: $COVERAGE_FILE"
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
    "analyze")
        if [ -z "${2:-}" ]; then
            echo -e "${RED}❌ Archive name required${NC}"
            echo "Usage: $0 analyze <archive_name>"
            echo ""
            echo "Available archives:"
            find "$ARCHIVE_DIR" -name "*.tar.gz" -exec basename {} \; 2>/dev/null | head -5
            exit 1
        fi
        analyze_archive "$2"
        ;;
    "help"|*)
        echo "DevOnboarder Enhanced Test Artifact Manager"
        echo "Extends centralized logging with structured session management"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  setup              - Create new test session for manual testing"
        echo "  run                - Run all tests with full artifact management"
        echo "  clean [days]       - Clean artifacts older than N days (default: 7)"
        echo "  list               - List current artifacts and sizes with details"
        echo "  analyze <archive>  - Extract and analyze archived test session"
        echo ""
        echo "Examples:"
        echo "  $0 run                           # Run tests with full artifact management"
        echo "  $0 setup                         # Setup session for manual testing"
        echo "  $0 clean 3                      # Clean artifacts older than 3 days"
        echo "  $0 list                          # Show current artifact status"
        echo "  $0 analyze test_artifacts_*.tar.gz # Analyze specific archive"
        echo ""
        echo "Directory Structure (extends logs/):"
        echo "  logs/temp/         - Session-based temporary artifacts"
        echo "  logs/archive/      - Compressed session archives"
        echo "  logs/coverage/     - Persistent coverage data"
        echo "  logs/pytest/       - Pytest artifacts"
        echo "  logs/*.log         - Regular DevOnboarder logs"
        ;;
esac
