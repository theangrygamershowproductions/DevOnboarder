#!/bin/bash
# Pre-commit cache troubleshooting script
# Run this when encountering validation caching issues

echo 'Clearing pre-commit cache...'
# Virtual environment activation - standard DevOnboarder pattern
# shellcheck disable=SC1091
source .venv/bin/activate
pre-commit clean

echo 'Re-running validation...'
pre-commit run terminal-output-policy --all-files

echo 'Cache troubleshooting complete'
