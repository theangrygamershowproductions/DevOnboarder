#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Interactive commit message fixer with DevOnboarder conventional commit format
# POTATO APPROVAL: emergency-interactive-commit-fix-20250807

set -euo pipefail

target "DevOnboarder Interactive Commit Message Fixer"
echo "================================================="
echo

# Activate virtual environment
if [ -f .venv/bin/activate ]; then
    # shellcheck disable=SC1091 # Runtime source operation
    source .venv/bin/activate
fi

# Function to convert message to conventional format
convert_to_conventional() {
    local original="$1"

    case "$original" in
        "RESOLVE: merge conflicts"*)
            echo "FIX(merge): resolve conflicts in AAR portal and frontend packages"
            ;;
        "Revert \"FEAT(infrastructure)"*)
            echo "REVERT(infrastructure): revert cloudflare tunnel architecture and discord bot ES modules"
            ;;
        "Merge branch 'main'"*)
            echo "CHORE(merge): merge main branch into feature branch"
            ;;
        "Merge branch 'feat/"*)
            echo "CHORE(merge): merge feature branch changes"
            ;;
        *)
            # Try to auto-detect and suggest format
            if [[ "$original" =~ ^[A-Z]+: ]]; then
                # Already has type, just need scope
                TYPE=$(echo "$original" | cut -d: -f1)
                DESCRIPTION=$(echo "$original" | cut -d: -f2- | sed 's/^ *//')
                echo "${TYPE}(scope): ${DESCRIPTION}"
            else
                # Guess type based on content
                if [[ "$original" =~ [Ff]ix|[Bb]ug|[Rr]esolve ]]; then
                    echo "FIX(component): $original"
                elif [[ "$original" =~ [Aa]dd|[Nn]ew|[Ii]mplement ]]; then
                    echo "FEAT(component): $original"
                elif [[ "$original" =~ [Dd]oc|[Rr]eadme ]]; then
                    echo "DOCS(component): $original"
                elif [[ "$original" =~ [Tt]est|[Cc]overage ]]; then
                    echo "TEST(component): $original"
                elif [[ "$original" =~ [Cc]lean|[Rr]emove|[Dd]elete ]]; then
                    echo "CHORE(component): $original"
                else
                    echo "FEAT(component): $original"
                fi
            fi
            ;;
    esac
}

# Get commits that need fixing
echo "🔍 Analyzing commits from origin/main to HEAD..."
COMMITS=$(git log --pretty=format:'%h %s' origin/main..HEAD)

check "Current commits:"
echo "$COMMITS"
echo

# Check which commits need fixing
NEEDS_FIXING=false
while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        # shellcheck disable=SC2034 # HASH used for analysis tracking
        HASH=$(echo "$line" | cut -d' ' -f1)
        MSG=$(echo "$line" | cut -d' ' -f2-)

        # Check if message follows conventional format
        if [[ ! "$MSG" =~ ^(FEAT|FIX|DOCS|STYLE|REFACTOR|TEST|CHORE|REVERT|CI|PERF|BUILD)\([a-z-]+\):.+ ]]; then
            error "Non-conventional: $MSG"
            NEEDS_FIXING=true
        else
            success "Conventional: $MSG"
        fi
    fi
done <<< "$COMMITS"

if [ "$NEEDS_FIXING" = false ]; then
    echo "🎉 All commits already follow conventional format!"
    exit 0
fi

echo
read -p "deploy "Would you like to auto-fix these commit messages? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    error "Operation cancelled."
    exit 1
fi

# Create backup
BACKUP_BRANCH="backup-interactive-fix-$(date +%Y%m%d-%H%M%S)"
echo "💾 Creating backup: $BACKUP_BRANCH"
git branch "$BACKUP_BRANCH"

# Start interactive rebase with auto-generated messages
tool "Starting interactive rebase with message fixes..."

# Create temporary rebase script
REBASE_SCRIPT=$(mktemp)
cat > "$REBASE_SCRIPT" << 'EOF'
#!/bin/bash
# Auto-generated rebase script for conventional commit messages

convert_message() {
    local msg="$1"
    case "$msg" in
        "RESOLVE: merge conflicts"*)
            echo "FIX(merge): resolve conflicts in AAR portal and frontend packages"
            ;;
        "Revert \"FEAT(infrastructure)"*)
            echo "REVERT(infrastructure): revert cloudflare tunnel architecture and discord bot ES modules"
            ;;
        *)
            echo "$msg"
            ;;
    esac
}

# Read the current commit message
ORIGINAL_MSG=$(cat "$1")
NEW_MSG=$(convert_message "$ORIGINAL_MSG")

echo "$NEW_MSG" > "$1"
EOF

chmod +x "$REBASE_SCRIPT"

# Set the commit message editor to our script
export GIT_EDITOR="$REBASE_SCRIPT"

# Run interactive rebase
git rebase -i origin/main

# Clean up
rm -f "$REBASE_SCRIPT"

success "Interactive rebase completed!"
echo "🔍 Checking results..."
git log --oneline origin/main..HEAD | head -5

echo
echo "🎉 Commit message fixing complete!"
check "Backup available at: $BACKUP_BRANCH"
deploy "Run: git push --force-with-lease origin $(git branch --show-current)"
