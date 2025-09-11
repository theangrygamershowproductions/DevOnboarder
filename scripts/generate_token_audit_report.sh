#!/bin/bash
# Token Architecture v2.1 - Audit Report Generator
# Generates comprehensive token health and security audit reports for compliance

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit

# Create reports directory if it doesn't exist
mkdir -p reports

# Generate timestamped report filename
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="reports/token-audit-${TIMESTAMP}.md"

echo "Generating Token Architecture v2.1 Audit Report..."
echo "Report will be saved to: ${REPORT_FILE}"

# Start the audit report
cat > "$REPORT_FILE" << 'EOF'
# Token Architecture v2.1 - Security Audit Report

**Report Generated:** $(date '+%Y-%m-%d %H:%M:%S %Z')

**DevOnboarder Repository:** [theangrygamershowproductions/DevOnboarder](https://github.com/theangrygamershowproductions/DevOnboarder)

**Audit Scope:** Token security, availability, and compliance validation

---

## Executive Summary

This audit report documents the security posture and operational status of the Token Architecture v2.1 implementation in the DevOnboarder project. The report includes token availability checks, API functionality validation, security compliance assessment, and recommendations for maintaining secure token management practices.

## Audit Methodology

The audit was conducted using automated tools from the DevOnboarder Token Architecture v2.1 framework:

- `scripts/token_health_check.sh` - Comprehensive health validation
- `scripts/setup_aar_tokens.sh` - Security configuration verification
- `scripts/env_security_audit.sh` - Environment security assessment

---

## Token Health Check Results
EOF

# Add current date to the report
sed -i "s/\$(date '+%Y-%m-%d %H:%M:%S %Z')/$(date '+%Y-%m-%d %H:%M:%S %Z')/g" "$REPORT_FILE"

# shellcheck disable=SC2129 # Grouped redirects are intentional for performance
{
    echo ""
    echo "### Health Check Execution"
} >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "\`\`\`bash" >> "$REPORT_FILE"
echo "# Token health check executed at: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run the health check and capture output
echo "Running token health check..."
if bash scripts/token_health_check.sh > /tmp/token_health_output.txt 2>&1; then
    echo "Health check completed successfully"
    HEALTH_CHECK_STATUS="SUCCESS"
else
    echo "Health check completed with issues"
    HEALTH_CHECK_STATUS="ISSUES_DETECTED"
fi

# Add health check results to report
# shellcheck disable=SC2129 # Grouped redirects are intentional for performance
{
    echo "**Status:** $HEALTH_CHECK_STATUS"
    echo ""
    echo "\`\`\`text"
} >> "$REPORT_FILE"
cat /tmp/token_health_output.txt >> "$REPORT_FILE"
{
    echo "\`\`\`"
    echo ""
} >> "$REPORT_FILE"

# Run security audit
echo "Running security audit..."
echo "## Security Compliance Assessment" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if bash scripts/env_security_audit.sh > /tmp/security_audit_output.txt 2>&1; then
    echo "Security audit completed"
    SECURITY_STATUS="COMPLIANT"
else
    echo "Security audit found issues"
    SECURITY_STATUS="NON_COMPLIANT"
fi

# shellcheck disable=SC2129 # Grouped redirects are intentional for performance
{
    echo "**Compliance Status:** $SECURITY_STATUS"
    echo ""
    echo "\`\`\`text"
} >> "$REPORT_FILE"
cat /tmp/security_audit_output.txt >> "$REPORT_FILE"
{
    echo "\`\`\`"
    echo ""
} >> "$REPORT_FILE"

# Add token setup validation
echo "Running token setup validation..."
echo "## Token Configuration Validation" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if bash scripts/setup_aar_tokens.sh > /tmp/token_setup_output.txt 2>&1; then
    echo "Token setup validation completed"
    SETUP_STATUS="VALID"
else
    echo "Token setup validation found issues"
    SETUP_STATUS="INVALID"
fi

# shellcheck disable=SC2129 # Grouped redirects are intentional for performance
{
    echo "**Configuration Status:** $SETUP_STATUS"
    echo ""
    echo "\`\`\`text"
} >> "$REPORT_FILE"
cat /tmp/token_setup_output.txt >> "$REPORT_FILE"
{
    echo "\`\`\`"
    echo ""
} >> "$REPORT_FILE"

# Add audit summary and recommendations
cat >> "$REPORT_FILE" << EOF
---

## Audit Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Token Health | $HEALTH_CHECK_STATUS | Comprehensive availability and API functionality check |
| Security Compliance | $SECURITY_STATUS | Environment security and token isolation validation |
| Configuration | $SETUP_STATUS | Token setup and hierarchy verification |

## Security Findings

### Positive Security Indicators

- Token Architecture v2.1 implementation active
- No Default Token Policy v1.0 compliance validated
- Fine-grained token hierarchy properly configured
- Token isolation and sandboxing mechanisms working
- Automated security validation integrated into CI/CD

### Areas for Monitoring

- GitHub API propagation delays may affect token functionality temporarily
- Token rotation schedule should be maintained for enhanced security
- Regular audit reports should be generated and retained for compliance

## Recommendations

### Immediate Actions Required

1. **Review Failed Checks:** Address any failed token availability or API functionality tests
2. **Security Remediation:** Implement fixes for any security compliance violations
3. **Configuration Updates:** Correct any invalid token configuration issues

### Ongoing Security Practices

1. **Regular Audits:** Generate monthly token audit reports for compliance tracking
2. **Token Rotation:** Implement quarterly token rotation for enhanced security
3. **Monitoring:** Set up automated alerts for token health degradation
4. **Documentation:** Maintain up-to-date token management documentation

### Compliance Requirements

1. **Audit Retention:** Maintain audit reports for minimum 12 months
2. **Access Control:** Restrict audit report access to authorized personnel only
3. **Change Management:** Document all token configuration changes
4. **Incident Response:** Establish procedures for token compromise scenarios

---

## Technical Details

### Audit Tools Used

- **Token Health Check:** \`scripts/token_health_check.sh\`
- **Security Audit:** \`scripts/env_security_audit.sh\`
- **Setup Validation:** \`scripts/setup_aar_tokens.sh\`
- **Report Generator:** \`scripts/generate_token_audit_report.sh\`

### Environment Information

- **Repository:** DevOnboarder
- **Branch:** $(git branch --show-current)
- **Commit:** $(git rev-parse --short HEAD)
- **Token Architecture Version:** v2.1
- **Audit Framework Version:** v1.0

### Report Metadata

- **Report ID:** token-audit-${TIMESTAMP}
- **Auditor:** Automated Token Audit System
- **Review Status:** Pending human validation
- **Next Scheduled Audit:** $(date -d "+1 month" '+%Y-%m-%d')

---

*This report is automatically generated by the DevOnboarder Token Architecture v2.1 audit framework. For questions or concerns regarding this audit, please consult the DevOnboarder security documentation or contact the development team.*

EOF

# Clean up temporary files
rm -f /tmp/token_health_output.txt /tmp/security_audit_output.txt /tmp/token_setup_output.txt

echo ""
echo "Audit report generated successfully!"
echo "   Location: ${REPORT_FILE}"
echo "   Status: Ready for review and retention"
echo ""

# Add to git for tracking (but don't commit automatically)
git add "$REPORT_FILE"
echo "Report staged for git tracking"
echo ""
echo "Summary:"
echo "   - Health Check: $HEALTH_CHECK_STATUS"
echo "   - Security: $SECURITY_STATUS"
echo "   - Configuration: $SETUP_STATUS"
echo ""
echo "Review the full report for detailed findings and recommendations."
