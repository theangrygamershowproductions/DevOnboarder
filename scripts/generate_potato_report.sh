#!/usr/bin/env bash
# Generate Potato Policy Audit Report
# Creates comprehensive audit trail and compliance report

set -euo pipefail

TEMPLATE_FILE="templates/potato-report.md"
OUTPUT_FILE="reports/potato-policy-audit-$(date +%Y%m%d-%H%M%S).md"

echo "📊 Generating Potato Policy Audit Report"
echo "========================================"

# Ensure directories exist
mkdir -p reports

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Generate report by evaluating bash expressions in template
envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

# Process bash command substitutions manually since envsubst doesn't handle them
CURRENT_DATE=$(date -Iseconds)
CURRENT_BRANCH=$(git branch --show-current)
CURRENT_COMMIT=$(git rev-parse --short HEAD)

sed -i "s/\$(date -Iseconds)/${CURRENT_DATE}/g" "$OUTPUT_FILE"
sed -i "s/\$(git branch --show-current)/${CURRENT_BRANCH}/g" "$OUTPUT_FILE"
sed -i "s/\$(git rev-parse --short HEAD)/${CURRENT_COMMIT}/g" "$OUTPUT_FILE"

echo "✅ Report generated: $OUTPUT_FILE"
echo "📁 Report size: $(wc -l < "$OUTPUT_FILE") lines"

# Also create a latest report symlink
ln -sf "$(basename "$OUTPUT_FILE")" reports/potato-policy-latest.md

echo "🔗 Latest report link: reports/potato-policy-latest.md"

# If running in CI, also output key metrics
if [ "${CI:-false}" = "true" ]; then
    echo "::notice title=Potato Policy Report::Generated audit report: $OUTPUT_FILE"
fi
