#!/bin/bash
# ---
# codex-agent:
#   name: Agent.CheckBotPermissions
#   role: Verifies bot/agent has required permissions for workflow action
#   scope: scripts/check-bot-permissions.sh
#   triggers: Called by CI workflows before privileged bot actions
#   output: CI logs, audit trail
#   tags: [automation, codex, security, permissions, ci]
#   version: 1.0.0
#   last_updated: 2025-07-25
#   owner: TAGS Engineering
# ---

set -e

BOT_NAME="$1"
PERMISSION="$2"

echo "🔍 Checking if bot '$BOT_NAME' has '$PERMISSION' permission..."

# Path to your permissions manifest file (update path if needed)
PERMISSIONS_FILE="agents/permissions.yml"

if [[ ! -f "$PERMISSIONS_FILE" ]]; then
    echo "❌ Permissions manifest '$PERMISSIONS_FILE' not found."
    exit 1
fi

# Use yq to parse YAML manifest; fallback to grep/awk if yq isn't available
if command -v yq >/dev/null 2>&1; then
    HAS_PERMISSION=$(yq e ".${BOT_NAME}.permissions[]" "$PERMISSIONS_FILE" | grep -Fx "$PERMISSION" || true)
else
    # Fallback (naive): Just search for the key and permission text (not robust for all YAML)
    HAS_PERMISSION=$(awk "/$BOT_NAME:/,/-/{if(\$1==\"-\" && \$2==\"$PERMISSION\") print \$2}" "$PERMISSIONS_FILE" || true)
fi

if [[ -z "$HAS_PERMISSION" ]]; then
    echo "❌ Bot '$BOT_NAME' is NOT authorized for '$PERMISSION'"
    exit 1
else
    echo "✅ Bot '$BOT_NAME' IS authorized for '$PERMISSION'"
fi

# Optionally, show the token prefix for audit/debugging (never print the whole token)
if [[ -n "$BOT_KEY" ]]; then
    echo "🔑 BOT_KEY present (starts with: ${BOT_KEY:0:6}...)"
else
    echo "⚠️  BOT_KEY environment variable is NOT set!"
fi
