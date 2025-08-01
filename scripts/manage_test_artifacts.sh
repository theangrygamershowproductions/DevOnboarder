#!/usr/bin/env bash
# Enhanced test artifact management for DevOnboarder with token governance

set -euo pipefail

if [ ! -f ".github/workflows/ci.yml" ]; then
    echo "❌ Please run this script from the DevOnboarder root directory"
    exit 1
fi

mkdir -p logs
LOG_FILE="logs/test_artifact_management_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

LOGS_DIR="logs"
TEMP_DIR="$LOGS_DIR/temp"
ARCHIVE_DIR="$LOGS_DIR/archive"
COVERAGE_DIR="$LOGS_DIR/coverage"
PYTEST_DIR="$LOGS_DIR/pytest"
TOKEN_AUDIT_DIR="$LOGS_DIR/token-audit"
CURRENT_SESSION="test_session_$(date +%Y%m%d_%H%M%S)"

validate_token_environment() {
    mkdir -p "$TOKEN_AUDIT_DIR"
    if [ ! -f ".codex/tokens/token_scope_map.yaml" ]; then
        mkdir -p .codex/tokens
        echo "# Token scope registry - please configure" > .codex/tokens/token_scope_map.yaml
        echo "⚠️  Token scope registry not found" >&2
    fi
    if [ ! -f "scripts/audit_token_usage.py" ]; then
        echo "⚠️  Warning: scripts/audit_token_usage.py not found. Skipping token audit." >&2
        return
    fi
    if [ -d ".venv" ]; then
        source .venv/bin/activate
        python scripts/audit_token_usage.py --project-root . --json-output "$TOKEN_AUDIT_DIR/session-token-audit.json"
    else
        echo "❌ Virtual environment not found. Unable to run token audit." >&2
    fi
}

init_structure() {
    mkdir -p "$TEMP_DIR" "$ARCHIVE_DIR" "$COVERAGE_DIR" "$PYTEST_DIR" "$TOKEN_AUDIT_DIR"
    for d in "$TEMP_DIR" "$ARCHIVE_DIR" "$TOKEN_AUDIT_DIR"; do
        [ -f "$d/.gitignore" ] || printf "*\n!.gitignore\n" > "$d/.gitignore"
    done
    validate_token_environment
}

setup_session() {
    init_structure
    SESSION_DIR="$TEMP_DIR/$CURRENT_SESSION"
    mkdir -p "$SESSION_DIR/pytest" "$SESSION_DIR/coverage" "$SESSION_DIR/logs" "$SESSION_DIR/artifacts" "$SESSION_DIR/token-audit"
    export PYTEST_CACHE_DIR="$SESSION_DIR/pytest/.pytest_cache"
    export COVERAGE_FILE="$SESSION_DIR/coverage/.coverage"
    export NODE_ENV="test"
    echo "$SESSION_DIR" > "$TEMP_DIR/.current_session"
    trap 'cleanup_session "$SESSION_DIR"' EXIT
}

activate_env() {
    if [ ! -d ".venv" ]; then
        echo "❌ Virtual environment not found" >&2
        return 1
    fi
    source .venv/bin/activate
}

run_tests() {
    setup_session
    SESSION_DIR="$TEMP_DIR/$CURRENT_SESSION"
    if activate_env; then
        python -m pytest --cache-dir="$SESSION_DIR/pytest/.pytest_cache" \
            --cov=src --cov-report=term --junitxml="$SESSION_DIR/artifacts/pytest.xml" tests/ | tee "$SESSION_DIR/logs/pytest.log"
    else
        return 1
    fi
}

cleanup_session() {
    local d="$1"
    [ -d "$d" ] || return
    if [ -f "$d/coverage/.coverage" ]; then
        cp "$d/coverage/.coverage" "$COVERAGE_DIR/.coverage.$CURRENT_SESSION"
    fi
    tar -czf "$ARCHIVE_DIR/test_artifacts_$CURRENT_SESSION.tar.gz" -C "$TEMP_DIR" "$(basename "$d")" || true
    rm -rf "$d" "$TEMP_DIR/.current_session"
}

case "${1:-run}" in
    run)
        run_tests
        ;;
    clean)
        init_structure
        find "$ARCHIVE_DIR" -name '*.tar.gz' -mtime +7 -delete
        ;;
    list)
        init_structure
        ls -l "$ARCHIVE_DIR" | head
        ;;
    validate)
        init_structure
        ;;
    *)
        echo "Usage: $0 [run|clean|list|validate]" >&2
        ;;
esac
