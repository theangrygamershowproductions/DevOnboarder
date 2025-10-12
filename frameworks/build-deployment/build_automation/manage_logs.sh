#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Log management utility for DevOnboarder
set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

LOGS_DIR="logs"
DAYS_TO_KEEP=7
DRY_RUN=false

usage() {
    cat << EOF
Usage: $0 [OPTIONS] COMMAND

Commands:
    clean       Remove old log files (older than $DAYS_TO_KEEP days)
    smart-clean Clean temporary artifacts but preserve important logs
    pre-build   Clean build-specific artifacts before CI (aggressive)
    pre-run     Clean ALL test artifacts for fresh diagnosis (aggressive)
    purge       Remove ALL log files (use with caution)
    list        List all log files with sizes
    archive     Create timestamped archive of current logs
    cache       Manage cache directories in logs/

Cache subcommands:
    cache list      List all cache directories with sizes
    cache clean     Clean cache directories older than $DAYS_TO_KEEP days
    cache size      Show cache size analysis
    cache purge     Remove all cache directories

Options:
    -d, --days DAYS     Number of days to keep logs (default: $DAYS_TO_KEEP)
    -n, --dry-run       Show what would be done without actually doing it
    -h, --help          Show this help message

Examples:
    $0 clean                    # Remove logs older than 7 days
    $0 smart-clean              # Clean temporary artifacts, preserve important logs
    $0 pre-build                # Clean build artifacts before CI
    $0 pre-run                  # Clean ALL test artifacts for fresh run
    $0 --days 3 clean          # Remove logs older than 3 days
    $0 --dry-run purge         # Show what would be purged
    $0 list                    # List all log files
    $0 archive                 # Create archive of current logs
    $0 cache list              # List cache directories
    $0 cache clean             # Clean old cache directories

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--days)
            DAYS_TO_KEEP="$2"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        clean|smart-clean|pre-build|pre-run|purge|list|archive|cache)
            COMMAND="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ -z "${COMMAND:-}" ]; then
    echo "Error: No command specified" >&2
    usage >&2
    exit 1
fi

# Ensure logs directory exists
mkdir -p "$LOGS_DIR"

list_logs() {
    echo "📂 Log files in $LOGS_DIR:"
    if [ -d "$LOGS_DIR" ] && [ "$(ls -A "$LOGS_DIR" 2>/dev/null)" ]; then
        # Use find instead of ls | grep to avoid shellcheck warning
        find "$LOGS_DIR" -maxdepth 1 -type f -exec ls -lah {} \;
        echo ""
        report "Total size: $(du -sh "$LOGS_DIR" | cut -f1)"
    else
        echo "   (no log files found)"
    fi
}

clean_pytest_artifacts() {
    echo "Cleaning pytest temporary directories and test artifacts..."

    if [ ! -d "$LOGS_DIR" ]; then
        return 0
    fi

    # Remove specific pytest-of-creesey directory
    if [ -d "$LOGS_DIR/pytest-of-creesey" ]; then
        echo "   Removing: $LOGS_DIR/pytest-of-creesey/"
        rm -rf "$LOGS_DIR/pytest-of-creesey"
        echo "   pytest-of-creesey cleaned"
    fi

    # Find pytest temporary directories (pytest-of-*)
    pytest_dirs=$(find "$LOGS_DIR" -type d -name "pytest-of-*" 2>/dev/null || true)

    if [ -n "$pytest_dirs" ]; then
        echo "   Additional pytest directories to remove:"
        echo "$pytest_dirs" | while read -r dir; do
            echo "     - $dir"
        done

        if [ "$DRY_RUN" = "false" ]; then
            echo "$pytest_dirs" | xargs rm -rf
            echo "   Cleaned $(echo "$pytest_dirs" | wc -l) pytest directories"
        else
            echo "   DRY RUN: Would remove $(echo "$pytest_dirs" | wc -l) pytest directories"
        fi
    else
        echo "   No pytest directories found"
    fi

    # Clean ALL previous test artifacts for clean diagnosis (not just old ones)
    if [ "$DRY_RUN" = "false" ]; then
        echo "   Cleaning ALL previous test artifacts for clean diagnosis..."
        # Remove all timestamped log files from previous runs
        find "$LOGS_DIR" -name "*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].log" -delete 2>/dev/null || true
        # Remove coverage artifacts
        find "$LOGS_DIR" -name ".coverage*" -delete 2>/dev/null || true
        find "$LOGS_DIR" -name "coverage.xml" -delete 2>/dev/null || true
        rm -rf "$LOGS_DIR/htmlcov/" 2>/dev/null || true
        # Remove validation artifacts
        find "$LOGS_DIR" -name "validation_*.log" -delete 2>/dev/null || true
        # Remove temporary database files
        find "$LOGS_DIR" -name "tmp*.db" -delete 2>/dev/null || true
        remaining_files=$(find "$LOGS_DIR" -type f 2>/dev/null | wc -l)
        echo "   ALL test artifacts cleaned ($remaining_files files remaining)"
    else
        echo "   DRY RUN: Would clean ALL test artifacts"
    fi
}

