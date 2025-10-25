#!/usr/bin/env bash
# Create markdown files that are lint-compliant from the start
# Usage: bash scripts/create_compliant_markdown.sh "filename" "title"

set -euo pipefail

FILENAME="$1"
TITLE="$2"
FILEPATH="docs/${FILENAME}.md"

echo " Creating lint-compliant markdown: $FILEPATH"

# Create file with proper formatting from the start
cat > "$FILEPATH" << EOF
# $TITLE

Brief description here.

## Overview

Content section with proper spacing.

### Key Features

The following features are available:

- **Feature 1:** Description
- **Feature 2:** Description
- **Feature 3:** Description

### Implementation

Implementation details here.

#### Code Example

\`\`\`bash
# Example command
echo "Example"
\`\`\`

### Results

Summary of outcomes.

## Conclusion

Final thoughts and next steps.

**Status:** Complete

---

*Generated using lint-compliant markdown template*
EOF

echo " Created: $FILEPATH"
echo " Running lint check..."

# Validate immediately
if command -v markdownlint &> /dev/null; then
    markdownlint "$FILEPATH" && echo " Lint check passed" || echo " Lint check failed"
else
    echo "ℹ️ markdownlint not available, manual validation recommended"
fi

echo " File ready for editing: $FILEPATH"
