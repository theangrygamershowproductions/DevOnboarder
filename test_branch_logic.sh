#!/bin/bash
echo "=== Testing Branch Detection Logic ==="

# Test 1: GitHub Actions environment (should show success message)
echo "Test 1: Simulating GitHub Actions PR merge..."
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $current_branch"

if [[ "$current_branch" == "main" ]]; then
    # Check if running in GitHub Actions (PR merge context)
    if [[ -n "${GITHUB_ACTIONS:-}" && "${GITHUB_EVENT_NAME:-}" == "push" && "${GITHUB_REF:-}" == "refs/heads/main" ]]; then
        echo "✅ GitHub Actions PR merge to main detected - allowing QC validation"
    else
        echo "WARNING: You're about to push to main branch!"
    fi
else
    echo "Feature branch detected - normal flow"
fi

echo
echo "Test 2: Setting GitHub Actions environment and re-testing..."
export GITHUB_ACTIONS=true
export GITHUB_EVENT_NAME=push
export GITHUB_REF=refs/heads/main

if [[ "$current_branch" == "main" ]]; then
    if [[ -n "${GITHUB_ACTIONS:-}" && "${GITHUB_EVENT_NAME:-}" == "push" && "${GITHUB_REF:-}" == "refs/heads/main" ]]; then
        echo "✅ GitHub Actions PR merge to main detected - allowing QC validation"
    else
        echo "WARNING: You're about to push to main branch!"
    fi
else
    echo "Feature branch detected - normal flow"
fi

echo
echo "=== Branch Detection Test Complete ==="