# Clean up build-specific artifacts before CI runs.
# Removes dashboard execution logs and coverage artifacts from the logs directory.
# This function is typically used in CI pipelines to ensure a clean build environment.
# Respects the DRY_RUN flag to show actions without performing them.
clean_build_artifacts() {
    echo "Cleaning build-specific artifacts for CI..."

    if [ ! -d "$LOGS_DIR" ]; then
        echo "   No logs directory found"
        return 0
    fi

    # Remove dashboard execution logs (generated during builds)
    dashboard_count=$(find "$LOGS_DIR" -name "dashboard_execution_*.log" 2>/dev/null | wc -l)
    if [ "$dashboard_count" -gt 0 ]; then
        echo "   Removing $dashboard_count dashboard execution logs..."
        if [ "$DRY_RUN" = "false" ]; then
            find "$LOGS_DIR" -name "dashboard_execution_*.log" -delete 2>/dev/null || true
            echo "   Dashboard execution logs cleaned"
        else
            echo "   DRY RUN: Would remove $dashboard_count dashboard execution logs"
        fi
    fi

    # Remove coverage artifacts
    coverage_count=$(find "$LOGS_DIR" -name ".coverage*" -o -name "coverage.xml" 2>/dev/null | wc -l)
    if [ "$coverage_count" -gt 0 ]; then
        echo "   Removing $coverage_count coverage artifacts..."
        if [ "$DRY_RUN" = "false" ]; then
            find "$LOGS_DIR" -name ".coverage*" -delete 2>/dev/null || true
            find "$LOGS_DIR" -name "coverage.xml" -delete 2>/dev/null || true
            rm -rf "$LOGS_DIR/htmlcov/" 2>/dev/null || true
            echo "   Coverage artifacts cleaned"
        else
            echo "   DRY RUN: Would remove $coverage_count coverage artifacts"
        fi
    fi

    # Remove temporary database files
    temp_db_count=$(find "$LOGS_DIR" -name "tmp*.db" -o -name "test.db" 2>/dev/null | wc -l)
    if [ "$temp_db_count" -gt 0 ]; then
        echo "   Removing $temp_db_count temporary database files..."
        if [ "$DRY_RUN" = "false" ]; then
            find "$LOGS_DIR" -name "tmp*.db" -delete 2>/dev/null || true
            find "$LOGS_DIR" -name "test.db" -delete 2>/dev/null || true
            echo "   Temporary database files cleaned"
        else
            echo "   DRY RUN: Would remove $temp_db_count temporary database files"
        fi
    fi

    # Remove pytest directories
    pytest_count=$(find "$LOGS_DIR" -type d -name "pytest-of-*" 2>/dev/null | wc -l)
    if [ "$pytest_count" -gt 0 ]; then
        echo "   Removing $pytest_count pytest directories..."
        if [ "$DRY_RUN" = "false" ]; then
            find "$LOGS_DIR" -type d -name "pytest-of-*" -exec rm -rf {} + 2>/dev/null || true
            echo "   Pytest directories cleaned"
        else
            echo "   DRY RUN: Would remove $pytest_count pytest directories"
        fi
    fi

    if [ "$DRY_RUN" = "false" ]; then
        remaining_files=$(find "$LOGS_DIR" -type f 2>/dev/null | wc -l)
        echo "   Build artifacts cleaned ($remaining_files files remaining)"
    fi
}

