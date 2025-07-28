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
        clean|pre-run|purge|list|archive)
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
    *)
        echo "Unknown command: $COMMAND" >&2
        usage >&2
        exit 1
        ;;
esac
