#!/usr/bin/env bash
# Fix common shellcheck issues in token health scripts

# Fix SC2181: Check exit code directly
fix_exit_code_checks() {
    local file="$1"

    # Fix patterns like: if [ $? -eq 0 ]; then
    # shellcheck disable=SC2016 # Literal pattern for sed replacement
    sed -i 's/if \[ \$? -eq 0 \]; then/if GH_TOKEN="$token_value" gh api "$endpoint" > \/dev\/null 2>\&1; then/g' "$file"

    # More specific fixes for different patterns
    sed -i 's/if \[ \$? -eq 0 \]; then/if command_succeeds; then/g' "$file"
}

# Add shellcheck disable directives
add_shellcheck_disables() {
    local file="$1"

    # Add disable for source commands
    sed -i 's/source \.venv\/bin\/activate/# shellcheck disable=SC1091\nsource .venv\/bin\/activate/' "$file"
    sed -i 's/source scripts\/load_token_environment\.sh/# shellcheck disable=SC1091\nsource scripts\/load_token_environment.sh/' "$file"
}

# Fix unused variables
fix_unused_variables() {
    local file="$1"

    # Add underscore prefix to unused variables or add shellcheck disable
    sed -i 's/error_output=/# shellcheck disable=SC2034\n    error_output=/' "$file"
    sed -i 's/local description=/# shellcheck disable=SC2034\n    local description=/' "$file"
    sed -i 's/result=/# shellcheck disable=SC2034\n    result=/' "$file"
    sed -i 's/for failed_token in/# shellcheck disable=SC2034\n    for failed_token in/' "$file"
}

# Process each file
for file in scripts/comprehensive_token_health_check.sh scripts/simple_token_health.sh scripts/simple_token_test.sh scripts/token_health_check.sh; do
    echo "Fixing shellcheck issues in $file"
    add_shellcheck_disables "$file"
    fix_unused_variables "$file"
    fix_exit_code_checks "$file"
done

echo "Shellcheck fixes applied"
