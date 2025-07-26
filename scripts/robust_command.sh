#!/usr/bin/env bash
# Robust command execution wrapper to fix terminal communication issues

set -euo pipefail

execute_with_output() {
    local cmd="$1"
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo "Executing: $cmd" >&2
        
        # Execute command with explicit output capture and error handling
        if output=$(eval "$cmd" 2>&1); then
            echo "$output"
            return 0
        else
            ((retry++))
            echo "Retry $retry/$max_retries failed" >&2
            sleep 1
        fi
    done
    
    echo "Command failed after $max_retries attempts" >&2
    return 1
}

# Test the wrapper
execute_with_output "echo 'Terminal communication test successful'"
