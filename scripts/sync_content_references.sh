#!/bin/bash
# Phase 2: Automated Content Reference Synchronization
# Syncs content references when canonical sources change

set -euo pipefail

# Configuration
DOCS_ROOT="${DOCS_ROOT:-docs}"
LOG_DIR="${LOG_DIR:-logs}"
SYNC_MODE="${SYNC_MODE:-check}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/content_sync_$TIMESTAMP.log"

# Canonical source mappings
declare -A CANONICAL_SOURCES=(
    ["virtual-environment"]="docs/policies/virtual-environment-policy.md"
    ["terminal-output"]="docs/policies/terminal-output-policy.md"
    ["quality-control"]="docs/policies/quality-control-policy.md"
    ["potato-policy"]="docs/policies/potato-policy.md"
    ["commit-standards"]="docs/development/code-quality-requirements.md"
)

# Reference patterns to sync
declare -A REFERENCE_PATTERNS=(
    ["virtual-environment"]="virtual environment|\.venv|source.*activate"
    ["terminal-output"]="terminal output|echo.*emoji|hanging.*terminal"
    ["quality-control"]="quality control|95.*percent|qc.*validation"
    ["potato-policy"]="potato policy|enhanced.*potato|sensitive.*files"
    ["commit-standards"]="commit message|conventional.*commit|TYPE.*scope"
)

# Ensure logging directory exists
mkdir -p "$LOG_DIR"

# Initialize logging
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🔄 DevOnboarder Content Reference Synchronization"
echo "=================================================="
echo "Timestamp: $(date)"
echo "Phase: 2 - Automation Opportunities"
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "Mode: $SYNC_MODE"
echo

