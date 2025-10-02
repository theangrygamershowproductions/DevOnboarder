#!/usr/bin/env bash
# Enhanced safe commit wrapper - redirects to new implementation
exec "$(dirname "$0")/safe_commit_enhanced.sh" "$@"
