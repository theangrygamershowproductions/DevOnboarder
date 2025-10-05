#!/usr/bin/env bash
# Security scanning script with proper report directory handling
# Prevents root artifact violations by using logs/reports/ directory

set -euo pipefail

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORTS_DIR="$PROJECT_ROOT/logs/reports"

# Ensure reports directory exists
mkdir -p "$REPORTS_DIR"

# Create timestamp for this scan
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCAN_PREFIX="security_scan_${TIMESTAMP}"

echo "🔒 Security Scan Starting - $(date)"
echo "📁 Reports will be saved to: $REPORTS_DIR"

# Python Security Analysis
echo "🐍 Running Python security analysis..."

echo "  → Bandit (Python security scanner)..."
bandit -r src/ -f json -o "$REPORTS_DIR/${SCAN_PREFIX}_bandit.json" || echo "Bandit completed with warnings"

echo "  → Safety (dependency vulnerability scanner)..."
safety scan --output json --file "$REPORTS_DIR/${SCAN_PREFIX}_safety.json" || echo "Safety completed with warnings"

echo "  → Semgrep (static analysis)..."
semgrep --config=auto --json --output "$REPORTS_DIR/${SCAN_PREFIX}_semgrep.json" . || echo "Semgrep completed with warnings"

# Container/Filesystem Security
echo "🐳 Running container and filesystem security analysis..."

echo "  → Trivy (vulnerability scanner)..."
trivy fs . --format json --output "$REPORTS_DIR/${SCAN_PREFIX}_trivy.json" || echo "Trivy completed with warnings"

# Code Quality Analysis
echo "📊 Running code quality analysis..."

echo "  → Prospector (Python analysis aggregator)..."
prospector src/ --output-format json > "$REPORTS_DIR/${SCAN_PREFIX}_prospector.json" || echo "Prospector completed with warnings"

echo "  → Vulture (dead code detection)..."
vulture src/ --min-confidence 60 > "$REPORTS_DIR/${SCAN_PREFIX}_vulture.txt" || echo "Vulture completed with warnings"

# Generate summary report
echo "📋 Generating summary report..."
cat > "$REPORTS_DIR/${SCAN_PREFIX}_summary.md" << EOF
# Security Scan Summary

**Scan Date**: $(date)
**Scan ID**: ${SCAN_PREFIX}

## Reports Generated

- \`${SCAN_PREFIX}_bandit.json\` - Python security issues
- \`${SCAN_PREFIX}_safety.json\` - Dependency vulnerabilities
- \`${SCAN_PREFIX}_semgrep.json\` - Static analysis findings
- \`${SCAN_PREFIX}_trivy.json\` - Container/filesystem vulnerabilities
- \`${SCAN_PREFIX}_prospector.json\` - Code quality analysis
- \`${SCAN_PREFIX}_vulture.txt\` - Dead code detection

## Next Steps

1. Review each report for actionable findings
2. Address high-severity security issues first
3. Update dependencies with known vulnerabilities
4. Remove identified dead code
5. Integrate findings into CI/CD pipeline

EOF

echo "✅ Security scan completed successfully!"
echo "📁 All reports saved to: $REPORTS_DIR"
echo "📋 Summary: $REPORTS_DIR/${SCAN_PREFIX}_summary.md"

# List generated reports
echo -e "\n📄 Generated Reports:"
find "$REPORTS_DIR" -name "${SCAN_PREFIX}*" -exec ls -la {} \;
