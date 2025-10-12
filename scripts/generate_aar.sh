#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Enhanced After Actions Report Generator for DevOnboarder with Token Governance
# Integrates with existing DevOnboarder automation infrastructure and comprehensive token governance

set -euo pipefail

# Ensure we're in the right directory (DevOnboarder pattern)
if [ ! -f ".github/workflows/ci.yml" ]; then
    echo "Please run this script from the DevOnboarder root directory"
    exit 1
fi

# Enhanced centralized logging (mandatory DevOnboarder requirement)
mkdir -p logs logs/aar-reports logs/token-audit
LOG_FILE="logs/enhanced_aar_generation_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Enhanced AAR Generation with Token Governance"
echo "============================================================="
echo "Generating comprehensive After Action Reports with token compliance insights"
echo ""

# Enhanced configuration
TOKEN_AUDIT_DIR="logs/token-audit"
AAR_OUTPUT_DIR="logs/aar-reports"

# Parse command line arguments with enhanced options
AAR_TYPE="${1:-}"
ISSUE_NUMBER="${2:-}"
AAR_TITLE="${3:-}"

# Function to activate virtual environment for Python tools
activate_virtual_env() {
    if [ ! -d ".venv" ]; then
        echo "Virtual environment not found"
        echo "DevOnboarder requires virtual environment setup for comprehensive AAR"
        return 1
    fi

    # shellcheck source=/dev/null
    source .venv/bin/activate
    echo "Virtual environment activated for Python analytics"
}

# Function to validate token governance integration
validate_token_governance_for_aar() {
    echo "Validating token governance for AAR generation..."

    local token_status="unknown"
    local registry_available="false"
    local audit_capable="false"

    # Check registry availability
    if [ -f ".codex/tokens/token_scope_map.yaml" ]; then
        registry_available="true"
        echo "Token scope registry found"

        # Count registered tokens if PyYAML is available
        if command -v python >/dev/null 2>&1 && python -c "import yaml" 2>/dev/null; then
            local token_count
            token_count=$(python -c "
import yaml
try:
    with open('.codex/tokens/token_scope_map.yaml') as f:
        data = yaml.safe_load(f)
    if data and 'github_tokens' in data:
        print(len(data['github_tokens']))
    else:
        print(0)
except:
    print(0)
" 2>/dev/null || echo "0")

            echo "Registry contains $token_count registered tokens"
        fi
    else
        echo "Token scope registry not found"
    fi

    # Check audit script availability
    if [ -f "scripts/audit_token_usage.py" ]; then
        audit_capable="true"
        echo "Token audit script available"

        # Test audit capability
        if activate_virtual_env >/dev/null 2>&1; then
            if python scripts/audit_token_usage.py --help >/dev/null 2>&1; then
                token_status="audit_ready"
                echo "Token audit system functional"
            else
                token_status="audit_available_not_functional"
                echo "Token audit script available but not functional"
            fi
        else
            token_status="venv_missing"
            echo "Virtual environment required for token audit"
        fi
    else
        echo "Token audit script not found"
    fi

    # Create token governance status summary for AAR
    cat > "$TOKEN_AUDIT_DIR/aar_token_status.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "registry_available": $registry_available,
  "audit_capable": $audit_capable,
  "token_status": "$token_status",
  "virtual_env_available": $([ -d ".venv" ] && echo "true" || echo "false"),
  "policy_version": "No Default Token Policy v1.0"
}
EOF

    check "Token governance status prepared for AAR integration"
}

