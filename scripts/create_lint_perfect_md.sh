#!/usr/bin/env bash
# DevOnboarder Lint-Perfect Markdown Generator
# Creates markdown files that pass all linting rules from the start

set -euo pipefail

create_lint_perfect_doc() {
    local filename="$1"
    local title="$2"
    local filepath="docs/${filename}.md"

    cat > "$filepath" << 'EOF'
# TITLE_PLACEHOLDER

Brief description of the document purpose.

## Overview

Main content section with proper spacing around headings.

### Key Features

Features are listed with proper spacing:

- **Feature One:** Description here
- **Feature Two:** Description here
- **Feature Three:** Description here

### Implementation Details

Implementation section with proper formatting.

#### Code Example

```bash
# Example commands with proper spacing
echo "This has blank lines above and below"
```

#### Configuration

Configuration details here.

### Results Summary

Summary of outcomes and results.

## Conclusion

Final thoughts and next steps.

**Status:** Implementation complete

---

*Document generated using lint-compliant template*
EOF

    # Replace placeholder with actual title
    sed -i "s/TITLE_PLACEHOLDER/$title/g" "$filepath"

    echo "✅ Created lint-perfect markdown: $filepath"
}

# Usage examples
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <filename> <title>"
        echo "Example: $0 my-feature 'My Feature Documentation'"
        exit 1
    fi

    create_lint_perfect_doc "$1" "$2"
fi
