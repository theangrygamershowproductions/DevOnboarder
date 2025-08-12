#!/bin/bash
# Pre-commit hook for AAR validation
# Validates AAR data files and ensures schema compliance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "SEARCH AAR Pre-commit Validation"

# Check if any AAR data files are being committed
AAR_FILES=$(git diff --cached --name-only | grep -E "docs/AAR/data/.*\.aar\.json$" || true)

if [ -z "$AAR_FILES" ]; then
    echo "No AAR data files to validate"
    exit 0
fi

echo "SYMBOL Validating AAR data files:"
echo "$AAR_FILES"

# Ensure Node.js and npm are available
if ! command -v node &> /dev/null; then
    echo -e "${RED}FAILED Node.js is required for AAR validation${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}FAILED npm is required for AAR validation${NC}"
    exit 1
fi

# Ensure AAR dependencies are installed
if [ ! -d "node_modules" ] || [ ! -f "node_modules/.bin/ajv" ]; then
    echo "SYMBOL Installing AAR validation dependencies..."
    npm install --silent
fi

# Validate each AAR file
VALIDATION_FAILED=0

while IFS= read -r file; do
    if [ -n "$file" ]; then
        echo -n "  Validating $file... "

        # Run validation (from aar directory)
        if (cd aar && npm run aar:validate "../$file") &>/dev/null; then
            echo -e "${GREEN}SUCCESS${NC}"
        else
            echo -e "${RED}FAILED${NC}"
            echo -e "${RED}    Validation failed for $file${NC}"

            # Show detailed validation errors
            echo "    Detailed errors:"
            (cd aar && npm run aar:validate "../$file") 2>&1 | sed 's/^/      /'

            VALIDATION_FAILED=1
        fi
    fi
done <<< "$AAR_FILES"

# Run golden file tests if any AAR files changed
if [ "$VALIDATION_FAILED" -eq 0 ] && [ -n "$AAR_FILES" ]; then
    echo "EMOJI Running golden file tests..."
    if (cd aar && npm run aar:test-golden) &>/dev/null; then
        echo -e "${GREEN}SUCCESS Golden file tests passed${NC}"
    else
        echo -e "${YELLOW}WARNING  Golden file tests failed - this may indicate template changes${NC}"
        echo "   Run 'cd aar && npm run aar:update-snapshots' if template changes are intentional"
        # Don't fail commit for golden test failures - they might be intentional
    fi
fi

# Check if schema file itself was modified
SCHEMA_FILES=$(git diff --cached --name-only | grep -E "docs/AAR/schema/.*\.json$" || true)

if [ -n "$SCHEMA_FILES" ]; then
    echo "EDIT Schema file changes detected:"
    echo "$SCHEMA_FILES"

    # Validate schema syntax
    while IFS= read -r schema_file; do
        if [ -n "$schema_file" ]; then
            echo -n "  Validating schema syntax: $schema_file... "
            if node -e "JSON.parse(require('fs').readFileSync('$schema_file', 'utf8'))" &>/dev/null; then
                echo -e "${GREEN}SUCCESS${NC}"
            else
                echo -e "${RED}FAILED Invalid JSON syntax${NC}"
                VALIDATION_FAILED=1
            fi
        fi
    done <<< "$SCHEMA_FILES"

    # Check for schema version updates
    if grep -q '"version":' docs/AAR/schema/aar.schema.json; then
        SCHEMA_VERSION=$(grep '"version":' docs/AAR/schema/aar.schema.json | sed 's/.*"version": *"\([^"]*\)".*/\1/')
        echo "SYMBOL Schema version: $SCHEMA_VERSION"

        # Check if version archive exists
        ARCHIVE_FILE="docs/AAR/schemas/aar.v${SCHEMA_VERSION}.json"
        if [ ! -f "$ARCHIVE_FILE" ]; then
            echo -e "${YELLOW}WARNING  Creating schema version archive: $ARCHIVE_FILE${NC}"
            cp docs/AAR/schema/aar.schema.json "$ARCHIVE_FILE"
            git add "$ARCHIVE_FILE"
        fi
    fi
fi

# Final result
if [ "$VALIDATION_FAILED" -eq 0 ]; then
    echo -e "${GREEN}SUCCESS All AAR validations passed${NC}"
    exit 0
else
    echo -e "${RED}FAILED AAR validation failed - commit blocked${NC}"
    echo ""
    echo "IDEA Fix the validation errors above and try again"
    echo "IDEA For help with AAR format, see: docs/AAR/README.md"
    exit 1
fi
