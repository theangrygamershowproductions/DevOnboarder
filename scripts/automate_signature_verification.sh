#!/bin/bash

# automate_signature_verification.sh - Automated signature verification workflow
# Follows DevOnboarder terminal output compliance and centralized logging

set -euo pipefail

# Centralized logging setup
mkdir -p logs
LOG_FILE="logs/signature_verification_$(date %Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starting automated signature verification workflow"
echo "Log file: $LOG_FILE"

# Function to check signature status
check_signature_status() {
    local commit_range="${1:-HEAD~5..HEAD}"
    echo "Checking signature status for commits: $commit_range"

    # Get commit signatures
    local signature_output
    signature_output=$(git log --show-signature --oneline "$commit_range" 2>&1 || true)

    echo "Signature verification results:"
    echo "$signature_output"

    # Parse signature statuses
    local good_signatures=0
    local unverified_signatures=0
    local no_signatures=0
    local bad_signatures=0

    while read -r line; do
        if [[ "$line" =~ ^gpg:.*Good\ signature ]]; then
            ((good_signatures))
        elif [[ "$line" =~ ^gpg:.*Can\'t\ check\ signature ]]; then
            ((unverified_signatures))
        elif [[ "$line" =~ ^gpg:.*BAD\ signature ]]; then
            ((bad_signatures))
        elif [[ "$line" =~ ^[a-f0-9]{7,}[[:space:]] ]]; then
            # Commit line without signature info means no signature
            ((no_signatures))
        fi
    done <<< "$signature_output"

    echo "=== Signature Summary ==="
    echo "Good signatures (G): $good_signatures"
    echo "Unverified signatures (U): $unverified_signatures"
    echo "No signatures (N): $no_signatures"
    echo "Bad signatures (BAD): $bad_signatures"

    # Return status counts
    echo "$good_signatures:$unverified_signatures:$no_signatures:$bad_signatures"
}

# Function to import GitHub GPG keys for U status resolution
import_github_keys() {
    echo "Importing GitHub GPG keys to resolve U status signatures"

    # Allow GPG key IDs to be provided via the GITHUB_GPG_KEYS environment variable (space or comma separated)
    local github_keys
    if [[ -n "${GITHUB_GPG_KEYS:-}" ]]; then
        # Support both space and comma as separators
        IFS=', ' read -r -a github_keys <<< "${GITHUB_GPG_KEYS//,/ }"
    else
        github_keys=("B5690EEEBB952194" "4AEE18F83AFDEB23")
    fi

    for key in "${github_keys[@]}"; do
        echo "Importing GitHub key: $key"
        if gpg --keyserver keys.openpgp.org --recv-keys "$key" 2>/dev/null; then
            echo "Successfully imported key: $key"
        else
            echo " Failed to import key: $key"
        fi
    done

    # Check if automated setup script exists
    if [[ -f "scripts/setup_github_gpg_keys.sh" ]]; then
        echo "Running automated GitHub GPG key setup"
        bash scripts/setup_github_gpg_keys.sh || echo " Automated key setup failed"
    fi
}

# Function to analyze problematic signatures
analyze_problematic_signatures() {
    local no_signatures="$1"
    local bad_signatures="$2"

    if [[ "$no_signatures" -gt 0 || "$bad_signatures" -gt 0 ]]; then
        echo "=== CRITICAL: Problematic signatures detected ==="
        echo "No signatures (N): $no_signatures commits"
        echo "Bad signatures (BAD): $bad_signatures commits"

        echo "Detailed analysis of problematic commits:"
        git log --show-signature --oneline HEAD~10..HEAD 2>&1 | grep -A2 -B1 -E "BAD|^[a-f0-9]{7,40}\b" || true

        echo "RECOMMENDED ACTIONS:"
        if [[ "$bad_signatures" -gt 0 ]]; then
            echo "1. CRITICAL: Bad signatures indicate potential security compromise"
            echo "2. Investigate all commits with BAD signature status immediately"
            echo "3. Contact repository administrators"
            echo "4. DO NOT merge until resolved"
        fi

        if [[ "$no_signatures" -gt 0 ]]; then
            echo "1. Review commits without signatures"
            echo "2. Use interactive rebase to add signatures if needed"
            echo "3. Ensure all future commits are signed"
            echo "4. Check git config for signing setup"
        fi

        return 1
    fi

    return 0
}

# Function to verify git signing configuration
verify_git_config() {
    echo "=== Verifying Git Signing Configuration ==="

    local user_email
    user_email=$(git config user.email 2>/dev/null || echo "NOT_CONFIGURED")
    echo "Git user email: $user_email"

    local signing_key
    signing_key=$(git config user.signingkey 2>/dev/null || echo "NOT_CONFIGURED")
    echo "Git signing key: $signing_key"

    local commit_gpgsign
    commit_gpgsign=$(git config commit.gpgsign 2>/dev/null || echo "false")
    echo "Commit GPG signing enabled: $commit_gpgsign"

    local gpg_format
    gpg_format=$(git config gpg.format 2>/dev/null || echo "openpgp")
    echo "GPG format: $gpg_format"

    # Check if configuration is complete
    if [[ "$user_email" == "NOT_CONFIGURED" || "$signing_key" == "NOT_CONFIGURED" ]]; then
        echo " Git signing configuration incomplete"
        echo "RECOMMENDED ACTIONS:"
        echo "1. Set user email: git config user.email 'your-email@example.com'"
        echo "2. Set signing key: git config user.signingkey 'your-key-id'"
        echo "3. Enable signing: git config commit.gpgsign true"
        return 1
    fi

    return 0
}

# Function to generate signature verification report
generate_report() {
    local signature_counts="$1"
    local config_status="$2"

    IFS=':' read -r good unverified none bad <<< "$signature_counts"

    echo "=== SIGNATURE VERIFICATION REPORT ==="
    echo "Generated: $(date)"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "SIGNATURE STATUS:"
    echo "  Good (G): $good commits"
    echo "  Unverified (U): $unverified commits"
    echo "  None (N): $none commits"
    echo "  Bad (BAD): $bad commits"
    echo ""
    echo "GIT CONFIGURATION:"
    if [[ "$config_status" == "0" ]]; then
        echo "  Status: CONFIGURED"
    else
        echo "  Status: INCOMPLETE"
    fi
    echo ""

    # Determine overall status
    local overall_status="UNKNOWN"
    if [[ "$bad" -gt 0 ]]; then
        overall_status="CRITICAL"
    elif [[ "$none" -gt 0 ]]; then
        overall_status="WARNING"
    elif [[ "$unverified" -gt 0 ]]; then
        overall_status="ATTENTION_NEEDED"
    elif [[ "$good" -gt 0 ]]; then
        overall_status="GOOD"
    fi

    echo "OVERALL STATUS: $overall_status"
    echo ""

    case "$overall_status" in
        "CRITICAL")
            echo "IMMEDIATE ACTION REQUIRED:"
            echo "- Bad signatures detected - potential security issue"
            echo "- Do not merge until resolved"
            echo "- Contact repository administrators"
            ;;
        "WARNING")
            echo "ACTION RECOMMENDED:"
            echo "- Unsigned commits found"
            echo "- Review and sign commits as needed"
            echo "- Configure git signing for future commits"
            ;;
        "ATTENTION_NEEDED")
            echo "OPTIONAL ACTION:"
            echo "- Import GitHub keys to verify merge commits"
            echo "- Run: $0 --import-keys"
            ;;
        "GOOD")
            echo "NO ACTION REQUIRED:"
            echo "- All commits properly signed and verified"
            ;;
    esac
}

