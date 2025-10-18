"""
Fallback timestamp utilities for standalone script execution.

This module provides fallback implementations for scripts that may run
outside the DevOnboarder virtual environment or before the main utils
module is available.

Usage Pattern:
    try:
        from src.utils.timestamps import get_utc_display_timestamp
    except ImportError:
        from src.utils.timestamp_fallback import get_utc_display_timestamp

This centralizes the fallback logic and reduces code duplication across
automation scripts while maintaining standalone execution capability.
"""

from datetime import datetime, timezone


def get_utc_display_timestamp()  str:
    """
    Fallback UTC timestamp function for standalone script execution.

    Returns:
        str: Human-readable UTC timestamp (e.g., "2025-09-21 19:06:26 UTC")

    Note:
        This is a fallback implementation. Scripts should prefer importing
        from src.utils.timestamps when the full DevOnboarder environment
        is available.
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")


def get_utc_timestamp()  str:
    """
    Fallback UTC timestamp in GitHub API compatible format.

    Returns:
        str: ISO 8601 UTC timestamp (e.g., "2025-09-21T19:06:26Z")

    Note:
        This is a fallback implementation. Scripts should prefer importing
        from src.utils.timestamps when the full DevOnboarder environment
        is available.
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def get_local_timestamp_for_filename()  str:
    """
    Get local timestamp suitable for filename generation.

    Returns:
        str: Local timestamp for filenames (e.g., "20250921_190626")

    Note:
        Uses local time intentionally for filename uniqueness on local machine.
        This is NOT for UTC synchronization - use get_utc_timestamp() for that.
    """
    return datetime.now().strftime("%Y%m%d_%H%M%S")
