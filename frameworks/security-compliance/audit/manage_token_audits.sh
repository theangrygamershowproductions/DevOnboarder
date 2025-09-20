#!/bin/bash
# Token Audit Report Management
# Manages retention, archival, and cleanup of token audit reports

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit

REPORTS_DIR="reports"
RETENTION_DAYS=365  # Keep audit reports for 1 year
ARCHIVE_AFTER_DAYS=90  # Archive reports older than 3 months

# Function to display usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  list         List all token audit reports"
    echo "  clean        Remove reports older than retention period"
    echo "  archive      Archive reports older than 3 months"
    echo "  status       Show audit report statistics"
    echo "  generate     Generate new audit report"
    echo ""
    echo "Options:"
    echo "  --retention-days N    Set retention period (default: 365)"
    echo "  --archive-days N      Set archive threshold (default: 90)"
}

# Function to list audit reports
list_reports() {
    echo "Token Audit Reports"
    echo "==================="

    if [ ! -d "$REPORTS_DIR" ]; then
        echo "No reports directory found."
        return 0
    fi

    if find "$REPORTS_DIR" -name "token-audit-*.md" -type f >/dev/null 2>&1; then
        echo "Found token audit reports:"
        echo ""
        find "$REPORTS_DIR" -name "token-audit-*.md" -type f -ls | while read -r _ _ _ _ _ size _ _ _ filepath; do
            # Extract filename and date info
            filename=$(basename "$filepath")

            echo "  Report: $filename"
            echo "     Size: $size bytes"
            echo ""
        done
    else
        echo "No token audit reports found."
    fi
}

# Function to show audit statistics
show_status() {
    echo "Token Audit Report Status"
    echo "========================="

    if [ ! -d "$REPORTS_DIR" ]; then
        echo "Reports directory: Not found"
        return 0
    fi

    # Count reports
    TOTAL_REPORTS=$(find "$REPORTS_DIR" -name "token-audit-*.md" -type f 2>/dev/null | wc -l)
    echo "Total audit reports: $TOTAL_REPORTS"

    if [ "$TOTAL_REPORTS" -gt 0 ]; then
        # Find oldest and newest
        OLDEST=$(find "$REPORTS_DIR" -name "token-audit-*.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | head -1 | cut -d' ' -f2-)
        NEWEST=$(find "$REPORTS_DIR" -name "token-audit-*.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)

        echo "Oldest report: $(basename "$OLDEST")"
        echo "Newest report: $(basename "$NEWEST")"

        # Check for reports needing attention
        CUTOFF_DATE=$(date -d "-${RETENTION_DAYS} days" '+%Y%m%d')
        OLD_REPORTS=0

        for report in "$REPORTS_DIR"/token-audit-*.md; do
            if [ -f "$report" ]; then
                # Extract date from filename (format: token-audit-YYYYMMDD_HHMMSS.md)
                REPORT_DATE=$(basename "$report" | sed 's/token-audit-\([0-9]\{8\}\)_.*/\1/')
                if [ "$REPORT_DATE" -lt "$CUTOFF_DATE" ]; then
                    OLD_REPORTS=$((OLD_REPORTS + 1))
                fi
            fi
        done

        if [ "$OLD_REPORTS" -gt 0 ]; then
            echo "WARNING: Reports beyond retention: $OLD_REPORTS"
            echo "   Run 'clean' command to remove old reports"
        else
            echo "SUCCESS: All reports within retention period"
        fi
    fi

    echo ""
    echo "Configuration:"
    echo "  Retention period: $RETENTION_DAYS days"
    echo "  Archive threshold: $ARCHIVE_AFTER_DAYS days"
}

# Function to clean old reports
clean_reports() {
    echo "Cleaning Token Audit Reports"
    echo "============================"

    if [ ! -d "$REPORTS_DIR" ]; then
        echo "No reports directory found."
        return 0
    fi

    CUTOFF_DATE=$(date -d "-${RETENTION_DAYS} days" '+%Y%m%d')
    REMOVED_COUNT=0

    echo "Removing reports older than $RETENTION_DAYS days (before $CUTOFF_DATE)..."
    echo ""

    for report in "$REPORTS_DIR"/token-audit-*.md; do
        if [ -f "$report" ]; then
            # Extract date from filename
            REPORT_DATE=$(basename "$report" | sed 's/token-audit-\([0-9]\{8\}\)_.*/\1/')
            if [ "$REPORT_DATE" -lt "$CUTOFF_DATE" ]; then
                echo "  Removing: $(basename "$report")"
                rm "$report"
                REMOVED_COUNT=$((REMOVED_COUNT + 1))
            fi
        fi
    done

    if [ "$REMOVED_COUNT" -eq 0 ]; then
        echo "SUCCESS: No reports needed removal"
    else
        echo ""
        echo "SUCCESS: Removed $REMOVED_COUNT old audit reports"
    fi
}

# Function to generate new audit report
generate_report() {
    echo "Generating New Token Audit Report"
    echo "================================="

    if [ ! -f "scripts/generate_token_audit_report.sh" ]; then
        echo "ERROR: Audit report generator not found"
        echo "   Expected: scripts/generate_token_audit_report.sh"
        exit 1
    fi

    bash scripts/generate_token_audit_report.sh
}

# Main script logic
case "${1:-help}" in
    list)
        list_reports
        ;;
    clean)
        clean_reports
        ;;
    status)
        show_status
        ;;
    generate)
        generate_report
        ;;
    archive)
        echo "Archive functionality not yet implemented"
        echo "   Reports older than $ARCHIVE_AFTER_DAYS days would be compressed"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "ERROR: Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac
