#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# DevOnboarder Change Impact Analysis Script
# Identifies related modules when changes are made to prevent orphaned references

set -euo pipefail

# Logging setup
mkdir -p logs
LOG_FILE="logs/change_impact_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🔍 DevOnboarder Change Impact Analysis"
echo "======================================"
echo "Timestamp: $(date)"
echo "Log: $LOG_FILE"
echo ""

# Configuration
DOCS_ROOT="${DOCS_ROOT:-docs}"
ANALYSIS_MODE="${ANALYSIS_MODE:-comprehensive}"
CHECK_EXTERNAL_REFS="${CHECK_EXTERNAL_REFS:-true}"

# Documentation paths to analyze
ANALYSIS_PATHS=(
    "$DOCS_ROOT/policies"
    "$DOCS_ROOT/development"
    "$DOCS_ROOT/troubleshooting"
    "$DOCS_ROOT/quick-reference"
    "$DOCS_ROOT/copilot-refactor"
    "$DOCS_ROOT/sessions"
    ".codex/agents"
    "schema"
)

# Reference patterns to detect
REFERENCE_PATTERNS=(
    "docs/[a-zA-Z0-9_/-]+\.md"          # Direct file references
    "\[.*\]\(docs/[^)]+\)"              # Markdown links to docs
    "\[.*\]\([^)]*\.md[^)]*\)"          # Markdown links to any .md files
    "scripts/[a-zA-Z0-9_/-]+\.sh"       # Script references
    "\.codex/[a-zA-Z0-9_/-]+\.md"       # Agent references
    "schema/[a-zA-Z0-9_/-]+\.json"      # Schema references
)

# Keywords and concepts for semantic analysis
CONCEPT_KEYWORDS=(
    "virtual environment:Virtual Environment Policy"
    "terminal output:Terminal Output Policy"
    "potato policy:Enhanced Potato Policy"
    "commit message:Quality Control Policy"
    "ci failure:CI/CD Troubleshooting"
    "discord bot:Development Workflow"
    "authentication:Security Best Practices"
    "testing:Code Quality Requirements"
    "backup:Change Impact Analysis"
    "documentation:Modular Documentation"
)

# Display configuration
display_config() {
    echo "Configuration:"
    echo "- Documentation Root: $DOCS_ROOT"
    echo "- Analysis Mode: $ANALYSIS_MODE"
    echo "- Check External References: $CHECK_EXTERNAL_REFS"
    echo "- Analysis Paths: ${#ANALYSIS_PATHS[@]} directories"
    echo "- Reference Patterns: ${#REFERENCE_PATTERNS[@]} patterns"
    echo "- Concept Keywords: ${#CONCEPT_KEYWORDS[@]} concepts"
    echo ""
}

# Find all documentation files
find_all_docs() {
    local all_files=()

    for path in "${ANALYSIS_PATHS[@]}"; do
        if [ -d "$path" ]; then
            while IFS= read -r -d '' file; do
                all_files+=("$file")
            done < <(find "$path" -type f \( -name "*.md" -o -name "*.json" \) -print0)
        fi
    done

    printf '%s\n' "${all_files[@]}"
}

