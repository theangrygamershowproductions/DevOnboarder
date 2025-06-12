#!/bin/bash
# PATCHED v0.2.5 scripts/create-env.sh — Create env files

# Purpose: Generate .env.development and .env.dev from .env.example

set -e

copy_if_missing() {
  src="$1"
  dest="$2"
  if [ -f "$dest" ]; then
    echo "[INFO] $dest already exists, skipping"
  elif [ -f "$src" ]; then
    cp "$src" "$dest"
    echo "[INFO] Created $dest from $src"
  else
    echo "[WARN] $src not found; skipping"
  fi
}

copy_if_missing ".env.example" ".env.development"
copy_if_missing ".env.example" ".env.dev"
copy_if_missing "infrastructure/.env.example" "infrastructure/.env"

if ! grep -q "OPENAI_API_KEY" .env.development; then
  echo "OPENAI_API_KEY=" >> .env.development
  echo "[+] Added OPENAI_API_KEY placeholder to .env.development"
fi

# End of file
