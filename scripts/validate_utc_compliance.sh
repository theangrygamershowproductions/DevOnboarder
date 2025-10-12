#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"

# QC Extension: UTC Timestamp Validation
# Purpose: Detect and prevent mixed timezone usage in DevOnboarder scripts
# Evidence: UTC Infrastructure Fix addressing GitHub API synchronization
# Integration: Should be added to scripts/qc_pre_push.sh

echo "=== QC Extension: UTC Timestamp Validation ==="

# INFRASTRUCTURE CHANGE: Improved pattern: match lines with both 'UTC' (or 'utc') and 'datetime.now()', in any order, and other problematic patterns
dangerous_patterns=$(grep -r -E "(UTC|utc).*datetime\.now\(\)|datetime\.now\(\).*(UTC|utc)|datetime\.now\(\)\.astimezone\(\s*timezone\.utc\s*\)|datetime\.now\(\)\.replace\(\s*tzinfo\s*=\s*timezone\.utc\s*\)|datetime\.now\(\)\.isoformat\(\)\s*\+\s*['\"]\s*UTC\s*['\"]" scripts/ 2>/dev/null | grep -v "# INFRASTRUCTURE CHANGE" || true)

if [ -n "$dangerous_patterns" ]; then
    error "CRITICAL: Found scripts claiming UTC but using local time:"
    echo "$dangerous_patterns"
    echo ""
    echo "Fix: Use src.utils.timestamps.get_utc_display_timestamp() instead"
    echo "Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md"
    exit 1
fi

# Check for inconsistent timezone usage
mixed_timezone_usage=$(grep -r "datetime\.now()" scripts/ | grep -E "UTC|timezone" | grep -v "INFRASTRUCTURE CHANGE" || true)

if [ -n "$mixed_timezone_usage" ]; then
    warning " WARNING: Mixed timezone usage detected:"
    echo "$mixed_timezone_usage"
    echo ""
    echo "Recommendation: Migrate to standardized UTC utilities"
fi

success "UTC timestamp compliance validated"
