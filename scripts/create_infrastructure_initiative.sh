#!/usr/bin/env bash
# GitHub Projects Workflow Automation - Phase 1 Implementation
# Creates infrastructure initiatives with automatic GitHub Projects integration

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034 # PROJECT_ROOT may be used by sourced scripts
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# GitHub Projects configuration
TEAM_PLANNING_PROJECT="4"
FEATURE_RELEASE_PROJECT="5"
ROADMAP_PROJECT="6"
ORG="theangrygamershowproductions"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <initiative_name> <initiative_type> <timeline> <priority>"
    echo ""
    echo "Arguments:"
    echo "  initiative_name   Name of the infrastructure initiative"
    echo "  initiative_type   Type: infrastructure|feature|security|quality"
    echo "  timeline         Timeline: 2-week|4-week|8-week"
    echo "  priority         Priority: P0|P1|P2"
    echo ""
    echo "Example:"
    echo "  $0 \"Docker Service Mesh\" infrastructure 4-week P0"
    exit 1
}

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}SUCCESS $1${NC}"
}

warn() {
    echo -e "${YELLOW}WARNING  $1${NC}"
}

error() {
    echo -e "${RED}FAILED $1${NC}"
    exit 1
}

validate_inputs() {
    if [[ -z "${INITIATIVE_NAME:-}" ]]; then
        error "Initiative name is required"
    fi

    if [[ ! "${INITIATIVE_TYPE:-}" =~ ^(infrastructure|feature|security|quality)$ ]]; then
        error "Initiative type must be: infrastructure|feature|security|quality"
    fi

    if [[ ! "${TIMELINE:-}" =~ ^(2-week|4-week|8-week)$ ]]; then
        error "Timeline must be: 2-week|4-week|8-week"
    fi

    if [[ ! "${PRIORITY:-}" =~ ^(P0|P1|P2)$ ]]; then
        error "Priority must be: P0|P1|P2"
    fi
}

check_github_cli() {
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed or not in PATH"
    fi

    if ! gh auth status &> /dev/null; then
        error "GitHub CLI is not authenticated. Run 'gh auth login'"
    fi
}

create_labels_if_needed() {
    local labels=("$@")

    for label in "${labels[@]}"; do
        if ! gh label list --json name | jq -e ".[] | select(.name == \"$label\")" > /dev/null; then
            log "Creating label: $label"
            case "$label" in
                "infrastructure")
                    gh label create "$label" --description "Infrastructure, automation, and CI/CD related tasks" --color "0366d6" || warn "Label $label might already exist"
                    ;;
                "automation")
                    gh label create "$label" --description "Automation and workflow enhancement" --color "857519" || warn "Label $label might already exist"
                    ;;
                "framework")
                    gh label create "$label" --description "Framework and infrastructure components" --color "8c564b" || warn "Label $label might already exist"
                    ;;
                *)
                    log "Label $label already exists or will be created manually"
                    ;;
            esac
        else
            log "Label $label already exists"
        fi
    done
}

generate_issue_template() {
    local phase="$1"
    local issue_title="$2"
    local issue_type="$3"

    cat << EOF
## $INITIATIVE_NAME - $phase

**Timeline**: $TIMELINE delivery plan
**Priority**: $PRIORITY ($issue_type)
**Initiative Type**: $INITIATIVE_TYPE

### Objective
[Automatically generated template - customize for specific phase]

### Implementation Tasks

#### Core Tasks
- [ ] Task 1 - [Customize based on phase]
- [ ] Task 2 - [Customize based on phase]
- [ ] Task 3 - [Customize based on phase]

#### Validation Tasks
- [ ] Integration testing
- [ ] Documentation updates
- [ ] Quality gate validation

### Success Criteria
- [ ] All implementation tasks completed
- [ ] Integration points validated
- [ ] Documentation updated and compliant
- [ ] Quality gates maintained (95%+ coverage)

### Integration Points
- **Dependencies**: [To be defined]
- **Enables**: [To be defined]
- **Related Issues**: [Cross-reference other initiative issues]

### Related Documentation
- Initiative Plan: codex/automation/github_projects_workflow_automation.md
- Coordination: [Master coordination issue]

**Phase Dependencies**: [Define dependencies]
**Next Phase**: [Define next steps]
EOF
}