# Analyze direct references in a file
analyze_direct_references() {
    local source_file="$1"
    local references=()

    echo "  CHECK: Analyzing direct references in: $(basename "$source_file")"

    for pattern in "${REFERENCE_PATTERNS[@]}"; do
        while IFS= read -r match; do
            if [ -n "$match" ]; then
                references+=("$match")
            fi
        done < <(grep -oE "$pattern" "$source_file" 2>/dev/null || true)
    done

    # Remove duplicates and sort
    if [ ${#references[@]} -gt 0 ]; then
        printf '%s\n' "${references[@]}" | sort -u
    fi
}

# Analyze semantic references (keywords and concepts)
analyze_semantic_references() {
    local source_file="$1"
    local concepts=()

    echo "  🧠 Analyzing semantic references in: $(basename "$source_file")"

    for concept_pair in "${CONCEPT_KEYWORDS[@]}"; do
        local keyword="${concept_pair%%:*}"
        local target="${concept_pair##*:}"

        if grep -qi "$keyword" "$source_file" 2>/dev/null; then
            concepts+=("$target")
        fi
    done

    # Remove duplicates
    if [ ${#concepts[@]} -gt 0 ]; then
        printf '%s\n' "${concepts[@]}" | sort -u
    fi
}

# Find reverse dependencies (what references this file)
find_reverse_dependencies() {
    local target_file="$1"
    local basename_target
    basename_target=$(basename "$target_file")
    local references=()

    echo "  🔙 Finding reverse dependencies for: $basename_target"

    # Search for direct file references
    while IFS= read -r file; do
        if [ "$file" != "$target_file" ] && [ -f "$file" ]; then
            if grep -q "$target_file\|$basename_target" "$file" 2>/dev/null; then
                references+=("$file")
            fi
        fi
    done < <(find_all_docs)

    # Remove duplicates
    if [ ${#references[@]} -gt 0 ]; then
        printf '%s\n' "${references[@]}" | sort -u
    fi
}

# Check for broken references
check_broken_references() {
    local source_file="$1"
    local broken_refs=()

    echo "  ERROR: Checking for broken references in: $(basename "$source_file")"

    # Check markdown links
    while IFS= read -r link; do
        if [ -n "$link" ]; then
            # Extract path from markdown link
            local path
            path=$(echo "$link" | sed -n 's/.*(\([^)]*\)).*/\1/p')

            # Skip external URLs
            if [[ "$path" =~ ^https?:// ]]; then
                continue
            fi

            # Check if file exists (relative to source file directory)
            local source_dir
            source_dir=$(dirname "$source_file")
            local full_path

            if [[ "$path" =~ ^/ ]]; then
                # Absolute path from repository root
                full_path=".$path"
            else
                # Relative path
                full_path="$source_dir/$path"
            fi

            if [ ! -f "$full_path" ] && [ ! -d "$full_path" ]; then
                broken_refs+=("$path (from $source_file)")
            fi
        fi
    done < <(grep -oE '\[.*\]\([^)]+\)' "$source_file" 2>/dev/null || true)

    if [ ${#broken_refs[@]} -gt 0 ]; then
        printf '%s\n' "${broken_refs[@]}"
    fi
}

# Suggest related documentation based on content analysis
suggest_related_docs() {
    local source_file="$1"
    local suggestions=()

    echo "  💡 Suggesting related documentation for: $(basename "$source_file")"

    # Analyze content for common patterns
    local content
    content=$(cat "$source_file" 2>/dev/null || echo "")

    # Check for common DevOnboarder patterns
    if echo "$content" | grep -qi "virtual environment\|venv\|pip install"; then
        suggestions+=("docs/policies/virtual-environment-policy.md")
    fi

    if echo "$content" | grep -qi "terminal\|echo\|output\|hanging"; then
        suggestions+=("docs/policies/terminal-output-policy.md")
    fi

    if echo "$content" | grep -qi "commit\|git\|pre-commit\|quality"; then
        suggestions+=("docs/policies/quality-control-policy.md")
    fi

    if echo "$content" | grep -qi "ci\|github actions\|workflow\|test"; then
        suggestions+=("docs/troubleshooting/common-issues-resolution.md")
    fi

    if echo "$content" | grep -qi "discord\|bot\|oauth\|integration"; then
        suggestions+=("docs/development/architecture-overview.md")
    fi

    if echo "$content" | grep -qi "security\|token\|secret\|auth"; then
        suggestions+=("docs/policies/security-best-practices.md")
    fi

    # Remove duplicates and filter out non-existent files
    local valid_suggestions=()
    for suggestion in "${suggestions[@]}"; do
        if [ -f "$suggestion" ]; then
            valid_suggestions+=("$suggestion")
        fi
    done

    if [ ${#valid_suggestions[@]} -gt 0 ]; then
        printf '%s\n' "${valid_suggestions[@]}" | sort -u
    fi
}

# Generate impact analysis report
generate_impact_report() {
    local source_file="$1"
    local output_file="$2"

    echo "📄 Generating impact analysis report for: $source_file"

    cat > "$output_file" << EOF
# Change Impact Analysis Report

## Source File Analysis

**File**: \`$source_file\`
**Generated**: $(date)
**Git Branch**: $(git branch --show-current 2>/dev/null || echo 'unknown')
**Git Commit**: $(git rev-parse HEAD 2>/dev/null || echo 'unknown')

---

## Direct References

EOF

    # Add direct references
    local direct_refs
    direct_refs=$(analyze_direct_references "$source_file")
    if [ -n "$direct_refs" ]; then
        echo "Found the following direct references:" >> "$output_file"
        echo "" >> "$output_file"
        echo "$direct_refs" | while read -r ref; do
            echo "- \`$ref\`" >> "$output_file"
        done
    else
        echo "No direct references found." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

---

## Semantic References

EOF

    # Add semantic references
    local semantic_refs
    semantic_refs=$(analyze_semantic_references "$source_file")
    if [ -n "$semantic_refs" ]; then
        echo "Found the following concept-related documentation:" >> "$output_file"
        echo "" >> "$output_file"
        echo "$semantic_refs" | while read -r ref; do
            echo "- **$ref**" >> "$output_file"
        done
    else
        echo "No semantic references found." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

---

## Reverse Dependencies

EOF

    # Add reverse dependencies
    local reverse_deps
    reverse_deps=$(find_reverse_dependencies "$source_file")
    if [ -n "$reverse_deps" ]; then
        echo "The following files reference this document:" >> "$output_file"
        echo "" >> "$output_file"
        echo "$reverse_deps" | while read -r dep; do
            echo "- \`$dep\`" >> "$output_file"
        done
    else
        echo "No reverse dependencies found." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

---

## Broken References

EOF

    # Add broken references
    local broken_refs
    broken_refs=$(check_broken_references "$source_file")
    if [ -n "$broken_refs" ]; then
        warning "**Found broken references that need attention:**" >> "$output_file"
        echo "" >> "$output_file"
        echo "$broken_refs" | while read -r ref; do
            echo "- ERROR: $ref" >> "$output_file"
        done
    else
        success "No broken references found." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

---

## Suggested Related Documentation

EOF

    # Add suggestions
    local suggestions
    suggestions=$(suggest_related_docs "$source_file")
    if [ -n "$suggestions" ]; then
        echo "Consider reviewing these related documents:" >> "$output_file"
        echo "" >> "$output_file"
        echo "$suggestions" | while read -r suggestion; do
            echo "- [\`$(basename "$suggestion")\`]($suggestion)" >> "$output_file"
        done
    else
        echo "No specific suggestions available." >> "$output_file"
    fi

    cat >> "$output_file" << EOF

---

## Impact Assessment

### Risk Level: $(assess_risk_level "$source_file")

### Recommended Actions:

1. **Review Direct References**: Ensure all referenced files are current and accurate
2. **Update Related Documentation**: Check semantic references for consistency
3. **Validate Reverse Dependencies**: Ensure files that reference this one remain accurate
4. **Fix Broken References**: Address any broken links or missing files
5. **Consider Related Updates**: Review suggested documentation for consistency

---

**Analysis completed**: $(date)
**Log file**: \`$LOG_FILE\`

EOF

    echo "   SUCCESS: Report generated: $output_file"
}

# Assess risk level based on analysis
assess_risk_level() {
    local source_file="$1"
    local risk_score=0

    # Count direct references
    local direct_count
    direct_count=$(analyze_direct_references "$source_file" | wc -l)
    risk_score=$((risk_score + direct_count))

    # Count reverse dependencies
    local reverse_count
    reverse_count=$(find_reverse_dependencies "$source_file" | wc -l)
    risk_score=$((risk_score + reverse_count * 2))

    # Count broken references
    local broken_count
    broken_count=$(check_broken_references "$source_file" | wc -l)
    risk_score=$((risk_score + broken_count * 3))

    # Determine risk level
    if [ $risk_score -eq 0 ]; then
        echo "🟢 LOW (Isolated file)"
    elif [ $risk_score -le 5 ]; then
        echo "🟡 MEDIUM (Some dependencies)"
    elif [ $risk_score -le 15 ]; then
        echo "🟠 HIGH (Multiple dependencies)"
    else
        echo "🔴 CRITICAL (Highly interconnected)"
    fi
}

# Analyze all files in batch mode
batch_analysis() {
    sync "Running batch analysis on all documentation..."

    local total_files=0
    local high_risk_files=()
    local broken_refs_total=0

    while IFS= read -r file; do
        echo ""
        echo "📁 Analyzing: $file"
        total_files=$((total_files + 1))

        local risk_level
        risk_level=$(assess_risk_level "$file")

        if [[ "$risk_level" =~ "HIGH"|"CRITICAL" ]]; then
            high_risk_files+=("$file ($risk_level)")
        fi

        local broken_count
        broken_count=$(check_broken_references "$file" | wc -l)
        broken_refs_total=$((broken_refs_total + broken_count))

        echo "   Risk Level: $risk_level"
        echo "   Broken References: $broken_count"

    done < <(find_all_docs)

    echo ""
    report "Batch Analysis Summary:"
    echo "   Total Files Analyzed: $total_files"
    echo "   High-Risk Files: ${#high_risk_files[@]}"
    echo "   Total Broken References: $broken_refs_total"

    if [ ${#high_risk_files[@]} -gt 0 ]; then
        echo ""
        warning "High-Risk Files Requiring Attention:"
        for file in "${high_risk_files[@]}"; do
            echo "   - $file"
        done
    fi
}

# Command line interface
case "${1:-help}" in
    "analyze"|"")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 analyze <file-path> [output-file]"
            echo "Example: $0 analyze docs/policies/terminal-output-policy.md"
            exit 1
        fi

        source_file="$2"
        output_file="${3:-logs/impact_analysis_$(basename "$source_file" .md)_$(date +%Y%m%d_%H%M%S).md}"

        if [ ! -f "$source_file" ]; then
            error "File not found: $source_file"
            exit 1
        fi

        display_config
        target "Analyzing impact for: $source_file"
        echo ""

        generate_impact_report "$source_file" "$output_file"

        echo ""
        success "Impact analysis completed!"
        echo "   📄 Report: $output_file"
        echo "   📄 Log: $LOG_FILE"
        ;;

    "batch")
        display_config
        batch_analysis
        ;;

    "check-refs")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 check-refs <file-path>"
            exit 1
        fi

        source_file="$2"
        if [ ! -f "$source_file" ]; then
            error "File not found: $source_file"
            exit 1
        fi

        echo "🔍 Checking references in: $source_file"
        echo ""

        check "Direct References:"
        analyze_direct_references "$source_file" || echo "   None found"

        echo ""
        error "Broken References:"
        check_broken_references "$source_file" || echo "   None found"
        ;;

    "suggest")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 suggest <file-path>"
            exit 1
        fi

        source_file="$2"
        if [ ! -f "$source_file" ]; then
            error "File not found: $source_file"
            exit 1
        fi

        echo "💡 Suggesting related documentation for: $source_file"
        echo ""
        suggest_related_docs "$source_file"
        ;;

    "risk")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 risk <file-path>"
            exit 1
        fi

        source_file="$2"
        if [ ! -f "$source_file" ]; then
            error "File not found: $source_file"
            exit 1
        fi

        target "Risk assessment for: $source_file"
        echo "   Risk Level: $(assess_risk_level "$source_file")"
        ;;

    "help"|"--help"|"-h")
        echo "DevOnboarder Change Impact Analysis Script"
        echo ""
        echo "Usage: $0 [command] [arguments]"
        echo ""
        echo "Commands:"
        echo "   analyze <file> [output]  Generate comprehensive impact analysis report"
        echo "   batch                    Analyze all documentation files"
        echo "   check-refs <file>        Check references in specific file"
        echo "   suggest <file>           Suggest related documentation"
        echo "   risk <file>              Assess risk level for file changes"
        echo "   help                     Show this help"
        echo ""
        echo "Environment Variables:"
        echo "   DOCS_ROOT               Documentation root directory (default: docs)"
        echo "   ANALYSIS_MODE           Analysis mode (default: comprehensive)"
        echo "   CHECK_EXTERNAL_REFS     Check external references (default: true)"
        echo ""
        echo "Examples:"
        echo "   $0 analyze docs/policies/terminal-output-policy.md"
        echo "   $0 batch"
        echo "   $0 check-refs docs/development/architecture-overview.md"
        echo "   $0 suggest docs/troubleshooting/common-issues-resolution.md"
        ;;

    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
