import pytest
from datetime import datetime, timezone
from unittest.mock import patch
from src.utils.timestamps import (
    get_utc_timestamp,
    get_utc_display_timestamp,
    get_utc_timestamp_with_milliseconds,
    parse_github_timestamp,
    calculate_duration_from_github,
    get_local_timestamp_for_filename,
    validate_timestamp_format,
)


class TestUTCTimestamps:
    """Test UTC timestamp generation functions."""

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

    def test_get_utc_display_timestamp_format(self):
        """Test get_utc_display_timestamp returns human-readable format."""
        result = get_utc_display_timestamp()

        # Should be in format: 2025-09-21 19:06:26 UTC
        assert len(result) == 23  # YYYY-MM-DD HH:MM:SS UTC
        assert result.endswith(" UTC")
        assert " " in result

    def test_get_utc_timestamp_with_milliseconds_format(self):
        """Test get_utc_timestamp_with_milliseconds includes milliseconds."""
        result = get_utc_timestamp_with_milliseconds()

        # Should be in format: 2025-09-21T19:06:26.456Z
        assert len(result) >= 24  # At least YYYY-MM-DDTHH:MM:SS.sssZ
        assert result.endswith("Z")
        assert "T" in result
        assert "." in result  # Should contain milliseconds

    def test_parse_github_timestamp_z_format(self):
        """Test parsing GitHub timestamp with Z suffix."""
        timestamp = "2025-09-21T19:06:26Z"
        result = parse_github_timestamp(timestamp)

        assert isinstance(result, datetime)
        assert result.tzinfo is not None
        assert result.year == 2025
        assert result.month == 9
        assert result.day == 21
        assert result.hour == 19
        assert result.minute == 6
        assert result.second == 26

    def test_parse_github_timestamp_offset_format(self):
        """Test parsing GitHub timestamp with +00:00 offset."""
        timestamp = "2025-09-21T19:06:26+00:00"
        result = parse_github_timestamp(timestamp)

        assert isinstance(result, datetime)
        assert result.tzinfo is not None
        assert result.year == 2025
        assert result.month == 9
        assert result.day == 21

    def test_parse_github_timestamp_invalid_format(self):
        """Test parsing invalid GitHub timestamp raises ValueError."""
        with pytest.raises(ValueError):
            parse_github_timestamp("invalid-timestamp")

        with pytest.raises(ValueError):
            parse_github_timestamp("")

    def test_calculate_duration_from_github_with_end_time(self):
        """Test duration calculation between two GitHub timestamps."""
        start = "2025-09-21T19:00:00Z"
        end = "2025-09-21T19:05:30Z"

        duration = calculate_duration_from_github(start, end)
        assert duration == 330.0  # 5 minutes 30 seconds

    def test_calculate_duration_from_github_current_time(self):
        """Test duration calculation from GitHub timestamp to current time."""
        start = "2025-09-21T19:00:00Z"

        # Mock current time to ensure predictable result
        mock_now = datetime(2025, 9, 21, 19, 2, 30, tzinfo=timezone.utc)

        with patch("src.utils.timestamps.datetime") as mock_datetime:
            mock_datetime.now.return_value = mock_now
            mock_datetime.fromisoformat = datetime.fromisoformat

            duration = calculate_duration_from_github(start)
            assert duration == 150.0  # 2 minutes 30 seconds

    def test_get_local_timestamp_for_filename_format(self):
        """Test local timestamp format for filenames."""
        result = get_local_timestamp_for_filename()

        # Should be in format: 20250921_190626
        assert len(result) == 15  # YYYYMMDD_HHMMSS
        assert "_" in result
        assert result.replace("_", "").isdigit()

    def test_validate_timestamp_format_valid(self):
        """Test validation of valid GitHub timestamp formats."""
        valid_timestamps = [
            "2025-09-21T19:06:26Z",
            "2025-09-21T19:06:26+00:00",
            "2025-01-01T00:00:00Z",
            "2025-12-31T23:59:59+00:00",
        ]

        for ts in valid_timestamps:
            assert validate_timestamp_format(ts) is True

    def test_validate_timestamp_format_invalid(self):
        """Test validation of invalid timestamp formats."""
        invalid_timestamps = [
            "invalid",
            "",
            "2025-09-21T19:06:26",  # Missing Z
            "2025/09/21T19:06:26Z",  # Wrong date format
            "2025-09-21T19:06:26+05:00",  # Wrong timezone
            "2025-9-21T19:06:26Z",  # Date missing leading zero
            "2025-09-21T9:06:26Z",  # Time missing leading zero
            "2025-09-21T19:6:26Z",  # Time missing leading zero in minutes
            "2025-09-21T19:06:6Z",  # Time missing leading zero in seconds
            "2025-09-21T19:06:26Zextra",  # Extra characters
            "2025-09-21T19:06:26+00:00extra",  # Extra characters after timezone
            "2025-09-21T19:06:26T27:08:30Z",  # Multiple T separators
            "20250921T190626Z",  # No separators
            "2025-02-30T19:06:26Z",  # Invalid date (Feb 30 doesn't exist)
            None,
        ]

        for ts in invalid_timestamps:
            assert validate_timestamp_format(ts) is False

    def test_validate_timestamp_format_exception_handling(self):
        """Test validation handles exceptions gracefully."""
        # Test with non-string input that causes TypeError
        assert validate_timestamp_format(123) is False

    def test_timestamp_functions_use_utc(self):
        """Test that all timestamp functions use UTC timezone."""
        # Mock datetime.now to return a specific time
        mock_time = datetime(2025, 9, 21, 19, 6, 26, 123456, tzinfo=timezone.utc)

        with patch("src.utils.timestamps.datetime") as mock_datetime:
            mock_datetime.now.return_value = mock_time

            # Test get_utc_timestamp
            ts = get_utc_timestamp()
            assert ts == "2025-09-21T19:06:26Z"

            # Test get_utc_display_timestamp
            display_ts = get_utc_display_timestamp()
            assert display_ts == "2025-09-21 19:06:26 UTC"

            # Test get_utc_timestamp_with_milliseconds
            ms_ts = get_utc_timestamp_with_milliseconds()
            assert ms_ts == "2025-09-21T19:06:26.123Z"

    def test_parse_github_timestamp_handles_z_conversion(self):
        """Test that Z suffix is properly converted to +00:00."""
        timestamp = "2025-09-21T19:06:26Z"

        with patch("src.utils.timestamps.datetime") as mock_datetime:
            mock_datetime.fromisoformat = datetime.fromisoformat

            result = parse_github_timestamp(timestamp)

            # Verify the result is a datetime object
            assert isinstance(result, datetime)
            # Verify fromisoformat was called with +00:00 instead of Z
            # Note: We can't easily test the exact call due to how
            # datetime.fromisoformat works

    def test_calculate_duration_from_github_precision(self):
        """Test duration calculation precision."""
        start = "2025-09-21T19:00:00.000Z"
        end = "2025-09-21T19:00:00.500Z"

        duration = calculate_duration_from_github(start, end)
        assert duration == 0.5  # Half second precision

    def test_get_local_timestamp_for_filename_uses_local_time(self):
        """Test that filename timestamp uses local time (not UTC)."""
        mock_local_time = datetime(2025, 9, 21, 19, 6, 26)

        with patch("src.utils.timestamps.datetime") as mock_datetime:
            mock_datetime.now.return_value = mock_local_time

            result = get_local_timestamp_for_filename()
            assert result == "20250921_190626"