create_initiative_issues() {
    local issues=()

    # Determine phases based on timeline
    case "$TIMELINE" in
        "2-week")
            phases=("Foundation" "Implementation")
            ;;
        "4-week")
            phases=("Phase 1: Foundation" "Phase 2: Implementation" "Phase 3: Validation" "Coordination")
            ;;
        "8-week")
            phases=("Phase 1: Foundation" "Phase 2: Core Implementation" "Phase 3: Advanced Features" "Phase 4: Integration" "Coordination")
            ;;
    esac

    for phase in "${phases[@]}"; do
        local issue_title="$INITIATIVE_TYPE: $INITIATIVE_NAME - $phase"
        local issue_body
        issue_body=$(generate_issue_template "$phase" "$issue_title" "$INITIATIVE_TYPE")

        log "Creating issue: $issue_title"

        # Determine labels based on initiative type and priority
        local label_list="$INITIATIVE_TYPE"
        if [[ "$PRIORITY" == "P0" ]]; then
            label_list="$label_list,critical,priority-high"
        elif [[ "$PRIORITY" == "P1" ]]; then
            label_list="$label_list,priority-high"
        fi

        if [[ "$phase" =~ "Foundation" ]]; then
            label_list="$label_list,foundation"
        fi

        # Create the issue
        local issue_url
        if issue_url=$(gh issue create --title "$issue_title" --body "$issue_body" --label "$label_list" 2>/dev/null); then
            success "Created issue: $issue_url"
            issues+=("$issue_url")
        else
            warn "Failed to create issue: $issue_title"
        fi
    done

    echo "${issues[@]}"
}

add_to_github_projects() {
    local issue_urls=("$@")

    for issue_url in "${issue_urls[@]}"; do
        log "Adding $issue_url to GitHub Projects"

        # Add to Team Planning (all issues)
        if gh project item-add "$TEAM_PLANNING_PROJECT" --owner "$ORG" --url "$issue_url" &> /dev/null; then
            success "Added to Team Planning project"
        else
            warn "Failed to add to Team Planning project"
        fi

        # Add to Feature Release (implementation issues)
        if [[ "$issue_url" =~ (Implementation|Phase) ]]; then
            if gh project item-add "$FEATURE_RELEASE_PROJECT" --owner "$ORG" --url "$issue_url" &> /dev/null; then
                success "Added to Feature Release project"
            else
                warn "Failed to add to Feature Release project"
            fi
        fi

        # Add coordination and strategic issues to Roadmap
        if [[ "$issue_url" =~ (Coordination|Strategic) ]] || [[ "$PRIORITY" == "P0" ]]; then
            if gh project item-add "$ROADMAP_PROJECT" --owner "$ORG" --url "$issue_url" &> /dev/null; then
                success "Added to Roadmap project"
            else
                warn "Failed to add to Roadmap project"
            fi
        fi
    done
}

update_readme_status() {
    log "Updating README.md project status"

    # This is a placeholder for README.md updates
    # In Phase 2, this will automatically update the Current Project Status section
    warn "README.md status update not yet implemented (Phase 2 feature)"
}

generate_summary_report() {
    local issue_urls=("$@")

    echo ""
    echo "=============================================="
    echo "TARGET Infrastructure Initiative Created Successfully"
    echo "=============================================="
    echo ""
    echo "Initiative: $INITIATIVE_NAME"
    echo "Type: $INITIATIVE_TYPE"
    echo "Timeline: $TIMELINE"
    echo "Priority: $PRIORITY"
    echo ""
    echo "SYMBOL Created Issues:"
    for issue_url in "${issue_urls[@]}"; do
        echo "  - $issue_url"
    done
    echo ""
    echo "STATS GitHub Projects:"
    echo "  - Team Planning: https://github.com/orgs/$ORG/projects/$TEAM_PLANNING_PROJECT"
    echo "  - Feature Release: https://github.com/orgs/$ORG/projects/$FEATURE_RELEASE_PROJECT"
    echo "  - Roadmap: https://github.com/orgs/$ORG/projects/$ROADMAP_PROJECT"
    echo ""
    echo "SYMBOL Next Steps:"
    echo "  1. Customize issue templates with specific implementation details"
    echo "  2. Assign team members to issues in GitHub Projects"
    echo "  3. Set up dependency tracking between issues"
    echo "  4. Begin implementation following the defined timeline"
    echo ""
}

main() {
    # Parse arguments
    INITIATIVE_NAME="${1:-}"
    INITIATIVE_TYPE="${2:-}"
    TIMELINE="${3:-}"
    PRIORITY="${4:-}"

    # Validate inputs
    if [[ $# -ne 4 ]]; then
        usage
    fi

    validate_inputs
    check_github_cli

    log "Starting infrastructure initiative creation"
    log "Initiative: $INITIATIVE_NAME ($INITIATIVE_TYPE, $TIMELINE, $PRIORITY)"

    # Create necessary labels
    create_labels_if_needed "$INITIATIVE_TYPE" "automation" "framework"

    # Create initiative issues
    local issue_urls
    mapfile -t issue_urls < <(create_initiative_issues)

    if [[ ${#issue_urls[@]} -eq 0 ]]; then
        error "No issues were created successfully"
    fi

    # Add issues to GitHub Projects
    add_to_github_projects "${issue_urls[@]}"

    # Update project documentation
    update_readme_status

    # Generate summary report
    generate_summary_report "${issue_urls[@]}"

    success "Infrastructure initiative '$INITIATIVE_NAME' created successfully!"
}

# Run main function
main "$@"
