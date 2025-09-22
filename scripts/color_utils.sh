#!/bin/bash
# DevOnboarder Terminal Color Functions
# Centralized color utilities following DevOnboarder terminal output policy
#
# Usage: Source this file in your script, then use color functions
#   source scripts/color_utils.sh
#   green "Success message"
#   red "Error message"
#
# DO NOT use raw ANSI escape sequences - use these functions instead

# Color functions - DevOnboarder compliant terminal output
red() { printf "\033[31m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
blue() { printf "\033[34m%s\033[0m\n" "$1"; }
cyan() { printf "\033[36m%s\033[0m" "$1"; }
purple() { printf "\033[35m%s\033[0m\n" "$1"; }
bold() { printf "\033[1m%s\033[0m" "$1"; }

# Error reporting with consistent format
error() {
    red "ERROR: $1" >&2
}

# Success reporting with consistent format
success() {
    green "SUCCESS: $1"
}

# Warning reporting with consistent format
warn() {
    yellow "WARNING: $1"
}

# Info reporting with consistent format
info() {
    blue "INFO: $1"
}

# Debug reporting with consistent format (only shows if DEBUG=1)
debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        cyan "DEBUG: $1"
    fi
}

# Section headers for structured output
section() {
    echo ""
    bold "=== $1 ==="
    echo ""
}
