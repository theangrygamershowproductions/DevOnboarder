#!/usr/bin/env python3
"""
Standardized UTC timestamp utilities for DevOnboarder automation.

INFRASTRUCTURE CHANGE LOG:
- Created: 2025-09-21
- Purpose: Fix critical diagnostic issue with GitHub API vs local timestamp sync
- Evidence: docs/troubleshooting/TIMESTAMP_SYNCHRONIZATION_DIAGNOSTIC_ISSUE.md
- Impact: Ensures diagnostic accuracy across 50+ automation scripts

This module provides UTC-consistent timestamp functions to replace the inconsistent
datetime.now() usage that was causing diagnostic "whack" behavior when comparing
local timestamps with GitHub API timestamps.

BEFORE (problematic pattern found in 20+ scripts):
    # Claims UTC but uses local time
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")

AFTER (standardized approach):
    from src.utils.timestamps import get_utc_display_timestamp
    timestamp = get_utc_display_timestamp()  # Actually uses UTC
"""

from datetime import datetime, timezone
from typing import Optional


def get_utc_timestamp() -> str:
    """
    Get current UTC timestamp in GitHub API compatible format.

    Returns:
        str: ISO 8601 UTC timestamp (e.g., "2025-09-21T19:06:26Z")

    Use this for:
        - GitHub API interactions
        - Cross-system timestamp comparisons
        - Automation decision logic

    Example:
        >>> timestamp = get_utc_timestamp()
        >>> print(timestamp)
        "2025-09-21T19:06:26Z"
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def get_utc_display_timestamp() -> str:
    """
    Get current UTC timestamp for display and logging.

    Returns:
        str: Human-readable UTC timestamp (e.g., "2025-09-21 19:06:26 UTC")

    Use this to replace:
        - datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")  # WRONG - uses local time

    Example:
        >>> timestamp = get_utc_display_timestamp()
        >>> print(f"Generated: {timestamp}")
        "Generated: 2025-09-21 19:06:26 UTC"
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


def get_utc_timestamp_with_milliseconds() -> str:
    """
    Get current UTC timestamp with millisecond precision.

    Returns:
        str: ISO 8601 UTC timestamp with milliseconds (e.g., "2025-09-21T19:06:26.456Z")

    Use this for:
        - High-precision diagnostics
        - Performance measurement
        - Detailed audit trails

    Example:
        >>> timestamp = get_utc_timestamp_with_milliseconds()
        >>> print(timestamp)
        "2025-09-21T19:06:26.456Z"
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-4] + "Z"


def parse_github_timestamp(github_ts: str) -> datetime:
    """
    Parse GitHub API timestamp to timezone-aware datetime object.

    Args:
        github_ts: GitHub API timestamp (e.g., "2025-09-21T19:06:26Z")

    Returns:
        datetime: Timezone-aware datetime object in UTC

    Use this for:
        - Converting GitHub API timestamps for calculations
        - Duration measurements between local and GitHub events
        - Accurate time comparisons

    Example:
        >>> github_time = parse_github_timestamp("2025-09-21T19:06:26Z")
        >>> local_time = datetime.now(timezone.utc)
        >>> duration = local_time - github_time
        >>> print(f"Duration: {duration.total_seconds():.1f}s")
    """
    # Handle both "Z" and "+00:00" format endings
    if github_ts.endswith("Z"):
        github_ts = github_ts.replace("Z", "+00:00")

    return datetime.fromisoformat(github_ts)


def calculate_duration_from_github(
    github_start: str, github_end: Optional[str] = None
) -> float:
    """
    Calculate duration between GitHub API timestamps.

    Args:
        github_start: GitHub API start timestamp
        github_end: GitHub API end timestamp (defaults to current UTC time)

    Returns:
        float: Duration in seconds with decimal precision

    Use this for:
        - GitHub workflow duration calculations
        - CI performance metrics
        - Accurate timing diagnostics

    Example:
        >>> duration = calculate_duration_from_github(
        ...     "2025-09-21T19:03:26Z", "2025-09-21T19:06:26Z"
        ... )
        >>> print(f"Duration: {duration:.1f}s")
        "Duration: 180.0s"
    """
    start_time = parse_github_timestamp(github_start)

    if github_end:
        end_time = parse_github_timestamp(github_end)
    else:
        end_time = datetime.now(timezone.utc)

    duration = end_time - start_time
    return duration.total_seconds()


def validate_timestamp_format(timestamp: str) -> bool:
    """
    Validate if timestamp follows GitHub API compatible format.

    Args:
        timestamp: Timestamp string to validate

    Returns:
        bool: True if valid GitHub API format, False otherwise

    Use this for:
        - QC validation of timestamp format
        - Preventing timestamp synchronization issues
        - Input validation in automation scripts

    Example:
        >>> is_valid = validate_timestamp_format("2025-09-21T19:06:26Z")
        >>> print(is_valid)
        True
    """
    try:
        parse_github_timestamp(timestamp)
        return True
    except (ValueError, TypeError):
        return False


# EVIDENTIAL DOCUMENTATION
# ========================
#
# INFRASTRUCTURE CHANGE EVIDENCE:
# - Issue: Critical diagnostic accuracy problems across DevOnboarder automation
# - Root Cause: 20+ scripts claiming "UTC" but using local time via datetime.now()
# - Detection: Manual analysis showing 3-minute discrepancies between local and
#              GitHub timestamps
# - Impact: "Whack" diagnostic behavior affecting CI correlation, PR automation
#           timing, AAR accuracy
#
# AFFECTED SCRIPTS REQUIRING MIGRATION:
# - scripts/ci-monitor.py (line 238)
# - scripts/generate_aar.py (line 411)
# - scripts/file_version_tracker.py (line 412)
# - scripts/comprehensive_emoji_fix.py (line 100)
# - scripts/analyze_issue_triage.py (line 182)
# - scripts/update_devonboarder_dictionary.py (lines 50, 308, 355)
# - scripts/comment_on_issue.py (lines 82, 83, 180, 181)
# - scripts/enhanced_ci_failure_analyzer.py (line 230)
# - scripts/generate_aar_portal.py (lines 845, 847, 859, 861, 874)
# - scripts/validate_frontmatter_content.py (lines 292, 297)
# - scripts/ci_health_aar_integration.py (line 31)
# - And 8+ additional scripts identified in audit
#
# VALIDATION STRATEGY:
# - Extend scripts/qc_pre_push.sh to detect datetime.now() + "UTC" pattern
# - Add timestamp format validation to prevent future regressions
# - Update copilot-instructions.md to mandate UTC timestamp usage
#
# MIGRATION PLAN:
# 1. Replace datetime.now().strftime(...UTC...) with get_utc_display_timestamp()
# 2. Replace datetime.now().isoformat() with get_utc_timestamp() for API compatibility
# 3. Use parse_github_timestamp() for all GitHub API timestamp handling
# 4. Add validation to QC system to prevent future issues