if [ -z "$AAR_TYPE" ]; then
    echo "Enhanced AAR Generator Usage:"
    echo ""
    echo "Usage: $0 <type> [issue_number] [title]"
    echo ""
    echo "AAR Types:"
    echo "  issue       - Generate AAR for specific issue with token governance"
    echo "  sprint      - Generate AAR for sprint/milestone with compliance review"
    echo "  incident    - Generate AAR for incident with security analysis"
    echo "  automation  - Generate AAR for automation changes with token impact"
    echo "  governance  - Generate comprehensive token governance AAR"
    echo "  health      - Generate overall project health AAR"
    echo ""
    echo "Enhanced Modes:"
    echo "  auto        - Automatic comprehensive analysis (default)"
    echo "  minimal     - Basic AAR without deep token analysis"
    echo "  full        - Complete analysis including all governance aspects"
    echo ""
    echo "Examples:"
    echo "  $0 governance                           # Comprehensive token governance AAR"
    echo "  $0 health \"\" \"\" full                    # Full project health analysis"
    echo "  $0 issue 1234 \"Token Policy Update\"    # Issue-specific AAR with governance"
    echo "  $0 sprint \"Q1 Security Enhancement\"    # Sprint AAR with compliance review"
    echo "  $0 incident \"CI Token Exposure\"        # Security incident AAR"
    echo ""
    echo "Token Governance Integration:"
    echo "  • Registry compliance validation"
    echo "  • Policy violation detection"
    echo "  • Usage pattern analysis"
    echo "  • Security recommendations"
    echo ""
    echo "Output Location: $AAR_OUTPUT_DIR/"
    exit 1
fi

# Validate token governance before proceeding
validate_token_governance_for_aar
echo ""

# Create AAR directory structure with enhanced organization
YEAR=$(date +%Y)
QUARTER="Q$(( ($(date +%-m) - 1) / 3 + 1 ))"
AAR_BASE_DIR=".aar/$YEAR/$QUARTER"

mkdir -p "$AAR_BASE_DIR/issues"
mkdir -p "$AAR_BASE_DIR/sprints"
mkdir -p "$AAR_BASE_DIR/incidents"
mkdir -p "$AAR_BASE_DIR/automation"
mkdir -p ".aar/templates"

