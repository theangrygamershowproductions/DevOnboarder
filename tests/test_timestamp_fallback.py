#!/usr/bin/env python3
"""
Tests for src/utils/timestamp_fallback.py module.

This module provides fallback timestamp utilities for standalone script execution.
"""

from datetime import datetime, timezone
from unittest.mock import patch

from src.utils.timestamp_fallback import (
    get_utc_display_timestamp,
    get_utc_timestamp,
    get_local_timestamp_for_filename,
)


class TestTimestampFallback:
    """Test fallback timestamp functions."""

    def test_get_utc_display_timestamp_format(self):
        """Test get_utc_display_timestamp returns correct format."""
        result = get_utc_display_timestamp()

        # Should be in format: 2025-09-21 19:06:26 UTC
        assert len(result) == 23  # YYYY-MM-DD HH:MM:SS UTC
        assert result.endswith(" UTC")
        assert " " in result

    def test_get_utc_timestamp_format(self):
        """Test get_utc_timestamp returns correct ISO 8601 format."""
        result = get_utc_timestamp()

        # Should be in format: 2025-09-21T19:06:26Z
        assert len(result) == 20  # YYYY-MM-DDTHH:MM:SSZ
        assert result.endswith("Z")
        assert "T" in result

        # Should be parseable as ISO format
        parsed = datetime.fromisoformat(result.replace("Z", "+00:00"))
        assert parsed.tzinfo is not None

    def test_get_local_timestamp_for_filename_format(self):
        """Test local timestamp format for filenames."""
        result = get_local_timestamp_for_filename()

        # Should be in format: 20250921_190626
        assert len(result) == 15  # YYYYMMDD_HHMMSS
        assert "_" in result
        assert result.replace("_", "").isdigit()

    def test_functions_use_utc(self):
        """Test that UTC functions use UTC timezone."""
        # Mock datetime.now to return a specific time
        mock_time = datetime(2025, 9, 21, 19, 6, 26, 123456, tzinfo=timezone.utc)

        with patch("src.utils.timestamp_fallback.datetime") as mock_datetime:
            mock_datetime.now.return_value = mock_time

            # Test get_utc_timestamp
            ts = get_utc_timestamp()
            assert ts == "2025-09-21T19:06:26Z"

            # Test get_utc_display_timestamp
            display_ts = get_utc_display_timestamp()
            assert display_ts == "2025-09-21 19:06:26 UTC"

    def test_get_local_timestamp_for_filename_uses_local_time(self):
        """Test that filename timestamp uses local time (not UTC)."""
        mock_local_time = datetime(2025, 9, 21, 19, 6, 26)

        with patch("src.utils.timestamp_fallback.datetime") as mock_datetime:
            mock_datetime.now.return_value = mock_local_time

            result = get_local_timestamp_for_filename()
            assert result == "20250921_190626"

    def test_get_utc_timestamp_with_milliseconds_not_available(self):
        """Test that fallback doesn't include milliseconds (unlike main utils)."""
        result = get_utc_timestamp()

        # Fallback version doesn't include milliseconds
        assert "." not in result
        assert len(result) == 20  # No milliseconds

    def test_functions_are_callable(self):
        """Test that all functions are callable and return strings."""
        assert isinstance(get_utc_display_timestamp(), str)
        assert isinstance(get_utc_timestamp(), str)
        assert isinstance(get_local_timestamp_for_filename(), str)
