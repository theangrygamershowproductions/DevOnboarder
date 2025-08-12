"""
Test for routes/user.py to cover the last 2 missing lines.
"""

from unittest.mock import Mock

from routes.user import user_info


def test_user_info_endpoint():
    """Test the user info endpoint - covers lines 15-16."""
    mock_user = Mock()
    mock_user.discord_id = "123456789"
    mock_user.discord_username = "testuser"
    mock_user.avatar = "avatar_hash"
    mock_user.isAdmin = True  # Line 15
    mock_user.isVerified = True  # Line 16
    mock_user.verificationType = "discord"
    mock_user.roles = {"admin": True}

    result = user_info(current_user=mock_user)

    expected_keys = [
        "id",
        "username",
        "avatar",
        "isAdmin",
        "isVerified",
        "verificationType",
        "roles",
    ]
    for key in expected_keys:
        if key not in result:
            raise AssertionError(f"Missing key: {key}")

    if result["isAdmin"] is not True:
        raise AssertionError("isAdmin should be True")
    if result["isVerified"] is not True:
        raise AssertionError("isVerified should be True")