# Perform a "smart" cleanup of the logs directory.
# This removes temporary and non-essential artifacts (such as coverage files, test databases, and transient logs)
# while preserving important logs that may be needed for debugging, auditing, or compliance.
# Unlike regular cleanup, which may remove all logs older than a certain age, smart cleanup is selective:
# it targets only files that are safe to delete and keeps logs that are likely to be important.
smart_clean_logs() {
    echo "Smart cleanup: Removing temporary artifacts, preserving important logs..."

    if [ ! -d "$LOGS_DIR" ]; then
        echo "   No logs directory found"
        return 0
    fi

    # Define temporary artifacts (safe to delete)
    temp_artifacts=(
        "dashboard_execution_*.log"
        ".coverage*"
        "coverage.xml"
        "coverage.json"
        "tmp*.db"
        "test.db"
        "*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].log"
        "validation_*.log"
        "vale-results.json"
    )

    # Important logs to preserve
    important_patterns=(
        "pip-install*.log"
        "docker-build.log"
        "env_audit.*"
        "diagnostics.log"
        "pytest.log"
        "ci-*.log"
        "security-*.log"
    )

    total_cleaned=0

    for pattern in "${temp_artifacts[@]}"; do
        if [ "$DRY_RUN" = "false" ]; then
            count_before=$(find "$LOGS_DIR" -name "$pattern" 2>/dev/null | wc -l)
            find "$LOGS_DIR" -name "$pattern" -delete 2>/dev/null || true
            count_after=$(find "$LOGS_DIR" -name "$pattern" 2>/dev/null | wc -l)
            cleaned=$((count_before - count_after))
            if [ "$cleaned" -gt 0 ]; then
                echo "   Cleaned $cleaned files matching: $pattern"
                total_cleaned=$((total_cleaned + cleaned))
            fi
        else
            count=$(find "$LOGS_DIR" -name "$pattern" 2>/dev/null | wc -l)
            if [ "$count" -gt 0 ]; then
                echo "   DRY RUN: Would clean $count files matching: $pattern"
                total_cleaned=$((total_cleaned + count))
            fi
        fi
    done

    # Clean pytest and cache directories
    if [ "$DRY_RUN" = "false" ]; then
        pytest_count=$(find "$LOGS_DIR" -type d -name "pytest-of-*" 2>/dev/null | wc -l)
        if [ "$pytest_count" -gt 0 ]; then
            find "$LOGS_DIR" -type d -name "pytest-of-*" -exec rm -rf {} + 2>/dev/null || true
            echo "   Cleaned $pytest_count pytest directories"
            total_cleaned=$((total_cleaned + pytest_count))
        fi

        cache_count=$(find "$LOGS_DIR" -type d -name "*cache*" 2>/dev/null | wc -l)
        if [ "$cache_count" -gt 0 ]; then
            find "$LOGS_DIR" -type d -name "*cache*" -exec rm -rf {} + 2>/dev/null || true
            echo "   Cleaned $cache_count cache directories"
        fi
    else
        pytest_count=$(find "$LOGS_DIR" -type d -name "pytest-of-*" 2>/dev/null | wc -l)
        cache_count=$(find "$LOGS_DIR" -type d -name "*cache*" 2>/dev/null | wc -l)
        echo "   DRY RUN: Would clean $pytest_count pytest directories and $cache_count cache directories"
    fi

    # Report on preserved important logs
    preserved_count=0
    echo "   Important logs preserved:"
    for pattern in "${important_patterns[@]}"; do
        count=$(find "$LOGS_DIR" -name "$pattern" 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            echo "     - $count files matching: $pattern"
            preserved_count=$((preserved_count + count))
        fi
    done

    if [ "$preserved_count" -eq 0 ]; then
        echo "     - No important logs found to preserve"
    fi

    if [ "$DRY_RUN" = "false" ]; then
        remaining_files=$(find "$LOGS_DIR" -type f 2>/dev/null | wc -l)
        echo "   Smart cleanup complete: $total_cleaned artifacts removed, $remaining_files files remaining"
    else
        echo "   DRY RUN: Would remove $total_cleaned artifacts"
    fi
}

clean_logs() {
    echo "Cleaning logs older than $DAYS_TO_KEEP days..."

    # Clean pytest artifacts first
    clean_pytest_artifacts

    if [ ! -d "$LOGS_DIR" ]; then
        echo "   No logs directory found"
        return 0
    fi

    # Find files older than specified days
    old_files=$(find "$LOGS_DIR" -type f -mtime +"$DAYS_TO_KEEP" 2>/dev/null || true)

    if [ -z "$old_files" ]; then
        echo "   No old log files to clean"
        return 0
    fi

    echo "   Files to remove:"
    echo "$old_files" | while read -r file; do
        echo "     - $file"
    done

    if [ "$DRY_RUN" = "false" ]; then
        echo "$old_files" | xargs rm -f
        echo "   Cleaned $(echo "$old_files" | wc -l) files"
    else
        echo "   DRY RUN: Would remove $(echo "$old_files" | wc -l) files"
    fi
}

purge_logs() {
    echo "Purging ALL log files..."

    # Clean pytest artifacts first
    clean_pytest_artifacts

    if [ ! -d "$LOGS_DIR" ]; then
        echo "   No logs directory found"
        return 0
    fi

    log_count=$(find "$LOGS_DIR" -type f | wc -l)

    if [ "$log_count" -eq 0 ]; then
        echo "   No log files to purge"
        return 0
    fi

    echo "   This will remove $log_count log files"

    if [ "$DRY_RUN" = "false" ]; then
        find "$LOGS_DIR" -type f -delete
        echo "   Purged all log files"
    else
        echo "   DRY RUN: Would remove $log_count files"
    fi
}

archive_logs() {
    timestamp=$(date +"%Y%m%d_%H%M%S")
    archive_name="logs_archive_${timestamp}.tar.gz"

    echo "Creating log archive: $archive_name"

    if [ ! -d "$LOGS_DIR" ] || [ -z "$(ls -A "$LOGS_DIR" 2>/dev/null)" ]; then
        echo "   No logs to archive"
        return 0
    fi

    if [ "$DRY_RUN" = "false" ]; then
        tar -czf "$archive_name" "$LOGS_DIR"
        echo "   Created archive: $archive_name"
        echo "   Archive size: $(du -sh "$archive_name" | cut -f1)"
    else
        echo "   DRY RUN: Would create archive with $(find "$LOGS_DIR" -type f | wc -l) files"
    fi
}

manage_cache_logs() {
    local action="${1:-list}"

    case "$action" in
        "list")
            echo "Cache directories in logs:"
            if [ ! -d "$LOGS_DIR" ]; then
                echo "   No logs directory found"
                return 0
            fi

            cache_dirs=$(find "$LOGS_DIR" -name "*cache*" -type d 2>/dev/null || true)
            if [ -n "$cache_dirs" ]; then
                echo "$cache_dirs" | while read -r dir; do
                    size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "Unknown")
                    echo "   - $dir ($size)"
                done
            else
                echo "   No cache directories found"
            fi
            ;;
        "clean")
            echo "Cleaning cache directories older than $DAYS_TO_KEEP days..."
            if [ ! -d "$LOGS_DIR" ]; then
                echo "   No logs directory found"
                return 0
            fi

            old_caches=$(find "$LOGS_DIR" -name "*cache*" -type d -mtime +"$DAYS_TO_KEEP" 2>/dev/null || true)
            if [ -n "$old_caches" ]; then
                echo "   Found $(echo "$old_caches" | wc -l) old cache directories:"
                echo "$old_caches" | while read -r dir; do
                    size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "Unknown")
                    echo "     - $dir ($size)"
                done

                if [ "$DRY_RUN" = "false" ]; then
                    echo "$old_caches" | xargs rm -rf
                    echo "   Cleaned $(echo "$old_caches" | wc -l) cache directories"
                else
                    echo "   DRY RUN: Would remove $(echo "$old_caches" | wc -l) cache directories"
                fi
            else
                echo "   No old cache directories found"
            fi
            ;;
        "size")
            echo "Cache size analysis:"
            if [ ! -d "$LOGS_DIR" ]; then
                echo "   No logs directory found"
                return 0
            fi

            for cache_dir in "$LOGS_DIR/.pytest_cache" "$LOGS_DIR/.mypy_cache"; do
                if [ -d "$cache_dir" ]; then
                    size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1 || echo "Unknown")
                    echo "   $(basename "$cache_dir"): $size"
                else
                    echo "   $(basename "$cache_dir"): Not found"
                fi
            done

            total_cache_size=$(du -sh "$LOGS_DIR" 2>/dev/null | cut -f1 || echo "Unknown")
            echo "   Total logs directory: $total_cache_size"
            ;;
        "purge")
            echo "Purging all cache directories..."
            if [ ! -d "$LOGS_DIR" ]; then
                echo "   No logs directory found"
                return 0
            fi

            cache_dirs=$(find "$LOGS_DIR" -name "*cache*" -type d 2>/dev/null || true)
            if [ -n "$cache_dirs" ]; then
                echo "   Found $(echo "$cache_dirs" | wc -l) cache directories to remove"
                if [ "$DRY_RUN" = "false" ]; then
                    echo "$cache_dirs" | xargs rm -rf
                    echo "   Purged all cache directories"
                else
                    echo "   DRY RUN: Would purge all cache directories"
                fi
            else
                echo "   No cache directories found"
            fi
            ;;
        *)
            echo "Unknown cache action: $action" >&2
            echo "Available actions: list, clean, size, purge" >&2
            exit 1
            ;;
    esac
}

