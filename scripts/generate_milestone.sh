#!/bin/bash

# DevOnboarder Milestone Generation Script
# Automatically creates performance milestone records

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color

# Configuration
readonly MILESTONE_DIR="milestones"
readonly TEMPLATE_DIR="milestones/templates"
readonly LOGS_DIR="logs"

# Create directories if they don't exist
mkdir -p "$MILESTONE_DIR/$(date +%Y-%m)" "$TEMPLATE_DIR" "$LOGS_DIR"

# Log file for this script
LOG_FILE="$LOGS_DIR/milestone_generation_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

function print_header() {
    echo ""
    echo "=========================================="
    echo "DevOnboarder Milestone Generation"
    date
    echo "=========================================="
    echo ""
}

function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Generate performance milestone documentation"
    echo ""
    echo "Options:"
    echo "  --type TYPE        Milestone type (bug|feature|enhancement|ci-fix)"
    echo "  --issue NUMBER     Issue number (e.g., 1234)"
    echo "  --pr NUMBER        PR number (e.g., 5678)"
    echo "  --title TITLE      Brief title for the milestone"
    echo "  --priority LEVEL   Priority (critical|high|medium|low)"
    echo "  --template         Generate template only (no metrics capture)"
    echo "  --auto             Auto-detect from git context"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --type bug --issue 1234 --title 'CI failure fix'"
    echo "  $0 --auto --pr 5678"
    echo "  $0 --template --type feature"
}

