# DevOnboarder Security Ignore Registry

This file tracks all security vulnerabilities that are intentionally ignored in DevOnboarder, ensuring they receive periodic review and aren't forgotten.

## Pip-Audit Ignored Vulnerabilities

### GHSA-wj6h-64fc-37mp (ecdsa 0.19.1)

- **Vulnerability**: Timing attack in python-ecdsa on P-256 curve
- **Severity**: Low
- **First Ignored**: 2025-07-30
- **Next Review**: 2025-10-30 (Quarterly)
- **Reason**: No fix available - maintainers consider timing attacks "out of scope"
- **Impact Assessment**:
    - DevOnboarder uses JWT verification (not signing) so minimal risk
    - Required by python-jose for authentication functionality
    - No viable alternative without major architectural changes
- **Review Actions**:
    - [ ] Check if new ecdsa version available with fix
    - [ ] Verify DevOnboarder still only uses JWT verification
    - [ ] Consider alternative JWT libraries if fix available
    - [ ] Document any new risks or mitigations

## Review Process

1. **Quarterly Reviews**: All ignored vulnerabilities reviewed every 3 months
2. **AAR Integration**: Security reviews included in After Actions Reports
3. **Automatic Reminders**: Weekly security audit reports include ignore status
4. **Owner Assignment**: Security team responsible for review scheduling

## Review History

- **2025-07-30**: Initial ignore configuration created for GHSA-wj6h-64fc-37mp
- **Next Review**: 2025-10-30

## Escalation

If ignored vulnerabilities develop into critical risks:

1. Create security incident issue with `security` and `critical` labels
2. Trigger emergency AAR via `aar-automation.yml` workflow
3. Coordinate with security team for immediate remediation