# Execute the command
case "$COMMAND" in
    list)
        list_logs
        ;;
    clean)
        clean_logs
        ;;
    smart-clean)
        echo "Smart cleanup: Removing temporary artifacts while preserving important logs..."
        smart_clean_logs
        echo "Smart cleanup complete - temporary artifacts removed, important logs preserved"
        ;;
    pre-build)
        echo "Pre-build cleanup: Removing build artifacts for CI..."
        clean_build_artifacts
        echo "Pre-build cleanup complete - logs directory ready for CI"
        ;;
    pre-run)
        echo "Pre-run cleanup: Removing ALL test artifacts for fresh diagnosis..."
        clean_pytest_artifacts
        echo "Pre-run cleanup complete - logs directory ready for fresh run"
        ;;
    purge)
        if [ "$DRY_RUN" = "false" ]; then
            echo "Are you sure you want to purge ALL logs? This cannot be undone."
            read -r -p "Type 'yes' to confirm: " confirm
            if [ "$confirm" != "yes" ]; then
                echo "Purge cancelled"
                exit 1
            fi
        fi
        purge_logs
        ;;
    archive)
        archive_logs
        ;;
    cache)
        cache_action="${1:-list}"
        manage_cache_logs "$cache_action"
        ;;
    *)
        echo "Unknown command: $COMMAND" >&2
        usage >&2
        exit 1
        ;;
esac
