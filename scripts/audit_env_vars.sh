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

# Output machine-readable summary
to_json_array() {
  local input="$1"
  if [ -z "$input" ]; then
    echo "[]"
    return
  fi
  local json="["
  local first=true
  while IFS= read -r var; do
    [ -n "$var" ] || continue
    if [ "$first" = true ]; then
      json+="\"$var\""
      first=false
    else
      json+=" ,\"$var\""
    fi
  done <<< "$input"
  json+="]"
  echo "$json"
}

json_missing=$(to_json_array "$missing")
json_extra=$(to_json_array "$extra")
summary="{\"missing\":${json_missing},\"extra\":${json_extra}}"
echo "$summary"
if [ -n "${JSON_OUTPUT:-}" ]; then
  echo "$summary" > "$JSON_OUTPUT"
fi