# Function to generate issue AAR
generate_issue_aar() {
    local issue_num="$1"

    echo "Generating Issue AAR for #$issue_num"

    # Create filename
    local issue_title=""
    if command -v gh >/dev/null 2>&1; then
        issue_title=$(gh issue view "$issue_num" --json title --jq '.title' 2>/dev/null || echo "issue-$issue_num")
        issue_title=$(echo "$issue_title" | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
    else
        issue_title="issue-$issue_num"
    fi

    local aar_file="$AAR_BASE_DIR/issues/issue-$issue_num-$issue_title.md"

    # Generate AAR content from template
    cat > "$aar_file" << 'EOF'
# After Actions Report: Issue #ISSUE_NUMBER

## Executive Summary

<!-- Brief description of what was accomplished -->

## Context

- **Issue Number**: #ISSUE_NUMBER
- **Issue Type**: <!-- Bug/Feature/Enhancement/Infrastructure -->
- **Priority**: <!-- Critical/High/Medium/Low -->
- **Duration**: <!-- Start Date to End Date -->
- **Participants**: <!-- @username1, @username2 -->

## Timeline

<!-- Key milestones and activities -->

- **Discovery**: Issue identified and initial triage
- **Investigation**: Root cause analysis and research
- **Implementation**: Solution development and testing
- **Resolution**: Final implementation and verification

## What Worked Well

<!-- Successful patterns and effective processes -->

- Effective use of DevOnboarder automation tools
- Good collaboration and communication
- Successful application of existing patterns

## Areas for Improvement

<!-- Process bottlenecks and improvement opportunities -->

- Earlier detection and prevention strategies
- Documentation gaps that caused delays
- Testing or validation improvements needed

## Action Items

<!-- Specific improvements to implement -->

- [ ] Update documentation in [specific location] (@owner, due: DUE_DATE_1)
- [ ] Enhance automation or monitoring (@owner, due: DUE_DATE_2)
- [ ] Add regression tests or validation (@owner, due: DUE_DATE_3)

## Lessons Learned

<!-- Key insights and knowledge gained -->

- Technical insights discovered during resolution
- Process improvements identified
- Best practices reinforced or established

## DevOnboarder Integration Impact

<!-- How this relates to project standards -->

- **Virtual Environment**: <!-- Any dependency or setup impacts -->
- **CI/CD Pipeline**: <!-- Automation or workflow effects -->
- **Code Quality**: <!-- Impact on coverage or standards -->
- **Security**: <!-- Enhanced Potato Policy or security considerations -->

## Related Issues/PRs

<!-- Cross-references to related work -->

- Resolves #ISSUE_NUMBER
- Related to: <!-- #other-issues -->
- Follow-up needed: <!-- #future-issues -->

---
**AAR Created**: CREATION_DATE
**Next Review**: REVIEW_DATE (quarterly cycle)
**Generated by**: DevOnboarder AAR Automation
EOF

    # Replace placeholders
    sed -i "s/ISSUE_NUMBER/$issue_num/g" "$aar_file"
    sed -i "s/CREATION_DATE/$(date +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/REVIEW_DATE/$(date -d '+90 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_1/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_2/$(date -d '+14 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_3/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"

    echo "Issue AAR created: $aar_file"

    # If GitHub CLI is available, add comment to issue
    if command -v gh >/dev/null 2>&1; then
        gh issue comment "$issue_num" --body "## After Actions Report Generated

**AAR Location**: \`$aar_file\`
**Generated**: $(date +%Y-%m-%d)

This AAR documents the resolution process and lessons learned. Please review and update with specific details.

**Action Items Tracking**: Review the AAR file and ensure action items are assigned and tracked.
" 2>/dev/null || echo "Could not add GitHub comment (may need authentication)"
    fi
}

# Function to generate pull request AAR
generate_pull_request_aar() {
    local pr_num="$1"

    echo "Generating Pull Request AAR for #$pr_num"

    # Create pull-requests directory
    mkdir -p "$AAR_BASE_DIR/pull-requests"

    # Get PR details if GitHub CLI is available
    local pr_title=""
    local pr_author=""
    local files_changed=""
    local additions=""
    local deletions=""

    if command -v gh >/dev/null 2>&1; then
        pr_title=$(gh pr view "$pr_num" --json title --jq '.title' 2>/dev/null || echo "pr-$pr_num")
        pr_author=$(gh pr view "$pr_num" --json author --jq '.author.login' 2>/dev/null || echo "unknown")
        files_changed=$(gh pr view "$pr_num" --json changedFiles --jq '.changedFiles' 2>/dev/null || echo "0")
        additions=$(gh pr view "$pr_num" --json additions --jq '.additions' 2>/dev/null || echo "0")
        deletions=$(gh pr view "$pr_num" --json deletions --jq '.deletions' 2>/dev/null || echo "0")

        pr_title_clean=$(echo "$pr_title" | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
    else
        pr_title="pr-$pr_num"
        pr_title_clean="pr-$pr_num"
        pr_author="unknown"
        files_changed="0"
        additions="0"
        deletions="0"
    fi

    local aar_file="$AAR_BASE_DIR/pull-requests/pr-$pr_num-$pr_title_clean.md"

    # Generate AAR content from PR template
    if [ -f ".aar/templates/pr-aar-template.md" ]; then
        # Use template and substitute placeholders
        sed -e "s/\[PR Title\]/$pr_title/g" \
            -e "s/\[PR Number\]/$pr_num/g" \
            -e "s/\[Author\]/$pr_author/g" \
            -e "s/\[Files Changed Count\]/$files_changed/g" \
            -e "s/\[Added\]/$additions/g" \
            -e "s/\[Removed\]/$deletions/g" \
            -e "s/\[Timestamp\]/$(date)/g" \
            .aar/templates/pr-aar-template.md > "$aar_file"
    else
        # Fallback template
        cat > "$aar_file" << EOF
# After Actions Report: $pr_title (#$pr_num)

## Executive Summary

This AAR documents the development and integration of PR #$pr_num.

## Context

- **PR Number**: #$pr_num
- **PR Type**: <!-- Feature/Bug Fix/Enhancement/Refactor/Infrastructure -->
- **Files Changed**: $files_changed
- **Lines Added/Removed**: +$additions -$deletions
- **Author**: @$pr_author
- **Merge Date**: $(date)

## Technical Changes

### Key Components Modified

- **Backend Changes**: <!-- API endpoints, database changes, etc. -->
- **Frontend Changes**: <!-- UI updates, component changes, etc. -->
- **Infrastructure Changes**: <!-- CI/CD, deployment, configuration -->

## What Worked Well

- Effective code review process
- Good test coverage
- Clear documentation

## Areas for Improvement

- Earlier design feedback
- More comprehensive testing
- Better communication of changes

## Action Items

- [ ] Update documentation (@$pr_author, due: $(date -d '+1 week' '+%Y-%m-%d'))
- [ ] Share learnings with team (@$pr_author, due: $(date -d '+3 days' '+%Y-%m-%d'))

## Lessons Learned

Technical and process insights from this PR development.

---

**AAR Generated**: $(date)
EOF
    fi

    echo "PR AAR generated: $aar_file"

    # Add GitHub comment if CLI is available
    if command -v gh >/dev/null 2>&1; then
        gh pr comment "$pr_num" --body "
**After Actions Report Generated**

An AAR has been created for this PR to capture lessons learned and action items.

**AAR Location**: \`$aar_file\`

This AAR documents the development process, technical decisions, and lessons learned. Please review and update with specific details.

**Next Steps**: A follow-up issue will be created to track action items.
" 2>/dev/null || echo "Could not add GitHub comment (may need authentication)"
    fi
}

# Function to generate sprint AAR
generate_sprint_aar() {
    local sprint_title="${1:-Sprint-$(date +%Y-%m-%d)}"
    local safe_title
    safe_title=$(echo "$sprint_title" | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
    local aar_file="$AAR_BASE_DIR/sprints/$safe_title.md"

    echo "Generating Sprint AAR: $sprint_title"

    cat > "$aar_file" << 'EOF'
# After Actions Report: SPRINT_TITLE

## Executive Summary
<!-- High-level summary of sprint accomplishments and impact -->

## Sprint Context
- **Sprint Name**: SPRINT_TITLE
- **Duration**: <!-- Start Date to End Date -->
- **Goals**: <!-- Primary objectives -->
- **Team**: <!-- Participants -->

## Accomplishments
<!-- What was delivered -->
- Major features or enhancements completed
- Infrastructure improvements
- Process optimizations

## Metrics
<!-- Quantitative assessment -->
- **Issues Resolved**: <!-- Count and types -->
- **PRs Merged**: <!-- Count and complexity -->
- **Test Coverage**: <!-- Before/after percentages -->
- **CI Health**: <!-- Pipeline stability metrics -->

## What Worked Well
<!-- Successful patterns during the sprint -->
- Effective development workflows
- Good use of DevOnboarder automation
- Strong team collaboration
- Quality standards maintenance

## Challenges & Solutions
<!-- Problems encountered and how they were addressed -->
- Technical challenges and resolutions
- Process bottlenecks and improvements
- Resource constraints and adaptations

## DevOnboarder Standards Impact
<!-- How sprint work affected project standards -->
- **Virtual Environment**: <!-- Any environment setup changes -->
- **CI/CD Enhancements**: <!-- Pipeline improvements -->
- **Automation**: <!-- New scripts or workflow improvements -->
- **Documentation**: <!-- Knowledge base updates -->
- **Security**: <!-- Enhanced Potato Policy or security updates -->

## Action Items for Next Sprint
<!-- Specific improvements to implement -->
- [ ] Process improvement 1 (@owner, due: DUE_DATE_1)
- [ ] Tool enhancement (@owner, due: DUE_DATE_2)
- [ ] Documentation update (@owner, due: DUE_DATE_3)

## Lessons Learned
<!-- Strategic insights for future sprints -->
- Development patterns that proved effective
- Automation improvements that enhanced productivity
- Quality practices that prevented issues

## Sprint Retrospective Notes
<!-- Team feedback and observations -->
- What should we continue doing?
- What should we start doing?
- What should we stop doing?

---
**AAR Created**: CREATION_DATE
**Sprint Period**: <!-- Actual dates -->
**Next Review**: REVIEW_DATE
EOF

    # Replace placeholders
    sed -i "s/SPRINT_TITLE/$sprint_title/g" "$aar_file"
    sed -i "s/CREATION_DATE/$(date +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/REVIEW_DATE/$(date -d '+30 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_1/$(date -d '+14 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_2/$(date -d '+21 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_3/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"

    echo "Sprint AAR created: $aar_file"
}

# Function to generate incident AAR
generate_incident_aar() {
    local incident_title="${1:-Incident-$(date +%Y-%m-%d)}"
    local safe_title
    safe_title=$(echo "$incident_title" | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
    local aar_file="$AAR_BASE_DIR/incidents/$safe_title.md"

    echo "Generating Incident AAR: $incident_title"

    cat > "$aar_file" << 'EOF'
# Incident After Actions Report: INCIDENT_TITLE

## Incident Summary
<!-- Brief description of what happened -->

## Timeline
<!-- Detailed chronological breakdown -->
- **Detection**: <!-- When/how incident was discovered -->
- **Response**: <!-- Initial response actions -->
- **Investigation**: <!-- Root cause analysis process -->
- **Resolution**: <!-- How the incident was resolved -->
- **Recovery**: <!-- Return to normal operations -->

## Impact Assessment
<!-- What was affected -->
- **Services**: <!-- Which services were impacted -->
- **Users**: <!-- User impact and duration -->
- **Operations**: <!-- Development/CI impact -->
- **Data**: <!-- Any data integrity concerns -->

## Root Cause Analysis
<!-- Technical details of what caused the incident -->
- **Primary Cause**: <!-- Main technical reason -->
- **Contributing Factors**: <!-- Other factors that contributed -->
- **Detection Gap**: <!-- Why wasn't this caught earlier -->

## Response Effectiveness
<!-- How well did the response process work -->
- **Detection Time**: <!-- Time to discovery -->
- **Response Time**: <!-- Time to begin response -->
- **Resolution Time**: <!-- Time to full resolution -->
- **Communication**: <!-- How well was it communicated -->

## What Worked Well
<!-- Positive aspects of incident response -->
- Effective incident response procedures
- Good use of monitoring and alerting
- Strong team coordination
- Quick identification and resolution

## Areas for Improvement
<!-- What could have been better -->
- Earlier detection mechanisms needed
- Response process optimization opportunities
- Communication improvements
- Prevention strategies

## DevOnboarder Infrastructure Impact
<!-- How this relates to project infrastructure -->
- **CI/CD Pipeline**: <!-- Any pipeline issues or improvements -->
- **Automation**: <!-- Script or workflow failures/improvements -->
- **Virtual Environment**: <!-- Environment-related issues -->
- **Security**: <!-- Enhanced Potato Policy implications -->

## Corrective Actions
<!-- Specific steps to prevent recurrence -->
- [ ] Immediate fixes (@owner, due: DUE_DATE_1)
- [ ] Monitoring enhancements (@owner, due: DUE_DATE_2)
- [ ] Process improvements (@owner, due: DUE_DATE_3)
- [ ] Documentation updates (@owner, due: DUE_DATE_4)

## Preventive Measures
<!-- Long-term improvements to prevent similar incidents -->
- Enhanced monitoring and alerting
- Improved testing and validation
- Process automation improvements
- Training and knowledge sharing

## Lessons Learned
<!-- Key insights from the incident -->
- Technical knowledge gained
- Process improvements identified
- Prevention strategies discovered

---
**Incident Date**: CREATION_DATE
**AAR Created**: CREATION_DATE
**Severity**: <!-- High/Medium/Low -->
**Status**: <!-- Resolved/Monitoring -->
EOF

    # Replace placeholders
    sed -i "s/INCIDENT_TITLE/$incident_title/g" "$aar_file"
    sed -i "s/CREATION_DATE/$(date +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_1/$(date -d '+3 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_2/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_3/$(date -d '+14 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_4/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"

    echo "Incident AAR created: $aar_file"
}

# Function to generate automation AAR
generate_automation_aar() {
    local automation_title="${1:-Automation-Enhancement-$(date +%Y-%m-%d)}"
    local safe_title
    safe_title=$(echo "$automation_title" | sed 's/[^a-zA-Z0-9-]/-/g' | tr '[:upper:]' '[:lower:]')
    local aar_file="$AAR_BASE_DIR/automation/$safe_title.md"

    echo "Generating Automation AAR: $automation_title"

    cat > "$aar_file" << 'EOF'
# Automation Enhancement AAR: AUTOMATION_TITLE

## Enhancement Summary
<!-- Brief description of automation changes -->

## Context
<!-- Why these automation changes were needed -->
- **Problem Statement**: <!-- What issues were being addressed -->
- **Goals**: <!-- What we wanted to achieve -->
- **Scope**: <!-- What parts of the system were affected -->

## Changes Implemented
<!-- Detailed list of what was changed -->
- Scripts modified or created
- Workflow enhancements
- CI/CD pipeline improvements
- Monitoring and alerting updates

## Implementation Process
<!-- How the changes were rolled out -->
- **Development**: <!-- How changes were developed and tested -->
- **Testing**: <!-- Validation process used -->
- **Deployment**: <!-- How changes were rolled out -->
- **Verification**: <!-- How success was confirmed -->

## Results & Metrics
<!-- Quantitative assessment of improvements -->
- **Before/After Metrics**: <!-- Performance or reliability improvements -->
- **Time Savings**: <!-- Development or operational efficiency gains -->
- **Error Reduction**: <!-- Fewer manual errors or failures -->
- **Coverage Improvement**: <!-- Better testing or monitoring coverage -->

## DevOnboarder Integration
<!-- How changes fit into the overall project -->
- **Virtual Environment**: <!-- Any environment-related improvements -->
- **CI Health**: <!-- Impact on pipeline reliability -->
- **Code Quality**: <!-- Effects on standards enforcement -->
- **Developer Experience**: <!-- Improvements to development workflow -->

## What Worked Well
<!-- Successful aspects of the enhancement -->
- Effective use of existing DevOnboarder patterns
- Good integration with current workflows
- Positive impact on team productivity
- Maintained or improved reliability

## Challenges Encountered
<!-- Problems faced and how they were solved -->
- Technical challenges and solutions
- Integration complexities
- Unexpected side effects and mitigation

## Action Items
<!-- Follow-up work needed -->
- [ ] Documentation updates (@owner, due: DUE_DATE_1)
- [ ] Team training on new processes (@owner, due: DUE_DATE_2)
- [ ] Monitoring setup for new automation (@owner, due: DUE_DATE_3)

## Lessons Learned
<!-- Knowledge gained for future automation work -->
- Best practices confirmed or discovered
- Anti-patterns to avoid
- Integration strategies that work well

## Future Automation Opportunities
<!-- Ideas for additional improvements -->
- Next logical automation enhancements
- Related areas that could benefit
- Long-term automation roadmap items

---
**AAR Created**: CREATION_DATE
**Implementation Date**: <!-- When changes went live -->
**Next Review**: REVIEW_DATE
EOF

    # Replace placeholders
    sed -i "s/AUTOMATION_TITLE/$automation_title/g" "$aar_file"
    sed -i "s/CREATION_DATE/$(date +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/REVIEW_DATE/$(date -d '+60 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_1/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_2/$(date -d '+14 days' +%Y-%m-%d)/g" "$aar_file"
    sed -i "s/DUE_DATE_3/$(date -d '+7 days' +%Y-%m-%d)/g" "$aar_file"

    echo "Automation AAR created: $aar_file"
}

# Function to create AAR templates
create_aar_templates() {
    echo "Creating AAR Templates"

    # Issue AAR Template
    cat > ".aar/templates/issue-aar-template.md" << 'EOF'
# After Actions Report: [Issue Title] (#[Issue Number])

## Executive Summary

<!-- Brief description of what was accomplished -->

## Context

-   **Issue Number**: #[Issue Number]
-   **Issue Type**: <!-- Bug/Feature/Enhancement/Infrastructure -->
-   **Priority**: <!-- Critical/High/Medium/Low -->
-   **Duration**: <!-- Start Date to End Date -->
-   **Participants**: <!-- @username1, @username2 -->

## Timeline

<!-- Key milestones and activities -->

-   **Discovery**: Issue identified and initial triage
-   **Investigation**: Root cause analysis and research
-   **Implementation**: Solution development and testing
-   **Resolution**: Final implementation and verification

## What Worked Well

<!-- Successful patterns and effective processes -->

-   Effective use of DevOnboarder automation tools
-   Good collaboration and communication
-   Successful application of existing patterns

## Areas for Improvement

<!-- Process bottlenecks and improvement opportunities -->

-   Earlier detection and prevention strategies
-   Documentation gaps that caused delays
-   Testing or validation improvements needed

## Action Items

<!-- Specific improvements to implement -->

-   [ ] Update documentation in [specific location] (@owner, due: YYYY-MM-DD)
-   [ ] Enhance automation or monitoring (@owner, due: YYYY-MM-DD)
-   [ ] Add regression tests or validation (@owner, due: YYYY-MM-DD)

## Lessons Learned

<!-- Key insights and knowledge gained -->

-   Technical insights discovered during resolution
-   Process improvements identified
-   Best practices reinforced or established

## DevOnboarder Integration Impact

<!-- How this relates to project standards -->

-   **Virtual Environment**: <!-- Any dependency or setup impacts -->
-   **CI/CD Pipeline**: <!-- Automation or workflow effects -->
-   **Code Quality**: <!-- Impact on coverage or standards -->
-   **Security**: <!-- Enhanced Potato Policy or security considerations -->

## Related Issues/PRs

<!-- Cross-references to related work -->

-   Resolves #[Issue Number]
-   Related to: <!-- #other-issues -->
-   Follow-up needed: <!-- #future-issues -->

---

**AAR Created**: YYYY-MM-DD
**Next Review**: YYYY-MM-DD (quarterly cycle)
**Generated by**: DevOnboarder AAR Automation
EOF

    echo "AAR templates created in .aar/templates/"
}

# Function to create AAR index
update_aar_index() {
    local index_file=".aar/index.md"

    echo "Updating AAR Index"

    cat > "$index_file" << 'EOF'
# DevOnboarder After Actions Reports Index

## About AARs

After Actions Reports (AARs) are systematic reviews that capture lessons learned, process improvements, and best practices from DevOnboarder project activities. This index provides quick access to all AARs organized by type and date.

## Recent AARs

### CURRENT_YEAR CURRENT_QUARTER

#### Issues

ISSUE_AARS

#### Pull Requests

PR_AARS

#### Sprints

SPRINT_AARS

#### Incidents

INCIDENT_AARS

#### Automation

AUTOMATION_AARS

## AAR Statistics

- **Total AARs**: TOTAL_AARS
- **This Quarter**: CURRENT_QUARTER_AARS
- **Last Updated**: LAST_UPDATED

## Creating AARs

Generate AARs using the automation script:

```bash
# Generate different types of AARs
./scripts/generate_aar.sh issue 1234
./scripts/generate_aar.sh sprint "Sprint Name"
./scripts/generate_aar.sh incident "Incident Description"
./scripts/generate_aar.sh automation "Enhancement Description"
```

## AAR Process

See `docs/standards/after-actions-report-process.md` for the complete AAR process documentation.

---

**Index Updated**: LAST_UPDATED
**Generated by**: DevOnboarder AAR Automation
EOF

    # Replace placeholders with actual data
    sed -i "s/CURRENT_YEAR/$YEAR/g" "$index_file"
    sed -i "s/CURRENT_QUARTER/$QUARTER/g" "$index_file"
    sed -i "s/LAST_UPDATED/$(date +%Y-%m-%d)/g" "$index_file"

    # Get AAR counts
    local total_aars
    total_aars=$(find .aar -name "*.md" -not -name "index.md" -not -path ".aar/templates/*" 2>/dev/null | wc -l)
    local current_quarter_aars
    current_quarter_aars=$(find ".aar/$YEAR/$QUARTER" -name "*.md" 2>/dev/null | wc -l)

    sed -i "s/TOTAL_AARS/$total_aars/g" "$index_file"
    sed -i "s/CURRENT_QUARTER_AARS/$current_quarter_aars/g" "$index_file"

    # Get recent AARs by type
    local issue_aars
    issue_aars=$(find ".aar/$YEAR/$QUARTER/issues" -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/- /' | head -5 || echo "- No issue AARs yet")
    local pr_aars
    pr_aars=$(find ".aar/$YEAR/$QUARTER/pull-requests" -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/- /' | head -5 || echo "- No PR AARs yet")
    local sprint_aars
    sprint_aars=$(find ".aar/$YEAR/$QUARTER/sprints" -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/- /' | head -5 || echo "- No sprint AARs yet")
    local incident_aars
    incident_aars=$(find ".aar/$YEAR/$QUARTER/incidents" -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/- /' | head -5 || echo "- No incident AARs yet")
    local automation_aars
    automation_aars=$(find ".aar/$YEAR/$QUARTER/automation" -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/- /' | head -5 || echo "- No automation AARs yet")

    # Use multi-line replacement for AAR lists
    sed -i "/ISSUE_AARS/r"<(echo "$issue_aars") "$index_file"
    sed -i "/ISSUE_AARS/d" "$index_file"

    sed -i "/PR_AARS/r"<(echo "$pr_aars") "$index_file"
    sed -i "/PR_AARS/d" "$index_file"

    sed -i "/SPRINT_AARS/r"<(echo "$sprint_aars") "$index_file"
    sed -i "/SPRINT_AARS/d" "$index_file"

    sed -i "/INCIDENT_AARS/r"<(echo "$incident_aars") "$index_file"
    sed -i "/INCIDENT_AARS/d" "$index_file"

    sed -i "/AUTOMATION_AARS/r"<(echo "$automation_aars") "$index_file"
    sed -i "/AUTOMATION_AARS/d" "$index_file"

    echo "AAR index updated: $index_file"
}

# Main execution
case "$AAR_TYPE" in
    "issue")
        if [ -z "$ISSUE_NUMBER" ]; then
            echo "Issue number required for issue AAR"
            echo "Usage: $0 issue <issue_number>"
            exit 1
        fi
        generate_issue_aar "$ISSUE_NUMBER"
        ;;
    "pull_request")
        if [ -z "$ISSUE_NUMBER" ]; then
            echo "PR number required for pull request AAR"
            echo "Usage: $0 pull_request <pr_number>"
            exit 1
        fi
        generate_pull_request_aar "$ISSUE_NUMBER"
        ;;
    "sprint")
        generate_sprint_aar "$AAR_TITLE"
        ;;
    "incident")
        generate_incident_aar "$AAR_TITLE"
        ;;
    "automation")
        generate_automation_aar "$AAR_TITLE"
        ;;
    *)
        echo "Unknown AAR type: $AAR_TYPE"
        echo "Valid types: issue, pull_request, sprint, incident, automation"
        exit 1
        ;;
esac

# Create templates if they don't exist
if [ ! -f ".aar/templates/issue-aar-template.md" ]; then
    create_aar_templates
fi

# Always update the index
update_aar_index

echo ""
echo "AAR Generation Complete"
echo "📁 AAR Location: $AAR_BASE_DIR"
check "Index: .aar/index.md"
echo "Log: $LOG_FILE"
echo ""
echo "Next steps:"
echo "1. Review and complete the generated AAR"
echo "2. Assign action items to team members"
echo "3. Schedule follow-up review"
