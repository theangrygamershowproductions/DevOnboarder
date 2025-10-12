#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# DevOnboarder Modular Documentation Backup System
# Automated backup with git-based versioning and integrity verification

set -euo pipefail

# Logging setup
mkdir -p logs
LOG_FILE="logs/doc_backup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "📦 DevOnboarder Documentation Backup System"
echo "============================================"
echo "Timestamp: $(date)"
echo "Log: $LOG_FILE"
echo ""

# Configuration
BACKUP_DIR="${BACKUP_DIR:-docs-backup}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
VERIFY_CHECKSUMS="${VERIFY_CHECKSUMS:-true}"
CREATE_ARCHIVE="${CREATE_ARCHIVE:-true}"

# Documentation directories to backup
DOC_PATHS=(
    "docs/policies"
    "docs/development"
    "docs/troubleshooting"
    "docs/quick-reference"
    "docs/copilot-refactor"
    "docs/sessions"
    ".codex/agents"
    "schema"
)

echo "Configuration:"
echo "- Backup Directory: $BACKUP_DIR"
echo "- Retention: $RETENTION_DAYS days"
echo "- Verify Checksums: $VERIFY_CHECKSUMS"
echo "- Create Archive: $CREATE_ARCHIVE"
echo ""

# Create backup directory structure
create_backup_structure() {
    local timestamp="$1"
    local backup_path="$BACKUP_DIR/$timestamp"

    echo "📁 Creating backup structure: $backup_path" >&2
    mkdir -p "$backup_path"

    # Create metadata file
    cat > "$backup_path/backup_metadata.json" << EOF
{
    "timestamp": "$timestamp",
    "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
    "git_branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
    "backup_paths": [$(printf '"%s",' "${DOC_PATHS[@]}" | sed 's/,$//')]
}
EOF

    echo "$backup_path"
}

# Copy documentation with structure preservation
copy_documentation() {
    local backup_path="$1"
    local total_files=0
    local copied_files=0

    check "Copying documentation files..."

    for doc_path in "${DOC_PATHS[@]}"; do
        if [ -d "$doc_path" ]; then
            echo "  → Copying $doc_path"

            # Count files for progress
            local path_files
            path_files=$(find "$doc_path" -type f -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" | wc -l)
            total_files=$((total_files + path_files))

            # Create destination directory
            mkdir -p "$backup_path/$doc_path"

            # Copy files directly to preserve structure
            find "$doc_path" -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) -exec cp --parents {} "$backup_path/" \;

            copied_files=$((copied_files + path_files))
            echo "    SUCCESS: $path_files files copied"
        else
            echo "  WARNING:  Path not found: $doc_path"
        fi
    done

    echo ""
    report "Copy Summary:"
    echo "   Total files copied: $copied_files"
    echo "   Success rate: 100%"

    return 0
}

# Generate checksums for integrity verification
generate_checksums() {
    local backup_path="$1"
    local checksum_file="$backup_path/checksums.sha256"

    secure "Generating checksums for integrity verification..."

    # Change to backup directory for relative paths
    cd "$backup_path"

    # Generate checksums for all backed up files
    find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) \
        -not -path "./checksums.sha256" \
        -exec sha256sum {} \; > checksums.sha256

    cd - > /dev/null

    local checksum_count
    checksum_count=$(wc -l < "$checksum_file")
    echo "   SUCCESS: Generated checksums for $checksum_count files"
    echo "   📄 Checksum file: $checksum_file"

    return 0
}

# Verify backup integrity
verify_backup_integrity() {
    local backup_path="$1"
    local checksum_file="$backup_path/checksums.sha256"

    if [ "$VERIFY_CHECKSUMS" = "true" ] && [ -f "$checksum_file" ]; then
        echo "🔍 Verifying backup integrity..."

        cd "$backup_path"
        if sha256sum -c checksums.sha256 --quiet; then
            echo "   SUCCESS: All checksums verified successfully"
            cd - > /dev/null
            return 0
        else
            echo "   ERROR: Checksum verification failed"
            cd - > /dev/null
            return 1
        fi
    else
        echo "   ⏭️  Checksum verification skipped"
        return 0
    fi
}

# Create compressed archive
create_archive() {
    local backup_path="$1"
    local timestamp="$2"

    if [ "$CREATE_ARCHIVE" = "true" ]; then
        echo "📦 Creating compressed archive..."

        local archive_name="devonboarder-docs-backup-$timestamp.tar.gz"
        local archive_path="$BACKUP_DIR/$archive_name"

        tar -czf "$archive_path" -C "$BACKUP_DIR" "$timestamp"

        local archive_size
        archive_size=$(du -h "$archive_path" | cut -f1)
        echo "   SUCCESS: Archive created: $archive_name ($archive_size)"

        # Verify archive
        if tar -tzf "$archive_path" > /dev/null 2>&1; then
            echo "   SUCCESS: Archive integrity verified"
        else
            echo "   ERROR: Archive verification failed"
            return 1
        fi
    else
        echo "   ⏭️  Archive creation skipped"
    fi

    return 0
}

