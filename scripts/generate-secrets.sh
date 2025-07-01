#!/usr/bin/env bash
set -eo pipefail

ENV_FILE=".env.dev"

# Helper: write or replace an env var in $ENV_FILE
write_env() {
  local key=$1 value=$2
  if grep -qE "^${key}=" "$ENV_FILE"; then
    sed -i -E "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# Ensure we have a fresh file
cp .env.example "$ENV_FILE"

# Generate secrets
write_env "JWT_SECRET_KEY" "$(openssl rand -hex 32)"
write_env "DISCORD_CLIENT_SECRET" "$(openssl rand -base64 24 | tr '/+' '_-')"
write_env "DISCORD_BOT_TOKEN" "$(openssl rand -hex 32)"

echo "✅ Generated secrets in $ENV_FILE"
