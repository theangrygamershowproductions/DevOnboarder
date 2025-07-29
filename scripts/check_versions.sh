#!/usr/bin/env bash
set -euo pipefail

README="README.md"

get_expected() {
    local lang="$1"
    grep -E "^\| ${lang//./\.}[[:space:]]+\|" "$README" | head -n1 | awk -F'|' '{gsub(/ /,"",$3); print $3}'
}

# Only check core required languages (as per .tool-versions)
expected_python=$(get_expected "Python")
expected_node=$(get_expected "Node.js")

errors=0

check() {
    local name="$1"
    local expected="$2"
    local cmd="$3"
    local regex="$4"
    echo "Checking $name version..."

    # Check if command exists
    if ! command -v "${cmd%% *}" >/dev/null 2>&1; then
        echo "Warning: $name is not installed, skipping version check"
        return 0
    fi

    output=$($cmd 2>&1)
    if [[ $output =~ $regex ]]; then
        version="${BASH_REMATCH[1]}"
        if [[ "$version" != "$expected" ]]; then
            echo "$name version $version does not match expected $expected" >&2
            errors=1
        else
            echo "$name version $version matches expected $expected"
        fi
    else
        echo "Unable to parse $name version from: $output" >&2
        errors=1
    fi
}

# Only check core requirements that are enforced in .tool-versions
check "Python" "$expected_python" "python --version" 'Python ([0-9]+\.[0-9]+)'
check "Node.js" "$expected_node" "node --version" 'v([0-9]+)'

# Optional checks for additional tools (warn but don't fail)
echo ""
echo "Optional tool versions (informational only):"

check_optional() {
    local name="$1"
    local expected="$2"
    local cmd="$3"
    local regex="$4"

    if ! command -v "${cmd%% *}" >/dev/null 2>&1; then
        echo "$name: Not installed"
        return 0
    fi

    output=$($cmd 2>&1) || { echo "$name: Command failed"; return 0; }
    if [[ $output =~ $regex ]]; then
        version="${BASH_REMATCH[1]}"
        echo "$name: $version (expected: $expected)"
    else
        echo "$name: Unable to parse version"
    fi
}

expected_ruby=$(get_expected "Ruby" 2>/dev/null || echo "unknown")
expected_rust=$(get_expected "Rust" 2>/dev/null || echo "unknown")
expected_go=$(get_expected "Go" 2>/dev/null || echo "unknown")
expected_bun=$(get_expected "Bun" 2>/dev/null || echo "unknown")

check_optional "Ruby" "$expected_ruby" "ruby --version" 'ruby ([0-9]+\.[0-9]+\.[0-9]+)'
check_optional "Rust" "$expected_rust" "rustc --version" 'rustc ([0-9]+\.[0-9]+\.[0-9]+)'
check_optional "Go" "$expected_go" "go version" 'go version go([0-9]+\.[0-9]+\.[0-9]+)'
check_optional "Bun" "$expected_bun" "bun --version" '([0-9]+\.[0-9]+\.[0-9]+)'

if [ "$errors" -ne 0 ]; then
    exit 1
fi