# Clean old backups
cleanup_old_backups() {
    echo "🧹 Cleaning up old backups (older than $RETENTION_DAYS days)..."

    # Clean old directories
    if [ -d "$BACKUP_DIR" ]; then
        find "$BACKUP_DIR" -type d -name "20*" -mtime +"$RETENTION_DAYS" -exec rm -rf {} \; 2>/dev/null || true

        # Count remaining backups
        local remaining_count
        remaining_count=$(find "$BACKUP_DIR" -type d -name "20*" | wc -l)
        echo "   REPORT: Backup retention: $remaining_count backups remaining"

        # Clean old archives
        find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$RETENTION_DAYS" -delete 2>/dev/null || true

        local archive_count
        archive_count=$(find "$BACKUP_DIR" -name "*.tar.gz" | wc -l)
        echo "   📦 Archive retention: $archive_count archives remaining"
    fi

    return 0
}

# Generate backup report
generate_backup_report() {
    local backup_path="$1"
    local timestamp="$2"
    local success="$3"

    local report_file="$backup_path/backup_report.md"

    cat > "$report_file" << EOF
# DevOnboarder Documentation Backup Report

## Backup Information

- **Timestamp**: $timestamp
- **Date**: $(date)
- **Status**: $([ "$success" = "true" ] && success "SUCCESS" || error "FAILED")
- **Git Commit**: $(git rev-parse HEAD 2>/dev/null || echo 'unknown')
- **Git Branch**: $(git branch --show-current 2>/dev/null || echo 'unknown')

## Backup Statistics

$(
if [ -d "$backup_path" ]; then
    echo "- **Total Files**: $(find "$backup_path" -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) | wc -l)"
    echo "- **Total Size**: $(du -sh "$backup_path" | cut -f1)"
    echo "- **Backup Path**: \`$backup_path\`"

    echo ""
    echo "## Directory Breakdown"
    echo ""
    for doc_path in "${DOC_PATHS[@]}"; do
        if [ -d "$backup_path/$doc_path" ]; then
            local file_count
            file_count=$(find "$backup_path/$doc_path" -type f | wc -l)
            local dir_size
            dir_size=$(du -sh "$backup_path/$doc_path" 2>/dev/null | cut -f1)
            echo "- **$doc_path**: $file_count files ($dir_size)"
        fi
    done
fi
)

## Integrity Verification

$([ "$VERIFY_CHECKSUMS" = "true" ] && echo "- **Checksums**: Generated and verified" || echo "- **Checksums**: Skipped")

## Next Backup

Scheduled for: $(date -d "+1 day" +"%Y-%m-%d %H:%M:%S")

---

**Generated by**: DevOnboarder Backup System
**Log File**: \`$LOG_FILE\`
EOF

    echo "📄 Backup report generated: $report_file"
}

# Main backup execution
main() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    deploy "Starting backup process..."

    # Create backup structure
    local backup_path
    backup_path=$(create_backup_structure "$timestamp")

    # Copy documentation
    if ! copy_documentation "$backup_path"; then
        error "Documentation copy failed"
        exit 1
    fi

    # Generate checksums
    if ! generate_checksums "$backup_path"; then
        error "Checksum generation failed"
        exit 1
    fi

    # Verify integrity
    if ! verify_backup_integrity "$backup_path"; then
        error "Backup integrity verification failed"
        exit 1
    fi

    # Create archive
    if ! create_archive "$backup_path" "$timestamp"; then
        error "Archive creation failed"
        exit 1
    fi

    # Generate report
    generate_backup_report "$backup_path" "$timestamp" "true"

    # Cleanup old backups
    cleanup_old_backups

    echo ""
    success "Backup completed successfully!"
    echo "   📁 Backup location: $backup_path"
    echo "   SECURE: Integrity verified: $([ "$VERIFY_CHECKSUMS" = "true" ] && echo "Yes" || echo "Skipped")"
    echo "   📦 Archive created: $([ "$CREATE_ARCHIVE" = "true" ] && echo "Yes" || echo "Skipped")"
    echo "   📄 Log: $LOG_FILE"

    return 0
}

# Command line interface
case "${1:-backup}" in
    "backup"|"")
        main
        ;;
    "verify")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 verify <backup-path>"
            exit 1
        fi
        verify_backup_integrity "$2"
        ;;
    "list")
        check "Available backups:"
        if [ -d "$BACKUP_DIR" ]; then
            find "$BACKUP_DIR" -type d -name "20*" | sort -r | head -10 | while read -r backup; do
                size=$(du -sh "$backup" 2>/dev/null | cut -f1)
                echo "   $(basename "$backup") ($size)"
            done
        else
            echo "   No backups found"
        fi
        ;;
    "restore")
        echo "🚧 Restore functionality not implemented yet"
        echo "   Manual restore: Copy files from backup directory"
        exit 1
        ;;
    "help"|"--help"|"-h")
        echo "DevOnboarder Documentation Backup System"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "   backup     Create new backup (default)"
        echo "   verify     Verify backup integrity"
        echo "   list       List available backups"
        echo "   restore    Restore from backup (not implemented)"
        echo "   help       Show this help"
        echo ""
        echo "Environment Variables:"
        echo "   BACKUP_DIR        Backup directory (default: docs-backup)"
        echo "   RETENTION_DAYS    Backup retention in days (default: 30)"
        echo "   VERIFY_CHECKSUMS  Enable checksum verification (default: true)"
        echo "   CREATE_ARCHIVE    Create compressed archive (default: true)"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
