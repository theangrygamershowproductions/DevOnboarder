#!/usr/bin/env bash
set -euo pipefail

README="README.md"

get_expected() {
    local lang="$1"
    grep -E "^\| ${lang//./\.}[[:space:]]+\|" "$README" | head -n1 | awk -F'|' '{gsub(/ /,"",$3); print $3}'
}

expected_python=$(get_expected "Python")
expected_node=$(get_expected "Node.js")
expected_ruby=$(get_expected "Ruby")
expected_rust=$(get_expected "Rust")
expected_go=$(get_expected "Go")
expected_bun=$(get_expected "Bun")
expected_java=$(get_expected "Java")
expected_swift=$(get_expected "Swift")

errors=0

check() {
    local name="$1"
    local expected="$2"
    local cmd="$3"
    local regex="$4"
    echo "Checking $name version..."
    
    # Check if command exists first
    if ! command -v "${cmd%% *}" >/dev/null 2>&1; then
        echo "Warning: $name is not installed, skipping version check" >&2
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

check "Python" "$expected_python" "python --version" 'Python ([0-9]+\.[0-9]+)'
check "Node.js" "$expected_node" "node --version" 'v([0-9]+)'
check "Ruby" "$expected_ruby" "ruby --version" 'ruby ([0-9]+\.[0-9]+\.[0-9]+)'
check "Rust" "$expected_rust" "rustc --version" 'rustc ([0-9]+\.[0-9]+\.[0-9]+)'
check "Go" "$expected_go" "go version" 'go version go([0-9]+\.[0-9]+\.[0-9]+)'
check "Bun" "$expected_bun" "bun --version" '([0-9]+\.[0-9]+\.[0-9]+)'
check "Java" "$expected_java" "java --version" 'openjdk ([0-9]+)'
check "Swift" "$expected_swift" "swift --version" 'Swift version ([0-9]+\.[0-9]+)'

if [ "$errors" -ne 0 ]; then
    exit 1
fi

