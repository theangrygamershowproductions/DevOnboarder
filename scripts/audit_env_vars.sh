#!/usr/bin/env bash
set -euo pipefail

# Gather required variable names from example files
FILES=(.env.example frontend/src/.env.example bot/.env.example auth/.env.example)
required_vars=$(grep -h -oE '^[A-Za-z_][A-Za-z0-9_]*' "${FILES[@]}" | sort -u)

# Current environment variable names
current_vars=$(env | cut -d= -f1 | sort -u)

# Print missing variables: required but not present in environment
missing=$(comm -23 <(printf '%s\n' "$required_vars") <(printf '%s\n' "$current_vars"))
# Print extra variables: present in environment but not required
extra=$(comm -13 <(printf '%s\n' "$required_vars") <(printf '%s\n' "$current_vars"))

echo "Missing variables:"; echo "$missing"
echo
echo "Extra variables:"; echo "$extra"