# Main workflow
main() {
    local import_keys=false
    local commit_range="HEAD~5..HEAD"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --import-keys)
                import_keys=true
                shift
                ;;
            --range)
                commit_range="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [--import-keys] [--range RANGE]"
                echo "Options:"
                echo "  --import-keys    Import GitHub GPG keys for verification"
                echo "  --range RANGE    Specify commit range (default: HEAD~5..HEAD)"
                echo "Examples:"
                echo "  $0                           # Check last 5 commits"
                echo "  $0 --import-keys             # Import keys and check"
                echo "  $0 --range HEAD~10..HEAD     # Check last 10 commits"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    echo "=== Automated Signature Verification ==="
    echo "Commit range: $commit_range"

    # Step 1: Import GitHub keys if requested
    if [[ "$import_keys" == true ]]; then
        echo "=== Step 1: Importing GitHub GPG Keys ==="
        import_github_keys
    fi

    # Step 2: Check signature status
    echo "=== Step 2: Checking Signature Status ==="
    local signature_counts
    signature_counts=$(check_signature_status "$commit_range")

    # Step 3: Verify git configuration
    echo "=== Step 3: Verifying Git Configuration ==="
    local config_status=0
    verify_git_config || config_status=$?

    # Step 4: Analyze problematic signatures
    echo "=== Step 4: Analyzing Signatures ==="
    IFS=':' read -r good unverified none bad <<< "$signature_counts"
    local analysis_status=0
    analyze_problematic_signatures "$none" "$bad" || analysis_status=$?

    # Step 5: Generate report
    echo "=== Step 5: Generating Report ==="
    generate_report "$signature_counts" "$config_status"

    echo "=== Signature verification completed ==="
    echo "Log file: $LOG_FILE"

    # Exit with appropriate status
    if [[ "$analysis_status" -ne 0 ]]; then
        exit 1
    fi
}

# Execute main function with all arguments
main "$@"
