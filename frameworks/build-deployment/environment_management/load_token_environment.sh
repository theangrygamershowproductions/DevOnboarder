#!/bin/bash
# Token Environment Wrapper v2.1
# Loads tokens from Token Architecture and exports to environment
# Usage: source scripts/load_token_environment.sh

# Check if we're in DevOnboarder project
if [ ! -f "scripts/token_loader.py" ]; then
    echo "Warning: Not in DevOnboarder project root"
    # shellcheck disable=SC2317 # Defensive programming pattern
    return 1 2>/dev/null || exit 1
fi

# Load tokens using Python token loader
if command -v python3 >/dev/null 2>&1; then
    # Create temporary file for token export
    TOKEN_EXPORT_FILE=$(mktemp)

    # Use Python to safely export tokens
    python3 -c "
import sys
sys.path.insert(0, '.')
try:
    from scripts.token_loader import TokenLoader
    loader = TokenLoader()
    tokens = loader.load_tokens_by_type(loader.TOKEN_TYPE_ALL)

    with open('$TOKEN_EXPORT_FILE', 'w') as f:
        for key, value in tokens.items():
            # Safely escape token values for shell
            escaped_value = value.replace('\\\\', '\\\\\\\\').replace('\"', '\\\\\"').replace('\$', '\\\\\$').replace('\`', '\\\\\`')
            f.write(f'export {key}=\"{escaped_value}\"\\n')

    print(f'Loaded {len(tokens)} tokens from Token Architecture v2.1')
except Exception as e:
    print(f'Error loading tokens: {e}', file=sys.stderr)
    sys.exit(1)
"

    # Source the exported tokens if successful
    if [ -f "$TOKEN_EXPORT_FILE" ]; then
        # shellcheck disable=SC1090
        source "$TOKEN_EXPORT_FILE"
        rm -f "$TOKEN_EXPORT_FILE"
        echo "Token environment loaded successfully"
    else
        rm -f "$TOKEN_EXPORT_FILE" 2>/dev/null
        echo "Failed to load token environment"
        # shellcheck disable=SC2317 # Defensive programming pattern
        return 1 2>/dev/null || exit 1
    fi
else
    echo "Error: python3 not available"
    # shellcheck disable=SC2317 # Defensive programming pattern
    return 1 2>/dev/null || exit 1
fi
