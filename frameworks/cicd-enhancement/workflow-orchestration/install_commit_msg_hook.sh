#!/usr/bin/env bash
set -euo pipefail

repo_hook="$(dirname "$0")/commit-msg"
hook_dest=".git/hooks/commit-msg"

if [ ! -d "$(git rev-parse --git-dir)" ]; then
  echo "Error: not inside a git repository" >&2
  exit 1
fi

cp "$repo_hook" "$hook_dest"
chmod +x "$hook_dest"
echo "Installed commit-msg hook to $hook_dest"
