#!/bin/bash
# scripts/language_upgrade_mode.sh
# Activates matrix testing for language version upgrades

set -euo pipefail

# Initialize logging
mkdir -p logs
LOG_FILE="logs/language_upgrade_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== DevOnboarder Language Upgrade Mode ==="
echo "Script: language_upgrade_mode.sh"
echo "Date: $(date)"
echo ""

# Parse command line arguments
LANGUAGE=""
NEW_VERSION=""
ACTION="test"  # test, apply, or revert

usage() {
    echo "Usage: $0 <language> <new_version> [action]"
    echo ""
    echo "Languages: python, node"
    echo "Actions:"
    echo "  test   - Enable matrix testing (default)"
    echo "  apply  - Apply new version as default"
    echo "  revert - Return to single version mode"
    echo ""
    echo "Examples:"
    echo "  $0 python 3.13 test      # Test Python 3.12 + 3.13"
    echo "  $0 node 24 test          # Test Node 22 + 24"
    echo "  $0 python 3.13 apply     # Switch to Python 3.13 only"
    echo "  $0 python 3.13 revert    # Return to single version"
}

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

LANGUAGE="$1"
NEW_VERSION="$2"
ACTION="${3:-test}"

echo "Language: $LANGUAGE"
echo "New Version: $NEW_VERSION"
echo "Action: $ACTION"
echo ""

# Validate language
case "$LANGUAGE" in
    python)
        CURRENT_VERSION="3.12"
        VERSIONS_JSON="[\"${CURRENT_VERSION}\", \"${NEW_VERSION}\"]"
        ;;
    node)
        CURRENT_VERSION="22"
        VERSIONS_JSON="[\"${CURRENT_VERSION}\", \"${NEW_VERSION}\"]"
        ;;
    *)
        echo "ERROR: Unsupported language: $LANGUAGE"
        echo "Supported: python, node"
        exit 1
        ;;
esac

# GitHub CLI upgrade command generator
generate_upgrade_command() {
    local action="$1"

    case "$action" in
        test)
            echo "gh workflow run component-orchestrator.yml"
            echo "  --field upgrade-mode=true"
            if [ "$LANGUAGE" = "python" ]; then
                echo "  --field python-versions='$VERSIONS_JSON'"
            elif [ "$LANGUAGE" = "node" ]; then
                echo "  --field node-versions='$VERSIONS_JSON'"
            fi
            ;;
        apply)
            echo "# Update .tool-versions file:"
            echo "sed -i 's/${LANGUAGE} ${CURRENT_VERSION}/${LANGUAGE} ${NEW_VERSION}/' .tool-versions"
            echo ""
            echo "# Update workflow defaults and commit:"
            echo "git add .tool-versions"
            echo "./scripts/safe_commit.sh \"FEAT(upgrade): update ${LANGUAGE} to ${NEW_VERSION}\""
            ;;
        revert)
            echo "gh workflow run component-orchestrator.yml"
            echo "  --field upgrade-mode=false"
            ;;
    esac
}

# Execute action
case "$ACTION" in
    test)
        echo "=== ACTIVATING MATRIX TESTING ==="
        echo "Testing compatibility between:"
        echo "  Current: $LANGUAGE $CURRENT_VERSION"
        echo "  Target:  $LANGUAGE $NEW_VERSION"
        echo ""
        echo "Command to run:"
        generate_upgrade_command "test"
        echo ""
        echo "This will run CI with both versions in parallel."
        echo "Monitor results and fix any compatibility issues."
        ;;

    apply)
        echo "=== APPLYING UPGRADE ==="
        echo "Switching to single version: $LANGUAGE $NEW_VERSION"
        echo ""
        echo "Commands to run:"
        generate_upgrade_command "apply"
        echo ""
        echo "This will update .tool-versions and disable matrix testing."
        ;;

    revert)
        echo "=== REVERTING TO SINGLE VERSION ==="
        echo "Disabling matrix testing, using current .tool-versions"
        echo ""
        echo "Command to run:"
        generate_upgrade_command "revert"
        ;;

    *)
        echo "ERROR: Invalid action: $ACTION"
        usage
        exit 1
        ;;
esac

echo ""
echo "=== Language Upgrade Mode Complete ==="
echo "Log saved: $LOG_FILE"
