#!/usr/bin/env bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
set -euo pipefail

RETRO_DIR="docs/checklists/retros"
TEMPLATE="docs/checklists/retrospective-template.md"
DATE="$(date +%Y-%m-%d)"
NEW_FILE="$RETRO_DIR/$DATE.md"

if [ -f "$NEW_FILE" ]; then
  error "$NEW_FILE already exists" >&2
  exit 1
fi

cp "$TEMPLATE" "$NEW_FILE"
sed -i "s|\[YYYY-MM-DD or Sprint #\]|$DATE|" "$NEW_FILE"
echo "Created $NEW_FILE"