# Function: Check if canonical source has been modified
check_canonical_modifications() {
    echo "🔍 Checking canonical source modifications..."

    local modified_sources=()

    for topic in "${!CANONICAL_SOURCES[@]}"; do
        local canonical_file="${CANONICAL_SOURCES[$topic]}"

        if [[ ! -f "$canonical_file" ]]; then
            echo "   ⚠️  Canonical source missing: $canonical_file"
            continue
        fi

        # Check git modification time (last 24 hours)
        local last_modified
        last_modified=$(git log -1 --format="%ct" -- "$canonical_file" 2>/dev/null || echo "0")
        local current_time
        current_time=$(date +%s)
        local hours_since_modified
        hours_since_modified=$(( (current_time - last_modified) / 3600 ))

        if [[ "$hours_since_modified" -lt 24 ]]; then
            echo "   🔄 Recently modified: $canonical_file ($hours_since_modified hours ago)"
            modified_sources+=("$topic")
        else
            echo "   ✅ No recent changes: $canonical_file"
        fi
    done

    if [[ ${#modified_sources[@]} -gt 0 ]]; then
        echo "   📝 Modified canonical sources: ${modified_sources[*]}"
        return 0
    else
        echo "   ✅ No canonical sources modified recently"
        return 1
    fi
}

# Function: Find files that reference a topic
find_referencing_files() {
    local topic="$1"
    local pattern="${REFERENCE_PATTERNS[$topic]}"
    local canonical_file="${CANONICAL_SOURCES[$topic]}"

    echo "   🔍 Finding files that reference '$topic'..."

    local referencing_files=()
    while IFS= read -r file; do
        # Skip the canonical source itself
        if [[ "$file" != "$canonical_file" ]]; then
            referencing_files+=("$file")
        fi
    done < <(grep -r -l -E "$pattern" "$DOCS_ROOT" 2>/dev/null || true)

    echo "      Found ${#referencing_files[@]} referencing files"
    for file in "${referencing_files[@]}"; do
        echo "      - $file"
    done

    printf '%s\n' "${referencing_files[@]}"
}

# Function: Generate sync recommendations
generate_sync_recommendations() {
    local topic="$1"
    local canonical_file="${CANONICAL_SOURCES[$topic]}"
    local output_file="$LOG_DIR/sync_recommendations_${topic}_$TIMESTAMP.md"

    echo "   📝 Generating sync recommendations for '$topic'..."

    cat > "$output_file" << EOF
# Content Sync Recommendations: $topic

**Generated**: $(date)
**Canonical Source**: \`$canonical_file\`
**Topic**: $topic

## Overview

The canonical source for '$topic' has been recently modified. The following files reference this topic and may need to be updated to maintain consistency.

## Recommended Actions

### 1. Review Canonical Changes
- **File**: \`$canonical_file\`
- **Action**: Review recent changes to understand what updates were made
- **Command**: \`git log --oneline -5 -- $canonical_file\`

### 2. Update References
Replace detailed content with references to the canonical source:

\`\`\`markdown
> **$topic**: See [$topic Policy]($canonical_file) for complete guidance.
\`\`\`

### 3. Files to Review
EOF

    # Add referencing files to recommendations
    local referencing_files
    readarray -t referencing_files < <(find_referencing_files "$topic")

    for file in "${referencing_files[@]}"; do
        {
            echo "- \`$file\`"
        } >> "$output_file"
        echo "  - Review content for potential consolidation" >> "$output_file"
        echo "  - Consider replacing detailed explanations with policy references" >> "$output_file"
        echo >> "$output_file"
    done

    cat >> "$output_file" << EOF

## Validation Steps

1. **Before Changes**: Run content duplication detection
   \`\`\`bash
   ./scripts/detect_content_duplication.sh patterns
   \`\`\`

2. **After Changes**: Verify consolidation effectiveness
   \`\`\`bash
   ./scripts/monitor_duplication.sh --quick-check
   \`\`\`

3. **Impact Analysis**: Check for broken references
   \`\`\`bash
   ./scripts/analyze_change_impact.sh $canonical_file
   \`\`\`

## Integration with DevOnboarder

- **Quality Gates**: Changes will be validated by duplication monitoring
- **Backup**: Automated backup before applying changes
- **Testing**: Full CI validation ensures no regressions

---

**Next Steps**: Review recommendations and apply consolidation changes systematically.
EOF

    echo "      📄 Recommendations saved: $output_file"
}

# Function: Automated reference replacement (dry-run mode)
preview_reference_replacement() {
    local topic="$1"
    local canonical_file="${CANONICAL_SOURCES[$topic]}"
    local pattern="${REFERENCE_PATTERNS[$topic]}"

    echo "   👀 Previewing reference replacements for '$topic'..."

    local referencing_files
    readarray -t referencing_files < <(find_referencing_files "$topic")

    local preview_file="$LOG_DIR/replacement_preview_${topic}_$TIMESTAMP.txt"

    echo "# Reference Replacement Preview: $topic" > "$preview_file"
    echo "Generated: $(date)" >> "$preview_file"
    echo >> "$preview_file"

    for file in "${referencing_files[@]}"; do
        echo "## File: $file" >> "$preview_file"
        echo >> "$preview_file"

        # Find lines matching the pattern
        local matching_lines
        matching_lines=$(grep -n -E "$pattern" "$file" 2>/dev/null || true)

        if [[ -n "$matching_lines" ]]; then
            {
                echo "### Current content:"
            } >> "$preview_file"
            echo '```' >> "$preview_file"
            echo "$matching_lines" >> "$preview_file"
            echo '```' >> "$preview_file"
            echo >> "$preview_file"

            echo "### Suggested replacement:" >> "$preview_file"
            echo '```markdown' >> "$preview_file"
            echo "> **$topic**: See [$topic Policy]($canonical_file) for complete guidance." >> "$preview_file"
            echo '```' >> "$preview_file"
        else
            echo "No matching patterns found" >> "$preview_file"
        fi

        echo >> "$preview_file"
    done

    echo "      📄 Preview saved: $preview_file"
}

# Function: Check reference consistency
check_reference_consistency() {
    echo "🔍 Checking reference consistency across documentation..."

    local consistency_issues=0

    for topic in "${!CANONICAL_SOURCES[@]}"; do
        local canonical_file="${CANONICAL_SOURCES[$topic]}"
        local pattern="${REFERENCE_PATTERNS[$topic]}"

        echo "   📋 Checking '$topic' references..."

        if [[ ! -f "$canonical_file" ]]; then
            echo "      ❌ Canonical source missing: $canonical_file"
            ((consistency_issues++))
            continue
        fi

        # Count references vs duplicated content
        local reference_count
        reference_count=$(grep -r -c "See.*$topic.*Policy\|$canonical_file" "$DOCS_ROOT" 2>/dev/null | grep -c -v ":0$" || echo "0")

        local content_count
        content_count=$(grep -r -l -E "$pattern" "$DOCS_ROOT" 2>/dev/null | wc -l || echo "0")

        local reference_ratio
        if [[ "$content_count" -gt 0 ]]; then
            reference_ratio=$(( reference_count * 100 / content_count ))
        else
            reference_ratio=100
        fi

        echo "      📊 References: $reference_count, Content duplications: $content_count"
        echo "      📈 Reference ratio: $reference_ratio%"

        if [[ "$reference_ratio" -lt 50 ]]; then
            echo "      ⚠️  Low reference ratio suggests opportunities for consolidation"
            ((consistency_issues++))
        else
            echo "      ✅ Good reference consistency"
        fi
    done

    return "$consistency_issues"
}

# Function: Display usage information
show_usage() {
    cat << 'EOF'
Usage: sync_content_references.sh [OPTIONS]

Automated content reference synchronization for DevOnboarder documentation.

OPTIONS:
    --mode MODE         Sync mode: check, preview, recommend (default: check)
    --topic TOPIC       Sync specific topic only
    --force             Force sync even without recent changes
    --consistency       Check reference consistency only
    --help              Show this help message

SYNC MODES:
    check               Check for modifications and generate reports
    preview             Preview potential reference replacements
    recommend           Generate detailed synchronization recommendations

TOPICS:
    virtual-environment Virtual environment setup and usage
    terminal-output     Terminal output requirements and policies
    quality-control     Quality control procedures and validation
    potato-policy       Enhanced Potato Policy enforcement
    commit-standards    Commit message and development standards

ENVIRONMENT VARIABLES:
    DOCS_ROOT           Documentation root directory (default: docs)
    LOG_DIR            Log directory (default: logs)
    SYNC_MODE          Default sync mode (default: check)

EXAMPLES:
    # Check all topics for recent modifications
    ./scripts/sync_content_references.sh

    # Preview reference replacements for virtual environment
    ./scripts/sync_content_references.sh --mode preview --topic virtual-environment

    # Generate sync recommendations for all modified topics
    ./scripts/sync_content_references.sh --mode recommend

    # Check reference consistency
    ./scripts/sync_content_references.sh --consistency

INTEGRATION:
    This synchronization system integrates with:
    - Content duplication detection for identifying opportunities
    - Change impact analysis for understanding dependencies
    - Backup system for safe operations
    - Monitoring system for validation
    - Quality gates for ensuring consistency

WORKFLOW:
    1. Detect modifications to canonical sources
    2. Identify files that reference modified topics
    3. Generate consolidation recommendations
    4. Preview reference replacements
    5. Validate consistency after changes

EOF
}

# Main synchronization workflow
main() {
    local specific_topic=""
    local force_sync=false
    local consistency_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --mode)
                SYNC_MODE="$2"
                shift 2
                ;;
            --topic)
                specific_topic="$2"
                shift 2
                ;;
            --force)
                force_sync=true
                shift
                ;;
            --consistency)
                consistency_only=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    echo "🚀 Starting Content Reference Synchronization"
    echo "Configuration:"
    echo "   - Documentation root: $DOCS_ROOT"
    echo "   - Sync mode: $SYNC_MODE"
    echo "   - Specific topic: ${specific_topic:-'all'}"
    echo "   - Force sync: $force_sync"
    echo

    # Consistency check mode
    if [[ "$consistency_only" == "true" ]]; then
        local consistency_issues=0
        if check_reference_consistency; then
            echo "✅ Reference consistency check passed"
        else
            consistency_issues=$?
            echo "⚠️  Reference consistency check found $consistency_issues issues"
        fi
        exit "$consistency_issues"
    fi

    # Check for modifications (unless forced)
    local has_modifications=false
    if [[ "$force_sync" == "true" ]]; then
        echo "🔄 Force sync enabled - skipping modification check"
        has_modifications=true
    else
        if check_canonical_modifications; then
            has_modifications=true
        fi
    fi

    if [[ "$has_modifications" == "false" ]]; then
        echo "✅ No recent modifications detected - sync not needed"
        echo "💡 Use --force to sync anyway"
        exit 0
    fi

    # Process specific topic or all topics
    local topics_to_process=()
    if [[ -n "$specific_topic" ]]; then
        if [[ -n "${CANONICAL_SOURCES[$specific_topic]:-}" ]]; then
            topics_to_process=("$specific_topic")
        else
            echo "❌ Unknown topic: $specific_topic"
            echo "Available topics: ${!CANONICAL_SOURCES[*]}"
            exit 1
        fi
    else
        topics_to_process=("${!CANONICAL_SOURCES[@]}")
    fi

    echo "📋 Processing topics: ${topics_to_process[*]}"
    echo

    # Execute sync mode for each topic
    for topic in "${topics_to_process[@]}"; do
        echo "🔄 Processing topic: $topic"

        case "$SYNC_MODE" in
            check)
                echo "   📊 Running consistency check..."
                find_referencing_files "$topic" > /dev/null
                ;;
            preview)
                echo "   👀 Generating replacement preview..."
                preview_reference_replacement "$topic"
                ;;
            recommend)
                echo "   📝 Generating sync recommendations..."
                generate_sync_recommendations "$topic"
                ;;
            *)
                echo "   ❌ Unknown sync mode: $SYNC_MODE"
                exit 1
                ;;
        esac

        echo
    done

    echo "✅ Content reference synchronization complete!"
    echo "   📄 Log: $LOG_FILE"
    echo "   📊 Outputs: $LOG_DIR/*_$TIMESTAMP.*"
    echo
    echo "🔄 Next steps based on mode:"
    case "$SYNC_MODE" in
        check)
            echo "   💡 Run with --mode recommend to get consolidation guidance"
            ;;
        preview)
            echo "   💡 Review previews and apply reference replacements manually"
            ;;
        recommend)
            echo "   💡 Review recommendations and implement consolidation changes"
            ;;
    esac
}

# Execute main workflow if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
