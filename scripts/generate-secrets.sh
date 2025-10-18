#!/usr/bin/env bash
set -eo pipefail

# Determine source file based on environment
if [ "${CI:-false}" = "true" ]; then
    SOURCE_FILE=".env.example"
    echo "Running in CI environment, using $SOURCE_FILE as source"
else
    SOURCE_FILE=".env"
    echo "Running in local development, using $SOURCE_FILE as source"
fi

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file $SOURCE_FILE not found"
    exit 1
fi

# Helper: write or replace an env var in target file
write_env() {
  local target_file=$1 key=$2 value=$3
  if grep -qE "^${key}=" "$target_file"; then
    sed -i -E "s|^${key}=.*|${key}=${value}|" "$target_file"
  else
    echo "${key}=${value}" >> "$target_file"
  fi
}

# Helper function to generate secret only if empty or missing
generate_secret_if_empty() {
    local env_file="$1"
    local key="$2"
    local current_value

    # Extract current value from the environment file
    if [ -f "$env_file" ] && grep -q "^${key}=" "$env_file"; then
        current_value=$(grep "^${key}=" "$env_file" | cut -d'=' -f2-)
        # Remove quotes if present
        current_value="${current_value%\"}"
        current_value="${current_value#\"}"
    fi

    # Only generate if value is empty or missing
    if [ -z "$current_value" ]; then
        echo "Generating secret for $key in $env_file..."
        if [ "$key" = "DISCORD_CLIENT_SECRET" ]; then
            write_env "$env_file" "$key" "$(openssl rand -base64 24 | tr '/' '_-')"
        else
            write_env "$env_file" "$key" "$(openssl rand -hex 32)"
        fi
    else
        echo "Preserving existing $key in $env_file"
    fi
}

# Generate both .env.dev and .env.prod files
for ENV_FILE in ".env.dev" ".env.prod"; do
    echo "Generating $ENV_FILE from $SOURCE_FILE"
    cp "$SOURCE_FILE" "$ENV_FILE"

    # Generate secrets for this environment file (only if empty)
    generate_secret_if_empty "$ENV_FILE" "JWT_SECRET_KEY"
    generate_secret_if_empty "$ENV_FILE" "DISCORD_CLIENT_SECRET"
    generate_secret_if_empty "$ENV_FILE" "DISCORD_BOT_TOKEN"

    echo "Generated secrets for $ENV_FILE"
done

echo "Successfully generated secrets for both .env.dev and .env.prod"
