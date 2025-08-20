# Security Audit - 2025-08-19

We ran dependency audits for Python and Node packages and scanned the code with Bandit.

## Python (`pip-audit`)

### ⚠️ Ignored Vulnerabilities (Require Periodic Review)

The following vulnerabilities are currently ignored:

```text
# DevOnboarder pip-audit ignore configuration
# This file contains security vulnerabilities that cannot be fixed
# due to upstream maintainer decisions or lack of available patches
#
# CRITICAL: All ignored vulnerabilities must be documented in:
# docs/security-ignore-registry.md with quarterly review schedules
#
# GHSA-wj6h-64fc-37mp: Timing attack in python-ecdsa on P-256 curve
# - Affects: ecdsa 0.19.1 (required by python-jose for JWT functionality)
# - Severity: Low (timing attacks affect signing operations, not verification)
# - Status: No planned fix according to maintainers (considered 'out of scope')
# - Impact: DevOnboarder uses JWT verification (not signing) so minimal risk
# - First ignored: 2025-07-30
# - Next review: 2025-10-30
GHSA-wj6h-64fc-37mp
```

**ACTION REQUIRED**: These ignored vulnerabilities should be reviewed quarterly.
Next review due: 2025-11-19

Traceback (most recent call last):
  File "/home/potato/DevOnboarder/.venv/lib/python3.12/site-packages/pip_audit/_service/pypi.py", line 63, in query
    response.raise_for_status()
  File "/home/potato/DevOnboarder/.venv/lib/python3.12/site-packages/requests/models.py", line 1026, in raise_for_status
    raise HTTPError(http_error_msg, response=self)
requests.exceptions.HTTPError: 503 Server Error: Service Unavailable for url: <https://pypi.org/pypi/devonboarder/0.1.0/json>

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/home/potato/DevOnboarder/.venv/bin/pip-audit", line 8, in module
    sys.exit(audit())
             ^^^^^^^
  File "/home/potato/DevOnboarder/.venv/lib/python3.12/site-packages/pip_audit/_cli.py", line 538, in audit
    for spec, vulns in auditor.audit(source):
  File "/home/potato/DevOnboarder/.venv/lib/python3.12/site-packages/pip_audit/_audit.py", line 68, in audit
    for dep, vulns in self._service.query_all(specs):
  File "/home/potato/DevOnboarder/.venv/lib/python3.12/site-packages/pip_audit/_service/interface.py", line 156, in query_all
    yield self.query(spec)
          ^^^^^^^^^^^^^^^^
  File "/home/potato/DevOnboarder/.venv/lib/python3.12/site-packages/pip_audit/_service/pypi.py", line 84, in query
    raise ServiceError from http_error
pip_audit._service.interface.ServiceError