function detect_context() {
    local branch_name
    local issue_number=""
    local pr_number=""
    local milestone_type="enhancement"

    branch_name=$(git branch --show-current 2>/dev/null || echo "main")

    # Extract issue/PR numbers from branch name
    if [[ $branch_name =~ issue-([0-9]+) ]]; then
        issue_number="${BASH_REMATCH[1]}"
    fi

    if [[ $branch_name =~ pr-([0-9]+) ]]; then
        pr_number="${BASH_REMATCH[1]}"
    fi

    # Determine type from branch prefix
    case $branch_name in
        feat/*|feature/*) milestone_type="feature" ;;
        fix/*|bugfix/*) milestone_type="bug" ;;
        enhance/*|enhancement/*) milestone_type="enhancement" ;;
        ci/*|chore/*) milestone_type="ci-fix" ;;
        *) milestone_type="enhancement" ;;
    esac

    echo "$milestone_type|$issue_number|$pr_number"
}

function generate_milestone_id() {
    local type="$1"
    local title="$2"
    local date_str

    date_str=$(date +%Y-%m-%d)

    # Sanitize title for filename
    local clean_title
    clean_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

    echo "${date_str}-${type}-${clean_title}"
}

function capture_performance_metrics() {
    local milestone_file="$1"

    echo "Capturing performance metrics..."

    # Git statistics
    local commit_count
    local files_changed
    local total_changes

    commit_count=$(git rev-list --count HEAD ^origin/main 2>/dev/null || echo "0")
    files_changed=$(git diff --name-only origin/main..HEAD 2>/dev/null | wc -l)
    total_changes=$(git diff --stat origin/main..HEAD 2>/dev/null | tail -1 | awk '{print $4 + $6}' || echo "0")

    # Recent test results
    local test_duration=""
    local success_rate=""
    local coverage=""

    if [[ -f "$LOGS_DIR/test_run_latest.log" ]]; then
        test_duration=$(grep -oP "======.*in \K[0-9.]+s" "$LOGS_DIR/test_run_latest.log" | tail -1 || echo "")
        success_rate=$(grep -oP "(\d+) passed" "$LOGS_DIR/test_run_latest.log" | head -1 | grep -oP "\d+" || echo "")
        coverage=$(grep -oP "TOTAL.*\K[0-9]+%" "$LOGS_DIR/test_run_latest.log" | tail -1 || echo "")
    fi

    # QC metrics
    local qc_duration=""
    if [[ -f "$LOGS_DIR/qc_pre_push_latest.log" ]]; then
        qc_duration=$(grep -oP "Quality Score.*" "$LOGS_DIR/qc_pre_push_latest.log" | tail -1 || echo "")
    fi

    # Write metrics to milestone file
    cat >> "$milestone_file" << EOF

## Automated Metrics Capture

### Git Statistics
- **Commits**: $commit_count
- **Files Changed**: $files_changed
- **Total Line Changes**: $total_changes

### Performance Data
- **Test Duration**: ${test_duration:-"Not captured"}
- **Success Rate**: ${success_rate:-"Not captured"} passed
- **Coverage**: ${coverage:-"Not captured"}
- **QC Score**: ${qc_duration:-"Not captured"}

### Timing Data
- **Milestone Generated**: $(date -Iseconds)
- **Branch**: $(git branch --show-current)
- **Commit**: $(git rev-parse --short HEAD)

EOF
}

function create_milestone_file() {
    local milestone_id="$1"
    local type="$2"
    local title="$3"
    local issue_number="$4"
    local pr_number="$5"
    local priority="$6"
    local template_only="$7"

    local milestone_file
    local complexity="moderate"  # Default

    milestone_file="$MILESTONE_DIR/$(date +%Y-%m)/${milestone_id}.md"

    echo "Creating milestone file: $milestone_file"

    # Generate the milestone file
    cat > "$milestone_file" << EOF
---
milestone_id: "$milestone_id"
date: "$(date +%Y-%m-%d)"
type: "$type"
issue_number: "${issue_number:+#$issue_number}"
pr_number: "${pr_number:+#$pr_number}"
priority: "$priority"
complexity: "$complexity"
generated_by: "scripts/generate_milestone.sh"
---

# $title - Performance Milestone

## Problem Statement

**What**: [Brief description of the issue/feature]
**Impact**: [Business/technical impact - critical, user-facing, development velocity, etc.]
**Scope**: [Files/services affected]

## DevOnboarder Tools Performance

### Resolution Timeline

| Phase | DevOnboarder Time | Standard Approach Time | Improvement Factor |
|-------|-------------------|------------------------|-------------------|
| **Diagnosis** | [X] minutes/seconds | [Y] minutes/hours | [Z]x faster |
| **Implementation** | [X] minutes/hours | [Y] hours/days | [Z]x faster |
| **Validation** | [X] seconds/minutes | [Y] minutes/hours | [Z]x faster |
| **Total Resolution** | [X] hours | [Y] hours/days | **[Z]x faster overall** |

### Automation Metrics

- **Manual Steps Eliminated**: [X] steps
- **Error Rate**: [X]% (vs [Y]% manual)
- **First-Attempt Success**: [X]% (vs [Y]% manual)
- **Validation Coverage**: [X]% automated

### Tools Used

- [ ] CI Failure Analyzer (\`scripts/enhanced_ci_failure_analyzer.py\`)
- [ ] Quick Validation (\`scripts/quick_validate.sh\`)
- [ ] QC Pre-Push (\`scripts/qc_pre_push.sh\`)
- [ ] Targeted Testing (\`scripts/validate_ci_locally.sh\`)
- [ ] Other: ________________

## Competitive Advantage Demonstrated

### Speed Improvements

- **Diagnosis Speed**: [X] faster than manual approach
- **Resolution Speed**: [X] faster than standard tools
- **Validation Speed**: [X] faster than manual testing

### Quality Improvements

- **Error Prevention**: [X] issues prevented through automation
- **Success Rate**: [X]% vs [Y]% industry standard
- **Coverage**: [X]% automated vs [Y]% manual

### Developer Experience

- **Learning Curve**: Reduced by [X]%
- **Context Switching**: Eliminated [X] manual steps
- **Documentation**: Auto-generated vs manual

## Evidence & Artifacts

### Performance Data

\`\`\`bash
# Commands run and timing
time ./scripts/[tool_name].sh  # [X] seconds
# vs estimated manual time: [Y] minutes

# Success metrics
echo "Success rate: [X]% first attempt"
echo "Coverage achieved: [X]%"
echo "Issues prevented: [X]"
\`\`\`

### Before/After Comparison

**Before DevOnboarder**:

- Manual process took [X] hours
- Required [Y] manual steps
- [Z]% success rate
- Required domain expertise

**After DevOnboarder**:

- Automated process takes [X] minutes
- [Y] steps automated
- [Z]% success rate
- Guided resolution with validation

## Strategic Impact

### Product Positioning

- **Competitive Advantage**: [X] faster than [competitor/manual approach]
- **Market Differentiation**: First to achieve [X]% automation in [Y] area
- **Value Proposition**: Reduces development time by [X]%

### Scalability Evidence

- **Team Onboarding**: New developers productive in [X] hours vs [Y] days
- **Knowledge Transfer**: Automated vs tribal knowledge
- **Consistency**: [X]% reproducible results vs [Y]% manual variation

## Integration Points

### Updated Systems

- [ ] CI/CD pipeline improvements
- [ ] Documentation updates
- [ ] Script enhancements
- [ ] Quality gate additions

### Knowledge Capture

- [ ] Pattern added to failure analysis database
- [ ] Troubleshooting guide updated
- [ ] Training materials enhanced
- [ ] Automation scripts improved

## Success Metrics Summary

| Metric | DevOnboarder | Industry Standard | Competitive Edge |
|--------|--------------|------------------|------------------|
| Resolution Time | [X] | [Y] | [Z]x faster |
| Success Rate | [X]% | [Y]% | +[Z] percentage points |
| Automation Level | [X]% | [Y]% | +[Z] percentage points |
| Developer Velocity | [X] | [Y] | [Z]x improvement |

---

**Milestone Impact**: [Brief summary of competitive advantage demonstrated]
**Next Optimization**: [What could be improved further]
**Replication**: [How this can be applied to similar issues]

EOF

    # Add automated metrics if not template-only
    if [[ "$template_only" != "true" ]]; then
        capture_performance_metrics "$milestone_file"
    fi

    echo -e "${GREEN}✅ Milestone file created: $milestone_file${NC}"
}

function main() {
    local type=""
    local issue_number=""
    local pr_number=""
    local title=""
    local priority="medium"
    local template_only="false"
    local auto_detect="false"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type)
                type="$2"
                shift 2
                ;;
            --issue)
                issue_number="$2"
                shift 2
                ;;
            --pr)
                pr_number="$2"
                shift 2
                ;;
            --title)
                title="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --template)
                template_only="true"
                shift
                ;;
            --auto)
                auto_detect="true"
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    print_header

    # Auto-detect context if requested
    if [[ "$auto_detect" == "true" ]]; then
        IFS='|' read -r type issue_number pr_number <<< "$(detect_context)"
        echo "Auto-detected context:"
        echo "  Type: $type"
        echo "  Issue: ${issue_number:-"none"}"
        echo "  PR: ${pr_number:-"none"}"
        echo ""
    fi

    # Validate required parameters
    if [[ -z "$type" ]]; then
        echo -e "${RED}Error: --type is required${NC}"
        usage
        exit 1
    fi

    if [[ ! "$type" =~ ^(bug|feature|enhancement|ci-fix|security|performance)$ ]]; then
        echo -e "${RED}Error: Invalid type. Must be one of: bug, feature, enhancement, ci-fix, security, performance${NC}"
        exit 1
    fi

    if [[ -z "$title" ]]; then
        # Generate default title
        title="$type"
        if [[ -n "$issue_number" ]]; then
            title="$title-issue-$issue_number"
        fi
        if [[ -n "$pr_number" ]]; then
            title="$title-pr-$pr_number"
        fi
    fi

    # Generate milestone ID
    local milestone_id
    milestone_id=$(generate_milestone_id "$type" "$title")

    echo "Generating milestone:"
    echo "  ID: $milestone_id"
    echo "  Type: $type"
    echo "  Title: $title"
    echo "  Priority: $priority"
    echo "  Template Only: $template_only"
    echo ""

    # Create the milestone file
    create_milestone_file "$milestone_id" "$type" "$title" "$issue_number" "$pr_number" "$priority" "$template_only"

    echo ""
    echo -e "${GREEN}🎯 Milestone generation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Edit the milestone file to add specific metrics"
    echo "2. Fill in performance comparison data"
    echo "3. Document competitive advantages achieved"
    echo "4. Add to monthly milestone summary"
    echo ""
    echo "File location: $MILESTONE_DIR/$(date +%Y-%m)/${milestone_id}.md"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
