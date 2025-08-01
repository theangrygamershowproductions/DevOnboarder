#!/usr/bin/env bash
# Log management utility for DevOnboarder
set -euo pipefail

LOGS_DIR="logs"
DAYS_TO_KEEP=7
DRY_RUN=false

usage() {
    cat << EOF
Usage: $0 [OPTIONS] COMMAND

Commands:
    clean       Remove old log files (older than $DAYS_TO_KEEP days)
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
        clean|pre-run|purge|list|archive|cache)
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
        echo "📊 Total size: $(du -sh "$LOGS_DIR" | cut -f1)"
    else
        echo "   (no log files found)"
    fi
}

clean_pytest_artifacts() {
    echo "🧪 Cleaning pytest temporary directories and test artifacts..."

    if [ ! -d "$LOGS_DIR" ]; then
        return 0
    fi

    # Remove specific pytest-of-creesey directory
    if [ -d "$LOGS_DIR/pytest-of-creesey" ]; then
        echo "   Removing: $LOGS_DIR/pytest-of-creesey/"
        rm -rf "$LOGS_DIR/pytest-of-creesey"
        echo "   ✅ pytest-of-creesey cleaned"
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
            echo "   ✅ Cleaned $(echo "$pytest_dirs" | wc -l) pytest directories"
        else
            echo "   🔍 DRY RUN: Would remove $(echo "$pytest_dirs" | wc -l) pytest directories"
        fi
    else
        echo "   ✅ No pytest directories found"
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
        echo "   ✅ ALL test artifacts cleaned ($remaining_files files remaining)"
    else
        echo "   🔍 DRY RUN: Would clean ALL test artifacts"
    fi
}

clean_logs() {
    echo "🧹 Cleaning logs older than $DAYS_TO_KEEP days..."

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
        echo "   ✅ Cleaned $(echo "$old_files" | wc -l) files"
    else
        echo "   🔍 DRY RUN: Would remove $(echo "$old_files" | wc -l) files"
    fi
}

purge_logs() {
    echo "💥 Purging ALL log files..."

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

    echo "   ⚠️  This will remove $log_count log files"

    if [ "$DRY_RUN" = "false" ]; then
        find "$LOGS_DIR" -type f -delete
        echo "   ✅ Purged all log files"
    else
        echo "   🔍 DRY RUN: Would remove $log_count files"
    fi
}

archive_logs() {
    timestamp=$(date +"%Y%m%d_%H%M%S")
    archive_name="logs_archive_${timestamp}.tar.gz"

    echo "📦 Creating log archive: $archive_name"

    if [ ! -d "$LOGS_DIR" ] || [ -z "$(ls -A "$LOGS_DIR" 2>/dev/null)" ]; then
        echo "   No logs to archive"
        return 0
    fi

    if [ "$DRY_RUN" = "false" ]; then
        tar -czf "$archive_name" "$LOGS_DIR"
        echo "   ✅ Created archive: $archive_name"
        echo "   📊 Archive size: $(du -sh "$archive_name" | cut -f1)"
    else
        echo "   🔍 DRY RUN: Would create archive with $(find "$LOGS_DIR" -type f | wc -l) files"
    fi
}

manage_cache_logs() {
    local action="${1:-list}"

    case "$action" in
        "list")
            echo "📂 Cache directories in logs:"
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
            echo "🧹 Cleaning cache directories older than $DAYS_TO_KEEP days..."
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
                    echo "   ✅ Cleaned $(echo "$old_caches" | wc -l) cache directories"
                else
                    echo "   🔍 DRY RUN: Would remove $(echo "$old_caches" | wc -l) cache directories"
                fi
            else
                echo "   ✅ No old cache directories found"
            fi
            ;;
        "size")
            echo "📊 Cache size analysis:"
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
            echo "🗑️  Purging all cache directories..."
            if [ ! -d "$LOGS_DIR" ]; then
                echo "   No logs directory found"
                return 0
            fi

            cache_dirs=$(find "$LOGS_DIR" -name "*cache*" -type d 2>/dev/null || true)
            if [ -n "$cache_dirs" ]; then
                echo "   Found $(echo "$cache_dirs" | wc -l) cache directories to remove"
                if [ "$DRY_RUN" = "false" ]; then
                    echo "$cache_dirs" | xargs rm -rf
                    echo "   ✅ Purged all cache directories"
                else
                    echo "   🔍 DRY RUN: Would purge all cache directories"
                fi
            else
                echo "   ✅ No cache directories found"
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
    pre-run)
        echo "🧹 Pre-run cleanup: Removing ALL test artifacts for fresh diagnosis..."
        clean_pytest_artifacts
        echo "✅ Pre-run cleanup complete - logs directory ready for fresh run"
        ;;
    purge)
        if [ "$DRY_RUN" = "false" ]; then
            echo "⚠️  Are you sure you want to purge ALL logs? This cannot be undone."
            read -r -p "Type 'yes' to confirm: " confirm
            if [ "$confirm" != "yes" ]; then
                echo "❌ Purge cancelled"
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
